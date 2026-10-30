#!/usr/bin/env python3
"""Builds the Battle Helmet layer from the PixelLab helmed elf (design bible 13.4, 13.5).

The Battle Suit worn under the Battle Helmet has a body set of its own, drawn helmed in
PixelLab (hero_battle_helm). With any other set the helmet is a layer on the head, and it is
cut from that same art so the two match: the helm's steel in the first frame of the helmed
idle (art/pixellab/hero/battle_helm_cloak/idle/00.png), the connected pale steel from the
crest down to the cheek guards, with the face and ear it frames (over another set the bare
head's hair would show through the opening).

It is scaled as the importer scales the hero sets (their 46 px figure at the 2x render
density, design bible 12.1), hardened to a 1-bit alpha, given the dark sprite outline,
reduced to a small palette and written to assets/sprites/battle_helmet.png. The player draws
it with its top-left PlayerVisual.HELMET_OFFSET from the frame's crown; this prints that
offset, measured on the bare Battle Suit's idle, whose head lies where the helm's does.

The earlier layer, Sean's pixel helmet for the Autosprite hero, stays in art/battle_helmet/.

Usage: python3 tools/art/helmetgen.py
"""
import colorsys
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from autosprite_import import head_point  # noqa: E402

HELMED = ROOT / "art/pixellab/hero/battle_helm_cloak/idle/00.png"
BARE = ROOT / "art/pixellab/hero/battle_cloak/idle/00.png"
OUT = ROOT / "assets/sprites/battle_helmet.png"
## The hero sets' figure height in sheet pixels (46 world px at density 2).
FIGURE = 92
## The helm reaches no lower than this source row (its cheek guards); below is the collar.
HELM_BOTTOM = 52
OUTLINE = (18, 15, 25, 255)
COLORS = 20


def steel(p) -> bool:
    if p[3] == 0:
        return False
    _, s, v = colorsys.rgb_to_hsv(*(q / 255 for q in p[:3]))
    return s < 0.3 and v > 0.3


def helm_mask(img: Image.Image) -> np.ndarray:
    """The helm: steel connected to the topmost steel pixel, above HELM_BOTTOM."""
    px = img.load()
    w, h = img.size
    seed = next((x, y) for y in range(h) for x in range(w) if steel(px[x, y]))
    keep = {seed}
    todo = [seed]
    while todo:
        x, y = todo.pop()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny <= HELM_BOTTOM and (nx, ny) not in keep and steel(px[nx, ny]):
                keep.add((nx, ny))
                todo.append((nx, ny))
    mask = np.zeros((h, w), bool)
    for x, y in keep:
        mask[y, x] = True
    # The face and ear inside it too, as drawn under the helm: over another set the bare
    # head's hair would show through the opening. Not the purple scarf or the green cloak.
    ys, xs = np.nonzero(mask)
    for y in range(ys.min(), HELM_BOTTOM + 1):
        row = xs[ys == y]
        if len(row) == 0:
            continue
        for x in range(row.min(), w):
            p = px[x, y]
            if p[3] == 0 and x > row.max():
                break
            hue, sat, _ = colorsys.rgb_to_hsv(*(q / 255 for q in p[:3]))
            if p[3] > 0 and not (sat > 0.5 and (0.7 <= hue <= 0.9 or 0.25 <= hue <= 0.42)):
                mask[y, x] = True
    return mask


def scale_of(img: Image.Image) -> float:
    _, y0, _, y1 = img.getbbox()
    return FIGURE / float(y1 - y0)


def small(img: Image.Image, s: float) -> Image.Image:
    return img.resize((round(img.width * s), round(img.height * s)), Image.BOX)


def build():
    """(layer image, its top-left from the bare head's crown in world px)."""
    helmed = Image.open(HELMED).convert("RGBA")
    bare = Image.open(BARE).convert("RGBA")
    s = scale_of(bare)
    a = np.asarray(helmed).copy()
    a[~helm_mask(helmed)] = 0
    helm = small(Image.fromarray(a), s)
    arr = np.asarray(helm).astype(float)
    x0, y0, x1, y1 = helm.getbbox()
    arr = arr[y0:y1, x0:x1]
    solid = arr[..., 3] > 110
    rgb = np.where(arr[..., 3:4] > 0, arr[..., :3], 0).clip(0, 255).astype("uint8")
    rgb = np.asarray(Image.fromarray(rgb).quantize(COLORS, method=Image.Quantize.MEDIANCUT).convert("RGB"))
    h, w = solid.shape
    out = np.zeros((h + 2, w + 2, 4), "uint8")
    pad = np.pad(solid, 1)
    ring = np.zeros_like(pad)
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        ring |= np.roll(np.roll(pad, dx, 1), dy, 0)
    out[ring & ~pad] = OUTLINE
    inner = out[1:-1, 1:-1]
    inner[solid, :3] = rgb[solid]
    inner[solid, 3] = 255
    cx, cy = head_point(small(bare, s))
    # The layer's top-left (its outline) from the crown, in world px (half a sheet px).
    offset = ((x0 - 1 - int(cx)) / 2.0, (y0 - 1 - int(cy)) / 2.0)
    return Image.fromarray(out), offset


def main() -> None:
    img, offset = build()
    img.save(OUT)
    print("wrote", OUT.relative_to(ROOT), img.size, "HELMET_OFFSET", offset)


if __name__ == "__main__":
    main()
