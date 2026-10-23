#!/usr/bin/env python3
"""Generates the small decor sprites that dress room surfaces (design bible 12.5:
the decor layer between the tiles and the foreground).

Each zone gets an atlas of cells, one cell per 16x32 world pixels, drawn at the
2x render density (design bible 12.1), so a cell is 32x64 atlas pixels. Four rows:
  row 0  floor pieces, standing on the bottom of the cell
  row 1  ceiling pieces, hanging from the top of the cell
  row 2  pieces on a wall to the left (attached at x = 0)
  row 3  the same, mirrored, for a wall to the right
and a JSON file: the cell size in world pixels, the density, how many variants
each row has, and the glow points (world pixels within the cell) of the pieces
that give off light (the Trunk's cyan fungus, Eolis's sconces).

Pieces are painted in atlas pixels: strokes are one atlas pixel wide, half a
world pixel, which is where the extra detail comes from.

scripts/world/decor.gd scatters them over a room's open cells. Every color is
from the master palette. Usage: python3 tools/art/decorgen.py
"""
import json
import math
import random
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import palette  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "decor"
## Atlas pixels per world pixel.
D = 2
CELL_W, CELL_H = 16, 32
W, H = CELL_W * D, CELL_H * D
COLS = 6

PAL = {}
for _name, _hue, _sat in palette.RAMPS:
    for _i in range(8):
        PAL[f"{_name}-{_i}"] = palette.shade(_hue, _sat, _i) + (255,)


class Cell:
    def __init__(self):
        self.img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        self.glow = []

    def px(self, x, y, color):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < W and 0 <= y < H:
            self.img.putpixel((x, y), PAL[color])

    def rect(self, x, y, w, h, color):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.px(xx, yy, color)

    def line(self, pts, color):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
            for i in range(n + 1):
                t = i / n
                self.px(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, color)

    def disc(self, cx, cy, rx, ry, color):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                    self.px(x, y, color)

    def opaque(self, x, y):
        return 0 <= x < W and 0 <= y < H and self.img.getpixel((x, y))[3] > 0

    def outline(self, color):
        """A one pixel outline of `color` around everything drawn so far."""
        src = self.img.copy()
        for y in range(H):
            for x in range(W):
                if src.getpixel((x, y))[3]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W and 0 <= ny < H and src.getpixel((nx, ny))[3]:
                        self.img.putpixel((x, y), PAL[color])
                        break

    def add_glow(self, x, y):
        """A light source at atlas pixel (x, y), stored in world pixels."""
        self.glow.append([round(x / D, 1), round(y / D, 1)])


def blade(c, x, h, lean, dark, light, tip):
    """A grass blade from the floor: two pixels wide at the root, one at the tip."""
    pts = [(x + lean * (k / h) ** 1.6, H - 1 - k) for k in range(h)]
    for k, (px, py) in enumerate(pts):
        c.px(px, py, light if k > h * 0.55 else dark)
        if k < h * 0.4:
            c.px(px + 1, py, dark)
    c.px(pts[-1][0], pts[-1][1], tip)


# --- Trunk Hollows -------------------------------------------------------------

def trunk_tuft(rng):
    c = Cell()
    for i in range(rng.randint(8, 12)):
        x = rng.randint(5, 25)
        h = rng.randint(5, 15)
        blade(c, x, h, rng.uniform(-4, 4), "leaf-1", "leaf-2" if i % 3 else "leaf-3", "leaf-4")
    # A few seed heads.
    for _ in range(rng.randint(0, 2)):
        x = rng.randint(8, 22)
        h = rng.randint(14, 19)
        c.line([(x, H - 1), (x + 1, H - h)], "leaf-2")
        c.rect(x, H - h - 3, 2, 3, "gold-3")
        c.px(x, H - h - 3, "gold-5")
    return c


