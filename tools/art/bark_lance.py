#!/usr/bin/env python3
"""Lengthens the Bark Knight's lance in his thrust and rooted clips (art loop pass 4).

His lance reaches about 72 world px in front of him (`BarkKnight.LANCE_TO`), and while he roots
it is a ledge you stand on, so the art must reach that far at the lance's height
(`BarkKnight.LANCE_Y`). A PixelLab canvas is 256 px, which holds only the first 20 or so world
px of it. So each frame is set on a wider canvas and the lance drawn on to its full length, built
from the clip's own pixels (one column of its shaft, repeated, then its thorn point), so it keeps
the frame's colours, thickness and outline. The importer then scales and outlines it with the
rest (tools/art/autosprite_import.py, frame_size LANCE_CELL).

Run after tools/art/pixellab_sheets.py: it writes strips beside that script's, in
art/pixellab/sheets/bark_knight/.

Usage: python3 tools/art/bark_lance.py
"""
from pathlib import Path

from PIL import Image

import pixellab_sheets

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "art" / "pixellab" / "sheets" / "bark_knight"
# The wide canvas (square, as the importer reads cells); the clip's 256 px frame sits at its
# bottom left.
LANCE_CELL = 640
# Per clip, in source pixels: the row through the middle of the clip's lance, the green shaft
# column copied, and the middle of his stance (the game's origin; the manifest's "feet_x").
ARMORED = {"mid": 129, "shaft_x": 204, "feet_x": 140}
BARE = {"mid": 109, "shaft_x": 176, "feet_x": 88}
# Rows taken above and below the middle: the lance with the thorn's barbs.
HALF = 17
# World px per source px: the manifest's "height" (36) over the reference frame's figure (243 px).
WORLD = 36.0 / 243.0
LANCE_TO = 72.0

# strip -> (clip folder, its numbers, {frame: world px the lance reaches past his middle})
# (frames not named are set on the wide canvas as drawn: the brace)
STRIPS = {
    "thrust_lance.png": ("thrust", ARMORED, {10: 50.0, 12: LANCE_TO}),
    "rooted_lance.png": ("rooted", ARMORED, {i: LANCE_TO for i in range(9)}),
    # The first bare thrust drifted to another model (red bark, a green glow): the retake.
    "bare_thrust_lance.png": ("bare_thrust_r", BARE, {10: 50.0, 12: LANCE_TO}),
    "bare_rooted_lance.png": ("bare_rooted", BARE, {i: LANCE_TO for i in range(9)}),
}


def lengthen(frame, reach, clip):
    """The frame on the wide canvas, its lance drawn out to `reach` world px past his middle."""
    wide = Image.new("RGBA", (LANCE_CELL, LANCE_CELL))
    top = LANCE_CELL - frame.height
    wide.alpha_composite(frame, (0, top))
    if reach is None:
        return wide
    mid, shaft_x = clip["mid"], clip["shaft_x"]
    end = int(round(clip["feet_x"] + reach / WORLD))
    y0, y1 = mid - HALF, mid + HALF
    # The clip's head: its pale thorn point and the ferrule just behind it, to the lance's end.
    pale = next(x for x in range(shaft_x + 2, frame.width) if sum(frame.getpixel((x, mid))[:3]) > 350)
    last = max(x for x in range(pale, frame.width) if frame.getpixel((x, mid))[3] > 128)
    head = frame.crop((pale - 8, y0, last + 1, y1))
    shaft = frame.crop((shaft_x, y0, shaft_x + 1, y1))
    # Clear the clip's own head, then lay the shaft out to the new point.
    start = shaft_x + 1
    wide.paste(Image.new("RGBA", (frame.width - start, y1 - y0)), (start, top + y0))
    for x in range(start, end - head.width):
        wide.alpha_composite(shaft, (x, top + y0))
    wide.alpha_composite(head, (end - head.width, top + y0))
    return wide


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (clip, nums, frames) in STRIPS.items():
        paths = pixellab_sheets.frames_of(f"enemies/bark_knight/{clip}")
        if not paths:
            print(f"bark_knight/{name}: no frames in {clip}, skipped")
            continue
        strip = Image.new("RGBA", (LANCE_CELL * len(paths), LANCE_CELL))
        for i, p in enumerate(paths):
            im = Image.open(p).convert("RGBA")
            pixellab_sheets.clear_slabs(im)
            strip.paste(lengthen(im, frames.get(i), nums), (i * LANCE_CELL, 0))
        strip.save(OUT / name)
        print(f"bark_knight/{name}: {len(paths)} frames, lance to {LANCE_TO:.0f} px")


if __name__ == "__main__":
    main()
