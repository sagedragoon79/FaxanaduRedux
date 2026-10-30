#!/usr/bin/env python3
"""Painterly scenery test (not the shipping style): paints the Fountain Plaza of
Eolis as soft, brushy scenery for the pixel-art cast to stand in front of, in
the spirit of Legend of Mana, Valkyrie Profile and Octopath Traveler.

Three images, all at the render density (2 px per world px, design bible 12.1):
  assets/painted/eolis_far.png    1280x960  parallax, the World Tree and the sky
  assets/painted/eolis_mid.png    1280x960  parallax, root-houses (tiles sideways)
  assets/painted/eolis/plaza.png  2560x736  room plate: floor, walls, fountain,
                                            doorways, lamps, the hanging ledge

The plate is painted from the room's own grid (levels/eolis/plaza.room), so its
floor, walls and ledge sit exactly on the collision. Room loads a plate when one
exists for its id and hides the tiles, decor, fountain and door frames under it.

How it paints: shapes are laid in as flat soft-edged masses with light and
shadow fields, then re-painted with thousands of brush strokes. Each stroke
samples the color under it, wobbles it a little and follows the image's edges
(or a default direction such as vertical for bark), largest brushes first.

Usage: python3 tools/art/paintgen.py
"""
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "painted"
D = 2
T = 16 * D


def hexc(h: str) -> np.ndarray:
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], np.float32)


# Eolis: cool stone and blue-violet shadow against warm amber lamplight.
INK = hexc("15121f")
NIGHT = hexc("1f1a33")
DUSK = hexc("3a3150")
VIOLET = hexc("5a4a72")
MAUVE = hexc("8a6a86")
ROSE = hexc("c08a7a")
HAZE = hexc("d9ad84")
STONE_D = hexc("3b3547")
STONE = hexc("6d6478")
STONE_L = hexc("a59bad")
BARK_D = hexc("2a2230")
BARK = hexc("4a3a45")
BARK_L = hexc("7a6260")
AMBER = hexc("f0b44c")
AMBER_L = hexc("ffe0a0")
EMBER = hexc("d9772e")
MOSS = hexc("5d7a4a")
MOSS_D = hexc("33452f")
WOOD = hexc("7a4e30")
WOOD_D = hexc("4a2e1e")
BANNER = hexc("2f5a46")
GOLD = hexc("c9a25a")


# --- fields -----------------------------------------------------------------

def noise(w, h, cell, seed, wrap=False, octaves=4):
    """Fractal value noise in 0..1, optionally seamless sideways."""
    rng = np.random.default_rng(seed)
    out = np.zeros((h, w), np.float32)
    amp, total = 1.0, 0.0
    for o in range(octaves):
        c = max(2.0, cell / (2 ** o))
        gw, gh = int(math.ceil(w / c)) + 1, int(math.ceil(h / c)) + 3
        g = rng.random((gh, gw)).astype(np.float32)
        if wrap:
            g = np.concatenate([g, g, g], axis=1)
        z = ndimage.zoom(g, c, order=3, mode="nearest")
        if wrap:
            sw = gw * c
            z = z[:, int(sw):int(sw) + w] if z.shape[1] >= sw + w else z[:, :w]
        out += amp * z[:h, :w]
        total += amp
        amp *= 0.5
    return np.clip(out / total, 0, 1)


def mask_from(draw_fn, w, h, blur=0.0):
    im = Image.new("L", (w, h), 0)
    draw_fn(ImageDraw.Draw(im))
    if blur > 0:
        im = im.filter(ImageFilter.GaussianBlur(blur))
    return np.asarray(im, np.float32) / 255.0


def vgrad(h, w, stops):
    """Vertical gradient through (t, color) stops."""
    ys = np.linspace(0, 1, h)
    ts = [s[0] for s in stops]
    out = np.stack([np.interp(ys, ts, [s[1][i] for s in stops]) for i in range(3)], -1)
    return np.repeat(out[:, None, :], w, 1).astype(np.float32)


