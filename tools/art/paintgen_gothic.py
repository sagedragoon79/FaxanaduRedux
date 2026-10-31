#!/usr/bin/env python3
"""Painterly scenery test, second take: the Fountain Plaza rebuilt in code after
Sean's GPT concept paintings (art/painted-test/nano_5..8.png): pale gothic elven
stone, pointed arches with tracery, blue banners with the tree emblem, lanterns
on iron brackets, a balustrade with a view over the misty root-town, a broken
stepped fountain, and the World Tree climbing behind with lit halls on its roots.

Same outputs and density as paintgen.py (which it borrows its brushes from):
assets/painted/eolis_far.png, eolis_mid.png and the room plate eolis/plaza.png,
painted from levels/eolis/plaza.room so it sits on the collision.

Usage: python3 tools/art/paintgen_gothic.py
"""
import math

import numpy as np
from scipy import ndimage

from paintgen import (ROOT, OUT, T, Canvas, crisp, glow, grain, hexc, mask_from, noise, read_room,
                      rough_edges, soften, strokes, vgrad)

INK = hexc("1a1626")
SKY_TOP = hexc("2c2848")
SKY_MID = hexc("5f5488")
SKY_LOW = hexc("9a7aa8")
PEACH = hexc("e8a27a")
HAZE = hexc("8f86b8")
STONE = hexc("9c96a0")
STONE_W = hexc("bfb4a4")
STONE_D = hexc("6e6676")
STONE_DD = hexc("4a4456")
BARK = hexc("5a4a5c")
BARK_D = hexc("3a3046")
LEAF = hexc("4f6a3c")
LEAF_D = hexc("2e4030")
LEAF_L = hexc("8aa05a")
BLUE = hexc("2c3d78")
BLUE_D = hexc("1d2850")
GOLD = hexc("d8b870")
AMBER = hexc("f2b04a")
AMBER_L = hexc("fff0b8")
WOOD = hexc("5a3e2a")
WOOD_D = hexc("3a281c")
FLOWER = hexc("e8e4d8")


def pointed(d, cx, base, hw, top, fill=255, outline=None, width=0):
    """A gothic pointed arch from `base` up to an apex at `top`, half-width `hw`:
    two arcs whose centers sit inside the opposite jamb (an equilateral arch)."""
    rise = min(base - top, hw * 1.7)
    spring = top + rise
    k = 0.75
    r = hw * (1 + k)
    # Apex height of two arcs centered at cx +- hw*k is sqrt(r^2 - (hw*k)^2); fit it to `rise`.
    ah = math.sqrt(r * r - (hw * k) ** 2)
    sy = rise / ah
    pts = [(cx - hw, base), (cx - hw, spring)]
    for i in range(1, 25):
        x = cx - hw + hw * i / 24
        dx = x - (cx + hw * k)
        y = spring - math.sqrt(max(0.0, r * r - dx * dx)) * sy
        pts.append((x, y))
    for i in range(24, 0, -1):
        x = 2 * cx - (cx - hw + hw * i / 24)
        dx = x - (cx - hw * k)
        y = spring - math.sqrt(max(0.0, r * r - dx * dx)) * sy
        pts.append((x, y))
    pts += [(cx + hw, spring), (cx + hw, base)]
    d.polygon(pts, fill=fill, outline=outline, width=width)