def trunk_fungus(rng, big):
    """Cyan glowing caps on thin stems: the zone's light sources."""
    c = Cell()
    caps = 3 if big else 2
    for i in range(caps):
        x = 8 + i * (8 if big else 12) + rng.randint(-2, 2)
        h = rng.randint(6, 16 if big else 10)
        r = 4 if i == 1 and big else 3
        top = H - 1 - h
        c.line([(x, H - 1), (x, top)], "stone-5")
        c.line([(x + 1, H - 1), (x + 1, top + 2)], "stone-3")
        # Domed cap: a dark rim, a bright body, a near-white glint.
        for dy in range(r):
            span = r + 1 - dy // 2 if dy else r + 2
            c.rect(x - span + 1, top - dy, span * 2, 1, "sky-4" if dy == 0 else "sky-5")
        c.rect(x - r, top + 1, 2 * r + 2, 1, "sky-2")
        c.px(x - r + 1, top - r + 1, "sky-6")
        c.px(x - r + 2, top - r + 1, "sky-7")
        c.px(x - r + 1, top - r + 2, "sky-6")
        for k in range(-r + 1, r + 1, 2):
            c.px(x + k, top + 1, "sky-3")
        c.add_glow(x + 0.5, top - 1)
    c.outline("sky-1")
    # Spores drifting off the caps (left outside the outline).
    for _ in range(rng.randint(1, 3)):
        c.px(rng.randint(4, W - 5), rng.randint(H - 34, H - 22), "sky-5")
    return c


def trunk_mushroom(rng):
    c = Cell()
    x = rng.randint(12, 18)
    h = rng.randint(8, 12)
    top = H - 1 - h
    c.rect(x, top, 4, h + 1, "bark-6")
    c.rect(x + 3, top, 1, h + 1, "bark-5")
    c.rect(x - 1, H - 2, 6, 2, "bark-5")
    c.disc(x + 2, top - 1, 8, 4.5, "bark-3")
    c.disc(x + 1, top - 2, 6, 3.2, "bark-4")
    c.rect(x - 5, top + 1, 14, 2, "bark-2")
    for k in range(-5, 9, 2):
        c.px(x + k + 1, top + 2, "bark-5")
    # Pale spots on the cap.
    for dx, dy in ((-3, -3), (3, -4), (0, -5), (5, -2)):
        c.px(x + dx, top + dy, "gold-6")
    c.outline("bark-1")
    return c


def trunk_twig(rng):
    c = Cell()
    y = H - 2
    x0 = rng.randint(2, 7)
    c.line([(x0, y), (x0 + 20, y - 1), (x0 + 24, y - 5)], "bark-3")
    c.line([(x0, y + 1), (x0 + 20, y)], "bark-1")
    c.line([(x0 + 8, y), (x0 + 12, y - 6), (x0 + 14, y - 7)], "bark-2")
    c.rect(x0 + 13, y - 9, 3, 2, "leaf-2")
    c.px(x0 + 15, y - 10, "leaf-3")
    for _ in range(5):
        c.rect(rng.randint(3, 26), H - 1, rng.randint(1, 3), 1, rng.choice(("stone-3", "stone-2", "bark-2")))
    return c


def trunk_roots(rng, glow):
    c = Cell()
    strands = rng.randint(2, 3)
    for s in range(strands):
        x = 6 + s * 10 + rng.randint(-2, 2)
        length = rng.randint(20, 56)
        phase = rng.random() * math.tau
        pts = [(x + math.sin(phase + y * 0.17) * 2.4, y) for y in range(length)]
        for y, (px, _) in enumerate(pts):
            w = 3 if y < length * 0.3 else (2 if y < length * 0.75 else 1)
            c.rect(px, y, w, 1, "bark-2" if s % 2 == 0 else "bark-1")
            if w > 1:
                c.px(px, y, "bark-3")
        # Rootlets branching off.
        for _ in range(rng.randint(1, 2)):
            k = rng.randint(6, max(7, length - 8))
            bx, by = pts[k]
            d = rng.choice((-1, 1))
            c.line([(bx, by), (bx + 3 * d, by + 3), (bx + 4 * d, by + 7)], "bark-1")
        if glow and s == strands - 1:
            tx, ty = pts[-1]
            c.rect(tx - 1, ty + 1, 3, 3, "sky-5")
            c.px(tx, ty + 2, "sky-7")
            c.px(tx, ty + 4, "sky-4")
            c.add_glow(tx + 0.5, ty + 2)
    return c


