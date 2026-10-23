"""Shared pieces for the code-drawn character sheets (spritegen.py, castgen.py).

A Canvas is one animation frame: parts are rasterized at 1x into masks
(capsules, ellipses, polygons), each shaded with a top-left key light from a
master-palette ramp and separated from the parts behind it by a darker line,
and finish() adds the full outline. write_sheet() packs frames into a sheet,
a flat white silhouette sheet (hit flashes, afterimages) and a JSON file that
scripts/fx/sheet.gd reads.
"""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import autosprite_import  # noqa: E402
import palette  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
SPRITES = ROOT / "assets" / "sprites"

PAL = {}
for _name, _hue, _sat in palette.RAMPS:
    for _i in range(8):
        PAL[f"{_name}-{_i}"] = palette.shade(_hue, _sat, _i)

OUTLINE = PAL["night-0"]


def mat(ramp, hi, base, shadow, line):
    """A material: (highlight, base, shadow, separating line) from one ramp."""
    return tuple(PAL[f"{ramp}-{i}"] for i in (hi, base, shadow, line))


def nearest(hex_color, ramps=None):
    """(ramp, index) of the master palette color closest to `hex_color`, optionally
    only among `ramps`."""
    h = hex_color.lstrip("#")
    rgb = tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
    best = None
    for key, c in PAL.items():
        if ramps and key.split("-")[0] not in ramps:
            continue
        d = sum((a - b) ** 2 for a, b in zip(rgb, c))
        if best is None or d < best[0]:
            best = (d, key)
    ramp, idx = best[1].split("-")
    return ramp, int(idx)


def mat_from(hex_color, ramps=None):
    """A material around the palette color nearest `hex_color`."""
    ramp, i = nearest(hex_color, ramps)
    i = max(1, min(6, i))
    return mat(ramp, min(7, i + 1), i, i - 1, max(0, i - 3))


def shifted(mask, dx, dy):
    """mask moved by (dx, dy); pixels shifted in from outside are False."""
    out = np.zeros_like(mask)
    h, w = mask.shape
    xs0, xs1 = max(0, dx), min(w, w + dx)
    ys0, ys1 = max(0, dy), min(h, h + dy)
    out[ys0:ys1, xs0:xs1] = mask[ys0 - dy:ys1 - dy, xs0 - dx:xs1 - dx]
    return out


def neighbors4(mask):
    return shifted(mask, 1, 0) | shifted(mask, -1, 0) | shifted(mask, 0, 1) | shifted(mask, 0, -1)


def ik(a, b, l1, l2, bend):
    """The middle joint of a two-bone limb from a to b. bend +1 puts it forward (+x)."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = max(0.001, math.hypot(dx, dy))
    d_c = min(d, l1 + l2 - 0.01)
    cos_a = (l1 * l1 + d_c * d_c - l2 * l2) / (2 * l1 * d_c)
    ang = math.acos(max(-1.0, min(1.0, cos_a)))
    base = math.atan2(dy, dx)
    c1 = base + ang
    c2 = base - ang
    j1 = (a[0] + math.cos(c1) * l1, a[1] + math.sin(c1) * l1)
    j2 = (a[0] + math.cos(c2) * l1, a[1] + math.sin(c2) * l1)
    return j1 if (j1[0] - j2[0]) * bend >= 0 else j2


def reach(a, b, length):
    """b pulled to within `length` of a."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy)
    if d <= length:
        return b
    return (a[0] + dx / d * length, a[1] + dy / d * length)


