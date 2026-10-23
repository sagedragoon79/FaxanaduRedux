#!/usr/bin/env python3
"""Turns one Autosprite still into a spin cycle for a rigged part (design bible 13.2).

Rokusutahn's head is a grinding wheel of mandibles: rather than spend clip credits on a
spin, the still's outer ring is rotated in steps through a full turn while the hub (the
throat and its eyes) stays put. Rotating at full source resolution and letting the import
scale it down keeps the pixels clean. The output is an ordinary source sheet for
autosprite_import.py (square cells, left to right).

Usage: python3 tools/art/autosprite_spin.py SRC DEST --center X,Y --radius R --hub R
                                            [--frames 24] [--size 512] [--mirror]
       SRC and DEST are paths under art/autosprite/, e.g. rokusutahn/base.png rokusutahn/head.png.
       The still's plain light background is keyed out from the borders inward. --mirror
       replaces the lower half of the turning ring with the upper half flipped, for a still whose
       part overlaps something below it (the head drawn on top of the grub's body); the hub
       always comes from the still as drawn.
"""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "art" / "autosprite"


def key_background(img, tol=18):
    """Clears the light background connected to the image border."""
    a = np.asarray(img.convert("RGBA")).copy()
    bg = (a[..., :3].astype(int) >= 255 - tol).all(-1)
    h, w = bg.shape
    seen = np.zeros_like(bg)
    stack = [(y, x) for y in (0, h - 1) for x in range(w)] + [(y, x) for x in (0, w - 1) for y in range(h)]
    while stack:
        y, x = stack.pop()
        if 0 <= y < h and 0 <= x < w and bg[y, x] and not seen[y, x]:
            seen[y, x] = True
            stack += [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)]
    a[seen, 3] = 0
    return Image.fromarray(a, "RGBA")


def disk(size, center, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).ellipse([center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius], 255)
    return m


def mirrored(img, center):
    """The image with everything below the center replaced by the part above it, flipped."""
    cx, cy = center
    top = img.crop((0, 0, img.width, cy))
    out = img.copy()
    out.paste(Image.new("RGBA", (img.width, img.height - cy), (0, 0, 0, 0)), (0, cy))
    flipped = top.transpose(Image.FLIP_TOP_BOTTOM)
    out.paste(flipped.crop((0, 0, img.width, min(cy, img.height - cy))), (0, cy))
    return out


def spin(img, center, radius, hub, frames, size, hub_img=None):
    """`frames` square cells of `size` px: the disk of `radius` turned 360/frames degrees each
    step, under the still hub (taken from `hub_img`, by default `img`)."""
    cx, cy = center
    box = (cx - radius, cy - radius, cx + radius, cy + radius)

    def cut(src, r):
        layer = Image.new("RGBA", src.size, (0, 0, 0, 0))
        layer.paste(src, (0, 0), disk(src.size, center, r))
        return layer.crop(box)

    part = cut(img, radius)
    hub_layer = cut(hub_img or img, hub)
    c = (radius, radius)
    sheet = Image.new("RGBA", (size * frames, size), (0, 0, 0, 0))
    for k in range(frames):
        turned = part.rotate(-360.0 * k / frames, Image.BICUBIC, center=c)
        turned.alpha_composite(hub_layer)
        sheet.paste(turned.resize((size, size), Image.LANCZOS), (k * size, 0))
    return sheet


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("dest")
    ap.add_argument("--center", required=True)
    ap.add_argument("--radius", type=int, required=True)
    ap.add_argument("--hub", type=int, required=True)
    ap.add_argument("--frames", type=int, default=24)
    ap.add_argument("--size", type=int, default=512)
    ap.add_argument("--mirror", action="store_true")
    a = ap.parse_args()
    cx, cy = (int(v) for v in a.center.split(","))
    still = key_background(Image.open(SOURCES / a.src))
    img = mirrored(still, (cx, cy)) if a.mirror else still
    sheet = spin(img, (cx, cy), a.radius, a.hub, a.frames, a.size, hub_img=still)
    dest = SOURCES / a.dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    sheet.quantize(256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(dest, optimize=True)
    print(f"{dest.relative_to(ROOT)}: {a.frames} frames of {a.size} px")


if __name__ == "__main__":
    main()
