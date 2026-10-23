#!/usr/bin/env python3
"""Generates the zone tilesets and parallax backgrounds (design bible 13.3).

Every color comes from the master palette (tools/art/palette.py). Each zone is a
material spec: a texture painter for the ground, edge rules for exposed sides
(a cap on top, a lip underneath, outlines on the sides), and background layers.

Tileset atlas (16 px tiles, 8 columns):
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
T = 16
COLS = 8
BG_W, BG_H = 640, 480

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
    """Masonry: rows of 8x4 bricks offset per row, lit from the top left."""
    for y in range(T):
        for x in range(T):
            row = y // 4
            bx = (x + (row % 2) * 4) // 8
            by = row
            mortar = y % 4 == 3 or (x + (row % 2) * 4) % 8 == 0
            shade = 3 if hash2(bx, by, seed) > 0.45 else 2
            if hash2(bx, by, seed + 9) > 0.92:
                shade = 4
            if mortar:
                col = f"{ramp}-1"
            elif y % 4 == 0 or (x + (row % 2) * 4) % 8 == 1:
                col = f"{ramp}-{shade + 1}"
            else:
                col = f"{ramp}-{shade}"
                if hash2(x, y, seed + 3) > 0.9:
                    col = f"{ramp}-{shade - 1}"
            img.putpixel((ox + x, oy + y), c(col))


def paint_wood(img, ox, oy, seed, ramp):
    """Living wood: long vertical grain, low contrast, the odd knot."""
    for x in range(T):
        base = 1 if hash2(x // 2, 0, seed) > 0.4 else 2
        phase = hash2(x, 1, seed) * 16
        for y in range(T):
            n = math.sin((y + phase) * 0.39)
            col = base
            if n > 0.93 and base == 2 and x % 3 == 1:
                col = 3
            elif n < -0.85:
                col = base - 1
            if x % 6 == 0:
                col = min(col, 1)
            img.putpixel((ox + x, oy + y), c(f"{ramp}-{max(col, 0)}"))
    if hash2(seed, 7, 3) > 0.6:
        kx, ky = 4 + int(hash2(seed, 1, 5) * 8), 4 + int(hash2(seed, 2, 5) * 8)
        for dx, dy in [(0, 0), (1, 0), (0, 1), (1, 1)]:
            img.putpixel((ox + kx + dx, oy + ky + dy), c(f"{ramp}-0"))
        img.putpixel((ox + kx - 1, oy + ky), c(f"{ramp}-3"))


def cap_moss(img, ox, oy, seed, x0, x1, light="leaf", glow=None, top=5):
    """A ragged cap of moss over the top edge, with a lit fringe."""
    for x in range(x0, x1):
        depth = 3 + (1 if hash2(x, 0, seed) > 0.55 else 0) + (1 if hash2(x, 5, seed) > 0.9 else 0)
        for y in range(depth):
            col = f"{light}-{top}" if y == 0 else (f"{light}-{top - 1}" if y < depth - 1 else f"{light}-{top - 3}")
            img.putpixel((ox + x, oy + y), c(col))
        if glow and hash2(x, 3, seed) > 0.88:
            img.putpixel((ox + x, oy + depth), c(glow))


def cap_stone(img, ox, oy, seed, x0, x1, ramp="stone"):
    """A dressed stone lip: bright rim, then a shadow line, a few moss tufts."""
    for x in range(x0, x1):
        img.putpixel((ox + x, oy), c(f"{ramp}-6"))
        img.putpixel((ox + x, oy + 1), c(f"{ramp}-5"))
        img.putpixel((ox + x, oy + 2), c(f"{ramp}-2"))
        if hash2(x, 9, seed) > 0.8:
            img.putpixel((ox + x, oy), c("leaf-4"))
            img.putpixel((ox + x, oy + 1), c("leaf-3"))


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
    # Sides: a dark outline and a soft shade a pixel in.
    if not mask & W:
        for y in range(T):
            img.putpixel((ox, oy + y), out)
            img.putpixel((ox + 1, oy + y), c(f"{ramp}-1"))
    if not mask & E:
        for y in range(T):
            img.putpixel((ox + T - 1, oy + y), out)
            img.putpixel((ox + T - 2, oy + y), c(f"{ramp}-1"))
    # Underside: outline, a dark lip, the odd hanging root or drip.
    if not mask & S:
        for x in range(T):
            img.putpixel((ox + x, oy + T - 1), out)
            img.putpixel((ox + x, oy + T - 2), c(z["under"]))
    # Top: the zone's cap.
    if not mask & N:
        x0 = 0 if mask & W else 1
        x1 = T if mask & E else T - 1
        if z["cap"] == "moss":
            cap_moss(img, ox, oy, seed, x0, x1, z["light"], z["glow"], z.get("cap_top", 5))
        else:
            cap_stone(img, ox, oy, seed, x0, x1, ramp)
    # Inner corners: a dark notch where two solid sides meet an open diagonal.
    for bit, a, b, px, py in [(NE, N, E, T - 1, 0), (SE, S, E, T - 1, T - 1), (SW, S, W, 0, T - 1), (NW, N, W, 0, 0)]:
        if mask & a and mask & b and not mask & bit:
            img.putpixel((ox + px, oy + py), out)
            nx = px - 1 if px else px + 1
            ny = py - 1 if py else py + 1
            img.putpixel((ox + nx, oy + py), c(f"{ramp}-1"))
            img.putpixel((ox + px, oy + ny), c(f"{ramp}-1"))
    # Outer corners: round them off.
    for a, b, px, py in [(N, W, 0, 0), (N, E, T - 1, 0), (S, W, 0, T - 1), (S, E, T - 1, T - 1)]:
        if not mask & a and not mask & b:
            img.putpixel((ox + px, oy + py), CLEAR)


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
    wood = "bark"
    for x in range(T):
        for y in range(6):
            col = f"{wood}-4" if y == 1 else (f"{wood}-5" if y == 0 else f"{wood}-3")
            if y == 4:
                col = f"{wood}-2"
            if y == 5:
                col = "night-0"
            if x % 8 == 0 and 1 <= y <= 4:
                col = f"{wood}-1"
            img.putpixel((ox + x, oy + y), c(col))
        # Brackets under the plank.
        if x % 8 in (3, 4):
            for y in range(6, 10):
                img.putpixel((ox + x, oy + y), c(f"{wood}-2" if y < 9 else "night-0"))


def paint_amber(img, ox, oy):
    for y in range(T):
        for x in range(T):
            col = "gold-3"
            if y == 0:
                col = "gold-5"
            elif y == 1:
                col = "gold-4"
            elif hash2(x, y, 41) > 0.93:
                col = "gold-2"
            elif (x + y * 2) % 13 == 0:
                col = "gold-4"
            img.putpixel((ox + x, oy + y), c(col))
    for bx, by in [(4, 5), (11, 9), (7, 12)]:
        img.putpixel((ox + bx, oy + by), c("gold-6"))


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


def trunk_far():
    img = Image.new("RGBA", (BG_W, BG_H), c("night-0"))
    gradient(img, "night-0", "bark-0")
    rng = random.Random(5)
    # Great fibres of the trunk's heartwood, far away.
    for i in range(14):
        x0 = rng.randrange(BG_W)
        w = rng.randrange(10, 26)
        col = "bark-1" if i % 3 else "night-1"
        for y in range(BG_H):
            sway = int(math.sin(y * 0.02 + i) * 6)
            for dx in range(w):
                if hash2(dx, y // 6, i) > 0.08:
                    img.putpixel(((x0 + sway + dx) % BG_W, y), c(col))
    # Faint glowing spores.
    for _ in range(90):
        x, y = rng.randrange(BG_W), rng.randrange(BG_H)
        img.putpixel((x, y), c(rng.choice(["sky-4", "gold-3", "sky-3"])))
    return img


def trunk_mid():
    img = Image.new("RGBA", (BG_W, BG_H), CLEAR)
    rng = random.Random(9)
    # Hanging roots from the top, rooted columns from the bottom.
    for i in range(18):
        x0 = rng.randrange(BG_W)
        length = rng.randrange(60, 260)
        w = rng.choice([2, 3, 3, 4])
        for y in range(length):
            sway = int(math.sin(y * 0.05 + i * 1.7) * 5)
            taper = max(1, int(w * (1 - y / length) + 0.5))
            for dx in range(taper):
                img.putpixel(((x0 + sway + dx) % BG_W, y), c("bark-1" if dx else "bark-2"))
        # A glowing fungus cap at some root tips.
        if i % 3 == 0:
            tx = (x0 + int(math.sin(length * 0.05 + i * 1.7) * 5)) % BG_W
            for dx in range(-2, 3):
                img.putpixel(((tx + dx) % BG_W, length), c("sky-5"))
            img.putpixel((tx % BG_W, length + 1), c("sky-6"))
    for i in range(7):
        x0 = rng.randrange(BG_W)
        w = rng.randrange(18, 40)
        h = rng.randrange(80, 200)
        for y in range(BG_H - h, BG_H):
            k = (y - (BG_H - h)) / h
            ww = int(w * (0.5 + 0.5 * k))
            for dx in range(-ww // 2, ww // 2):
                col = "bark-1" if abs(dx) < ww // 2 - 2 else "night-1"
                img.putpixel(((x0 + dx) % BG_W, y), c(col))
    return img


def eolis_far():
    img = Image.new("RGBA", (BG_W, BG_H), c("night-0"))
    gradient(img, "night-0", "night-1")
    rng = random.Random(3)
    # Distant houses carved into the roots, with lit windows.
    x = 0
    while x < BG_W:
        w = rng.randrange(40, 80)
        h = rng.randrange(80, 200)
        top = BG_H - 120 - h
        for yy in range(top, BG_H):
            for xx in range(x, min(x + w, BG_W)):
                img.putpixel((xx, yy), c("night-1" if (xx - x) > 2 else "stone-1"))
        # Arched roof.
        for xx in range(x, min(x + w, BG_W)):
            k = (xx - x) / max(w - 1, 1)
            rise = int(math.sin(k * math.pi) * 12)
            for yy in range(top - rise, top):
                img.putpixel((xx, yy), c("night-1"))
        for wy in range(top + 14, BG_H - 140, 26):
            for wx in range(x + 8, x + w - 12, 18):
                if rng.random() < 0.22:
                    for yy in range(wy, wy + 9):
                        for xx in range(wx, wx + 6):
                            if xx < BG_W:
                                img.putpixel((xx, yy), c("gold-3" if yy > wy + 1 else "gold-4"))
        x += w + rng.randrange(6, 24)
    return img


def eolis_mid():
    img = Image.new("RGBA", (BG_W, BG_H), CLEAR)
    rng = random.Random(4)
    # Great roots arching overhead, and hanging lanterns.
    for i in range(4):
        cx = i * 160 + rng.randrange(-20, 20)
        for x in range(cx - 120, cx + 120):
            k = (x - (cx - 120)) / 240
            y0 = int(30 + math.sin(k * math.pi) * -20 + 40)
            for y in range(0, y0):
                img.putpixel((x % BG_W, y), c("night-1"))
            for y in range(y0, y0 + 3):
                img.putpixel((x % BG_W, y), c("bark-1"))
    for i in range(6):
        x = rng.randrange(BG_W)
        length = rng.randrange(60, 130)
        for y in range(40, length):
            img.putpixel((x, y), c("stone-2"))
        for dy in range(8):
            for dx in range(-3, 4):
                col = "gold-5" if abs(dx) < 2 and 1 < dy < 7 else "stone-2"
                img.putpixel(((x + dx) % BG_W, length + dy), c(col))
        # A faint ring of lamplight around the lantern.
        for k in range(48):
            ang = k / 48 * math.tau
            px = (x + int(math.cos(ang) * 9)) % BG_W
            py = length + 4 + int(math.sin(ang) * 9)
            if k % 2 == 0 and img.getpixel((px, py))[3] == 0:
                img.putpixel((px, py), c("gold-3", 120))
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
