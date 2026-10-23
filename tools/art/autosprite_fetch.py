#!/usr/bin/env python3
"""Downloads an Autosprite sheet into art/autosprite/ and stores it compactly.

Autosprite's sheetUrl (from get_spritesheet; it carries a short-lived ?sig= token) points at
a full-RGBA PNG. The import (autosprite_import.py) maps every frame onto the master palette
anyway, so the source is kept as a 256-color RGBA palette PNG, about a fifth of the size,
with no visible change at game scale.

Usage: python3 tools/art/autosprite_fetch.py "<sheetUrl>" elf/run.png
       python3 tools/art/autosprite_fetch.py --compact elf/run.png      (a sheet already on disk)
"""
import io
import sys
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "art" / "autosprite"


def compact(img):
    return img.convert("RGBA").quantize(256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    dest = SOURCES / sys.argv[2]
    if sys.argv[1] == "--compact":
        img = Image.open(dest)
    else:
        with urllib.request.urlopen(sys.argv[1]) as r:
            img = Image.open(io.BytesIO(r.read()))
    dest.parent.mkdir(parents=True, exist_ok=True)
    compact(img).save(dest, optimize=True)
    print(f"{dest.relative_to(ROOT)}: {img.width}x{img.height}, {dest.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
