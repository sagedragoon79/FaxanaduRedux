#!/usr/bin/env python3
"""Packs Autosprite animation sheets into the game's sheet format (design bible 13.1 to 13.3).

Autosprite renders smooth, high-resolution frames (usually 256x256). This turns them into
game frames: the figure is scaled so a reference frame matches a target height, area-averaged
down, cut to a hard alpha edge, mapped onto the master palette (only the ramps the character
uses), its dark anti-aliased rim is dropped and it gets the same 1 px full outline as the
code-drawn sprites (12.3). The feet land on the sheet's origin, so the frames line up with the
code-drawn ones and the game code does not change.

Sources live in art/autosprite/<dir>/ (the downloaded sheet PNGs, kept so the import is
reproducible without spending credits) and art/autosprite/manifest.json says which
animations of which sheet they replace:

  "player": {                         sheet name in assets/sprites/
    "dir": "elf",
    "ramps": ["night", "bark", ...],  palette ramps the figure may use
    "height": 42,                     reference figure height in px, before the outline
    "reference": "idle",              animation whose first picked frame sets the scale
    "animations": {
      "idle": {"file": "idle.png", "frame_size": 256, "columns": 4, "count": 16,
               "pick": [0, 4, 8, 12],    source frames to keep (default: all)
               "seq": [...], "fps": 8, "loop": true,   playback (default: the code rig's)
               "anchor": "ground",       "ground": each frame's lowest pixel on the origin;
                                         "fixed": the reference frame's feet (jumps, deaths)
               "feet_x": "self",         "self": find the feet in this sheet's first picked frame
                                         (attack moves come in 512 px cells, figure bottom-centre)
               "drop": ["blade"],        code-rig metadata keys to leave out (the clip draws the sword)
               "meta": {"art_prop": true},  keys added to every frame's metadata
               "extra_ramps": ["stone"], more palette ramps for this animation (a steel blade)
               "erase": [170, 250],      hue range (degrees) to cut out first, e.g. a spell glow
                                         the game draws itself
               "erase_white": true}      also cut out the glow's near-white core
    }
  }

pixelrig.write_sheet() calls imported() for every sheet it writes, so spritegen.py and
castgen.py pick up the imported animations and keep the code-drawn ones for the rest.
Per-frame metadata (hand, neck, blade, eye...) comes from the code rig's frame at the same
point of the animation; for the player, the neck and front hand are found in the pixels.

Usage: python3 tools/art/autosprite_import.py             reruns spritegen.py and castgen.py
       python3 tools/art/autosprite_import.py --loop elf/run.png [min max]
                                                          finds the cleanest loop (start, length) in a
                                                          full-rate sheet, for the manifest's "pick"
       python3 tools/art/autosprite_import.py --selftest  round trip: blows the code-drawn run up to a
                                                          fake 256 px sheet, imports it, checks the result
"""
import json
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import palette  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "art" / "autosprite"
MANIFEST = SOURCES / "manifest.json"

PAL = {}
for _name, _hue, _sat in palette.RAMPS:
    for _i in range(8):
        PAL[f"{_name}-{_i}"] = palette.shade(_hue, _sat, _i)
OUTLINE = PAL["night-0"]


def _lab(rgb):
    """sRGB (..., 3) uint8 -> CIE Lab, for perceptual nearest-color matching."""
    c = np.asarray(rgb, np.float64) / 255.0
    c = np.where(c > 0.04045, ((c + 0.055) / 1.055) ** 2.4, c / 12.92)
    m = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ m.T / np.array([0.9505, 1.0, 1.089])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)


def load_manifest():
    if not MANIFEST.exists():
        return {}
    return json.loads(MANIFEST.read_text())


