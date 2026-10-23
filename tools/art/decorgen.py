#!/usr/bin/env python3
"""Generates the small decor sprites that dress room surfaces (design bible 12.5:
the decor layer between the tiles and the foreground).

Each zone gets an atlas of 16x32 cells in four rows:
  row 0  floor pieces, standing on the bottom of the cell
  row 1  ceiling pieces, hanging from the top of the cell
  row 2  pieces on a wall to the left (attached at x = 0)
  row 3  the same, mirrored, for a wall to the right
and a JSON file: how many variants each row has, and the glow points (cell
pixels) of the pieces that give off light (the Trunk's cyan fungus).

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
W, H = 16, 32
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

    def line(self, pts, color):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
            for i in range(n + 1):
                t = i / n
                self.px(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, color)

    def outline(self, color):
        """A 1 px outline of `color` around everything drawn so far."""
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


# --- Trunk Hollows -------------------------------------------------------------

def trunk_tuft(rng):
    c = Cell()
    for i in range(rng.randint(4, 6)):
        x = rng.randint(3, 12)
        h = rng.randint(3, 7)
        lean = rng.choice((-1, 0, 1))
        c.line([(x, H - 1), (x + lean, H - h)], "leaf-2" if i % 2 else "leaf-1")
        c.px(x + lean, H - h, "leaf-3")
    return c


def trunk_fungus(rng, big):
    """Cyan glowing caps on thin stems: the zone's light sources."""
    c = Cell()
    caps = 3 if big else 2
    for i in range(caps):
        x = 4 + i * (4 if big else 6) + rng.randint(-1, 1)
        h = rng.randint(3, 8 if big else 5)
        c.line([(x, H - 1), (x, H - h)], "stone-5")
        r = 2 if i == 1 and big else 1
        for dx in range(-r - 1, r + 2):
            c.px(x + dx, H - h - 1, "sky-4")
        for dx in range(-r, r + 1):
            c.px(x + dx, H - h - 2, "sky-5")
        c.px(x - 1, H - h - 2, "sky-6")
        c.glow.append([x, H - h - 1])
    c.outline("sky-1")
    return c


def trunk_mushroom(rng):
    c = Cell()
    x = rng.randint(6, 9)
    h = rng.randint(4, 6)
    c.line([(x, H - 1), (x, H - h)], "bark-6")
    c.line([(x + 1, H - 1), (x + 1, H - h)], "bark-5")
    for dx in range(-3, 5):
        c.px(x + dx, H - h - 1, "bark-3")
    for dx in range(-2, 4):
        c.px(x + dx, H - h - 2, "bark-4" if dx < 1 else "bark-3")
    c.px(x - 1, H - h - 2, "bark-5")
    c.px(x + 1, H - h - 1, "bark-6")
    c.outline("bark-1")
    return c


def trunk_twig(rng):
    c = Cell()
    y = H - 1
    x0 = rng.randint(1, 4)
    c.line([(x0, y), (x0 + 10, y), (x0 + 12, y - 2)], "bark-2")
    c.line([(x0 + 4, y), (x0 + 6, y - 3)], "bark-2")
    c.px(x0 + 6, y - 3, "leaf-2")
    for i in range(3):
        c.px(rng.randint(2, 13), y, "stone-3")
    return c


def trunk_roots(rng, glow):
    c = Cell()
    strands = rng.randint(2, 3)
    for s in range(strands):
        x = 3 + s * 5 + rng.randint(-1, 1)
        length = rng.randint(10, 28)
        phase = rng.random() * math.tau
        pts = [(x + math.sin(phase + y * 0.35) * 1.2, y) for y in range(0, length)]
        c.line(pts, "bark-2" if s % 2 == 0 else "bark-1")
        for y in range(0, min(length, 8)):
            c.px(pts[y][0] + 1, y, "bark-1")
        if glow and s == strands - 1:
            tx, ty = pts[-1]
            c.px(tx, ty + 1, "sky-5")
            c.px(tx, ty + 2, "sky-6")
            c.glow.append([round(tx), ty + 2])
    return c