def glow(w, h, points, wrap=False):
    """Soft additive light: points are (x, y, radius, color, strength)."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    out = np.zeros((h, w, 3), np.float32)
    for x, y, r, c, s in points:
        dx = xx - x
        if wrap:
            dx = (dx + w / 2) % w - w / 2
        d2 = (dx * dx + (yy - y) ** 2) / (r * r)
        out += (s * np.exp(-d2 * 2.2))[..., None] * c
    return out


class Canvas:
    def __init__(self, w, h, wrap=False):
        self.w, self.h, self.wrap = w, h, wrap
        self.rgb = np.zeros((h, w, 3), np.float32)
        self.a = np.zeros((h, w), np.float32)

    def lay(self, mask, color, alpha=1.0):
        """Lays `color` (a color or an h*w*3 field) through `mask`."""
        m = np.clip(mask * alpha, 0, 1)[..., None]
        self.rgb = self.rgb * (1 - m) + np.broadcast_to(color, self.rgb.shape) * m
        self.a = np.maximum(self.a, m[..., 0]) if alpha >= 0.999 else self.a + (1 - self.a) * m[..., 0]

    def shade(self, mask, factor):
        """Multiplies the color under `mask` (factor may be a field)."""
        f = 1 + (np.asarray(factor, np.float32) - 1) * mask
        if f.ndim == 2:
            f = f[..., None]
        self.rgb *= f

    def light(self, field, mask=None):
        if mask is not None:
            field = field * mask[..., None]
        # Warm light multiplies into what it falls on, and only its core goes pale.
        self.rgb = self.rgb * (1 + field * 1.6) + field * field * 0.35

    def image(self):
        rgb = np.clip(self.rgb, 0, 1)
        a = np.clip(self.a, 0, 1)
        arr = np.concatenate([rgb, a[..., None]], -1)
        return Image.fromarray((arr * 255 + 0.5).astype(np.uint8), "RGBA")


def strokes(cv: Canvas, n, length, width, seed, alpha=0.8, jitter=0.05, base_angle=0.0,
            follow=1.0, region=None, angle_field=None):
    """Re-paints the canvas with brush strokes (Hertzmann-style).

    Each stroke takes the color under its middle, wobbles hue and value by
    `jitter`, and lies along the image's edges where they are strong (`follow`)
    or along `base_angle` (radians, 0 = horizontal) where they are weak.
    """
    rng = np.random.default_rng(seed)
    h, w = cv.h, cv.w
    a = cv.a
    # Fill the clear area with nearby colors so edge strokes do not drag in black.
    wa = ndimage.gaussian_filter(a, 6, mode="wrap" if cv.wrap else "nearest") + 1e-4
    src = np.stack([ndimage.gaussian_filter(cv.rgb[..., i] * a, 6, mode="wrap" if cv.wrap else "nearest") / wa
                    for i in range(3)], -1)
    src = src * (1 - a[..., None]) + cv.rgb * a[..., None]
    sm = np.stack([ndimage.gaussian_filter(src[..., i], 1.2) for i in range(3)], -1)
    lum = sm.mean(-1)
    gy = ndimage.sobel(ndimage.gaussian_filter(lum, 3), 0)
    gx = ndimage.sobel(ndimage.gaussian_filter(lum, 3), 1)
    mag = np.hypot(gx, gy)
    mag = mag / (mag.max() + 1e-6)
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(layer)
    for _ in range(n):
        x, y = int(rng.integers(0, w)), int(rng.integers(0, h))
        if region is not None and region[y, x] < 0.5:
            continue
        if a[y, x] < 0.02:
            continue
        c = sm[y, x] * (1 + rng.normal(0, jitter)) + rng.normal(0, jitter * 0.5, 3)
        c = np.clip(c, 0, 1)
        if angle_field is not None:
            ang0 = angle_field[y, x]
        else:
            ang0 = base_angle
        edge = math.atan2(gy[y, x], gx[y, x]) + math.pi / 2
        k = min(1.0, mag[y, x] * 6 * follow)
        ang = ang0 * (1 - k) + edge * k if abs(edge - ang0) < math.pi / 2 else ang0 * (1 - k) + (edge - math.pi) * k
        ang += rng.normal(0, 0.12)
        ln = rng.uniform(*length) * (1 - 0.5 * k)
        wd = max(1, int(rng.uniform(*width)))
        dx, dy = math.cos(ang) * ln / 2, math.sin(ang) * ln / 2
        col = tuple(int(v * 255) for v in c) + (int(255 * alpha * rng.uniform(0.6, 1.0)),)
        # A slightly curved stroke: two segments.
        bend = rng.normal(0, ln * 0.08)
        mx, my = x - math.sin(ang) * bend, y + math.cos(ang) * bend
        pts = [(x - dx, y - dy), (mx, my), (x + dx, y + dy)]
        dr.line(pts, fill=col, width=wd, joint="curve")
        if cv.wrap:
            for off in (-w, w):
                if (x - ln < 0 and off == w) or (x + ln > w and off == -w):
                    dr.line([(p[0] + off, p[1]) for p in pts], fill=col, width=wd, joint="curve")
    arr = np.asarray(layer, np.float32) / 255.0
    m = arr[..., 3:4]
    if region is not None:
        m = m * region[..., None]
    # Strokes only re-color what is painted; the alpha edge gets its own roughening.
    m = m * a[..., None]
    cv.rgb = cv.rgb * (1 - m) + arr[..., :3] * m


def rough_edges(cv: Canvas, amount, cell, seed):
    """Breaks the alpha edge up like dry brush."""
    n = noise(cv.w, cv.h, cell, seed, wrap=cv.wrap, octaves=3)
    a = ndimage.gaussian_filter(cv.a, 1.5)
    cv.a = np.clip((a - 0.5) * 3 + (n - 0.5) * amount * 3 + 0.5, 0, 1) * (cv.a > 0.01)


def grain(cv: Canvas, seed, strength=0.035):
    rng = np.random.default_rng(seed)
    g = ndimage.gaussian_filter(rng.normal(0, 1, (cv.h, cv.w)).astype(np.float32), 0.7)
    canvas_weave = noise(cv.w, cv.h, 6, seed + 1, wrap=cv.wrap, octaves=1) - 0.5
    cv.rgb *= (1 + strength * g + strength * 0.8 * canvas_weave)[..., None]


def soften(cv: Canvas, haze_color, amount, sat=1.0):
    """Atmospheric distance: desaturate and lift toward the haze."""
    lum = cv.rgb.mean(-1, keepdims=True)
    cv.rgb = lum + (cv.rgb - lum) * sat
    cv.rgb = cv.rgb * (1 - amount) + haze_color * amount


# --- the far layer: sky and the World Tree --------------------------------------

def paint_far():
    w, h = 1280, 960
    cv = Canvas(w, h, wrap=True)
    sky = vgrad(h, w, [(0.0, INK), (0.3, NIGHT), (0.55, DUSK), (0.72, VIOLET), (0.84, MAUVE), (0.92, ROSE), (1.0, MAUVE)])
    clouds = noise(w, h, 260, 11, wrap=True)
    sky = sky * (0.9 + 0.2 * clouds[..., None])
    cv.lay(np.ones((h, w)), sky)
    # The trunk: a colossal column, its crown lost in cloud. Seamless: drawn on wrap.
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx = 640 + 30 * np.sin(yy / 210)
    half = 250 + 40 * (yy / h) ** 3 * 4
    dx = (xx - cx)
    trunk = np.clip((half - np.abs(dx)) / 18, 0, 1)
    # Flaring roots at the base.
    flare = np.clip(1 - np.abs(dx) / (half + 340 * np.clip((yy - 560) / 400, 0, 1) ** 1.6), 0, 1)
    trunk = np.maximum(trunk, (flare > 0.02) * np.clip((yy - 560) / 60, 0, 1))
    bark = noise(w, h, 40, 21, wrap=True, octaves=4)
    ridges = noise(w, h, 18, 22, wrap=True, octaves=2)
    ridges = ndimage.zoom(ridges[::8, :], (8, 1), order=1)[:h]
    side = np.clip(dx / half, -1, 1)
    bark_col = (BARK[None, None] * (0.75 + 0.35 * bark[..., None]) * (0.8 + 0.4 * ridges[..., None]))
    # Lit from the town below-left: a warm rim on the left flank, cool on the right.
    rim = np.clip(-side - 0.55, 0, 1) * 2.2
    bark_col = bark_col + rim[..., None] * (ROSE - bark_col) * 0.5
    bark_col = bark_col * (1 - 0.35 * np.clip(side, 0, 1)[..., None])
    cv.lay(trunk, bark_col)
    # Distant root arches, both sides, and a second ridge of roots further back.
    def roots(d):
        for x0, x1, top, thick in ((-60, 520, 640, 46), (760, 1340, 620, 52), (120, 420, 720, 30),
                                   (880, 1180, 700, 34)):
            pts_top = []
            pts_bot = []
            for i in range(41):
                t = i / 40
                x = x0 + (x1 - x0) * t
                y = top + (1 - math.sin(t * math.pi)) * 260
                pts_top.append((x, y))
                pts_bot.append((x, y + thick * (0.6 + 0.4 * math.sin(t * math.pi))))
            d.polygon(pts_top + pts_bot[::-1], fill=255)
    rm = mask_from(roots, w, h, blur=1.5)
    cv.lay(rm, BARK_D * 1.3 + 0.0 * bark[..., None])
    # Far root-town lights: tiny warm windows sprinkled over the roots and trunk base.
    rng = np.random.default_rng(31)
    pts = []
    for _ in range(70):
        x, y = rng.uniform(0, w), rng.uniform(620, 900)
        if trunk[int(y), int(x)] > 0.5 or rm[int(y), int(x)] > 0.5:
            pts.append((x, y))
    def windows(d):
        for x, y in pts:
            d.rounded_rectangle((x - 2, y - 4, x + 2, y + 4), 2, fill=255)
    wm = mask_from(windows, w, h, blur=0.6)
    cv.lay(wm, AMBER)
    cv.light(glow(w, h, [(x, y, 22, AMBER, 0.25) for x, y in pts], wrap=True))
    # Cloud wisps across the trunk high up, and haze at the foot.
    wisps = np.clip((noise(w, h, 180, 41, wrap=True) - 0.5) * 3, 0, 1) * np.clip(1 - yy / 500, 0, 1)
    cv.lay(wisps, MAUVE * 1.1, 0.6)
    foot = np.clip((yy - 700) / 220, 0, 1) ** 1.3
    cv.lay(foot, HAZE * 0.85, 0.55)
    # The faint wrong light of the meteor at the crown.
    cv.light(glow(w, h, [(640, -40, 260, hexc("b0c4ff"), 0.22)], wrap=True))
    strokes(cv, 9000, (40, 90), (10, 18), 51, alpha=0.7, base_angle=0.0, follow=0.6)
    strokes(cv, 14000, (16, 40), (4, 8), 52, alpha=0.75, base_angle=math.pi / 2, follow=1.0,
            region=trunk)
    strokes(cv, 9000, (14, 30), (3, 6), 53, alpha=0.6, base_angle=0.0, follow=1.0)
    soften(cv, MAUVE, 0.3, sat=0.8)
    grain(cv, 54, 0.025)
    cv.a[:] = 1
    return cv.image()


# --- the mid layer: root-houses ----------------------------------------------

def paint_mid():
    w, h = 1280, 960
    cv = Canvas(w, h, wrap=True)
    ground = 770
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    bark = noise(w, h, 30, 61, wrap=True, octaves=4)
    lit = []
    # A great root arching over the street, top of the layer, houses hung on it.
    def arch(d):
        pts_t, pts_b = [], []
        for i in range(65):
            t = i / 64
            x = -40 + (w + 80) * t
            y = 150 + 70 * math.sin(t * math.pi * 2) + 30 * math.sin(t * 11)
            pts_t.append((x, y))
            pts_b.append((x, y + 70 + 20 * math.sin(t * 7)))
        d.polygon(pts_t + pts_b[::-1], fill=255)
    am = mask_from(arch, w, h, blur=1.2)
    root_col = BARK[None, None] * (0.8 + 0.4 * bark[..., None])
    cv.lay(am, root_col * 0.9)
    # Root-houses: tall rounded towers grown from root, each with a round door,
    # arched windows and a little roof cap. Positions tile sideways.
    houses = [(90, 150, 330), (300, 120, 250), (520, 160, 360), (860, 130, 280), (1080, 160, 340)]
    for i, (x, hw, tall) in enumerate(houses):
        top = ground - tall
        def body(d, x=x, hw=hw, top=top):
            for off in (-w, 0, w):
                X = x + off
                d.rounded_rectangle((X - hw / 2, top, X + hw / 2, ground + 40), int(hw * 0.48), fill=255)
                # A root foot spreading at the base.
                d.polygon([(X - hw / 2 - 30, ground + 40), (X - hw / 2, ground - 90), (X + hw / 2, ground - 90),
                           (X + hw / 2 + 30, ground + 40)], fill=255)
        bm = mask_from(body, w, h, blur=1.0)
        shade_side = np.clip(((xx - x + w / 2) % w - w / 2) / (hw / 2), -1, 1)
        tone = 0.95 + 0.1 * (i % 3)
        col = (STONE_D * 0.55 + BARK * 0.35 + VIOLET * 0.2)[None, None] * tone * (0.8 + 0.35 * bark[..., None])
        # Lighter at the top where the sky catches it, sinking into shadow at the foot.
        col = col * (1.15 - 0.45 * np.clip((yy - top) / tall, 0, 1))[..., None]
        col = col * (1 - 0.3 * np.clip(shade_side, 0, 1))[..., None]
        col = col + np.clip(-shade_side - 0.6, 0, 1)[..., None] * (ROSE - col) * 0.6
        cv.lay(bm, col)
        # Roof: a pointed leaf-shingle cap on some, a chimney on others.
        def roof(d, x=x, hw=hw, top=top, i=i):
            for off in (-w, 0, w):
                X = x + off
                if i % 2 == 0:
                    d.polygon([(X - hw / 2 - 14, top + hw * 0.32), (X, top - 70), (X + hw / 2 + 14, top + hw * 0.32)],
                              fill=255)
                else:
                    d.rectangle((X + hw * 0.18, top - 30, X + hw * 0.32, top + 40), fill=255)
        rf = mask_from(roof, w, h, blur=1.0)
        cv.lay(rf, MOSS_D * 0.9 if i % 2 == 0 else STONE_D * 0.9)
        # Windows: lit arches in rows.
        rng = np.random.default_rng(70 + i)
        rows = max(2, int((tall - 160) / 90))
        wins = []
        for r in range(rows):
            for cpos in ((-0.22, 0.22) if hw > 140 else (0.0,)):
                if rng.random() < 0.8:
                    wx = x + cpos * hw
                    wy = top + 90 + r * 90
                    wins.append((wx, wy))
        def winmask(d, wins=wins):
            for wx, wy in wins:
                for off in (-w, 0, w):
                    X = wx + off
                    d.rounded_rectangle((X - 9, wy - 16, X + 9, wy + 16), 9, fill=255)
        wm = mask_from(winmask, w, h, blur=0.8)
        cv.lay(wm, AMBER * 0.95)
        lit += [(wx, wy, 40, AMBER, 0.28) for wx, wy in wins]
        # Round door at the foot, dark with a warm crack of light.
        def door(d, x=x):
            for off in (-w, 0, w):
                X = x + off
                d.rounded_rectangle((X - 22, ground - 78, X + 22, ground + 40), 22, fill=255)
        dm = mask_from(door, w, h, blur=0.8)
        cv.lay(dm, INK * 1.6)
        lit.append((x, ground - 30, 46, EMBER, 0.18))
    # Hanging lanterns on chains from the arch.
    lanterns = [(200, 320), (700, 300), (980, 330)]
    def chains(d):
        for lx, ly in lanterns:
            for off in (-w, 0, w):
                d.line([(lx + off, 200), (lx + off, ly - 14)], fill=255, width=2)
    cv.lay(mask_from(chains, w, h, blur=0.4), INK * 2)
    def lamps(d):
        for lx, ly in lanterns:
            for off in (-w, 0, w):
                d.rounded_rectangle((lx + off - 9, ly - 14, lx + off + 9, ly + 12), 5, fill=255)
    cv.lay(mask_from(lamps, w, h, blur=0.6), AMBER)
    lit += [(lx, ly, 90, AMBER, 0.45) for lx, ly in lanterns]
    # Dark ground band the plate covers anyway, so the layer reads to its foot.
    cv.lay(np.clip((yy - ground + 10) / 30, 0, 1), STONE_D * 0.8)
    # Light from windows and lamps, inside the painted shapes only.
    g = glow(w, h, lit, wrap=True)
    strokes(cv, 16000, (20, 50), (6, 12), 81, alpha=0.75, base_angle=math.pi / 2, follow=0.9)
    strokes(cv, 16000, (8, 22), (2, 5), 82, alpha=0.7, base_angle=math.pi / 2, follow=1.2)
    cv.light(g * 0.9, cv.a)
    rough_edges(cv, 0.5, 6, 83)
    # Atmosphere: they stand in the dusk haze, a step back from the plate.
    soften(cv, DUSK, 0.28, sat=0.75)
    grain(cv, 84, 0.03)
    # Their glow spills into the air around them.
    halo = np.clip(g.mean(-1) * 1.4, 0, 0.55)
    cv.rgb = np.where(cv.a[..., None] > 0.02, cv.rgb, AMBER[None, None])
    cv.a = np.maximum(cv.a, halo * 0.7)
    return cv.image()


# --- the plate: the room itself -----------------------------------------------

def read_room(path):
    text = path.read_text().split("\n---\n", 1)[1]
    return [r for r in text.split("\n") if r.strip()]


def paint_plate(grid):
    rows, cols = len(grid), len(grid[0])
    w, h = cols * T, rows * T
    cv = Canvas(w, h)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    stone_n = noise(w, h, 24, 91, octaves=4)
    bark_n = noise(w, h, 26, 92, octaves=4)

    def solid(x, y):
        return 0 <= y < rows and 0 <= x < cols and grid[y][x] == "#"

    # Collision footprint of every '#' and '-' cell, so the paint sits on it.
    def cells(ch):
        def f(d):
            for y in range(rows):
                for x in range(cols):
                    if grid[y][x] == ch:
                        d.rectangle((x * T, y * T, x * T + T - 1, y * T + T - 1), fill=255)
        return f

    floor_y = None
    for y in range(rows):
        if all(c == "#" for c in grid[y]) and y > rows // 2:
            floor_y = y * T
            break

    # Lamps (warm pools of light): posts on the floor and lanterns from the ceiling.
    posts = [10, 27, 55, 71]
    hanging = [(14, 5.5), (37, 4.0), (49, 6.0), (66, 4.5)]
    door3, door4 = 18, 62
    lights = []
    for px in posts:
        lights.append((px * T + 16, floor_y - 170, 260, AMBER, 0.7))
    for hx, hy in hanging:
        lights.append((hx * T + 16, hy * T, 260, AMBER, 0.6))
    lights.append((door3 * T + 16, floor_y - 60, 170, EMBER, 0.45))
    lights.append((door4 * T + 16, floor_y - 60, 170, hexc("8fd0c0"), 0.35))
    light_field = glow(w, h, lights)

    # Facades around the two inner doors: the King's Hall (carved stone, banners)
    # and the Temple of Mantras (a round root-door with a glowing rune).
    def hall(d):
        x = door3 * T + 16
        d.rounded_rectangle((x - 210, floor_y - 330, x + 210, floor_y + 4), 40, fill=255)
        d.polygon([(x - 240, floor_y - 330), (x, floor_y - 420), (x + 240, floor_y - 330)], fill=255)
    hm = mask_from(hall, w, h, blur=1.0)
    blocks = ((np.floor(xx / 64) + np.floor(yy / 36)) % 2) * 0.06
    mortar = ((yy % 36) < 3) | (((xx + 32 * (np.floor(yy / 36) % 2)) % 64) < 3)
    hall_col = STONE[None, None] * (0.78 + 0.3 * stone_n[..., None] + blocks[..., None])
    hall_col = np.where(mortar[..., None], STONE_D[None, None] * 0.9, hall_col)
    hall_col = hall_col * (0.95 - 0.35 * np.clip((yy - floor_y + 330) / 330, 0, 1))[..., None]
    hall_col = hall_col * (1 - 0.35 * np.clip((xx - door3 * T - 16) / 210, 0, 1))[..., None]
    cv.lay(hm, hall_col * 0.82)
    def hall_trim(d):
        x = door3 * T + 16
        d.polygon([(x - 250, floor_y - 326), (x, floor_y - 424), (x + 250, floor_y - 326), (x + 250, floor_y - 310),
                   (x, floor_y - 404), (x - 250, floor_y - 310)], fill=255)
        for cx in (x - 150, x + 150):
            d.rectangle((cx - 22, floor_y - 300, cx + 22, floor_y), fill=255)
    cv.lay(mask_from(hall_trim, w, h, blur=0.8), STONE * 0.85)
    def hall_door(d):
        x = door3 * T + 16
        d.rounded_rectangle((x - 46, floor_y - 150, x + 46, floor_y + 2), 46, fill=255)
    cv.lay(mask_from(hall_door, w, h, blur=0.8), WOOD_D)
    def hall_door_in(d):
        x = door3 * T + 16
        d.rounded_rectangle((x - 36, floor_y - 140, x + 36, floor_y + 2), 36, fill=255)
    cv.lay(mask_from(hall_door_in, w, h, blur=0.8), WOOD)
    def hall_seam(d):
        x = door3 * T + 16
        d.line([(x, floor_y - 140), (x, floor_y)], fill=255, width=3)
        for yy_ in range(int(floor_y - 110), int(floor_y), 30):
            d.line([(x - 34, yy_), (x + 34, yy_)], fill=255, width=2)
    cv.lay(mask_from(hall_seam, w, h, blur=0.5), WOOD_D * 0.8)
    def banners(d):
        x = door3 * T + 16
        for cx in (x - 95, x + 95):
            d.polygon([(cx - 24, floor_y - 280), (cx + 24, floor_y - 280), (cx + 24, floor_y - 150), (cx, floor_y - 128),
                       (cx - 24, floor_y - 150)], fill=255)
    bn = mask_from(banners, w, h, blur=0.8)
    cv.lay(bn, BANNER * (0.85 + 0.3 * bark_n[..., None]))
    def emblem(d):
        x = door3 * T + 16
        for cx in (x - 95, x + 95):
            d.ellipse((cx - 11, floor_y - 236, cx + 11, floor_y - 214), outline=255, width=3)
            d.line([(cx, floor_y - 214), (cx, floor_y - 196)], fill=255, width=3)
    cv.lay(mask_from(emblem, w, h, blur=0.5), GOLD)

    def temple(d):
        x = door4 * T + 16
        d.ellipse((x - 200, floor_y - 360, x + 200, floor_y + 60), fill=255)
        d.rectangle((x - 200, floor_y - 160, x + 200, floor_y + 4), fill=255)
    tm = mask_from(temple, w, h, blur=1.0)
    tside = np.clip((xx - door4 * T) / 200, -1, 1)
    tcol = BARK[None, None] * (0.75 + 0.45 * bark_n[..., None])
    tcol = tcol * (1 - 0.3 * np.clip(tside, 0, 1))[..., None]
    # Bark ridges following the dome's curve, darker toward its rim.
    tr = noise(w, h, 14, 93, octaves=2)
    tr = ndimage.zoom(tr[::10, :], (10, 1), order=1)[:h]
    tcol = tcol * (0.75 + 0.5 * tr[..., None])
    inner = ndimage.gaussian_filter(tm, 16)
    tcol = tcol * (0.6 + 0.4 * np.clip(inner * 1.6, 0, 1))[..., None]
    tcol = tcol * (0.8 + 0.25 * hexc("b08aa0"))[None, None]
    cv.lay(tm, tcol)
    def temple_rim(d):
        x = door4 * T + 16
        d.ellipse((x - 64, floor_y - 130, x + 64, floor_y + 100), fill=255)
    cv.lay(mask_from(temple_rim, w, h, blur=0.8), STONE * 0.8)
    def temple_door(d):
        x = door4 * T + 16
        d.ellipse((x - 54, floor_y - 120, x + 54, floor_y + 90), fill=255)
    cv.lay(mask_from(temple_door, w, h, blur=0.8), STONE_D)
    def temple_door_in(d):
        x = door4 * T + 16
        d.ellipse((x - 42, floor_y - 108, x + 42, floor_y + 80), fill=255)
    cv.lay(mask_from(temple_door_in, w, h, blur=0.8), INK * 1.8)
    def rune(d):
        x = door4 * T + 16
        y = floor_y - 200
        d.ellipse((x - 28, y - 28, x + 28, y + 28), outline=255, width=4)
        d.line([(x, y - 22), (x, y + 22)], fill=255, width=4)
        d.line([(x - 14, y - 8), (x, y + 6), (x + 14, y - 8)], fill=255, width=4)
    cv.lay(mask_from(rune, w, h, blur=0.7), hexc("bff0e0"))
    lights.append((door4 * T + 16, floor_y - 200, 80, hexc("8fd0c0"), 0.5))
    # Temple windows.
    def twin(d):
        x = door4 * T + 16
        for cx, cy in ((x - 120, floor_y - 200), (x + 120, floor_y - 200), (x - 70, floor_y - 290), (x + 70, floor_y - 290)):
            d.rounded_rectangle((cx - 11, cy - 20, cx + 11, cy + 20), 11, fill=255)
    tw = mask_from(twin, w, h, blur=0.6)
    cv.lay(tw, AMBER)

    # Walls at the room's edges (rows above the exits): thick gnarled roots.
    wall = mask_from(cells("#"), w, h)
    wall_rows = np.zeros((h, w), np.float32)
    if floor_y:
        wall_rows[:floor_y] = 1
    side_wall = wall * wall_rows
    side_wall[: 2 * T] = 0
    side_wall = ndimage.binary_dilation(side_wall > 0.5, iterations=10).astype(np.float32) * (xx < 3 * T) + \
        ndimage.binary_dilation(side_wall > 0.5, iterations=10).astype(np.float32) * (xx > w - 3 * T)
    side_wall = np.clip(side_wall, 0, 1) * wall_rows
    root_col = BARK[None, None] * (0.7 + 0.5 * bark_n[..., None])
    cv.lay(ndimage.gaussian_filter(side_wall, 2), root_col)

    # Exit arches at the two edge doors.
    def gates(d):
        for gx, sgn in ((0, 1), (w, -1)):
            x0 = gx + sgn * 2 * T
            d.rectangle((min(gx, x0), floor_y - 3 * T - 30, max(gx, x0), floor_y - 3 * T), fill=255)
            d.rectangle((min(x0, x0 + sgn * 20), floor_y - 3 * T - 30, max(x0, x0 + sgn * 20), floor_y), fill=255)
    cv.lay(mask_from(gates, w, h, blur=0.8), STONE * 0.9)

    # The ceiling: a huge root running the room's width, with moss and hanging tendrils.
    ceil_rows = 0
    while ceil_rows < rows and all(c == "#" for c in grid[ceil_rows]):
        ceil_rows += 1
    cy = ceil_rows * T
    edge = cy + 6 * np.sin(xx[0] / 70) + 4 * np.sin(xx[0] / 23)
    ceil = (yy < edge[None, :]).astype(np.float32)
    cv.lay(ndimage.gaussian_filter(ceil, 1.5), BARK_D[None, None] * (0.8 + 0.5 * bark_n[..., None]))
    cv.shade(ceil, 1 + 0.35 * np.clip((yy - cy + 30) / 30, 0, 1))
    def tendrils(d):
        rng = np.random.default_rng(95)
        for _ in range(70):
            x = rng.uniform(0, w)
            ln = rng.uniform(20, 120)
            pts = [(x + 6 * math.sin(i * 0.7 + x), cy + i * ln / 8) for i in range(9)]
            d.line(pts, fill=255, width=int(rng.uniform(2, 5)), joint="curve")
    cv.lay(mask_from(tendrils, w, h, blur=0.6), MOSS_D)
    def moss_lip(d):
        rng = np.random.default_rng(96)
        for _ in range(90):
            x = rng.uniform(0, w)
            d.ellipse((x - 18, cy - 10, x + 18, cy + rng.uniform(2, 12)), fill=255)
    cv.lay(mask_from(moss_lip, w, h, blur=1.0) * (yy > cy - 12), MOSS_D * 0.9 + MOSS * 0.2)

    # Hanging lanterns on chains.
    def chains(d):
        for hx, hy in hanging:
            x = hx * T + 16
            d.line([(x, cy), (x, hy * T - 18)], fill=255, width=3)
    cv.lay(mask_from(chains, w, h, blur=0.4), INK * 2.2)
    def lantern(d):
        for hx, hy in hanging:
            x, y = hx * T + 16, hy * T
            d.polygon([(x - 16, y - 18), (x + 16, y - 18), (x + 12, y + 18), (x - 12, y + 18)], fill=255)
    cv.lay(mask_from(lantern, w, h, blur=0.6), WOOD_D)
    def lantern_glass(d):
        for hx, hy in hanging:
            x, y = hx * T + 16, hy * T
            d.polygon([(x - 11, y - 12), (x + 11, y - 12), (x + 8, y + 13), (x - 8, y + 13)], fill=255)
    cv.lay(mask_from(lantern_glass, w, h, blur=0.6), AMBER)

    # Lamp posts: iron, with a lit lantern on an arm.
    def post(d):
        for px in posts:
            x = px * T + 16
            d.rectangle((x - 4, floor_y - 170, x + 4, floor_y), fill=255)
            d.polygon([(x - 12, floor_y), (x + 12, floor_y), (x + 6, floor_y - 20), (x - 6, floor_y - 20)], fill=255)
            d.line([(x, floor_y - 168), (x + 22, floor_y - 182)], fill=255, width=4)
            d.polygon([(x - 14, floor_y - 186), (x + 14, floor_y - 186), (x, floor_y - 204)], fill=255)
    cv.lay(mask_from(post, w, h, blur=0.5), INK * 2.0)
    def post_glass(d):
        for px in posts:
            x = px * T + 16
            d.rounded_rectangle((x - 10, floor_y - 186, x + 10, floor_y - 156), 4, fill=255)
    cv.lay(mask_from(post_glass, w, h, blur=0.6), AMBER)

    # The hanging ledge: planks on two chains from the ceiling root.
    ledge = mask_from(cells("-"), w, h)
    if ledge.max() > 0:
        ys, xs = np.nonzero(ledge)
        lx0, lx1, ly0 = xs.min(), xs.max(), ys.min()
        def ledge_draw(d):
            d.rectangle((lx0 - 4, ly0, lx1 + 4, ly0 + 16), fill=255)
            for bx in (lx0 + 14, lx1 - 14):
                d.polygon([(bx - 6, ly0 + 14), (bx + 6, ly0 + 14), (bx, ly0 + 34)], fill=255)
        lm = mask_from(ledge_draw, w, h, blur=0.6)
        plank = WOOD_D[None, None] * (0.9 + 0.5 * bark_n[..., None]) * (1 - 0.25 * ((xx // 22) % 2))[..., None]
        cv.lay(lm, plank)
        cv.shade(lm * (yy > ly0 + 10), 0.7)
        def ropes(d):
            for bx in (lx0 + 14, lx1 - 14):
                d.line([(bx, cy), (bx, ly0)], fill=255, width=3)
        cv.lay(mask_from(ropes, w, h, blur=0.4), INK * 2.2)

    # Plinth and bollards (the free-standing '#' blocks above the floor).
    lone = wall.copy()
    lone[:cy + T] = 0
    lone[floor_y:] = 0
    lone[:, :3 * T] = 0
    lone[:, w - 3 * T:] = 0
    lab, n = ndimage.label(lone > 0.5)
    for i in range(1, n + 1):
        ys, xs = np.nonzero(lab == i)
        x0, x1, y0 = xs.min(), xs.max() + 1, ys.min()
        tall = floor_y - y0
        def blk(d):
            d.rounded_rectangle((x0, y0, x1, floor_y + 2), 6, fill=255)
            if tall > 2 * T:
                d.rectangle((x0 - 8, y0, x1 + 8, y0 + 14), fill=255)
                d.rectangle((x0 - 6, floor_y - 16, x1 + 6, floor_y + 2), fill=255)
        bm = mask_from(blk, w, h, blur=0.6)
        bcol = STONE[None, None] * (0.8 + 0.35 * stone_n[..., None])
        bside = np.clip((xx - (x0 + x1) / 2) / ((x1 - x0) / 2 + 8), -1, 1)
        bcol = bcol * (1 - 0.32 * np.clip(bside, 0, 1))[..., None] * (1 + 0.15 * np.clip(-bside, 0, 1))[..., None]
        cv.lay(bm, bcol)
        cv.lay(bm * (yy < y0 + 5), STONE_L)
        if tall > 2 * T:
            def leaf(d):
                mx, my = (x0 + x1) / 2, (y0 + floor_y) / 2
                d.ellipse((mx - 10, my - 18, mx + 10, my + 18), outline=255, width=3)
                d.line([(mx, my - 16), (mx, my + 16)], fill=255, width=2)
            cv.lay(mask_from(leaf, w, h, blur=0.5), STONE_D)
            # Moss spilling over the top.
            def mossy(d):
                rng = np.random.default_rng(int(x0))
                for _ in range(10):
                    mx = rng.uniform(x0 - 6, x1 + 6)
                    d.ellipse((mx - 9, y0 - 3, mx + 9, y0 + rng.uniform(6, 22)), fill=255)
            cv.lay(mask_from(mossy, w, h, blur=0.8), MOSS)

    # The Fountain of Eolis, dry: basin, pedestal and a high bowl.
    fx = 40 * T + 16
    def basin(d):
        d.rounded_rectangle((fx - 140, floor_y - 44, fx + 140, floor_y + 2), 10, fill=255)
        d.rectangle((fx - 152, floor_y - 52, fx + 152, floor_y - 38), fill=255)
    fb = mask_from(basin, w, h, blur=0.6)
    fside = np.clip((xx - fx) / 150, -1, 1)
    fcol = STONE_L[None, None] * (0.6 + 0.3 * stone_n[..., None]) * (1 - 0.3 * np.clip(fside, 0, 1))[..., None]
    cv.lay(fb, fcol)
    cv.shade(fb * (yy > floor_y - 38), 0.78)
    def ped(d):
        d.polygon([(fx - 20, floor_y - 52), (fx + 20, floor_y - 52), (fx + 13, floor_y - 168), (fx - 13, floor_y - 168)],
                  fill=255)
        d.ellipse((fx - 30, floor_y - 120, fx + 30, floor_y - 98), fill=255)
        d.chord((fx - 70, floor_y - 214, fx + 70, floor_y - 150), 0, 180, fill=255)
        d.rectangle((fx - 76, floor_y - 186, fx + 76, floor_y - 176), fill=255)
        d.polygon([(fx - 8, floor_y - 186), (fx + 8, floor_y - 186), (fx + 4, floor_y - 232), (fx - 4, floor_y - 232)],
                  fill=255)
        d.ellipse((fx - 12, floor_y - 248, fx + 12, floor_y - 226), fill=255)
    pm = mask_from(ped, w, h, blur=0.6)
    cv.lay(pm, fcol)
    cv.shade(pm, 1 + 0.25 * np.clip(-(xx - fx) / 40, 0, 1))
    # Cracked dry bed with dead leaves, glimpsed over the rim.
    def cracks(d):
        rng = np.random.default_rng(97)
        for _ in range(9):
            x = rng.uniform(fx - 120, fx + 120)
            d.line([(x, floor_y - 50), (x + rng.uniform(-16, 16), floor_y - 30), (x + rng.uniform(-20, 20), floor_y - 8)],
                   fill=255, width=2)
    cv.lay(mask_from(cracks, w, h, blur=0.4) * fb, STONE_D)
    def leaves(d):
        rng = np.random.default_rng(98)
        for _ in range(14):
            x = rng.uniform(fx - 136, fx + 136)
            d.ellipse((x - 4, floor_y - 55, x + 4, floor_y - 51), fill=255)
    cv.lay(mask_from(leaves, w, h, blur=0.5), WOOD * 0.9)

    # The street: cobbles with warm light pooled under the lamps.
    floor = np.zeros((h, w), np.float32)
    floor[floor_y:] = 1
    cob_col = STONE[None, None] * (0.6 + 0.35 * stone_n[..., None])
    cv.lay(floor, cob_col)
    def cobbles(d):
        rng = np.random.default_rng(99)
        y = floor_y + 16
        r = 0
        while y < h + 20:
            x = -rng.uniform(0, 40)
            while x < w:
                cw = rng.uniform(34, 56)
                d.ellipse((x + 3, y - 10, x + cw - 3, y + 10), fill=255)
                x += cw
            y += 22
            r += 1
    cm = mask_from(cobbles, w, h, blur=1.2) * floor
    cv.shade(floor * (1 - cm), 0.55)
    cv.shade(cm, 1.0 + 0.15 * (stone_n - 0.5))
    # The walking edge: a pale worn lip so the floor line reads under the feet.
    lip = ((yy >= floor_y) & (yy < floor_y + 10)).astype(np.float32)
    cv.lay(lip, STONE_L * (0.7 + 0.15 * stone_n[..., None]))
    cv.shade(((yy >= floor_y + 10) & (yy < floor_y + 16)).astype(np.float32), 0.6)
    cv.shade(floor, np.clip(1 - (yy - floor_y) / (h - floor_y) * 0.55, 0.4, 1))
    # Tufts of grass in the cracks along the lip.
    def tufts(d):
        rng = np.random.default_rng(100)
        for _ in range(60):
            x = rng.uniform(0, w)
            for k in range(4):
                d.line([(x + k * 3, floor_y + 2), (x + k * 3 + rng.uniform(-6, 6), floor_y - rng.uniform(6, 16))],
                       fill=255, width=2)
    cv.lay(mask_from(tufts, w, h, blur=0.4), MOSS)

    # Light: lamp pools and door glows warm everything they touch.
    light_field = glow(w, h, lights)
    pool = glow(w, h, [(px * T + 16, floor_y + 10, 160, AMBER, 0.5) for px in posts] +
                [(hx * T + 16, floor_y + 6, 200, AMBER, 0.3) for hx, _ in hanging])
    cv.light(light_field * 0.8 + pool * floor[..., None], cv.a)

    # Re-paint with brushes: broad first, then fine, bark and cobbles keep their grain.
    strokes(cv, 26000, (24, 56), (8, 14), 101, alpha=0.6, base_angle=0.0, follow=0.9)
    vert = np.zeros((h, w), np.float32)
    vert[:] = math.pi / 2
    vert[floor_y:] = 0.0
    strokes(cv, 60000, (10, 26), (3, 6), 102, alpha=0.7, follow=1.2, angle_field=vert)
    strokes(cv, 40000, (5, 12), (2, 3), 103, alpha=0.55, follow=1.4, angle_field=vert)
    # Glass and flames stay bright through the strokes.
    cv.light(glow(w, h, [(hx * T + 16, hy * T, 22, AMBER_L, 0.9) for hx, hy in hanging] +
                  [(px * T + 16, floor_y - 171, 20, AMBER_L, 0.9) for px in posts]))
    rough_edges(cv, 0.35, 5, 104)
    # Scenery a touch softer and cooler than the cast, so the sprites pop.
    soften(cv, DUSK, 0.06, sat=0.92)
    cv.rgb = np.clip(cv.rgb, 0, 1) ** 1.15 * 0.92
    grain(cv, 105, 0.03)
    # The floor and walls the player touches stay fully opaque.
    solidm = ndimage.binary_dilation(wall > 0.5, iterations=2).astype(np.float32)
    cv.a = np.maximum(cv.a, solidm * (yy >= floor_y - 2))
    cv.a = np.maximum(cv.a, ceil)
    return cv.image()


def main():
    (OUT / "eolis").mkdir(parents=True, exist_ok=True)
    paint_far().save(OUT / "eolis_far.png")
    print("eolis_far")
    paint_mid().save(OUT / "eolis_mid.png")
    print("eolis_mid")
    grid = read_room(ROOT / "levels" / "eolis" / "plaza.room")
    paint_plate(grid).save(OUT / "eolis" / "plaza.png")
    print("eolis/plaza")


if __name__ == "__main__":
    main()
