#!/usr/bin/env python3
"""Packs PixelLab map objects (made by Sean in the PixelLab app) into Sheet
sprites in assets/sprites/: <name>.png, <name>_mask.png and <name>.json, one
row per state, read by scripts/fx/sheet.gd.

Sources are art/pixellab/<dir>/<state>/: base.png (the still) and f00.png,
f01.png ... (its animation, if it has one). Fetch them with
  python3 tools/art/pixellab.py get objects            (list, with ids)
  python3 tools/art/pixellab.py get objects/<id>       (storage_urls, frames)
and curl each URL (the storage host refuses urllib).

The sources are 2x density (two sheet pixels per world pixel), like the hero.
Every state is cropped to the same box so the object never shifts between
states, and the origin is the bottom center of that box.

Usage: python3 tools/art/pixellab_objects.py
"""
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "sprites"

# name: (source dir, [(anim, state dir, fps)]). A state without frames is a still.
OBJECTS = {
    # The Fountain of Eolis, one state per restored spring (scripts/world/fountain.gd).
    "fountain": ("art/pixellab/eolis/fountain", [
        ("dry", "dry", 1),
        ("third", "third", 8),
        ("two_thirds", "two_thirds", 8),
        ("full", "full", 10),
    ]),
    # Market Row's four shops, each behind its keeper (scripts/world/set_piece.gd).
    # The smithy's frames are Sean's hand edit in Pixelorama (arms/forge_animation.pxo):
    # the building holds still and only the chimney smoke moves.
    "shop_arms": ("art/pixellab/eolis/shops", [("idle", "arms", 6)]),
    "shop_sundries": ("art/pixellab/eolis/shops", [("idle", "sundries", 1)]),
    "shop_dyeworks": ("art/pixellab/eolis/shops", [("idle", "dyeworks", 1)]),
    "shop_cartographer": ("art/pixellab/eolis/shops", [("idle", "cartographer", 1)]),
}
PAD = 2
# Pixel-art sheets keep a limited palette (bible 12.2; test_sheets_use_the_master_palette).
MAX_COLORS = 96


def frames_of(src: Path) -> list[Image.Image]:
    files = sorted(src.glob("f*.png")) or [src / "base.png"]
    return [Image.open(f).convert("RGBA") for f in files]


def limit_palette(sheet: Image.Image) -> Image.Image:
    """One shared palette of at most MAX_COLORS for every state and frame."""
    alpha = sheet.getchannel("A")
    rgb = Image.new("RGB", sheet.size, (0, 0, 0))
    rgb.paste(sheet.convert("RGB"), mask=alpha)
    # One slot goes to the black under the transparent pixels.
    q = rgb.quantize(colors=MAX_COLORS - 1, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    out = q.convert("RGBA")
    out.putalpha(alpha)
    return out


def pack(name: str, src_dir: str, states: list) -> None:
    rows = [(anim, frames_of(ROOT / src_dir / sub), fps) for anim, sub, fps in states]
    boxes = [f.getbbox() for _, fs, _ in rows for f in fs]
    size = rows[0][1][0].size
    left = max(min(b[0] for b in boxes) - PAD, 0)
    top = max(min(b[1] for b in boxes) - PAD, 0)
    right = min(max(b[2] for b in boxes) + PAD, size[0])
    bottom = max(b[3] for b in boxes)
    # Keep the box symmetric about the canvas center so the origin is centered.
    half = max(size[0] // 2 - left, right - size[0] // 2)
    left, right = size[0] // 2 - half, size[0] // 2 + half
    cell = (right - left, bottom - top)
    columns = max(len(fs) for _, fs, _ in rows)
    sheet = Image.new("RGBA", (cell[0] * columns, cell[1] * len(rows)))
    animations = {}
    for r, (anim, fs, fps) in enumerate(rows):
        for c, f in enumerate(fs):
            sheet.alpha_composite(f.crop((left, top, right, bottom)), (c * cell[0], r * cell[1]))
        animations[anim] = {
            "row": r, "frames": [{} for _ in fs], "seq": list(range(len(fs))),
            "fps": fps, "loop": True,
        }
    sheet = limit_palette(sheet)
    mask = Image.new("RGBA", sheet.size)
    mask.putalpha(sheet.getchannel("A").point(lambda a: 255 if a > 0 else 0))
    mask = Image.composite(Image.new("RGBA", sheet.size, (255, 255, 255, 255)), mask, mask)
    sheet.save(OUT / f"{name}.png")
    mask.save(OUT / f"{name}_mask.png")
    manifest = {
        "cell": list(cell), "origin": [cell[0] // 2, cell[1]], "columns": columns,
        "density": 2, "own_palette": True, "animations": animations,
    }
    (OUT / f"{name}.json").write_text(json.dumps(manifest, indent=1) + "\n")
    print(f"{name}: cell {cell}, {len(rows)} states, {columns} columns")


def main() -> None:
    for name, (src_dir, states) in OBJECTS.items():
        pack(name, src_dir, states)


if __name__ == "__main__":
    main()