def trunk_moss(rng):
    c = Cell()
    for x in range(W):
        h = rng.randint(1, 4) if 2 < x < 14 else rng.randint(0, 1)
        for y in range(h):
            c.px(x, y, "leaf-1" if y < h - 1 else "leaf-2")
    return c


def trunk_shelf(rng, glow):
    """A bracket fungus growing out of a wall on the left."""
    c = Cell()
    y = rng.randint(12, 22)
    for i, w in enumerate((7, 6, 4)):
        for x in range(w):
            c.px(x, y + i, "gold-3" if i == 0 else "bark-3")
    for x in range(1, 6):
        c.px(x, y - 1, "gold-4")
    if glow:
        c.px(5, y + 3, "sky-5")
        c.glow.append([5, y + 3])
    c.outline("bark-1")
    return c


# --- Eolis ---------------------------------------------------------------------

def eolis_weeds(rng):
    c = Cell()
    for i in range(rng.randint(3, 5)):
        x = rng.randint(2, 13)
        h = rng.randint(2, 5)
        c.line([(x, H - 1), (x + rng.choice((-1, 1)), H - h)], "leaf-2" if i % 2 else "leaf-1")
    if rng.random() < 0.5:
        c.px(rng.randint(4, 11), H - 5, "gold-5")
    return c


def eolis_stones(rng):
    c = Cell()
    for i in range(2):
        x = rng.randint(2, 10)
        w = rng.randint(2, 4)
        for dx in range(w):
            c.px(x + dx, H - 1, "stone-3")
            if 0 < dx < w - 1 or w == 2:
                c.px(x + dx, H - 2, "stone-4")
        c.px(x, H - 2, "stone-5")
    return c


def eolis_crate(rng):
    c = Cell()
    x0 = rng.randint(2, 4)
    for y in range(H - 8, H):
        for x in range(x0, x0 + 9):
            c.px(x, y, "bark-3" if (y - (H - 8)) % 4 else "bark-2")
    c.line([(x0, H - 8), (x0 + 8, H - 1)], "bark-2")
    for x in range(x0, x0 + 9):
        c.px(x, H - 8, "bark-4")
    c.outline("bark-1")
    return c


def eolis_ivy(rng):
    c = Cell()
    for s in range(rng.randint(2, 3)):
        x = rng.randint(2, 13)
        length = rng.randint(5, 16)
        for y in range(length):
            xx = x + (1 if (y // 3) % 2 else 0)
            c.px(xx, y, "leaf-1")
            if y % 3 == 1:
                c.px(xx + 1, y, "leaf-2")
                c.px(xx - 1, y, "leaf-2")
    return c


def eolis_chain(rng):
    c = Cell()
    x = rng.randint(6, 9)
    length = rng.randint(6, 12)
    for y in range(0, length):
        c.px(x, y, "stone-4" if y % 2 else "stone-3")
    c.px(x - 1, length, "stone-3")
    c.px(x + 1, length, "stone-3")
    c.px(x, length + 1, "stone-3")
    return c


def eolis_banner(rng):
    c = Cell()
    color = rng.choice(("ember-2", "sky-2"))
    for y in range(1, 13):
        for x in range(4, 12):
            if y < 11 or abs(x - 7.5) > y - 11 + 0.5:
                c.px(x, y, color)
        c.px(4, y, "gold-3")
    for x in range(3, 13):
        c.px(x, 0, "bark-2")
    c.px(7, 5, "gold-4")
    c.px(8, 5, "gold-4")
    c.outline("night-1")
    return c


def eolis_sconce(rng):
    c = Cell()
    y = 14
    for x in range(0, 4):
        c.px(x, y, "stone-2")
    c.px(3, y - 1, "stone-3")
    c.px(3, y - 2, "gold-4")
    c.px(3, y - 3, "gold-5")
    c.px(3, y - 4, "ember-4")
    c.glow.append([3, y - 3])
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
        meta = {"cell": [W, H], "floor": [], "ceiling": [], "wall": []}
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
