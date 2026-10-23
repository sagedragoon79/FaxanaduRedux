#!/usr/bin/env python3
"""Generates the zone tilesets and parallax backgrounds (design bible 13.3).

Every color comes from the master palette (tools/art/palette.py). Each zone is a
material spec: a texture painter for the ground, edge rules for exposed sides
(a cap on top, a lip underneath, outlines on the sides), and background layers.

Tileset atlas (16 world px tiles at 2x render density, so 32 px each; 8 columns):
  rows 0-5: the 47 "blob" autotiles, in the order of blob_masks() below
            (scripts/world/tileset_factory.gd computes the same list)
  row 6:    one-way platform, amber, 2 interior tiles one shade darker (two
            tiles from open air) and 2 two shades darker (three or more)
Backgrounds: <zone>_far.png and <zone>_mid.png, 640x480, tile horizontally.

Usage: python3 tools/art/tilegen.py
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import palette  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
TILES = ROOT / "assets" / "tiles"
BG = ROOT / "assets" / "bg"
## Render density (design bible 12.1): tiles are 16 world pixels drawn with
## two pixels per world pixel, so the atlas holds 32 px tiles.
D = 2
T = 16 * D
COLS = 8
## Backgrounds are 640x480 world pixels, painted at the same density.
BG_W, BG_H = 640 * D, 480 * D

PAL = {}
for _name, _hue, _sat in palette.RAMPS:
    for _i in range(8):
        PAL[f"{_name}-{_i}"] = palette.shade(_hue, _sat, _i) + (255,)
CLEAR = (0, 0, 0, 0)


def c(name, alpha=255):
    r, g, b, _ = PAL[name]
    return (r, g, b, alpha)


# --- Blob autotile masks -------------------------------------------------------------
N, NE, E, SE, S, SW, W, NW = 1, 2, 4, 8, 16, 32, 64, 128


def reduce_mask(m):
    """Corners only count when both sides next to them are solid."""
    if not (m & N and m & E):
        m &= ~NE
    if not (m & S and m & E):
        m &= ~SE
    if not (m & S and m & W):
        m &= ~SW
    if not (m & N and m & W):
        m &= ~NW
    return m


def blob_masks():
    return sorted({reduce_mask(m) for m in range(256)})


# --- Materials ---------------------------------------------------------------------------
def hash2(x, y, seed):
    h = (x * 374761393 + y * 668265263 + seed * 2147483647) & 0xFFFFFFFF
    h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF
    return (h & 0xFFFF) / 0xFFFF


def paint_bricks(img, ox, oy, seed, ramp):
    """Masonry: rows of 8x4 world-pixel bricks offset per row, lit from the top
    left, with a one-render-pixel mortar line and a grain of tiny pits."""
    bw, bh = 8 * D, 4 * D
    for y in range(T):
        for x in range(T):
            row = y // bh
            sx = x + (row % 2) * (bw // 2)
            bx = sx // bw
            by = row
            lx, ly = sx % bw, y % bh
            shade = 3 if hash2(bx, by, seed) > 0.45 else 2
            if hash2(bx, by, seed + 9) > 0.92:
                shade = 4
            if ly == bh - 1 or lx == 0:
                col = f"{ramp}-1"
            elif ly == 0 or lx == 1:
                col = f"{ramp}-{shade + 1}"
            elif ly == bh - 2 or lx == bw - 1:
                col = f"{ramp}-{shade - 1}"
            else:
                col = f"{ramp}-{shade}"
                if hash2(x, y, seed + 3) > 0.93:
                    col = f"{ramp}-{shade - 1}"
                elif hash2(x, y, seed + 4) > 0.97:
                    col = f"{ramp}-{shade + 1}"
            img.putpixel((ox + x, oy + y), c(col))


def paint_wood(img, ox, oy, seed, ramp):
    """Living wood: long vertical grain in fine strands, low contrast, the odd knot."""
    for x in range(T):
        base = 1 if hash2(x // 3, 0, seed) > 0.4 else 2
        phase = hash2(x, 1, seed) * 32
        for y in range(T):
            n = math.sin((y + phase) * 0.2)
            col = base
            if n > 0.9 and base == 2 and x % 3 == 1:
                col = 3
            elif n < -0.85:
                col = base - 1
            if x % 12 == 0:
                col = min(col, 1)
            elif x % 12 == 1 and hash2(x, y // 4, seed) > 0.5:
                col = min(col + 1, 3)
            img.putpixel((ox + x, oy + y), c(f"{ramp}-{max(col, 0)}"))
    if hash2(seed, 7, 3) > 0.82:
        # A knot: a dark eye in a lighter ring of grain.
        kx, ky = 8 + int(hash2(seed, 1, 5) * 14), 8 + int(hash2(seed, 2, 5) * 14)
        for dy in range(-3, 4):
            for dx in range(-2, 3):
                r = (dx / 2.5) ** 2 + (dy / 3.5) ** 2
                if r <= 1.0:
                    col = f"{ramp}-0" if r < 0.35 else (f"{ramp}-3" if dx < 0 or dy < 0 else f"{ramp}-1")
                    img.putpixel((ox + kx + dx, oy + ky + dy), c(col))


def cap_moss(img, ox, oy, seed, x0, x1, light="leaf", glow=None, top=5):
    """A ragged cap of moss over the top edge: blades of uneven height, a lit
    fringe, and a dark under-edge where it meets the ground."""
    for x in range(x0, x1):
        depth = 6 + (2 if hash2(x // 2, 0, seed) > 0.55 else 0) + (1 if hash2(x, 5, seed) > 0.85 else 0)
        blade = 1 if hash2(x, 6, seed) > 0.7 else 0
        for y in range(depth):
            if y == 0 and blade == 0 and hash2(x, 7, seed) > 0.6:
                continue  # a ragged top
            if y <= 1:
                col = f"{light}-{top}"
            elif y < depth - 2:
                col = f"{light}-{top - 1}" if (x + y) % 5 else f"{light}-{top}"
            elif y < depth - 1:
                col = f"{light}-{top - 2}"
            else:
                col = f"{light}-{top - 3}"
            img.putpixel((ox + x, oy + y), c(col))
        if glow and hash2(x // 2, 3, seed) > 0.88:
            img.putpixel((ox + x, oy + depth), c(glow))
            if x % 2 == 0:
                img.putpixel((ox + x, oy + depth + 1), c(glow, 160))


def cap_stone(img, ox, oy, seed, x0, x1, ramp="stone"):
    """A dressed stone lip: bright rim, a mid band, then a shadow line, a few moss tufts."""
    for x in range(x0, x1):
        for y, col in enumerate([f"{ramp}-6", f"{ramp}-6", f"{ramp}-5", f"{ramp}-4", f"{ramp}-2", f"{ramp}-1"]):
            img.putpixel((ox + x, oy + y), c(col))
        if hash2(x // 3, 9, seed) > 0.8:
            img.putpixel((ox + x, oy), c("leaf-5" if x % 2 else "leaf-4"))
            img.putpixel((ox + x, oy + 1), c("leaf-4"))
            img.putpixel((ox + x, oy + 2), c("leaf-3"))


ZONES = {
    "gym": {"painter": paint_bricks, "ramp": "stone", "cap": "moss", "light": "leaf", "glow": None,
            "under": "stone-1", "outline": "night-0"},
    "eolis": {"painter": paint_bricks, "ramp": "stone", "cap": "stone", "light": "leaf", "glow": None,
              "under": "stone-1", "outline": "night-0"},
    "trunk": {"painter": paint_wood, "ramp": "bark", "cap": "moss", "light": "leaf", "glow": "sky-6", "cap_top": 4,
              "under": "bark-1", "outline": "night-0"},
}


def paint_tile(img, ox, oy, mask, zone, seed):
    z = ZONES[zone]
    z["painter"](img, ox, oy, seed, z["ramp"])
    ramp = z["ramp"]
    out = c(z["outline"])
    # Sides: a dark outline one world pixel thick, then a soft shade.
    if not mask & W:
        for y in range(T):
            for k in range(D):
                img.putpixel((ox + k, oy + y), out)
            img.putpixel((ox + D, oy + y), c(f"{ramp}-1"))
            if hash2(0, y // 3, seed) > 0.5:
                img.putpixel((ox + D + 1, oy + y), c(f"{ramp}-1"))
    if not mask & E:
        for y in range(T):
            for k in range(D):
                img.putpixel((ox + T - 1 - k, oy + y), out)
            img.putpixel((ox + T - 1 - D, oy + y), c(f"{ramp}-1"))
            if hash2(1, y // 3, seed) > 0.5:
                img.putpixel((ox + T - 2 - D, oy + y), c(f"{ramp}-1"))
    # Underside: outline, a dark lip, and the odd hanging root tip.
    if not mask & S:
        for x in range(T):
            for k in range(D):
                img.putpixel((ox + x, oy + T - 1 - k), out)
            img.putpixel((ox + x, oy + T - 1 - D), c(z["under"]))
            img.putpixel((ox + x, oy + T - 2 - D), c(z["under"]))
        for x in range(2, T - 2):
            if hash2(x, 11, seed) > 0.93:
                img.putpixel((ox + x, oy + T - 1), c(z["under"]))
    # Top: the zone's cap.
    if not mask & N:
        x0 = 0 if mask & W else D
        x1 = T if mask & E else T - D
        if z["cap"] == "moss":
            cap_moss(img, ox, oy, seed, x0, x1, z["light"], z["glow"], z.get("cap_top", 5))
        else:
            cap_stone(img, ox, oy, seed, x0, x1, ramp)
    # Inner corners: a dark notch where two solid sides meet an open diagonal.
    for bit, a, b, px, py in [(NE, N, E, T - D, 0), (SE, S, E, T - D, T - D), (SW, S, W, 0, T - D), (NW, N, W, 0, 0)]:
        if mask & a and mask & b and not mask & bit:
            for dy in range(D):
                for dx in range(D):
                    img.putpixel((ox + px + dx, oy + py + dy), out)
            nx = px - 1 if px else px + D
            ny = py - 1 if py else py + D
            for k in range(D):
                img.putpixel((ox + nx, oy + py + k), c(f"{ramp}-1"))
                img.putpixel((ox + px + k, oy + ny), c(f"{ramp}-1"))
    # Outer corners: round them off (a 2x2 notch and its diagonal neighbours).
    for a, b, px, py, sx, sy in [(N, W, 0, 0, 1, 1), (N, E, T - 1, 0, -1, 1), (S, W, 0, T - 1, 1, -1), (S, E, T - 1, T - 1, -1, -1)]:
        if not mask & a and not mask & b:
            for dx, dy in [(0, 0), (1, 0), (0, 1), (1, 1), (2, 0), (0, 2)]:
                img.putpixel((ox + px + sx * dx, oy + py + sy * dy), CLEAR)
            img.putpixel((ox + px + sx * 2, oy + py + sy * 1), out)
            img.putpixel((ox + px + sx * 1, oy + py + sy * 2), out)
            img.putpixel((ox + px + sx * 3, oy + py), out)
            img.putpixel((ox + px, oy + py + sy * 3), out)


def darken(img, ox, oy, steps):
    """Shifts every pixel of a tile `steps` shades down its palette ramp."""
    names = {v[:3]: k for k, v in PAL.items()}
    for y in range(T):
        for x in range(T):
            px = img.getpixel((ox + x, oy + y))
            name = names.get(px[:3])
            if name is None or px[3] == 0:
                continue
            ramp, i = name.rsplit("-", 1)
            j = int(i) - steps
            img.putpixel((ox + x, oy + y), c("night-0") if j < 0 else c(f"{ramp}-{j}"))


def paint_one_way(img, ox, oy, zone):
    """A plank on brackets: 6 world pixels thick with grain and nail heads."""
    wood = "bark"
    for x in range(T):
        for y in range(6 * D):
            if y < 2:
                col = f"{wood}-5"
            elif y < 3:
                col = f"{wood}-4"
            elif y < 8:
                col = f"{wood}-3" if (x + y * 3) % 11 else f"{wood}-2"
            elif y < 10:
                col = f"{wood}-2"
            else:
                col = "night-0"
            if x % (8 * D) == 0 and 2 <= y <= 9:
                col = f"{wood}-1"
            if x % (8 * D) in (3, 12) and y == 4:
                col = "stone-5"
            img.putpixel((ox + x, oy + y), c(col))
        # Brackets under the plank.
        if x % (8 * D) in (6, 7, 8, 9):
            for y in range(6 * D, 10 * D):
                edge = x % (8 * D) in (6, 9)
                img.putpixel((ox + x, oy + y), c("night-0" if y >= 10 * D - 2 or edge else f"{wood}-2"))


def paint_amber(img, ox, oy):
    for y in range(T):
        for x in range(T):
            col = "gold-3"
            if y < 2:
                col = "gold-5"
            elif y < 4:
                col = "gold-4"
            elif hash2(x, y, 41) > 0.95:
                col = "gold-2"
            elif (x + y * 2) % 23 == 0:
                col = "gold-4"
            img.putpixel((ox + x, oy + y), c(col))
    # Bubbles trapped in the amber, each with a highlight.
    for bx, by in [(8, 10), (22, 18), (14, 25)]:
        for dx, dy in [(0, 0), (1, 0), (0, 1), (1, 1)]:
            img.putpixel((ox + bx + dx, oy + by + dy), c("gold-5"))
        img.putpixel((ox + bx, oy + by), c("gold-7"))


def build_tileset(zone):
    masks = blob_masks()
    assert len(masks) == 47
    img = Image.new("RGBA", (T * COLS, T * 7), CLEAR)
    for i, m in enumerate(masks):
        paint_tile(img, (i % COLS) * T, (i // COLS) * T, m, zone, 11 + i)
    paint_one_way(img, 0, 6 * T, zone)
    paint_amber(img, T, 6 * T)
    # Wall interiors away from open air: one shade darker two tiles in, two
    # shades from three tiles in, so rooms read as space rather than texture.
    for k in range(4):
        paint_tile(img, (2 + k) * T, 6 * T, 255, zone, 101 + k)
        darken(img, (2 + k) * T, 6 * T, 1 if k < 2 else 2)
    TILES.mkdir(parents=True, exist_ok=True)
    img.save(TILES / f"{zone}.png")


# --- Backgrounds ---------------------------------------------------------------------
def wrap_noise(x, y, seed, period):
    """Smooth value noise that tiles horizontally with `period`."""
    def v(ix, iy):
        return hash2(ix % period, iy, seed)
    x0, y0 = math.floor(x), math.floor(y)
    fx, fy = x - x0, y - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a = v(x0, y0) + (v(x0 + 1, y0) - v(x0, y0)) * fx
    b = v(x0, y0 + 1) + (v(x0 + 1, y0 + 1) - v(x0, y0 + 1)) * fx
    return a + (b - a) * fy


def gradient(img, top, bottom, dither=True):
    for y in range(BG_H):
        k = y / (BG_H - 1)
        for x in range(BG_W):
            # Ordered dither between the two colors instead of blending.
            threshold = ((x % 4) * 4 + (y % 4) * 7 % 16) / 16.0 if dither else 0.5
            img.putpixel((x, y), c(bottom if k > threshold * 0.6 + 0.2 else top))


def put(img, x, y, col):
    """Sets a pixel, wrapping sideways (the layers repeat) and clipping vertically."""
    if 0 <= y < BG_H:
        img.putpixel((int(x) % BG_W, int(y)), col)


def glow_dot(img, x, y, core, rim, r=1):
    """A small light: a bright core with a dimmer rim (atlas pixels)."""
    for dy in range(-r - 1, r + 2):
        for dx in range(-r - 1, r + 2):
            d = abs(dx) + abs(dy)
            if d <= r:
                put(img, x + dx, y + dy, c(core))
            elif d == r + 1:
                put(img, x + dx, y + dy, c(rim))


def trunk_far():
    img = Image.new("RGBA", (BG_W, BG_H), c("night-0"))
    gradient(img, "night-0", "bark-0")
    rng = random.Random(5)
    # Great fibres of the trunk's heartwood, far away, with a streaked grain.
    for i in range(14):
        x0 = rng.randrange(BG_W)
        w = rng.randrange(10, 26) * D
        col = "bark-1" if i % 3 else "night-1"
        for y in range(BG_H):
            sway = int(math.sin(y * 0.01 + i) * 6 * D)
            for dx in range(w):
                if hash2(dx // 2, y // 9, i) > 0.08:
                    put(img, x0 + sway + dx, y, c(col))
            # Grain lines down the fibre.
            for g in range(3, w - 2, 7):
                if hash2(g, y // 40, i + 50) > 0.45:
                    put(img, x0 + sway + g, y, c("night-0" if col == "bark-1" else "bark-0"))
    # Faint glowing spores, a few of them larger and haloed.
    for k in range(240):
        x, y = rng.randrange(BG_W), rng.randrange(BG_H)
        col = rng.choice(["sky-4", "gold-3", "sky-3"])
        if k % 12 == 0:
            glow_dot(img, x, y, col, "sky-1", 0)
        else:
            put(img, x, y, c(col))
    return img


def trunk_mid():
    img = Image.new("RGBA", (BG_W, BG_H), CLEAR)
    rng = random.Random(9)
    # Hanging roots from the top, rooted columns from the bottom.
    for i in range(18):
        x0 = rng.randrange(BG_W)
        length = rng.randrange(60, 260) * D
        w = rng.choice([2, 3, 3, 4]) * D
        tip_x = x0
        for y in range(length):
            sway = int(math.sin(y * 0.025 + i * 1.7) * 5 * D)
            taper = max(1, int(w * (1 - y / length) + 0.5))
            for dx in range(taper):
                col = "bark-2" if dx == 0 else ("night-1" if dx == taper - 1 and taper > 2 else "bark-1")
                put(img, x0 + sway + dx, y, c(col))
            tip_x = x0 + sway
            # Thin rootlets curling off the main root.
            if y > 20 and hash2(i, y, 7) > 0.985:
                d = 1 if hash2(i, y, 8) > 0.5 else -1
                for k in range(rng.randrange(10, 26)):
                    put(img, x0 + sway + (taper if d > 0 else -1) + d * k, y + k * k // 14, c("bark-1"))
        # A glowing fungus cap at some root tips.
        if i % 3 == 0:
            for dy in range(4):
                half = 5 - dy
                for dx in range(-half, half + 1):
                    put(img, tip_x + dx, length + 3 - dy, c("sky-5" if dy else "sky-4"))
            put(img, tip_x - 2, length + 1, c("sky-7"))
            put(img, tip_x - 1, length + 1, c("sky-6"))
            for dx in range(-5, 6, 2):
                put(img, tip_x + dx, length + 4, c("sky-2"))
    for i in range(7):
        x0 = rng.randrange(BG_W)
        w = rng.randrange(18, 40) * D
        h = rng.randrange(80, 200) * D
        for y in range(BG_H - h, BG_H):
            k = (y - (BG_H - h)) / h
            ww = int(w * (0.5 + 0.5 * k))
            for dx in range(-ww // 2, ww // 2):
                edge = ww // 2 - abs(dx)
                col = "night-1" if edge <= 4 else "bark-1"
                # Bark ridges running up the column.
                if edge > 4 and (dx + ww) % 9 == 0 and hash2(dx, y // 14, i) > 0.3:
                    col = "night-1"
                if edge == 5 and dx < 0:
                    col = "bark-2"
                put(img, x0 + dx, y, c(col))
    return img


def eolis_far():
    img = Image.new("RGBA", (BG_W, BG_H), c("night-0"))
    gradient(img, "night-0", "night-1")
    rng = random.Random(3)
    # Distant houses carved into the roots, with lit windows.
    x = 0
    while x < BG_W:
        w = rng.randrange(40, 80) * D
        h = rng.randrange(80, 200) * D
        top = BG_H - 120 * D - h
        for yy in range(top, BG_H):
            for xx in range(x, min(x + w, BG_W)):
                col = "stone-1" if (xx - x) < 2 * D else "night-1"
                # Faint courses of stone.
                if (yy - top) % 22 == 0 and (xx - x) > 2 * D and hash2(xx // 12, yy, 3) > 0.4:
                    col = "night-0"
                img.putpixel((xx, yy), c(col))
        # Arched roof with a stone rim.
        for xx in range(x, min(x + w, BG_W)):
            k = (xx - x) / max(w - 1, 1)
            rise = int(math.sin(k * math.pi) * 12 * D)
            for yy in range(top - rise, top):
                img.putpixel((xx, yy), c("stone-1" if yy - (top - rise) < 2 else "night-1"))
        for wy in range(top + 14 * D, BG_H - 140 * D, 26 * D):
            for wx in range(x + 8 * D, x + w - 12 * D, 18 * D):
                if rng.random() < 0.22:
                    ww, wh = 6 * D, 9 * D
                    for yy in range(wy, wy + wh):
                        for xx in range(wx, wx + ww):
                            if xx >= BG_W:
                                continue
                            col = "gold-4" if yy < wy + 3 else "gold-3"
                            # A cross of mullions and a dark sill.
                            if xx == wx + ww // 2 or yy == wy + wh // 2:
                                col = "bark-1"
                            if yy == wy + wh - 1:
                                col = "stone-1"
                            img.putpixel((xx, yy), c(col))
                    # Rounded window top.
                    for xx in range(wx + 2, wx + ww - 2):
                        put(img, xx, wy - 1, c("gold-3"))
        x += w + rng.randrange(6, 24) * D
    return img


def eolis_mid():
    img = Image.new("RGBA", (BG_W, BG_H), CLEAR)
    rng = random.Random(4)
    # Great roots arching overhead, and hanging lanterns.
    for i in range(4):
        cx = (i * 160 + rng.randrange(-20, 20)) * D
        for x in range(cx - 120 * D, cx + 120 * D):
            k = (x - (cx - 120 * D)) / (240 * D)
            y0 = int((30 + math.sin(k * math.pi) * -20 + 40) * D)
            for y in range(0, y0):
                col = "night-1"
                if y > 6 and hash2(x // 3, y // 10, i) > 0.93:
                    col = "bark-0"
                put(img, x, y, c(col))
            for y in range(y0, y0 + 3 * D):
                put(img, x, y, c("bark-2" if y == y0 else "bark-1"))
            put(img, x, y0 + 3 * D, c("night-1"))
    for i in range(6):
        x = rng.randrange(BG_W)
        length = rng.randrange(60, 130) * D
        for y in range(40 * D, length):
            put(img, x, y, c("stone-2"))
            put(img, x + 1, y, c("stone-1" if (y // 3) % 2 else "stone-2"))
        # Lantern: a cap, glass panes with a frame, a base.
        for dx in range(-5, 7):
            put(img, x + dx, length, c("stone-2"))
            put(img, x + dx, length + 1, c("stone-3"))
        for dy in range(2, 14):
            for dx in range(-6, 8):
                frame = dx in (-6, 7, 1) or dy in (2, 13)
                col = "stone-2" if frame else ("gold-6" if abs(dx - 0.5) < 3 and 5 < dy < 11 else "gold-5")
                put(img, x + dx, length + dy, c(col))
        for dx in range(-4, 6):
            put(img, x + dx, length + 14, c("stone-2"))
        put(img, x, length + 15, c("stone-2"))
        put(img, x + 1, length + 15, c("stone-2"))
        # A faint ring of lamplight around the lantern.
        for r, alpha in ((18, 120), (24, 70)):
            for k in range(96):
                ang = k / 96 * math.tau
                px = x + int(math.cos(ang) * r)
                py = length + 8 + int(math.sin(ang) * r)
                if k % 2 == 0 and 0 <= py < BG_H and img.getpixel((px % BG_W, py))[3] == 0:
                    put(img, px, py, c("gold-3", alpha))
    return img


def gym_far():
    img = Image.new("RGBA", (BG_W, BG_H), c("night-0"))
    gradient(img, "night-0", "night-1")
    return img


BACKGROUNDS = {
    "trunk": (trunk_far, trunk_mid),
    "eolis": (eolis_far, eolis_mid),
    "gym": (gym_far, None),
}


def main():
    for zone in ZONES:
        build_tileset(zone)
    BG.mkdir(parents=True, exist_ok=True)
    for zone, (far, mid) in BACKGROUNDS.items():
        far().save(BG / f"{zone}_far.png")
        if mid:
            mid().save(BG / f"{zone}_mid.png")


if __name__ == "__main__":
    main()