def trunk_moss(rng):
    c = Cell()
    for x in range(W):
        h = rng.randint(2, 8) if 4 < x < 28 else rng.randint(0, 2)
        for y in range(h):
            c.px(x, y, "leaf-1" if y < h - 2 else ("leaf-2" if y < h - 1 else "leaf-3"))
    # Drips of moss hanging lower.
    for _ in range(rng.randint(2, 4)):
        x = rng.randint(6, 25)
        n = rng.randint(8, 14)
        c.line([(x, 0), (x, n)], "leaf-1")
        c.px(x, n + 1, "leaf-3")
    return c


def trunk_shelf(rng, glow):
    """A bracket fungus growing out of a wall on the left."""
    c = Cell()
    y = rng.randint(24, 44)
    for i, w in enumerate((14, 13, 11, 8)):
        c.rect(0, y + i * 2, w, 2, "gold-3" if i == 0 else ("bark-4" if i == 1 else "bark-3"))
    c.rect(0, y - 2, 12, 2, "gold-4")
    c.rect(2, y - 3, 7, 1, "gold-5")
    # Growth rings along the edge.
    for i in range(4):
        c.px(13 - i * 2, y + 2 + i, "bark-2")
    c.rect(0, y + 8, 6, 2, "bark-2")
    if glow:
        c.rect(9, y + 7, 2, 2, "sky-5")
        c.px(9, y + 7, "sky-7")
        c.add_glow(10, y + 8)
    c.outline("bark-1")
    return c


# --- Eolis ---------------------------------------------------------------------

def eolis_weeds(rng):
    c = Cell()
    for i in range(rng.randint(6, 9)):
        x = rng.randint(4, 26)
        h = rng.randint(4, 11)
        blade(c, x, h, rng.uniform(-3, 3), "leaf-1", "leaf-2", "leaf-3")
    if rng.random() < 0.6:
        # A small yellow flower.
        x, y = rng.randint(8, 22), H - 11
        c.line([(x, H - 1), (x, y)], "leaf-2")
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            c.px(x + dx, y + dy, "gold-5")
        c.px(x, y, "ember-4")
    return c


def eolis_stones(rng):
    c = Cell()
    for _ in range(2):
        x = rng.randint(3, 20)
        w = rng.randint(5, 9)
        h = rng.randint(3, 5)
        c.disc(x + w / 2, H - h / 2, w / 2, h / 2 + 0.5, "stone-3")
        c.rect(x + 1, H - h, w - 3, 1, "stone-5")
        c.px(x + 1, H - h + 1, "stone-6")
        c.rect(x, H - 1, w, 1, "stone-2")
    c.outline("night-1")
    return c


def eolis_crate(rng):
    c = Cell()
    x0 = rng.randint(4, 8)
    w, h = 18, 16
    top = H - h
    for y in range(top, H):
        c.rect(x0, y, w, 1, "bark-2" if (y - top) % 5 == 4 else "bark-3")
    # Grain on each plank, corner posts and a brace.
    for y in range(top + 1, H, 5):
        c.rect(x0 + rng.randint(2, 10), y + 1, rng.randint(3, 6), 1, "bark-4")
    c.rect(x0, top, 2, h, "bark-2")
    c.rect(x0 + w - 2, top, 2, h, "bark-2")
    c.line([(x0 + 2, top + 1), (x0 + w - 3, H - 2)], "bark-2")
    c.line([(x0 + 2, top + 2), (x0 + w - 4, H - 2)], "bark-4")
    c.rect(x0, top, w, 1, "bark-5")
    for nx in (x0 + 1, x0 + w - 2):
        c.px(nx, top + 1, "stone-5")
        c.px(nx, H - 2, "stone-5")
    c.outline("bark-1")
    return c