class Canvas:
    """One frame. Points are relative to `origin` (the node's origin in game).
    Sizes, points and radii are in world pixels; `scale` rasterizes them at that
    many pixels per world pixel (2 for the 2x render density, design bible 12.1),
    so lines, outlines and shading come out finer at the same world size."""

    def __init__(self, w, h, origin, scale=1):
        self.scale = scale
        self.w, self.h = w * scale, h * scale
        self.origin = origin
        ys, xs = np.mgrid[0:self.h, 0:self.w]
        self.gx, self.gy = (xs + 0.5) / scale, (ys + 0.5) / scale
        self.rgb = np.zeros((self.h, self.w, 3), np.uint8)
        self.filled = np.zeros((self.h, self.w), bool)

    def to_cell(self, p):
        return (self.origin[0] + p[0], self.origin[1] + p[1])

    def capsule(self, a, b, r):
        a, b = self.to_cell(a), self.to_cell(b)
        ax, ay = a
        dx, dy = b[0] - ax, b[1] - ay
        L2 = dx * dx + dy * dy
        if L2 == 0:
            t = np.zeros_like(self.gx)
        else:
            t = np.clip(((self.gx - ax) * dx + (self.gy - ay) * dy) / L2, 0.0, 1.0)
        px, py = ax + t * dx, ay + t * dy
        return (self.gx - px) ** 2 + (self.gy - py) ** 2 <= r * r

    def ellipse(self, c, rx, ry):
        cx, cy = self.to_cell(c)
        return ((self.gx - cx) / rx) ** 2 + ((self.gy - cy) / ry) ** 2 <= 1.0

    def polygon(self, points):
        img = Image.new("L", (self.w, self.h), 0)
        k = self.scale
        ImageDraw.Draw(img).polygon([(x * k, y * k) for x, y in (self.to_cell(p) for p in points)], fill=255)
        return np.array(img) > 0

    def right_of(self, x):
        return self.gx > self.to_cell((x, 0))[0]

    def below(self, y):
        return self.gy > self.to_cell((0, y))[1]

    def part(self, mask, material, deep=False):
        """Paints one shaded part over what is already there."""
        if not mask.any():
            return
        hi, base, shadow, line = material
        # A darker line where this part overlaps parts behind it.
        edge = neighbors4(mask) & ~mask & self.filled
        self.rgb[edge] = line
        self.rgb[mask] = base
        # Key light from the top left: lit where the pixel above or to the left is open.
        lit = mask & (~shifted(mask, 0, 1) | ~shifted(mask, 1, 0))
        dark = mask & (~shifted(mask, 0, -1) | ~shifted(mask, -1, 0))
        if deep:
            dark |= mask & ~shifted(mask, -2, 0)
        self.rgb[dark] = shadow
        self.rgb[lit & ~dark] = hi
        self.filled |= mask

    def flat(self, mask, color):
        """Paints a mask one color (eyes, markings), unshaded."""
        self.rgb[mask] = color
        self.filled |= mask

    def pixel(self, p, color):
        """One world pixel (scale x scale image pixels)."""
        c = self.to_cell(p)
        k = self.scale
        x0, y0 = int(math.floor(c[0])) * k, int(math.floor(c[1])) * k
        for y in range(y0, y0 + k):
            for x in range(x0, x0 + k):
                if 0 <= x < self.w and 0 <= y < self.h:
                    self.rgb[y, x] = color
                    self.filled[y, x] = True

    def finish(self):
        outline = neighbors4(self.filled) & ~self.filled
        img = np.zeros((self.h, self.w, 4), np.uint8)
        img[self.filled, :3] = self.rgb[self.filled]
        img[self.filled, 3] = 255
        img[outline, :3] = OUTLINE
        img[outline, 3] = 255
        mask = np.zeros((self.h, self.w, 4), np.uint8)
        mask[self.filled | outline] = (255, 255, 255, 255)
        return Image.fromarray(img, "RGBA"), Image.fromarray(mask, "RGBA")


def write_sheet(name, cell, origin, animations, render, density=1):
    """animations: [(anim name, [frame specs], playback sequence, fps, loop)].
    render(spec) -> (sheet image, mask image, per-frame metadata dict).
    `cell` and `origin` are in world pixels; `density` is how many pixels per
    world pixel the code-drawn frames were rasterized at (Canvas scale)."""
    SPRITES.mkdir(parents=True, exist_ok=True)
    # Render the code-drawn frames, then swap in any Autosprite imports (autosprite_import.py).
    # A sheet with imports at density 2 is written at double size; 1x code-drawn frames
    # are blown up to match and the metadata stays in world pixels.
    d = max(density, autosprite_import.density(name))
    cell, origin = (cell[0] * d, cell[1] * d), (origin[0] * d, origin[1] * d)
    cw, ch = cell
    rendered = []
    for anim, frames, seq, fps, loop in animations:
        out = []
        for spec in frames:
            img, mask, fmeta = render(spec)
            if img.size != (cw, ch):
                img = img.resize((cw, ch), Image.NEAREST)
                mask = mask.resize((cw, ch), Image.NEAREST)
            out.append((img, mask, fmeta))
        rendered.append([anim, out, seq, fps, loop])
    imports = autosprite_import.imported(name, cell, origin, {r[0]: [f[2] for f in r[1]] for r in rendered})
    for r in rendered:
        if r[0] in imports:
            frames, seq, fps, loop = imports[r[0]]
            rig_frames = len(r[1])
            r[1] = frames
            # The code rig's playback order only fits a clip with as many frames as the rig;
            # a longer clip (a 12-frame walk for a 4-frame rig) plays every frame.
            r[2] = seq or (r[2] if len(frames) == rig_frames else list(range(len(frames))))
            r[3] = fps or r[3]
            r[4] = r[4] if loop is None else loop
    cols = max(len(frames) for _, frames, _, _, _ in rendered)
    rows = len(rendered)
    sheet = Image.new("RGBA", (cols * cw, rows * ch), (0, 0, 0, 0))
    masks = Image.new("RGBA", (cols * cw, rows * ch), (0, 0, 0, 0))
    meta = {"cell": [cw, ch], "origin": list(origin), "columns": cols, "animations": {}}
    if d > 1:
        meta["density"] = d
    if autosprite_import.own_colors(name):
        # The imported frames use the sheet's own palette (design bible 12.2), plus the
        # master outline and any master ramps the code-drawn frames use.
        meta["own_palette"] = True
    flags = autosprite_import.flags(name)
    if flags:
        meta["flags"] = flags
    for row, (anim, frames, seq, fps, loop) in enumerate(rendered):
        assert max(seq) < len(frames), (name, anim)
        info = []
        for col, (img, mask, fmeta) in enumerate(frames):
            sheet.paste(img, (col * cw, row * ch))
            masks.paste(mask, (col * cw, row * ch))
            info.append(fmeta)
        meta["animations"][anim] = {"row": row, "frames": info, "seq": seq, "fps": fps, "loop": loop}
    sheet.save(SPRITES / f"{name}.png")
    masks.save(SPRITES / f"{name}_mask.png")
    (SPRITES / f"{name}.json").write_text(json.dumps(meta, indent=1) + "\n")
    print(f"{name}: {rows} animations, {cols} columns")
