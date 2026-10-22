#!/usr/bin/env python3
"""Generates the 64-color master palette (design bible section 12.2).

8 ramps of 8 shades. Shadows hue-shift toward blue-violet and highlights toward
warm yellow; no pure black or white. Writes art/palette/master.gpl (GIMP/Aseprite)
and art/palette/master.png (one 8x8 swatch per color, ramps in rows).
Usage: python3 tools/art/palette.py
"""
import colorsys
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parents[2] / "art" / "palette"

# (name, base hue in degrees, saturation)
RAMPS = [
    ("night", 255, 0.30),   # outlines, deep shadows, Zenis
    ("stone", 250, 0.14),   # masonry, Eolis, Dartmoor
    ("bark", 28, 0.45),     # wood, leather, Trunk
    ("leaf", 105, 0.45),    # foliage, the hero's tunic
    ("sky", 205, 0.45),     # sky, water, Branches
    ("ember", 8, 0.62),     # scarf, thorns, fire, blood
    ("gold", 45, 0.70),     # sap, lanterns, gold, UI
    ("crystal", 300, 0.45), # meteor crystal, magic
]


def shade(hue, sat, i, n=8):
    k = i / (n - 1)                       # 0 = darkest, 1 = lightest
    light = 0.08 + 0.84 * k
    # Hue shift: darks toward 250 (blue-violet), lights toward 50 (warm).
    target = 250 if k < 0.5 else 50
    amount = abs(k - 0.5) * 0.5
    dh = ((target - hue + 180) % 360) - 180
    h = (hue + dh * amount) % 360
    s = sat * (0.75 + 0.5 * (1 - abs(k - 0.55) * 1.6))
    r, g, b = colorsys.hls_to_rgb(h / 360, light, max(0.0, min(1.0, s)))
    return tuple(int(round(c * 255)) for c in (r, g, b))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    colors = []
    for name, hue, sat in RAMPS:
        for i in range(8):
            colors.append((f"{name}-{i}", shade(hue, sat, i)))
    lines = ["GIMP Palette", "Name: Faxanadu Redux Master", "Columns: 8", "#"]
    for name, (r, g, b) in colors:
        lines.append(f"{r:3d} {g:3d} {b:3d}\t{name}")
    (OUT / "master.gpl").write_text("\n".join(lines) + "\n")
    img = Image.new("RGB", (64, 64))
    for idx, (_, rgb) in enumerate(colors):
        x, y = idx % 8, idx // 8
        for dy in range(8):
            for dx in range(8):
                img.putpixel((x * 8 + dx, y * 8 + dy), rgb)
    img.save(OUT / "master.png")


if __name__ == "__main__":
    main()