def blocks(w, h, bw, bh, seed, base, var=0.14):
    """Dressed stone: staggered blocks with value variation and dark mortar."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    row = np.floor(yy / bh)
    xs = xx + (row % 2) * bw * 0.5
    col = np.floor(xs / bw)
    rng = np.random.default_rng(seed)
    table = rng.uniform(1 - var, 1 + var, (int(h / bh) + 2, int(w / bw) + 3)).astype(np.float32)
    v = table[row.astype(int), col.astype(int) % table.shape[1]]
    n = noise(w, h, 10, seed + 1, octaves=3)
    c = base[None, None] * (v * (0.88 + 0.24 * n))[..., None]
    mortar = ((yy % bh) < 2.5) | ((xs % bw) < 2.5)
    c = np.where(mortar[..., None], STONE_DD[None, None], c)
    # Lit top edge on each block.
    c = np.where((((yy % bh) >= 2.5) & ((yy % bh) < 5))[..., None], c * 1.12, c)
    return c


def ivy(d, rng, x, y, length, spread=10, size=5, droop=True):
    """A hanging (or climbing) strand of ivy leaves."""
    px, py = x, y
    spread, size = spread * 0.6, size * 0.55
    for i in range(int(length / 4)):
        px += rng.normal(0, 1.2)
        py += 4 if droop else -4
        for _ in range(3):
            ox, oy = rng.normal(0, spread * 0.5), rng.normal(0, 3)
            s = size * rng.uniform(0.6, 1.2)
            d.ellipse((px + ox - s, py + oy - s * 0.7, px + ox + s, py + oy + s * 0.7), fill=255)


# --- far: the World Tree and its lit halls ------------------------------------

def paint_far():
    w, h = 1280, 960
    cv = Canvas(w, h, wrap=True)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    sky = vgrad(h, w, [(0.0, SKY_TOP), (0.35, SKY_MID), (0.55, SKY_LOW), (0.66, PEACH), (0.78, SKY_LOW),
                       (1.0, HAZE)])
    clouds = noise(w, h, 140, 201, wrap=True)
    sky = sky * (0.9 + 0.22 * clouds[..., None])
    cv.lay(np.ones((h, w)), sky)
    # Cloud bands lit peach from below.
    band = np.clip((noise(w, h, 90, 202, wrap=True) - 0.45) * 4, 0, 1) * np.exp(-((yy - 520) / 120) ** 2)
    cv.lay(band, PEACH * 0.9, 0.7)
    # The trunk: wide, twisting, with roots like cliffs.
    cx = 640 + 60 * np.sin(yy / 260)
    half = 230 + 0.00055 * np.clip(yy - 300, 0, None) ** 2
    trunk = np.clip((half - np.abs(xx - cx)) / 6, 0, 1)
    ridges = ndimage.zoom(noise(w, h, 12, 203, wrap=True, octaves=2)[::12, :], (12, 1), order=1)[:h]
    bark_n = noise(w, h, 40, 204, wrap=True)
    side = np.clip((xx - cx) / half, -1, 1)
    bark = BARK[None, None] * (0.75 + 0.5 * ridges[..., None]) * (0.8 + 0.3 * bark_n[..., None])
    bark = bark + np.clip(-side - 0.5, 0, 1)[..., None] * (PEACH - bark) * 0.35
    cv.lay(trunk, bark * (1 - 0.25 * np.clip(side, 0, 1))[..., None])
    # Root cliffs to both sides and a branch canopy at the top.
    def cliffs(d):
        for x0, x1, top in ((-80, 520, 520), (760, 1360, 500)):
            pts = [(x0, h)]
            for i in range(25):
                t = i / 24
                x = x0 + (x1 - x0) * t
                rise = math.sin(t * math.pi) if x0 < 0 else math.sin(t * math.pi)
                pts.append((x, top + 300 * (1 - rise) * (0.5 if (x0 < 0) == (t > 0.5) else 1) + 30 * math.sin(t * 9)))
            pts.append((x1, h))
            d.polygon(pts, fill=255)
        for x in range(0, w, 160):
            d.ellipse((x - 140, -60, x + 160, 110 + (x % 320) / 4), fill=255)
    cm = mask_from(cliffs, w, h, blur=1.0)
    cliff_col = BARK_D[None, None] * (0.85 + 0.5 * bark_n[..., None]) + LEAF_D * 0.25
    cv.lay(cm, cliff_col)
    # Gothic halls perched on the roots and trunk: little pale facades with lit windows.
    rng = np.random.default_rng(205)
    halls = []
    for _ in range(26):
        x, y = rng.uniform(0, w), rng.uniform(250, 760)
        if trunk[int(y), int(x)] > 0.5 or cm[int(y), int(x)] > 0.5:
            halls.append((x, y, rng.uniform(26, 60)))
    def hall_shapes(d):
        for x, y, s in halls:
            for off in (-w, 0, w):
                X = x + off
                d.rectangle((X - s, y - s * 0.8, X + s, y + s * 0.5), fill=255)
                d.polygon([(X - s * 0.3, y - s * 0.8), (X, y - s * 1.9), (X + s * 0.3, y - s * 0.8)], fill=255)
    hm = mask_from(hall_shapes, w, h, blur=0.8)
    cv.lay(hm, STONE_D * 1.15)
    lights = []
    def hall_windows(d):
        for x, y, s in halls:
            n = max(2, int(s / 12))
            for k in range(n):
                wx = x - s * 0.7 + k * (s * 1.4 / max(1, n - 1))
                for off in (-w, 0, w):
                    pointed(d, wx + off, y + s * 0.2, 3.5, y - s * 0.45)
                lights.append((wx, y - s * 0.1, 26, AMBER, 0.35))
    cv.lay(mask_from(hall_windows, w, h, blur=0.5), AMBER)
    # A long arched bridge between the roots.
    def bridge(d):
        for off in (-w, 0, w):
            d.rectangle((300 + off, 610, 980 + off, 632), fill=255)
            for k in range(8):
                x = 320 + off + k * 85
                d.rectangle((x, 632, x + 16, 720), fill=255)
    cv.lay(mask_from(bridge, w, h, blur=0.8), STONE_D * 1.05)
    cv.light(glow(w, h, lights, wrap=True))
    # Mist pooling low, the far side of the valley lost in it.
    mist = np.clip((yy - 600) / 300, 0, 1) ** 1.2 * (0.75 + 0.25 * noise(w, h, 120, 206, wrap=True))
    cv.lay(mist, HAZE, 0.8)
    strokes(cv, 9000, (30, 70), (8, 14), 207, alpha=0.6, base_angle=0.0, follow=0.6)
    strokes(cv, 14000, (10, 26), (3, 6), 208, alpha=0.6, base_angle=math.pi / 2, follow=1.0)
    soften(cv, HAZE, 0.32, sat=0.8)
    grain(cv, 209, 0.02)
    cv.a[:] = 1
    return cv.image()


# --- mid: gothic towers and trees across the valley ---------------------------

def paint_mid():
    w, h = 1280, 960
    cv = Canvas(w, h, wrap=True)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    ground = 780
    rng = np.random.default_rng(301)
    lights = []
    # Dark tree clumps first, then towers among them.
    def trees(d):
        for _ in range(60):
            x, y = rng.uniform(0, w), rng.uniform(560, 760)
            r = rng.uniform(30, 70)
            for off in (-w, 0, w):
                d.ellipse((x + off - r, y - r * 0.8, x + off + r, y + r), fill=255)
    tm = mask_from(trees, w, h, blur=1.0)
    leaf_n = noise(w, h, 14, 302, wrap=True, octaves=3)
    cv.lay(tm, LEAF_D[None, None] * (0.8 + 0.5 * leaf_n[..., None]))
    towers = [(60, 40, 250), (250, 34, 200), (430, 48, 290), (620, 30, 180), (800, 44, 260), (1010, 36, 220), (1180, 42, 240)]
    for i, (x, hw, tall) in enumerate(towers):
        top = ground - tall
        def body(d, x=x, hw=hw, top=top):
            for off in (-w, 0, w):
                X = x + off
                d.rectangle((X - hw, top, X + hw, ground + 40), fill=255)
                d.polygon([(X - hw - 10, top + 4), (X, top - hw * 2.2), (X + hw + 10, top + 4)], fill=255)
                for s in (-1, 1):
                    d.polygon([(X + s * hw - 10, top + 10), (X + s * hw, top - 40), (X + s * hw + 10, top + 10)],
                              fill=255)
        bm = mask_from(body, w, h, blur=0.8)
        side = np.clip(((xx - x + w / 2) % w - w / 2) / hw, -1, 1)
        col = STONE_D[None, None] * (1.05 - 0.3 * np.clip(side, 0, 1))[..., None] * (0.9 + 0.2 * leaf_n[..., None])
        col = col * (1.1 - 0.35 * np.clip((yy - top) / tall, 0, 1))[..., None]
        cv.lay(bm, col)
        def wins(d, x=x, hw=hw, top=top, tall=tall):
            for r in range(int((tall - 80) / 80)):
                for c in ((-0.45, 0.45) if hw > 60 else (0.0,)):
                    wx, wy = x + c * hw, top + 70 + r * 80
                    for off in (-w, 0, w):
                        pointed(d, wx + off, wy + 26, 9, wy - 24)
                    lights.append((wx, wy, 44, AMBER, 0.3))
        cv.lay(mask_from(wins, w, h, blur=0.6), AMBER)
    # An arched viaduct crossing behind the plaza.
    def viaduct(d):
        for off in (-w, 0, w):
            d.rectangle((off, 470, w + off, 500), fill=255)
            for k in range(14):
                x = off + k * 96
                d.rectangle((x, 500, x + 22, ground), fill=255)
    vm = mask_from(viaduct, w, h, blur=0.8)
    cv.lay(vm * (1 - 0.0), STONE_D * 0.85)
    cv.lay(np.clip((yy - ground + 10) / 30, 0, 1), STONE_DD)
    g = glow(w, h, lights, wrap=True)
    pre = cv.rgb.copy()
    strokes(cv, 16000, (16, 40), (5, 10), 303, alpha=0.6, base_angle=math.pi / 2, follow=1.0)
    strokes(cv, 14000, (6, 16), (2, 4), 304, alpha=0.6, base_angle=math.pi / 2, follow=1.2)
    crisp(cv, pre, keep=0.45, ink=0.15, sharpen=0.4)
    cv.light(g * 0.9, cv.a)
    rough_edges(cv, 0.25, 6, 305)
    soften(cv, HAZE, 0.38, sat=0.7)
    grain(cv, 306, 0.025)
    return cv.image()


# --- plate: the terrace itself -------------------------------------------------

def paint_plate(grid):
    rows, cols = len(grid), len(grid[0])
    w, h = cols * T, rows * T
    cv = Canvas(w, h)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    rng = np.random.default_rng(401)
    stone_n = noise(w, h, 18, 402, octaves=4)
    floor_y = next(y * T for y in range(rows) if y > rows // 2 and all(c == "#" for c in grid[y]))
    ceil_y = 0
    while all(c == "#" for c in grid[ceil_y]):
        ceil_y += 1
    ceil_y *= T
    door3, door4 = 18 * T + 16, 62 * T + 16
    lights = []
    stone_blocks = blocks(w, h, 58, 30, 403, STONE)
    big_blocks = blocks(w, h, 84, 40, 404, STONE * 0.8, var=0.18)

    # Balustrade along the terrace edge with gothic openings: the misty town shows through.
    def balustrade(d):
        d.rectangle((1040, floor_y - 92, 1900, floor_y - 78), fill=255)
        d.rectangle((1040, floor_y - 30, 1900, floor_y), fill=255)
        for k in range(int((1900 - 1040) / 46)):
            x = 1040 + k * 46
            d.rectangle((x, floor_y - 78, x + 10, floor_y - 30), fill=255)
    bm = mask_from(balustrade, w, h, blur=0.6)
    def openings(d):
        for k in range(int((1900 - 1040) / 46)):
            x = 1040 + k * 46 + 10
            pointed(d, x + 18, floor_y - 30, 14, floor_y - 74)
    om = mask_from(openings, w, h, blur=0.5)
    bal_col = STONE[None, None] * (0.8 + 0.3 * stone_n[..., None])
    cv.lay(np.clip(bm + (1 - om) * mask_from(lambda d: d.rectangle((1040, floor_y - 78, 1900, floor_y - 30), fill=255),
                                                  w, h), 0, 1), bal_col * 0.85)

    # The King's Hall: a pale gothic facade, pointed doorway with tracery, steps.
    def hall(d):
        d.rectangle((door3 - 230, 140, door3 + 230, floor_y), fill=255)
        d.polygon([(door3 - 250, 150), (door3, -10), (door3 + 250, 150)], fill=255)
    hm = mask_from(hall, w, h, blur=0.6)
    hside = np.clip((xx - door3) / 230, -1, 1)
    hall_col = stone_blocks * (0.95 - 0.25 * np.clip(hside, 0, 1))[..., None]
    hall_col = hall_col * (1.0 - 0.3 * np.clip((yy - 140) / (floor_y - 140), 0, 1) ** 2)[..., None]
    cv.lay(hm, hall_col)
    def hall_frame(d):
        pointed(d, door3, floor_y, 86, floor_y - 250)
        for x in (door3 - 200, door3 + 200):
            d.rectangle((x - 22, 150, x + 22, floor_y), fill=255)
            d.polygon([(x - 26, 160), (x, 80), (x + 26, 160)], fill=255)
    cv.lay(mask_from(hall_frame, w, h, blur=0.5), STONE_W * 0.9)
    def hall_recess(d):
        pointed(d, door3, floor_y, 66, floor_y - 222)
    cv.lay(mask_from(hall_recess, w, h, blur=0.5), STONE_D)
    def hall_door(d):
        pointed(d, door3, floor_y - 12, 50, floor_y - 196)
    cv.lay(mask_from(hall_door, w, h, blur=0.5), WOOD * (0.9 + 0.3 * stone_n[..., None]))
    def tracery(d):
        d.line([(door3, floor_y - 190), (door3, floor_y - 12)], fill=255, width=3)
        for k in range(4):
            y = floor_y - 160 + k * 34
            d.arc((door3 - 40, y - 20, door3, y + 20), 270, 90, fill=255, width=2)
            d.arc((door3, y - 20, door3 + 40, y + 20), 90, 270, fill=255, width=2)
        d.rectangle((door3 - 70, floor_y - 12, door3 + 70, floor_y), fill=255)
    cv.lay(mask_from(tracery, w, h, blur=0.4), GOLD * 0.75)
    def hall_windows(d):
        for x in (door3 - 140, door3 + 140):
            pointed(d, x, floor_y - 200, 22, floor_y - 330)
            pointed(d, x, 300, 18, 200)
    hw_m = mask_from(hall_windows, w, h, blur=0.5)
    cv.lay(hw_m, AMBER * (0.85 + 0.3 * stone_n[..., None]))
    def mullions(d):
        for x in (door3 - 140, door3 + 140):
            d.line([(x, floor_y - 320), (x, floor_y - 200)], fill=255, width=3)
            d.line([(x, 210), (x, 300)], fill=255, width=2)
    cv.lay(mask_from(mullions, w, h, blur=0.3), STONE_D)
    for x in (door3 - 140, door3 + 140):
        lights += [(x, floor_y - 260, 80, AMBER, 0.3), (x, 250, 50, AMBER, 0.2)]

    # The Temple of Mantras: a chapel front with a tall arched door and a rose window.
    def temple(d):
        d.rectangle((door4 - 210, 180, door4 + 210, floor_y), fill=255)
        d.polygon([(door4 - 230, 190), (door4, 20), (door4 + 230, 190)], fill=255)
    tm = mask_from(temple, w, h, blur=0.6)
    tside = np.clip((xx - door4) / 210, -1, 1)
    cv.lay(tm, stone_blocks * (0.92 - 0.25 * np.clip(-tside, 0, 1))[..., None] *
           (1.0 - 0.3 * np.clip((yy - 180) / (floor_y - 180), 0, 1) ** 2)[..., None])
    def temple_frame(d):
        pointed(d, door4, floor_y, 80, floor_y - 240)
        d.ellipse((door4 - 56, 210, door4 + 56, 322), fill=255)
    cv.lay(mask_from(temple_frame, w, h, blur=0.5), STONE_W * 0.9)
    def temple_door(d):
        pointed(d, door4, floor_y, 60, floor_y - 212)
    cv.lay(mask_from(temple_door, w, h, blur=0.5), BLUE_D * 1.2)
    def temple_tree(d):
        # The World Tree carved into the door in gold.
        d.line([(door4, floor_y - 20), (door4, floor_y - 170)], fill=255, width=4)
        for k in range(5):
            y = floor_y - 60 - k * 24
            ln = 34 - k * 5
            d.line([(door4, y), (door4 - ln, y - 22)], fill=255, width=3)
            d.line([(door4, y), (door4 + ln, y - 22)], fill=255, width=3)
    cv.lay(mask_from(temple_tree, w, h, blur=0.4), GOLD)
    def rose(d):
        d.ellipse((door4 - 44, 222, door4 + 44, 310), fill=255)
    cv.lay(mask_from(rose, w, h, blur=0.5), hexc("9fe0d0"))
    def rose_bars(d):
        for k in range(8):
            a = k * math.pi / 4
            d.line([(door4, 266), (door4 + 44 * math.cos(a), 266 + 44 * math.sin(a))], fill=255, width=3)
        d.ellipse((door4 - 14, 252, door4 + 14, 280), outline=255, width=3)
    cv.lay(mask_from(rose_bars, w, h, blur=0.3), STONE_D)
    lights.append((door4, 266, 110, hexc("8fd8c8"), 0.4))

    # Blue banners with the tree, hung from iron rods.
    ban = [(door3 - 290, 180), (door4 + 300, 200)]
    def banner(d):
        for x, y in ban:
            d.polygon([(x - 30, y), (x + 30, y), (x + 30, y + 200), (x, y + 230), (x - 30, y + 200)], fill=255)
    bnm = mask_from(banner, w, h, blur=0.5)
    def banner_trim(d):
        for x, y in ban:
            d.line([(x - 44, y - 2), (x + 44, y - 2)], fill=255, width=5)
            d.line([(x, y + 40), (x, y + 170)], fill=255, width=3)
            for k in range(4):
                yy_ = y + 70 + k * 26
                d.line([(x, yy_), (x - 18, yy_ - 18)], fill=255, width=2)
                d.line([(x, yy_), (x + 18, yy_ - 18)], fill=255, width=2)
    # The banners hang on stone piers that rise from the terrace.
    def piers(d):
        for x, y in ban:
            d.rectangle((x - 50, y - 30, x + 50, floor_y), fill=255)
    pm = mask_from(piers, w, h, blur=0.6)
    cv.lay(pm * (1 - bnm), big_blocks * 0.95)
    cv.lay(bnm, BLUE * (0.85 + 0.3 * stone_n[..., None]))
    cv.lay(mask_from(banner_trim, w, h, blur=0.4), GOLD)

    # Edge walls (the room's sides): more pale stone, ivy over them.
    side = np.zeros((h, w), np.float32)
    side[ceil_y:floor_y - 3 * T, :2 * T] = 1
    side[ceil_y:floor_y - 3 * T, w - 2 * T:] = 1
    cv.lay(ndimage.gaussian_filter(side, 1.2), big_blocks)
    def gate_lintels(d):
        for x0, x1 in ((0, 2 * T + 10), (w - 2 * T - 10, w)):
            d.rectangle((x0, floor_y - 3 * T - 26, x1, floor_y - 3 * T), fill=255)
    cv.lay(mask_from(gate_lintels, w, h, blur=0.5), STONE_W * 0.85)

    # The ledge: a timber beam out of the hall wall on a diagonal brace, a lantern under it.
    ledge = [(x, y) for y in range(rows) for x in range(cols) if grid[y][x] == "-"]
    if ledge:
        lx0, lx1 = min(c[0] for c in ledge) * T, (max(c[0] for c in ledge) + 1) * T
        ly = ledge[0][1] * T
        def beam(d):
            d.rectangle((lx0 - 6, ly, lx1 + 8, ly + 18), fill=255)
            d.polygon([(lx0 + 30, ly + 18), (lx0 + 44, ly + 18), (door3 + 236, ly + 130), (door3 + 230, ly + 146)],
                      fill=255)
            d.rectangle((lx1 - 2, ly - 6, lx1 + 10, ly + 24), fill=255)
        cv.lay(mask_from(beam, w, h, blur=0.5), WOOD * (0.85 + 0.4 * stone_n[..., None]))
        cv.shade(mask_from(lambda d: d.rectangle((lx0 - 6, ly + 12, lx1 + 8, ly + 18), fill=255), w, h), 0.6)
        lan_x = lx1 - 26
        def chain(d):
            d.line([(lan_x, ly + 18), (lan_x, ly + 50)], fill=255, width=3)
        cv.lay(mask_from(chain, w, h, blur=0.3), INK * 1.6)
        hang_lanterns = [(lan_x, ly + 72)]
    else:
        hang_lanterns = []

    # Lanterns on iron brackets beside the doors, plus the hanging one.
    bracket_lanterns = [(door3 - 112, floor_y - 240, 1), (door3 + 112, floor_y - 240, -1),
                        (door4 - 120, floor_y - 236, 1), (door4 + 120, floor_y - 236, -1),
                        (10 * T, floor_y - 210, 1), (55 * T, floor_y - 210, 1), (72 * T, floor_y - 210, -1)]
    # Free-standing posts where no wall is near.
    posts = [10 * T + 16, 55 * T + 16, 72 * T + 16]
    def post(d):
        for x in posts:
            d.rectangle((x - 9, floor_y - 160, x + 9, floor_y), fill=255)
            d.rectangle((x - 16, floor_y - 18, x + 16, floor_y), fill=255)
            d.rectangle((x - 14, floor_y - 168, x + 14, floor_y - 156), fill=255)
    cv.lay(mask_from(post, w, h, blur=0.5), STONE * (0.8 + 0.3 * stone_n[..., None]))
    def brackets(d):
        for x, y, s in bracket_lanterns[:4]:
            d.line([(x - s * 30, y - 20), (x, y - 20), (x, y - 6)], fill=255, width=4)
            d.arc((x - s * 30 - 12, y - 30, x - s * 30 + 12, y - 6), 0, 360, fill=255, width=3)
    cv.lay(mask_from(brackets, w, h, blur=0.3), INK * 1.5)
    lamp_spots = [(x, y + 18) for x, y, _ in bracket_lanterns[:4]] + [(x, floor_y - 190) for x in posts] + hang_lanterns
    def lantern_body(d):
        for x, y in lamp_spots:
            d.polygon([(x - 6, y - 28), (x + 6, y - 28), (x + 14, y - 16), (x + 12, y + 16), (x - 12, y + 16),
                       (x - 14, y - 16)], fill=255)
            d.polygon([(x - 10, y + 16), (x + 10, y + 16), (x, y + 26)], fill=255)
    cv.lay(mask_from(lantern_body, w, h, blur=0.4), INK * 1.8)
    def lantern_glass(d):
        for x, y in lamp_spots:
            d.rectangle((x - 9, y - 14, x + 9, y + 12), fill=255)
    cv.lay(mask_from(lantern_glass, w, h, blur=0.4), AMBER)
    lights += [(x, y, 200, AMBER, 0.42) for x, y in lamp_spots]

    # The plinth and the two posts at the fountain: carved stone with pinnacle-capped faces.
    solid = np.zeros((h, w), np.float32)
    for y in range(rows):
        for x in range(cols):
            if grid[y][x] == "#":
                solid[y * T:(y + 1) * T, x * T:(x + 1) * T] = 1
    lone = solid.copy()
    lone[:ceil_y + T] = 0
    lone[floor_y:] = 0
    lone[:, :3 * T] = 0
    lone[:, w - 3 * T:] = 0
    lab, n = ndimage.label(lone > 0.5)
    for i in range(1, n + 1):
        ys, xs = np.nonzero(lab == i)
        x0, x1, y0 = xs.min(), xs.max() + 1, ys.min()
        def blk(d):
            d.rectangle((x0 - 2, y0 + 10, x1 + 2, floor_y), fill=255)
            d.rectangle((x0 - 8, y0, x1 + 8, y0 + 12), fill=255)
            d.rectangle((x0 - 8, floor_y - 14, x1 + 8, floor_y), fill=255)
        m = mask_from(blk, w, h, blur=0.5)
        bside = np.clip((xx - (x0 + x1) / 2) / ((x1 - x0) / 2 + 8), -1, 1)
        cv.lay(m, STONE[None, None] * (0.8 + 0.3 * stone_n[..., None]) * (1 - 0.3 * np.clip(bside, 0, 1))[..., None])
        if floor_y - y0 > 2 * T:
            def panel(d):
                pointed(d, (x0 + x1) / 2, floor_y - 24, (x1 - x0) / 2 - 10, y0 + 22, outline=255, width=3, fill=0)
            cv.lay(mask_from(panel, w, h, blur=0.4), STONE_D)

    # The Fountain of Eolis: a stepped base, carved pedestal, the bowl split and dry.
    fx = 40 * T + 16
    def fountain(d):
        d.rectangle((fx - 150, floor_y - 18, fx + 150, floor_y), fill=255)
        d.rectangle((fx - 124, floor_y - 36, fx + 124, floor_y - 16), fill=255)
        d.rectangle((fx - 96, floor_y - 54, fx + 96, floor_y - 34), fill=255)
        d.polygon([(fx - 40, floor_y - 54), (fx + 40, floor_y - 54), (fx + 24, floor_y - 120), (fx + 40, floor_y - 150),
                   (fx - 40, floor_y - 150), (fx - 24, floor_y - 120)], fill=255)
        d.chord((fx - 110, floor_y - 210, fx + 110, floor_y - 130), 0, 180, fill=255)
        d.rectangle((fx - 116, floor_y - 176, fx + 116, floor_y - 164), fill=255)
    fm = mask_from(fountain, w, h, blur=0.5)
    fside = np.clip((xx - fx) / 150, -1, 1)
    cv.lay(fm, STONE[None, None] * (0.78 + 0.3 * stone_n[..., None]) * (1 - 0.28 * np.clip(fside, 0, 1))[..., None])
    def step_shadow(d):
        for y in (floor_y - 18, floor_y - 36):
            d.rectangle((fx - 150, y - 3, fx + 150, y), fill=255)
    cv.shade(mask_from(step_shadow, w, h, blur=0.4) * fm, 0.6)
    def split(d):
        # The bowl is broken: a dark wedge out of its middle and a crack down the pedestal.
        d.polygon([(fx - 14, floor_y - 177), (fx + 18, floor_y - 177), (fx + 2, floor_y - 140)], fill=255)
        d.line([(fx + 2, floor_y - 140), (fx - 6, floor_y - 110), (fx + 4, floor_y - 80), (fx - 2, floor_y - 54)],
               fill=255, width=2)
    cv.lay(mask_from(split, w, h, blur=0.4), STONE_DD)
    def arches(d):
        for k in range(5):
            pointed(d, fx - 64 + k * 32, floor_y - 58, 9, floor_y - 92, outline=255, width=2, fill=0)
    cv.lay(mask_from(arches, w, h, blur=0.3), STONE_D)

    # The terrace: big flagstones on top, then the dressed-stone face of the wall below.
    top_band = ((yy >= floor_y) & (yy < floor_y + 30)).astype(np.float32)
    flag = blocks(w, h, 96, 15, 405, STONE_W * 0.85, var=0.12)
    cv.lay(top_band, flag)
    face = (yy >= floor_y + 30).astype(np.float32)
    cv.lay(face, big_blocks * 0.8)
    cv.shade(((yy >= floor_y + 28) & (yy < floor_y + 36)).astype(np.float32), 0.55)
    cv.shade(face, np.clip(1 - (yy - floor_y - 30) / (h - floor_y) * 0.6, 0.3, 1))

    # The ceiling: a great bough, dark bark, with ivy hanging in curtains.
    bark_n = noise(w, h, 30, 406, octaves=4)
    edge = ceil_y + 8 * np.sin(xx[0] / 90) + 6 * np.sin(xx[0] / 31)
    ceil = (yy < edge[None, :]).astype(np.float32)
    cv.lay(ndimage.gaussian_filter(ceil, 1.2), BARK_D[None, None] * (0.8 + 0.6 * bark_n[..., None]))
    def ivy_draw(d, seed, droop=True, area=None):
        r = np.random.default_rng(seed)
        if droop:
            for _ in range(46):
                x = r.uniform(0, w)
                ivy(d, r, x, ceil_y - 6, r.uniform(30, 160), spread=12, size=6)
        else:
            for x0, x1 in area:
                for _ in range(10):
                    x = r.uniform(x0, x1)
                    ivy(d, r, x, floor_y, r.uniform(60, 300), spread=14, size=6, droop=False)
    ivy_m = mask_from(lambda d: ivy_draw(d, 407), w, h, blur=0.5)
    climb = mask_from(lambda d: ivy_draw(d, 408, False, [(door3 - 240, door3 - 160), (door3 + 170, door3 + 240),
                                                         (door4 + 150, door4 + 220), (0, 2 * T), (w - 2 * T, w)]),
                      w, h, blur=0.5)
    leaf_n = noise(w, h, 8, 409, octaves=2)
    leaf_col = LEAF_D[None, None] + (LEAF - LEAF_D)[None, None] * leaf_n[..., None] * 1.4
    cv.lay(np.clip(ivy_m + climb * 0.9, 0, 1), leaf_col)
    # Leaf highlights where the lamps catch them.
    hi = np.clip(ivy_m + climb, 0, 1) * (leaf_n > 0.62)
    cv.lay(hi, LEAF_L, 0.8)

    # Urns of pale flowers at the doors.
    urns = [door3 - 120, door3 + 120, door4 - 120, door4 + 120]
    def urn(d):
        for x in urns:
            d.polygon([(x - 18, floor_y - 40), (x + 18, floor_y - 40), (x + 10, floor_y - 8), (x + 14, floor_y),
                       (x - 14, floor_y), (x - 10, floor_y - 8)], fill=255)
    cv.lay(mask_from(urn, w, h, blur=0.4), STONE * 0.85)
    def bloom(d):
        for x in urns:
            for _ in range(16):
                bx, by = x + rng.normal(0, 14), floor_y - 48 - abs(rng.normal(0, 10))
                d.ellipse((bx - 5, by - 5, bx + 5, by + 5), fill=255)
    fl = mask_from(bloom, w, h, blur=0.4)
    cv.lay(fl, LEAF_D)
    def petals(d):
        for x in urns:
            for _ in range(10):
                bx, by = x + rng.normal(0, 13), floor_y - 52 - abs(rng.normal(0, 9))
                d.ellipse((bx - 2.5, by - 2.5, bx + 2.5, by + 2.5), fill=255)
    cv.lay(mask_from(petals, w, h, blur=0.3), FLOWER)
    def tufts(d):
        r = np.random.default_rng(410)
        for _ in range(70):
            x = r.uniform(0, w)
            for k in range(4):
                d.line([(x + k * 3, floor_y + 2), (x + k * 3 + r.uniform(-5, 5), floor_y - r.uniform(5, 13))],
                       fill=255, width=2)
    cv.lay(mask_from(tufts, w, h, blur=0.3), LEAF)

    # Light: warm pools from every lamp, the terrace lip glowing under them.
    lf = glow(w, h, lights)
    pool = glow(w, h, [(x, floor_y + 8, 200, AMBER, 0.5) for x, _ in lamp_spots])
    # Cool ambient first: the side away from the lamps sinks into violet.
    cv.rgb = cv.rgb * (0.78 + 0.22 * hexc("8a86c0"))[None, None]
    cv.light(lf * 0.75 + pool * (yy >= floor_y)[..., None], cv.a)
    pre = cv.rgb.copy()
    strokes(cv, 22000, (20, 46), (6, 12), 411, alpha=0.4, base_angle=0.0, follow=1.0)
    vert = np.full((h, w), math.pi / 2, np.float32)
    vert[floor_y:] = 0.0
    strokes(cv, 60000, (8, 20), (2, 5), 412, alpha=0.6, follow=1.3, angle_field=vert)
    crisp(cv, pre, keep=0.7, ink=0.45, sharpen=0.8)
    cv.light(glow(w, h, [(x, y, 18, AMBER_L, 1.0) for x, y in lamp_spots]))
    rough_edges(cv, 0.12, 5, 413)
    cv.rgb = np.clip(cv.rgb, 0, 1) ** 1.08
    grain(cv, 414, 0.03)
    cv.a = np.maximum(cv.a, (yy >= floor_y).astype(np.float32))
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
