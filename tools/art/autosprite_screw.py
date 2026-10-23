#!/usr/bin/env python3
"""Turns a screw drawn on an Autosprite still: frames of a spinning drill (design bible 13.2).

A drill cone's spiral thread, slid along the drill's axis, reads as the drill turning: one
pitch of slide is one turn. This slides the texture inside the drill's own silhouette (so
the outline stays put) by a fraction of the pitch, for the frames of a spin-up or a running
drill, without paying for a clip. The drill must point along +x (a right-facing machine).

Usage: python3 tools/art/autosprite_screw.py SRC --x X0,X1 --pitch P --steps N DEST_PREFIX
       Paths are under art/autosprite/. Writes DEST_PREFIX1.png .. DEST_PREFIX{N-1}.png, frame k
       slid by k/N of a pitch (frame 0 is the still itself). --x is the drill's span in source
       columns (from where the cone leaves the collar to its tip); --pitch is the thread's
       pitch at the collar.
"""
import argparse

import numpy as np
from PIL import Image, ImageFilter

from autosprite_spin import SOURCES, ROOT
from autosprite_poses import clean


def screw(img, x0, x1, frac, pitch, rim=6):
    """The drill between columns x0 and x1 (its tip) slid by `frac` of a turn. The thread's
    pitch shrinks with the cone toward the tip, so the slide does too; the outer `rim` pixels
    stay as drawn, so the silhouette and its outline do not move."""
    a = np.asarray(img).copy()
    cone = np.zeros(a.shape[:2], bool)
    cone[:, x0:x1] = a[:, x0:x1, 3] > 0
    inner = np.asarray(Image.fromarray((cone * 255).astype(np.uint8)).filter(ImageFilter.MinFilter(2 * rim + 1))) > 0
    ys, xs = np.nonzero(inner)
    local = pitch * np.clip((x1 - xs) / float(x1 - x0), 0.15, 1.0)
    src = np.round(xs - frac * local).astype(int)
    ok = (src >= x0) & inner[ys, np.clip(src, 0, a.shape[1] - 1)]
    out = a.copy()
    out[ys[ok], xs[ok]] = a[ys[ok], src[ok]]
    return Image.fromarray(out, "RGBA")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("--x", required=True)
    ap.add_argument("--pitch", type=float, required=True)
    ap.add_argument("--steps", type=int, default=3)
    ap.add_argument("--holes", type=int, default=0)
    ap.add_argument("dest")
    a = ap.parse_args()
    x0, x1 = (int(v) for v in a.x.split(","))
    still = clean(Image.open(SOURCES / a.src), hole_top=a.holes)
    for k in range(1, a.steps):
        out = SOURCES / f"{a.dest}{k}.png"
        screw(still, x0, x1, k / a.steps, a.pitch).quantize(
            256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(out, optimize=True)
        print(f"{out.relative_to(ROOT)}: drill slid {k}/{a.steps} of a pitch")


if __name__ == "__main__":
    main()
