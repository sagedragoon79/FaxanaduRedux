#!/usr/bin/env python3
"""Builds the Battle Helmet layer from Sean's pixel helmet (design bible 13.4).

The source is art/battle_helmet/right.png: Sean's Autosprite pixel conversion of
his right-facing helmet reference, cut out of its white background at its own
pixel grid (88x109, every 8x8 block of the 1024 px export is one pixel).

It is shrunk to fit the hero's head at the 2x render density (design bible 12.1),
hardened to a 1-bit alpha, given the dark sprite outline, reduced to a small
palette and written to assets/sprites/battle_helmet.png. The player draws it over
the head, its crown at the frame's `head` point (see PlayerVisual.HELMET_OFFSET).

Usage: python3 tools/art/helmetgen.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art/battle_helmet/right.png"
OUT = ROOT / "assets/sprites/battle_helmet.png"
## Width in sheet pixels (two per world pixel): a little wider than the bare head.
WIDTH = 19
OUTLINE = (18, 15, 25, 255)
COLORS = 20


def build() -> Image.Image:
    src = Image.open(SOURCE).convert("RGBA")
    height = round(src.height * WIDTH / src.width)
    small = np.asarray(src.resize((WIDTH, height), Image.LANCZOS)).astype(float)
    solid = small[..., 3] > 110
    rgb = Image.fromarray(small[..., :3].clip(0, 255).astype("uint8"))
    rgb = rgb.quantize(COLORS, method=Image.Quantize.MEDIANCUT).convert("RGB")
    out = np.zeros((height + 2, WIDTH + 2, 4), "uint8")
    pad = np.pad(solid, 1)
    ring = np.zeros_like(pad)
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        ring |= np.roll(np.roll(pad, dx, 1), dy, 0)
    out[ring & ~pad] = OUTLINE
    inner = out[1:-1, 1:-1]
    inner[solid, :3] = np.asarray(rgb)[solid]
    inner[solid, 3] = 255
    return Image.fromarray(out)


def main() -> None:
    img = build()
    img.save(OUT)
    print("wrote", OUT.relative_to(ROOT), img.size)


if __name__ == "__main__":
    main()