def eolis_ivy(rng):
    c = Cell()
    for _ in range(rng.randint(2, 3)):
        x = rng.randint(4, 26)
        length = rng.randint(10, 32)
        for y in range(length):
            xx = x + round(math.sin(y * 0.3) * 1.5)
            c.px(xx, y, "leaf-1")
            if y % 6 == 3:
                # A leaf on alternating sides.
                d = 1 if (y // 6) % 2 else -1
                c.rect(xx + d, y - 1, 2 * d if d > 0 else 1, 2, "leaf-2")
                c.px(xx + 2 * d, y - 1, "leaf-3")
                c.px(xx + d, y + 1, "leaf-2")
    return c


def eolis_chain(rng):
    c = Cell()
    x = rng.randint(13, 18)
    length = rng.randint(12, 24)
    for y in range(0, length, 4):
        # Alternating links: an oval face-on, then one edge-on.
        if (y // 4) % 2 == 0:
            c.rect(x - 1, y, 1, 4, "stone-3")
            c.rect(x + 1, y, 1, 4, "stone-4")
            c.px(x, y, "stone-5")
            c.px(x, y + 3, "stone-3")
        else:
            c.rect(x, y, 1, 4, "stone-5")
    # A hook at the end.
    c.rect(x - 1, length, 3, 1, "stone-4")
    c.line([(x + 1, length), (x + 1, length + 4), (x - 1, length + 5), (x - 2, length + 3)], "stone-3")
    c.px(x + 1, length + 1, "stone-6")
    c.outline("night-1")
    return c


def eolis_banner(rng):
    c = Cell()
    color, shade = rng.choice((("ember-2", "ember-1"), ("sky-2", "sky-1")))
    for y in range(2, 26):
        for x in range(8, 24):
            if y < 22 or abs(x - 15.5) > (y - 22) * 2 + 0.5:
                c.px(x, y, shade if x > 20 or (x + y) % 9 == 0 else color)
    c.rect(8, 2, 2, 22, "gold-3")
    c.rect(22, 2, 1, 20, "gold-3")
    c.rect(6, 0, 20, 2, "bark-2")
    c.rect(6, 0, 20, 1, "bark-3")
    # An emblem: a small golden tree.
    c.rect(15, 8, 2, 7, "gold-4")
    c.disc(16, 8, 4, 3, "gold-4")
    c.px(14, 7, "gold-6")
    c.outline("night-1")
    return c


def eolis_sconce(rng):
    c = Cell()
    y = 28
    c.rect(0, y, 7, 2, "stone-2")
    c.rect(0, y, 6, 1, "stone-4")
    c.rect(5, y - 3, 3, 3, "stone-3")
    c.rect(5, y - 3, 3, 1, "stone-5")
    # The flame: a teardrop with a white-hot core.
    c.disc(6.5, y - 6, 2.2, 3, "ember-4")
    c.disc(6.5, y - 6, 1.4, 2.2, "gold-5")
    c.rect(6, y - 10, 1, 2, "ember-4")
    c.px(6, y - 6, "gold-7")
    c.add_glow(6.5, y - 6)
    c.outline("night-1")
    return c


ZONES = {
    "trunk": {
        "floor": [trunk_tuft, trunk_tuft, lambda r: trunk_fungus(r, False), lambda r: trunk_fungus(r, True),
                  trunk_mushroom, trunk_twig],
        "ceiling": [lambda r: trunk_roots(r, False), lambda r: trunk_roots(r, False),
                    lambda r: trunk_roots(r, True), trunk_moss],
        "wall": [lambda r: trunk_shelf(r, False), lambda r: trunk_shelf(r, True)],
    },
    "eolis": {
        "floor": [eolis_weeds, eolis_weeds, eolis_stones, eolis_weeds, eolis_stones, eolis_crate],
        "ceiling": [eolis_ivy, eolis_chain, eolis_banner],
        "wall": [eolis_sconce],
    },
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for zone, rows in ZONES.items():
        rng = random.Random(zone)
        atlas = Image.new("RGBA", (COLS * W, 4 * H), (0, 0, 0, 0))
        meta = {"cell": [CELL_W, CELL_H], "density": D, "floor": [], "ceiling": [], "wall": []}
        for row, kind in enumerate(("floor", "ceiling", "wall")):
            for col, fn in enumerate(rows[kind]):
                cell = fn(rng)
                atlas.paste(cell.img, (col * W, row * H))
                meta[kind].append({"glow": cell.glow})
                if kind == "wall":
                    atlas.paste(cell.img.transpose(Image.FLIP_LEFT_RIGHT), (col * W, 3 * H))
        atlas.save(OUT / f"{zone}.png")
        (OUT / f"{zone}.json").write_text(json.dumps(meta) + "\n")
        print(zone, {k: len(v) for k, v in rows.items()})


if __name__ == "__main__":
    main()
