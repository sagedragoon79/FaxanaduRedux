#!/usr/bin/env python3
"""Makes the Drowned Dwarf's mire frames (sunk, rise, sink) from his PixelLab crouch clip.

He lies sunk in the mire with only his helm's crest showing, hauls himself out, and sinks
back (scripts/enemies/drowned_dwarf.gd). PixelLab draws the crouch, not the mud, so each
frame here is a crouch frame pushed down below the ground line (his feet in the base view)
and cut off there. The importer then anchors them "fixed", on the same ground line.

  art/pixellab/enemies/drowned_dwarf/sink/       the clip: standing, crouching to his knees
  art/pixellab/enemies/drowned_dwarf/mire_rise/  written here: from the crest up to standing
  art/pixellab/enemies/drowned_dwarf/mire_sink/  written here: the rise played back
  art/pixellab/enemies/drowned_dwarf/mire_sunk/  written here: the crest alone, two frames

Usage: python3 tools/art/mire_frames.py  (then tools/art/pixellab_sheets.py)
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DWARF = ROOT / "art" / "pixellab" / "enemies" / "drowned_dwarf"
# How much of him shows above the mire in each rise frame, as a share of his standing
# height, and which crouch frame it is (the clip's last frame is the lowest kneel).
RISE = [(0.12, -1), (0.28, -1), (0.45, -2), (0.62, -3), (0.78, -4), (0.92, -5), (1.0, 2), (1.0, 0)]
# Lying in wait: only the crest of the helm, bobbing a pixel.
SUNK = [0.07, 0.08]


def ground(img):
    """The lowest opaque row: his feet."""
    a = img.getchannel("A").point(lambda v: 255 if v > 128 else 0)
    return a.getbbox()[3]


def sunk(img, floor, share, height):
    """`img` pushed down until `share` of `height` shows above the ground line `floor`."""
    top = img.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox()[1]
    depth = max(0, round((floor - top) - share * height))
    out = Image.new("RGBA", img.size)
    out.alpha_composite(img, (0, depth))
    # Everything below the ground line is under the mire.
    out.paste((0, 0, 0, 0), (0, floor, img.width, img.height))
    return out


def write(folder, frames):
    dest = DWARF / folder
    dest.mkdir(exist_ok=True)
    for old in dest.glob("[0-9][0-9].png"):
        old.unlink()
    for i, f in enumerate(frames):
        f.save(dest / f"{i:02d}.png")
    print(f"{dest.relative_to(ROOT)}: {len(frames)} frames")


def main():
    clip = [Image.open(p).convert("RGBA") for p in sorted((DWARF / "sink").glob("[0-9][0-9].png"))]
    floor = ground(clip[0])
    height = floor - clip[0].getchannel("A").getbbox()[1]
    rise = [sunk(clip[k], floor, d, height) for d, k in RISE]
    write("mire_rise", rise)
    write("mire_sink", rise[::-1])
    write("mire_sunk", [sunk(clip[-1], floor, d, height) for d in SUNK])


if __name__ == "__main__":
    main()
