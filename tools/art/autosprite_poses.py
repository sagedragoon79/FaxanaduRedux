#!/usr/bin/env python3
"""Packs Autosprite pose stills into a source sheet for autosprite_import.py (design bible 13.2).

A pose (generate_pose, 3 credits) is one clean still, where a clip of a heavy attack can drift
(the Iron Dwarf's slam clip grew a second hammer head). A few poses make the key frames of
a short attack. Poses come out at the base image's scale on a white ground, sometimes with a
patch of cracked floor under an impact; this keys the white out (also where it is closed in,
between the legs), clears the floor, keeps the figure (the largest connected part, so flying
chips go too) and scales each still into one square cell.

Usage: python3 tools/art/autosprite_poses.py DEST SRC[:cut=Y][:ground=Y][:x=X][:holes=Y][:rest=1] ... [--scale 0.25] [--size 256]
       DEST and SRC are under art/autosprite/. cut=Y clears every row from source row Y down
       (the floor a hammer head sinks into); ground=Y clears pale, grey floor pixels from row Y
       down. x=X is the source column under the hips: it lands on the cell's middle, so the
       poses stand on one spot (the manifest then gives the cell's middle as "feet_x").
       holes=Y: only white closed in below row Y is keyed out (a glass dome above keeps it).
       rest=1: the pose's lowest pixel rests on the cell's bottom (stills that each drew the
       floor at a different height: a spider that crouches, rears or lies on her back).
       --scale is the pose's scale against the animation clips (a 1024 px pose of a figure
       drawn on a 256 px clip cell: 0.25).
"""
import argparse

import numpy as np
from PIL import Image

from autosprite_spin import SOURCES, ROOT, key_background


def components(mask):
    """Labels of the 4-connected parts of `mask` (0 is background) and their sizes."""
    h, w = mask.shape
    labels = np.zeros((h, w), np.int32)
    sizes = [0]
    for y0, x0 in zip(*np.nonzero(mask)):
        if labels[y0, x0]:
            continue
        n = len(sizes)
        labels[y0, x0] = n
        stack, size = [(y0, x0)], 0
        while stack:
            y, x = stack.pop()
            size += 1
            for yy, xx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= yy < h and 0 <= xx < w and mask[yy, xx] and not labels[yy, xx]:
                    labels[yy, xx] = n
                    stack.append((yy, xx))
        sizes.append(size)
    return labels, sizes


def clean(img, cut=None, ground=None, hole=400, hole_top=0):
    a = np.asarray(key_background(img)).copy()
    rgb = a[..., :3].astype(int)
    # White closed in by the figure: near-white parts bigger than a highlight (from row
    # hole_top down, so glass higher up keeps its shine).
    white = (rgb >= 237).all(-1) & (a[..., 3] > 0)
    white[:hole_top] = False
    labels, sizes = components(white)
    big = np.array(sizes) > hole
    big[0] = False
    a[big[labels], 3] = 0
    if ground is not None:
        mx, mn = rgb.max(-1), rgb.min(-1)
        pale = (mx > 120) & ((mx - mn) < 0.3 * mx)
        a[ground:][pale[ground:], 3] = 0
    if cut is not None:
        a[cut:, 3] = 0
    # The figure alone: its largest part.
    labels, sizes = components(a[..., 3] > 0)
    if len(sizes) > 1:
        a[labels != int(np.argmax(sizes[1:])) + 1, 3] = 0
    return Image.fromarray(a, "RGBA")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("dest")
    ap.add_argument("srcs", nargs="+")
    ap.add_argument("--scale", type=float, default=0.25)
    ap.add_argument("--size", type=int, default=256)
    a = ap.parse_args()
    sheet = Image.new("RGBA", (a.size * len(a.srcs), a.size), (0, 0, 0, 0))
    for k, spec in enumerate(a.srcs):
        path, *opts = spec.split(":")
        opt = {o.split("=")[0]: int(o.split("=")[1]) for o in opts}
        still = clean(Image.open(SOURCES / path), opt.get("cut"), opt.get("ground"), hole_top=opt.get("holes", 0))
        side = int(round(still.width * a.scale))
        small = still.resize((side, side), Image.LANCZOS)
        # The hips (x=, default the still's middle) on the cell's middle, the feet where the pose had them.
        hip = opt.get("x", still.width // 2) * a.scale
        cell = Image.new("RGBA", (a.size, a.size), (0, 0, 0, 0))
        top = a.size - side
        if opt.get("rest"):
            rows = np.nonzero(np.asarray(small)[..., 3].any(1))[0]
            top = a.size - 1 - int(rows[-1])
        cell.paste(small, (int(round(a.size / 2 - hip)), top), small)
        sheet.paste(cell, (k * a.size, 0))
    dest = SOURCES / a.dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    sheet.quantize(256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).save(dest, optimize=True)
    print(f"{dest.relative_to(ROOT)}: {len(a.srcs)} poses of {a.size} px")


if __name__ == "__main__":
    main()
