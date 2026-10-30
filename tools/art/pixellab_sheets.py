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
CLIPS = (("idle.png", "idle"), ("run.png", "run"), ("walk.png", "walk"), ("jump.png", "jump"),
         ("pogo.png", "pogo"), ("mattock_swing.png", "swing"), ("slash1.png", "slash1"),
         ("slash2.png", "slash2"), ("slash3.png", "slash3"), ("slash_up.png", "slash_up"),
         ("dash.png", "dash"), ("wall.png", "wall"), ("hurt.png", "hurt"), ("death.png", "death"),
         ("drink.png", "drink"), ("cast.png", "cast"))
SETS = ("base", "leather", "studded", "plate", "battle", "battle_helm")

# The bare elf and the armor tiers (character states of Sean's elf, design bible 13.5), each with
# the cloak drawn in a key green the game dyes: clips made from the set's cloaked state, its state
# holding the Short Sword (attacks) and holding the Mattock (pogo and swing).
SHEETS = {"hero_" + s: {strip: f"hero/{s}_cloak/{clip}" for strip, clip in CLIPS} for s in SETS}
# Each set's four attacks again with the other blades (Sean: swords are drawn into the attacks),
# from its state holding that blade: sheet "hero_<set>_<blade>".
for _set in SETS:
    for _blade in ("long_sword", "broad_sword", "dragon_slayer"):
        # The set's own idle too, as the importer's reference for scale (it never plays from here).
        SHEETS[f"hero_{_set}_{_blade}"] = {"idle.png": SHEETS[f"hero_{_set}"]["idle.png"], **{
            f"{clip}.png": f"hero/{_set}_cloak/{_blade}/{clip}" for clip in ("slash1", "slash2", "slash3", "slash_up")}}

# Each set's block, from its state holding each shield up to guard (the shields are drawn in):
# sheet "hero_<set>_<shield>", the block and the set's idle as the importer's reference.
for _set in SETS:
    for _shield in ("small_shield", "large_shield", "magic_shield"):
        SHEETS[f"hero_{_set}_{_shield}"] = {"idle.png": SHEETS[f"hero_{_set}"]["idle.png"],
                                             "block.png": f"hero/{_set}_cloak/{_shield}/block"}

# Retakes where the first take's cloak dropped out of the frame (drawn as an empty outline).
SHEETS["hero_plate"].update({"run.png": "hero/plate_cloak/run_r1", "walk.png": "hero/plate_cloak/walk_r1",
                             "drink.png": "hero/plate_cloak/drink_r2", "hurt.png": "hero/plate_cloak/hurt_r1",
                             "slash1.png": "hero/plate_cloak/slash1_r1"})
SHEETS["hero_studded"]["walk.png"] = "hero/studded_cloak/walk_r2"
SHEETS["hero_battle_helm"].update({"walk.png": "hero/battle_helm_cloak/walk_r2", "slash2.png": "hero/battle_helm_cloak/slash2_r1"})
SHEETS["hero_battle_helm_dragon_slayer"]["slash1.png"] = "hero/battle_helm_cloak/dragon_slayer/slash1_r1"
# The Large Shield again on every set but the base, to match its crimson face and silver rim
# (the first takes drew it plain steel or dark), and blocks whose cloak dropped out.
for _set in ("leather", "studded", "plate", "battle", "battle_helm"):
    SHEETS[f"hero_{_set}_large_shield"]["block.png"] = f"hero/{_set}_cloak/large_shield/block_r1"
for _set in ("leather", "battle"):
    SHEETS[f"hero_{_set}_magic_shield"]["block.png"] = f"hero/{_set}_cloak/magic_shield/block_r1"
SHEETS["hero_base_magic_shield"]["block.png"] = "hero/base_cloak/magic_shield/block_r2"


def frames_of(folder):
    return sorted(p for p in (SOURCES / folder).glob("[0-9][0-9].png"))


# PixelLab sometimes leaves a flat grey slab behind a smear or a cloak: a big patch of dull grey,
# often one exact colour (about (130, 128, 130), (150, 142, 146), (128, 130, 126) or the bluer (119, 135, 142)) with a few
# mottled neighbours. A connected patch of dull grey is erased when it is bigger than SLAB_MIN and
# mostly one flat colour; the armor's steel is shaded, so no one colour dominates that much of it.
SLAB_MIN = 400
SLAB_FLAT = 0.5


def is_slab_grey(c):
    r, g, b, a = c
    # Not green-cast: the tunic's dull green is never a slab.
    return a > 0 and 95 <= max(r, g, b) <= 160 and max(r, g, b) - min(r, g, b) <= 32 and g <= max(r, b) + 4


def clear_slabs(im):
    px = im.load()
    w, h = im.size
    seen = set()
    for y in range(h):
        for x in range(w):
            if (x, y) in seen or not is_slab_grey(px[x, y]):
                continue
            patch, todo, counts = [], [(x, y)], {}
            seen.add((x, y))
            while todo:
                cx, cy = todo.pop()
                patch.append((cx, cy))
                counts[px[cx, cy]] = counts.get(px[cx, cy], 0) + 1
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and is_slab_grey(px[nx, ny]):
                        seen.add((nx, ny))
                        todo.append((nx, ny))
            if len(patch) >= SLAB_MIN and max(counts.values()) >= SLAB_FLAT * len(patch):
                for q in patch:
                    px[q] = (0, 0, 0, 0)
    return im


# A slab that touches the shaded steel floods into it and fails the flatness test above. In the
# takes listed here a large connected patch of one exact grey is erased on its own (not
# everywhere: the Broad Sword's blade and some tunics are flat greys that size).
FLAT_MIN = 600
FLAT_SLABS = {"hero/plate_cloak/large_shield/block_r1"}


def clear_flat(im):
    px = im.load()
    w, h = im.size
    seen = set()
    for y in range(h):
        for x in range(w):
            c = px[x, y]
            if (x, y) in seen or c[3] == 0 or not (95 <= max(c[:3]) <= 170 and max(c[:3]) - min(c[:3]) <= 40):
                continue
            patch, todo = [], [(x, y)]
            seen.add((x, y))
            while todo:
                cx, cy = todo.pop()
                patch.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and px[nx, ny] == c:
                        seen.add((nx, ny))
                        todo.append((nx, ny))
            if len(patch) >= FLAT_MIN:
                for q in patch:
                    px[q] = (0, 0, 0, 0)


def pack(paths):
    strip = Image.new("RGBA", (CELL * len(paths), CELL))
    for i, p in enumerate(paths):
        im = clear_slabs(Image.open(p).convert("RGBA"))
        if p.parent.relative_to(SOURCES).as_posix() in FLAT_SLABS:
            clear_flat(im)
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
