#!/usr/bin/env python3
"""Packs PixelLab clips (one PNG per frame, as tools/art/pixellab.py saves them) into the strip
sheets the sprite importer reads (tools/art/autosprite_import.py), so PixelLab characters go
through the same import as Autosprite ones: scale, palette, outline, rim light and anchors.

Each strip is one row of 256 px cells, frames in order. The manifest entry points its "dir" at
the strip folder (relative to art/autosprite/, so "../pixellab/sheets/hero_base") and picks
frames from the strips as usual.

Usage: python3 tools/art/pixellab_sheets.py      rebuilds every strip in SHEETS
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "art" / "pixellab"
OUT = SOURCES / "sheets"
CELL = 256

# sheet -> {strip file: clip folder under art/pixellab/ (frames 00.png, 01.png ...)}
SHEETS = {
    "hero_base": {
        "idle.png": "hero/sample/idle_v3",
        "run.png": "hero/base/run",
        "walk.png": "hero/base/walk_mm",
        "jump.png": "hero/sample/jump_mm",
        "pogo.png": "mattock/pogo_mm",
        "mattock_swing.png": "mattock/swing_mm",
        "slash1.png": "hero/base/slash1b",
        "slash2.png": "hero/base/slash2b",
        "slash3.png": "hero/base/slash3",
        "slash_up.png": "hero/base/slash_up",
        "dash.png": "hero/base/dash",
        "wall.png": "hero/base/wall",
        "hurt.png": "hero/base/hurt",
        "death.png": "hero/base/death",
        "drink.png": "hero/base/drink",
        "cast.png": "hero/base/cast",
    },
}

# The armor tiers (character states of Sean's elf, design bible 13.5): the same clips, made from
# the armor's own state, its state holding the Short Sword (attacks) and holding the Mattock.
for _armor in ("leather", "studded", "plate", "battle", "battle_helm"):
    SHEETS["hero_" + _armor] = {strip: f"hero/{_armor}/{clip}" for strip, clip in (
        ("idle.png", "idle"), ("run.png", "run"), ("walk.png", "walk"), ("jump.png", "jump"),
        ("pogo.png", "pogo"), ("mattock_swing.png", "swing"), ("slash1.png", "slash1"),
        ("slash2.png", "slash2"), ("slash3.png", "slash3"), ("slash_up.png", "slash_up"),
        ("dash.png", "dash"), ("wall.png", "wall"), ("hurt.png", "hurt"), ("death.png", "death"),
        ("drink.png", "drink"), ("cast.png", "cast"))}
# Retakes that came out better: pogos that stay in the air, and a first slash in profile.
SHEETS["hero_leather"]["pogo.png"] = "hero/leather/pogo_air3"
SHEETS["hero_studded"]["pogo.png"] = "hero/studded/pogo_air9"
SHEETS["hero_plate"]["pogo.png"] = "hero/plate/pogo_air9"
SHEETS["hero_battle"]["pogo.png"] = "hero/battle/pogo_air3"
SHEETS["hero_battle"]["slash1.png"] = "hero/battle/slash1b"
SHEETS["hero_battle_helm"]["pogo.png"] = "hero/battle_helm/pogo_air3"


def frames_of(folder):
    return sorted(p for p in (SOURCES / folder).glob("[0-9][0-9].png"))


def pack(paths):
    strip = Image.new("RGBA", (CELL * len(paths), CELL))
    for i, p in enumerate(paths):
        im = Image.open(p).convert("RGBA")
        # PixelLab clips are 256 px canvases; a smaller one is centred on the cell's floor.
        strip.alpha_composite(im, (i * CELL + (CELL - im.width) // 2, CELL - im.height))
    return strip


def main():
    for sheet, strips in SHEETS.items():
        dest = OUT / sheet
        dest.mkdir(parents=True, exist_ok=True)
        for name, folder in strips.items():
            paths = frames_of(folder)
            if not paths:
                print(f"{sheet}/{name}: no frames in art/pixellab/{folder}, skipped")
                continue
            pack(paths).save(dest / name)
            print(f"{sheet}/{name}: {len(paths)} frames")


if __name__ == "__main__":
    main()
