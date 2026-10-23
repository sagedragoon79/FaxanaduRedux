#!/usr/bin/env python3
"""Carries a local change from one Autosprite still onto other poses (design bible 13.2).

A boss whose second look differs only in one spot (Zoradohna's phase 3: the cockpit hatch
thrown back and a crystal harness on the pilot) needs that look on every pose. Rather than
paying for a second set of poses, the change is cut once from a pair of stills of the same
standing pose (BEFORE and AFTER), inside a box: what AFTER adds, and what it takes away.
The change is then turned and moved onto each pose, where the same spot sits at a given
point and angle. Poses keep everything outside the box.

Usage: python3 tools/art/autosprite_transplant.py BEFORE AFTER --box X0,Y0,X1,Y1 --anchor X,Y
                                                  [--holes Y] POSE:DEST:X,Y[:ANGLE[:SCALE]] ...
       Paths are under art/autosprite/. --anchor is a point of the changed spot in BEFORE (the
       middle of the cockpit dome); each POSE names where that point lands and the angle the
       pose is turned by (degrees, counter-clockwise: nose up on a right-facing machine) and
       its size against BEFORE. --holes Y: only white closed in below row Y is a hole (glass
       above it keeps its shine).
"""
import argparse
import math

import numpy as np
from PIL import Image, ImageFilter

from autosprite_spin import SOURCES, ROOT
from autosprite_poses import clean


def change(before, after, box, tol=40):
    """(layer of added pixels, mask of removed pixels) inside `box`."""
    b, a = np.asarray(before).astype(int), np.asarray(after).astype(int)
    inside = np.zeros(b.shape[:2], bool)
    x0, y0, x1, y1 = box
    inside[y0:y1, x0:x1] = True
    differs = np.abs(b[..., :3] - a[..., :3]).sum(-1) > tol
    added = inside & (a[..., 3] > 0) & ((b[..., 3] == 0) | differs)
    removed = inside & (b[..., 3] > 0) & (a[..., 3] == 0)
    layer = np.zeros_like(a, dtype=np.uint8)
    layer[added] = a[added]
    gone = Image.fromarray((removed * 255).astype(np.uint8), "L")
    return Image.fromarray(layer, "RGBA"), gone


def placed(img, anchor, at, angle, scale, resample):
    """`img` turned by `angle` (degrees, counter-clockwise) and scaled about `anchor`, which
    lands on `at`."""
    t = math.radians(angle)
    a, b = math.cos(t) / scale, -math.sin(t) / scale
    d, e = math.sin(t) / scale, math.cos(t) / scale
    c = anchor[0] - a * at[0] - b * at[1]
    f = anchor[1] - d * at[0] - e * at[1]
    return img.transform(img.size, Image.AFFINE, (a, b, c, d, e, f), resample)


def apply(pose, layer, gone, anchor, at, angle, scale=1.0):
    layer = placed(layer, anchor, at, angle, scale, Image.BICUBIC)
    # A little wider than the cut, so a slightly misplaced spot leaves no old pixels behind.
    gone = placed(gone, anchor, at, angle, scale, Image.BILINEAR).filter(ImageFilter.MaxFilter(9))
    out = np.asarray(pose).copy()
    out[np.asarray(gone) > 0, 3] = 0
    img = Image.fromarray(out, "RGBA")
    img.alpha_composite(layer)
    return img


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("before")
    ap.add_argument("after")
    ap.add_argument("--box", required=True)
    ap.add_argument("--anchor", required=True)
    ap.add_argument("--holes", type=int, default=0)
    ap.add_argument("poses", nargs="+")
    a = ap.parse_args()
    box = tuple(int(v) for v in a.box.split(","))
    anchor = tuple(float(v) for v in a.anchor.split(","))
    still = lambda path: clean(Image.open(SOURCES / path), hole_top=a.holes)
    layer, gone = change(still(a.before), still(a.after), box)
    for spec in a.poses:
        src, dest, at, *rest = spec.split(":")
        at = tuple(float(v) for v in at.split(","))
        turn = [float(v) for v in rest] + [0.0, 1.0][len(rest):]
        img = apply(still(src), layer, gone, anchor, at, *turn[:2])
        out = SOURCES / dest
        out.parent.mkdir(parents=True, exist_ok=True)
        img.quantize(256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(out, optimize=True)
        print(f"{out.relative_to(ROOT)}: change from {a.after} at {at}")


if __name__ == "__main__":
    main()
