#!/usr/bin/env python3
"""Builds a base-for-approval review picture for a redesigned character (style guide, step 1d).

Lays the east profile and the south-east three-quarter at 1x and 4x, with the hero at rough
scale, so Sean can approve the base before any animation is made from it.

  python3 tools/art/base_review.py <base_dir> <out.png> "<title>" "<zone colours>"

<base_dir> holds the PixelLab rotations (east.png, south-east.png ...). Nearest-neighbour
scaling throughout, so the pixels stay crisp.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
HERO_SHEET = ROOT / "assets" / "sprites" / "hero_base.png"
HERO_CELL = (64, 84)

BG = (26, 28, 32, 255)
PANEL = (34, 37, 42, 255)
INK = (214, 219, 224, 255)
DIM = (150, 156, 163, 255)


def font(size):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def trim(im):
    bbox = im.getbbox()
    return im.crop(bbox) if bbox else im


def scaled(im, factor):
    return im.resize((im.width * factor, im.height * factor), Image.NEAREST)


def fit_height(im, h):
    if im.height == 0:
        return im
    factor = max(1, round(h / im.height))
    return scaled(im, factor)


def hero_frame():
    sheet = Image.open(HERO_SHEET).convert("RGBA")
    cw, ch = HERO_CELL
    cols = sheet.width // cw
    rows = sheet.height // ch
    for r in range(rows):
        for c in range(cols):
            cell = sheet.crop((c * cw, r * ch, c * cw + cw, r * ch + ch))
            t = trim(cell)
            if t.width > 6 and t.height > 20:
                return t
    return trim(sheet)


def main():
    base_dir = Path(sys.argv[1])
    out = Path(sys.argv[2])
    title = sys.argv[3]
    zone = sys.argv[4] if len(sys.argv) > 4 else ""

    east = trim(Image.open(base_dir / "east.png").convert("RGBA"))
    se = trim(Image.open(base_dir / "south-east.png").convert("RGBA"))
    hero = hero_frame()

    W, H = 1020, 780
    img = Image.new("RGBA", (W, H), BG)
    d = ImageDraw.Draw(img)
    f_title = font(15)
    f_h = font(13)
    f_s = font(12)
    f_tiny = font(11)

    d.text((14, 10), title, font=f_title, fill=INK)
    d.text((14, 32), "For approval. Base only; no animation until you OK it. "
                     "Would replace the drawn head in haar_wyrm.gd (_draw_head).",
            font=f_s, fill=DIM)

    # --- East profile panel ---
    d.rectangle((14, 62, W - 14, 408), fill=PANEL)
    d.text((28, 72), "EAST PROFILE  ( -> base/guard.png; every moving clip starts here )",
           font=f_h, fill=INK)
    e1 = fit_height(east, 72)
    img.alpha_composite(e1, (36, 110))
    d.text((40, 188), "1x", font=f_tiny, fill=DIM)
    e4 = scaled(east, 4)
    # keep inside the panel
    if e4.height > 290:
        e4 = fit_height(east, 290)
    img.alpha_composite(e4, (214, 118))
    d.text((214, 386), "4x", font=f_tiny, fill=DIM)

    d.text((760, 72), "ROUGH SCALE", font=f_h, fill=INK)
    d.text((760, 90), "(2x-density sheet px)", font=f_s, fill=DIM)
    h2 = scaled(hero, 2)
    if h2.height > 150:
        h2 = fit_height(hero, 150)
    img.alpha_composite(h2, (766, 118))
    d.text((766, 250), f"hero ~{h2.height}", font=f_tiny, fill=DIM)
    headswatch = fit_height(east, 112)
    img.alpha_composite(headswatch, (864, 150))
    d.text((864, 250), f"head ~{headswatch.height}", font=f_tiny, fill=DIM)
    d.text((760, 290), "A guardian head sits a\nlittle taller than the hero.", font=f_s, fill=DIM)

    # --- South-east three-quarter panel ---
    d.rectangle((14, 420, W - 14, H - 12), fill=PANEL)
    d.text((28, 428), "SOUTH-EAST THREE-QUARTER  ( still poses only: idle, rest, intro/taunt )",
           font=f_h, fill=INK)
    s1 = fit_height(se, 72)
    img.alpha_composite(s1, (36, 468))
    d.text((40, 548), "1x", font=f_tiny, fill=DIM)
    s4 = scaled(se, 4)
    if s4.height > 290:
        s4 = fit_height(se, 290)
    img.alpha_composite(s4, (214, 456))
    d.text((214, 744), "4x", font=f_tiny, fill=DIM)
    if zone:
        d.text((760, 470), zone, font=f_s, fill=DIM)

    img.convert("RGB").save(out)
    print(f"wrote {out} ({img.width}x{img.height})")


if __name__ == "__main__":
    main()
