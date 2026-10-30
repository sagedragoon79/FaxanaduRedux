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
# Each set's four attacks again with the other blades (Sean: swords are drawn into the attacks),
# from its state holding that blade: sheet "hero_<set>_<blade>".
for _set in ("base", "leather", "studded", "plate", "battle", "battle_helm"):
    for _blade in ("long_sword", "broad_sword", "dragon_slayer"):
        # The set's own idle too, as the importer's reference for scale (it never plays from here).
        SHEETS[f"hero_{_set}_{_blade}"] = {"idle.png": SHEETS[f"hero_{_set}"]["idle.png"], **{
            f"{clip}.png": f"hero/{_set}/{_blade}/{clip}" for clip in ("slash1", "slash2", "slash3", "slash_up")}}
# Retakes that came out better: pogos that stay in the air, and a first slash in profile.
SHEETS["hero_leather"]["pogo.png"] = "hero/leather/pogo_air3"
SHEETS["hero_studded"]["pogo.png"] = "hero/studded/pogo_air9"
SHEETS["hero_plate"]["pogo.png"] = "hero/plate/pogo_air9"
SHEETS["hero_battle"]["pogo.png"] = "hero/battle/pogo_air3"
SHEETS["hero_battle"]["slash1.png"] = "hero/battle/slash1b"
SHEETS["hero_battle_helm"]["pogo.png"] = "hero/battle_helm/pogo_air3"


def frames_of(folder):
    return sorted(p for p in (SOURCES / folder).glob("[0-9][0-9].png"))


# PixelLab sometimes leaves a flat grey slab behind a smear or a cloak (one exact neutral grey,
# about (130, 128, 130)). Any patch of it bigger than this is erased; small specks may be armor.
SLAB_MIN = 150


def clear_slabs(im):
    px = im.load()
    w, h = im.size

    def slab(c):
        return c[3] > 0 and 120 <= c[1] <= 140 and abs(c[0] - c[1]) <= 4 and abs(c[2] - c[1]) <= 4

    seen = set()
    for y in range(h):
        for x in range(w):
            if (x, y) in seen or not slab(px[x, y]):
                continue
            patch, todo = [], [(x, y)]
            seen.add((x, y))
            while todo:
                cx, cy = todo.pop()
                patch.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and slab(px[nx, ny]):
                        seen.add((nx, ny))
                        todo.append((nx, ny))
            if len(patch) >= SLAB_MIN:
                for q in patch:
                    px[q] = (0, 0, 0, 0)
    return im


def pack(paths):
    strip = Image.new("RGBA", (CELL * len(paths), CELL))
    for i, p in enumerate(paths):
        im = clear_slabs(Image.open(p).convert("RGBA"))
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
