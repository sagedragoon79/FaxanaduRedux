#!/usr/bin/env python3
"""Turns an Autosprite still into the frames of a rigged part (design bible 13.2).

A boss part like Rokusutahn's bark plate or tail needs a second look for a state rather
than an animation: the plate cracked while he is staggered, the tail glowing when it is
open to hits. One pro still per part is cheaper than a clip, and the state frames are
drawn over it here. The output is an ordinary source sheet for autosprite_import.py.

Usage: python3 tools/art/autosprite_parts.py SRC DEST --box X0,Y0,X1,Y1 [--cut Y]
                                             --states plain,crack|glow [--size 512]
       SRC and DEST are under art/autosprite/. --box crops the part (square), --cut clears
       everything below source row Y (a tail tip under the round segment). States:
       plain   the still as drawn
       crack   pale fissures across it (cracked plates)
       glow    lifted toward a hot yellow (the weak point pulsing)
"""
import argparse
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance

from autosprite_spin import SOURCES, ROOT, key_background


def crack(img, seed=7):
    """Jagged pale fissures with a dark rim, on the opaque part only."""
    w, h = img.size
    rng = random.Random(seed)
    lines = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lines)
    for _ in range(3):
        x, y = rng.uniform(0.25, 0.75) * w, rng.uniform(0.1, 0.25) * h
        pts = [(x, y)]
        for _ in range(9):
            x += rng.uniform(-0.12, 0.12) * w
            y += rng.uniform(0.04, 0.08) * h
            pts.append((x, y))
        d.line(pts, (40, 18, 14, 255), max(4, w // 40), joint="curve")
        d.line(pts, (246, 222, 170, 255), max(2, w // 90), joint="curve")
    out = img.copy()
    out.alpha_composite(Image.composite(lines, Image.new("RGBA", img.size, (0, 0, 0, 0)), img.split()[3]))
    return out


def glow(img):
    lit = ImageEnhance.Brightness(img).enhance(1.35)
    tint = Image.new("RGBA", img.size, (255, 236, 150, 0))
    tint.putalpha(img.split()[3].point(lambda a: a * 0.25))
    lit.alpha_composite(tint)
    return lit


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("dest")
    ap.add_argument("--box", required=True)
    ap.add_argument("--cut", type=int)
    ap.add_argument("--states", required=True)
    ap.add_argument("--size", type=int, default=512)
    a = ap.parse_args()
    img = key_background(Image.open(SOURCES / a.src))
    if a.cut is not None:
        img.paste(Image.new("RGBA", (img.width, img.height - a.cut), (0, 0, 0, 0)), (0, a.cut))
    part = img.crop(tuple(int(v) for v in a.box.split(","))).resize((a.size, a.size), Image.LANCZOS)
    make = {"plain": lambda i: i, "crack": crack, "glow": glow}
    states = a.states.split(",")
    sheet = Image.new("RGBA", (a.size * len(states), a.size), (0, 0, 0, 0))
    for k, state in enumerate(states):
        sheet.paste(make[state](part), (k * a.size, 0))
    dest = SOURCES / a.dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    sheet.quantize(256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(dest, optimize=True)
    print(f"{dest.relative_to(ROOT)}: {', '.join(states)}")


if __name__ == "__main__":
    main()