def source_frames(spec, src_dir):
    """The picked frames of one Autosprite sheet as float RGBA arrays (premultiplied)."""
    sheet = Image.open(src_dir / spec["file"]).convert("RGBA")
    n = spec["frame_size"]
    cols = spec.get("columns", sheet.width // n)
    count = spec.get("count", cols * (sheet.height // n))
    out = []
    for i in spec.get("pick", range(count)):
        x, y = (i % cols) * n, (i // cols) * n
        a = np.asarray(sheet.crop((x, y, x + n, y + n)), np.float64) / 255.0
        a[..., :3] *= a[..., 3:4]
        out.append(a)
    return out


def _bbox(alpha, cut=0.5):
    ys, xs = np.nonzero(alpha >= cut)
    if len(ys) == 0:
        return None
    return xs.min(), ys.min(), xs.max(), ys.max()


def _shifted(mask, dx, dy):
    out = np.zeros_like(mask)
    h, w = mask.shape
    out[max(0, dy):min(h, h + dy), max(0, dx):min(w, w + dx)] = \
        mask[max(0, -dy):min(h, h - dy), max(0, -dx):min(w, w - dx)]
    return out


def _n4(mask):
    return _shifted(mask, 1, 0) | _shifted(mask, -1, 0) | _shifted(mask, 0, 1) | _shifted(mask, 0, -1)


def _erase_hue(src, lo, hi, white=False):
    """Clears saturated pixels whose hue lies in [lo, hi] degrees (premultiplied RGBA), and
    with `white` the near-white core of a glow too."""
    a = src[..., 3:4]
    rgb = np.where(a > 1e-6, src[..., :3] / np.maximum(a, 1e-6), 0)
    mx, mn = rgb.max(-1), rgb.min(-1)
    c = mx - mn
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    safe = np.maximum(c, 1e-6)
    h = np.where(mx == r, ((g - b) / safe) % 6, np.where(mx == g, (b - r) / safe + 2, (r - g) / safe + 4)) * 60
    sat = c / np.maximum(mx, 1e-6)
    out = src.copy()
    gone = (h >= lo) & (h <= hi) & (sat > 0.25) & (c > 0.12)
    if white:
        gone |= (sat < 0.15) & (mx > 0.8)
    out[gone] = 0
    return out


class Importer:
    def __init__(self, name, cfg, cell, origin):
        self.name, self.cfg = name, cfg
        self.cell, self.origin = cell, origin
        self.dir = SOURCES / cfg["dir"]
        self.use_ramps(cfg["ramps"])
        ref = cfg["animations"][cfg.get("reference", "idle")]
        frame = source_frames(ref, self.dir)[0]
        x0, y0, x1, y1 = _bbox(frame[..., 3])
        self.scale = cfg["height"] / float(y1 - y0 + 1)
        # The reference feet: bottom of the figure, centered on its lowest rows.
        self.ref_x = self.feet_x(frame)
        self.ref_y = y1 + 1.0

    def use_ramps(self, ramps):
        self.keys = [k for k in PAL if k.split("-")[0] in ramps]
        self.colors = np.array([PAL[k] for k in self.keys], np.uint8)
        self.lab = _lab(self.colors)

    def quantize(self, rgb):
        d = ((_lab(rgb)[:, None, :] - self.lab[None, :, :]) ** 2).sum(-1)
        return d.argmin(1)

    @staticmethod
    def feet_x(frame):
        """The middle of the figure's lowest rows, in source pixels."""
        x0, y0, x1, y1 = _bbox(frame[..., 3])
        bottom = frame[..., 3][max(y0, y1 - 6):y1 + 1] >= 0.5
        xs = np.nonzero(bottom.any(0))[0]
        return (xs.min() + xs.max() + 1) / 2.0

    def frame(self, src, anchor, ref_x=None):
        """One source frame -> (RGBA image, white mask image, palette key grid)."""
        n = src.shape[0]
        s = self.scale
        size = max(1, int(round(n * s)))
        # Area-average the premultiplied frame down to game scale.
        chans = [np.asarray(Image.fromarray(src[..., c].astype(np.float32), "F")
                            .resize((size, size), Image.BOX)) for c in range(4)]
        small = np.stack(chans, -1)
        alpha = small[..., 3]
        rgb = np.where(alpha[..., None] > 1e-6, small[..., :3] / np.maximum(alpha[..., None], 1e-6), 0)
        # Where the frame lands in the cell: the reference feet (scaled) on the origin.
        fy = self.ref_y
        if anchor == "ground":
            box = _bbox(src[..., 3])
            fy = box[3] + 1.0 if box else fy
        ox = int(round(self.origin[0] - (self.ref_x if ref_x is None else ref_x) * s))
        oy = int(round(self.origin[1] - fy * s))
        cw, ch = self.cell
        solid = np.zeros((ch, cw), bool)
        keys = np.full((ch, cw), -1, np.int32)
        ys, xs = np.nonzero(alpha >= 0.5)
        cx, cy = xs + ox, ys + oy
        ok = (cx >= 1) & (cx < cw - 1) & (cy >= 1) & (cy < ch - 1)
        ys, xs, cx, cy = ys[ok], xs[ok], cx[ok], cy[ok]
        solid[cy, cx] = True
        keys[cy, cx] = self.quantize((rgb[ys, xs] * 255).clip(0, 255))
        # Drop lone pixels, then the dark anti-aliased rim the outline replaces.
        lone = solid & ~(_shifted(solid, 1, 0) | _shifted(solid, -1, 0) | _shifted(solid, 0, 1) | _shifted(solid, 0, -1))
        solid &= ~lone
        dark = np.isin(keys, [i for i, k in enumerate(self.keys) if k in ("night-0", "night-1")])
        rim = solid & _n4(~solid) & dark
        solid &= ~rim
        outline = _n4(solid) & ~solid
        img = np.zeros((ch, cw, 4), np.uint8)
        img[solid, :3] = self.colors[keys[solid]]
        img[solid, 3] = 255
        img[outline, :3] = OUTLINE
        img[outline, 3] = 255
        mask = np.zeros((ch, cw, 4), np.uint8)
        mask[solid | outline] = 255
        grid = np.full((ch, cw), "", object)
        grid[solid] = np.array(self.keys, object)[keys[solid]]
        return Image.fromarray(img, "RGBA"), Image.fromarray(mask, "RGBA"), grid

    def to_point(self, x, y):
        return [int(x - self.origin[0]), int(y - self.origin[1])]

    def detect(self, grid, meta):
        """The player's neck (top of the tunic) and front hand (forward-most skin away from the face)."""
        meta = dict(meta)
        tunic = np.vectorize(lambda k: k.startswith("leaf-"))(grid)
        if tunic.any():
            # The first row with a real run of tunic, so stray green pixels in the hair don't count.
            rows = np.nonzero(tunic.sum(1) >= 3)[0]
            if len(rows) == 0:
                return meta
            top = rows.min()
            neck_x = np.nonzero(tunic[top])[0].mean()
            meta["neck"] = self.to_point(round(neck_x), top - 1)
            skin = np.vectorize(lambda k: k in ("bark-5", "bark-6", "bark-7"))(grid)
            skin[:top + 2] = False
            if skin.any():
                sy, sx = np.nonzero(skin)
                front = sx.max()
                pick = sx >= front - 1
                meta["hand"] = self.to_point(round(sx[pick].mean()), round(sy[pick].mean()))
        return meta


def imported(name, cell, origin, code_meta):
    """{anim: (frames [(img, mask, meta)], seq or None, fps or None, loop or None)} for the
    animations of sheet `name` that have Autosprite sources. `code_meta` is the code rig's
    {anim: [per-frame metadata]} to carry over."""
    cfg = load_manifest().get(name)
    if not cfg:
        return {}
    ref = cfg["animations"][cfg.get("reference", "idle")]
    if not (SOURCES / cfg["dir"] / ref["file"]).exists():
        print(f"  {name}: reference source {cfg['dir']}/{ref['file']} not downloaded yet, keeping the code-drawn frames")
        return {}
    imp = Importer(name, cfg, cell, origin)
    out = {}
    for anim, spec in cfg["animations"].items():
        if not (imp.dir / spec["file"]).exists():
            print(f"  {name}.{anim}: source {spec['file']} missing, keeping the code-drawn frames")
            continue
        frames = []
        srcs = source_frames(spec, imp.dir)
        base = code_meta.get(anim) or [{}]
        imp.use_ramps(cfg["ramps"] + spec.get("extra_ramps", []))
        if "erase" in spec:
            srcs = [_erase_hue(src, *spec["erase"], white=spec.get("erase_white", False)) for src in srcs]
        ref_x = imp.feet_x(srcs[0]) if spec.get("feet_x") == "self" else None
        for i, src in enumerate(srcs):
            img, mask, grid = imp.frame(src, spec.get("anchor", "ground"), ref_x)
            meta = base[min(len(base) - 1, i * len(base) // len(srcs))]
            meta = {k: v for k, v in meta.items() if k not in spec.get("drop", [])}
            meta.update(spec.get("meta", {}))
            if cfg.get("detect") == "elf":
                meta = imp.detect(grid, meta)
            frames.append((img, mask, meta))
        out[anim] = (frames, spec.get("seq"), spec.get("fps"), spec.get("loop"))
        print(f"  {name}.{anim}: {len(frames)} frames from Autosprite ({spec['file']})")
    return out


def selftest():
    """Imports a smooth 4x blow-up of the code-drawn run and checks that the figure, the
    feet and the detected neck and hand land where the code rig put them."""
    import tempfile
    import pixelrig
    import spritegen
    mod = pixelrig.autosprite_import  # this file as pixelrig sees it (not __main__)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        (tmp / "elf").mkdir()
        # The code-drawn sheet, with no imports (the real one may hold Autosprite frames).
        mod.SOURCES, mod.MANIFEST = tmp, tmp / "manifest.json"
        sprites = pixelrig.SPRITES
        pixelrig.SPRITES = tmp / "code"
        spritegen.main()
        pixelrig.SPRITES = sprites
        real = json.loads((tmp / "code" / "player.json").read_text())["animations"]["run"]
        src = Image.open(tmp / "code" / "player.png")
        row = real["row"] * 64
        sheet = Image.new("RGBA", (4 * 256, 2 * 256))
        for i in range(8):
            cell = src.crop((i * 64, row, i * 64 + 64, row + 64)).resize((256, 256), Image.BICUBIC)
            sheet.paste(cell, ((i % 4) * 256, (i // 4) * 256))
        sheet.save(tmp / "elf" / "run.png")
        mod.MANIFEST.write_text(json.dumps({"player": {
            "dir": "elf", "ramps": ["night", "bark", "leaf", "gold"], "height": 42, "reference": "run",
            "detect": "elf", "animations": {"run": {"file": "run.png", "frame_size": 256, "columns": 4}}}}))
        pixelrig.SPRITES = tmp / "out"
        spritegen.main()
        got = json.loads((tmp / "out" / "player.json").read_text())["animations"]["run"]["frames"]
        worst = 0.0
        for g, r in zip(got, real["frames"]):
            for key in ("neck", "hand"):
                worst = max(worst, abs(g[key][0] - r[key][0]), abs(g[key][1] - r[key][1]))
        before = np.asarray(src.crop((0, row, 512, row + 64)))[..., 3] > 0
        after = np.asarray(Image.open(tmp / "out" / "player.png").crop((0, row, 512, row + 64)))[..., 3] > 0
        overlap = (before & after).sum() / float((before | after).sum())
    print(f"selftest: silhouette overlap {overlap:.2f}, worst neck/hand error {worst:.1f} px")
    assert overlap > 0.8 and worst <= 4, "round trip drifted"


def find_loop(path, frame_size=256, min_len=6, max_len=40):
    """(start, length, score) of the cut whose last frame flows best into its first: the
    silhouette of frame start+length matches frame start. Autosprite clips hold several
    cycles, so the shortest strong match is one cycle."""
    sheet = np.asarray(Image.open(path).convert("RGBA"))[..., 3] >= 128
    cols = sheet.shape[1] // frame_size
    frames = []
    for i in range(cols * (sheet.shape[0] // frame_size)):
        x, y = (i % cols) * frame_size, (i // cols) * frame_size
        f = sheet[y:y + frame_size, x:x + frame_size]
        if not f.any():
            break
        frames.append(f)

    def iou(a, b):
        return (a & b).sum() / float(max(1, (a | b).sum()))

    best = None
    for start in range(len(frames)):
        for length in range(min_len, min(max_len, len(frames) - start - 1) + 1):
            score = iou(frames[start], frames[start + length])
            # Prefer short loops: a two-cycle loop matches as well as a one-cycle loop.
            if best is None or score > best[2] + 0.02 or (score >= best[2] - 0.005 and length < best[1]):
                best = (start, length, score)
    return best, len(frames)


def main():
    if "--loop" in sys.argv:
        args = sys.argv[sys.argv.index("--loop") + 1:]
        lo, hi = (int(args[1]), int(args[2])) if len(args) >= 3 else (6, 40)
        (start, length, score), total = find_loop(SOURCES / args[0], min_len=lo, max_len=hi)
        print(f"{args[0]}: {total} frames; loop start {start}, length {length} (match {score:.2f})")
        print(f'  "pick": {list(range(start, start + length))}')
        return
    if "--selftest" in sys.argv:
        selftest()
        return
    for script in ("spritegen.py", "castgen.py"):
        subprocess.run([sys.executable, str(Path(__file__).resolve().parent / script)], check=True)


if __name__ == "__main__":
    main()
