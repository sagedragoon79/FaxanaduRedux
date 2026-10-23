#!/usr/bin/env python3
"""Generates the enemy and NPC sprite sheets in the player's style (design
bible 12.3 and 13.3), with tools/art/pixelrig.py.

Enemies: monodron, hornet, rot_dwarf, sap_spitter, grub_lump, iron_dwarf (drawn at 2x); the parts of the boss Rokusutahn. Each frame's metadata gives the points
the game draws on top (the Monodron's eye, which tracks the player).
NPCs: one sheet per person in data/npcs.json, "npc_<id>", built from their
"look" (robe, trim, skin, hair, hat, plus optional beard and build), with every
color snapped to the master palette.

Usage: python3 tools/art/castgen.py
"""
import json
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pixelrig import PAL, ROOT, Canvas, ik, mat, mat_from, reach, write_sheet  # noqa: E402

EYE_WHITE = PAL["stone-7"]
DARK = PAL["night-1"]


# --- Monodron: a one-eyed hopper ----------------------------------------------

MONO_BODY = mat("night", 4, 3, 2, 0)
MONO_BELLY = mat("crystal", 6, 5, 4, 2)
MONO_HORN = mat("gold", 6, 5, 4, 2)
MONO_FEET = mat("night", 2, 1, 1, 0)


def monodron(rx, ry, lift=0.0, horn_tilt=0.0):
    def render(_):
        cv = Canvas(40, 32, (20, 30))
        cy = -ry - lift
        for side in (-1, 1):
            cv.part(cv.ellipse((side * (rx - 3.5), -1.2 - lift * 0.6), 2.6, 1.6), MONO_FEET)
        cv.part(cv.capsule((1, cy - ry + 1), (2 + horn_tilt, cy - ry - 3), 1.2), MONO_HORN)
        cv.part(cv.ellipse((0, cy), rx, ry), MONO_BODY, deep=True)
        belly = cv.ellipse((0.5, cy + ry * 0.45), rx * 0.62, ry * 0.42) & cv.ellipse((0, cy), rx - 1.5, ry - 1.5)
        cv.part(belly, MONO_BELLY)
        eye = (1.0, cy - ry * 0.25)
        cv.flat(cv.ellipse(eye, 3.6, 3.0), EYE_WHITE)
        cv.pixel((eye[0] - 2.0, eye[1] - 2.0), PAL["stone-6"])
        img, mask = cv.finish()
        return img, mask, {"eye": [round(eye[0], 1), round(eye[1], 1)]}
    return render


MONODRON = [
    ("idle", [monodron(9.0, 7.5), monodron(9.3, 7.2)], [0, 1], 3, True),
    ("windup", [monodron(10.5, 6.0, horn_tilt=-1), monodron(11.0, 5.6, horn_tilt=-1)], [0, 1], 8, True),
    ("hop", [monodron(8.0, 9.0, lift=2.0, horn_tilt=1)], [0], 1, False),
]


# --- Hornet -------------------------------------------------------------------

H_ABDOMEN = mat("gold", 5, 4, 3, 1)
H_THORAX = mat("bark", 3, 2, 1, 0)
H_HEAD = mat("gold", 4, 3, 2, 0)
H_WING = mat("sky", 7, 6, 5, 3)
H_STING = mat("stone", 7, 6, 4, 2)


def hornet(wing, curl=0.0, tilt=0.0):
    """wing: 'up', 'down' or 'back'. curl tucks the abdomen and sting forward."""
    def render(_):
        cv = Canvas(40, 32, (20, 16))
        rot = math.radians(tilt)

        def r(p):
            return (p[0] * math.cos(rot) - p[1] * math.sin(rot), p[0] * math.sin(rot) + p[1] * math.cos(rot))
        wings = {"up": ((-1, -7), 5.0, 2.4), "down": ((-2, -3.5), 5.5, 1.6), "back": ((-5, -5), 5.5, 1.8)}
        wc, wrx, wry = wings[wing]
        cv.part(cv.ellipse(r((wc[0] + 2, wc[1] + 0.5)), wrx * 0.8, wry), mat("sky", 6, 5, 4, 2))
        abd = r((-4 + curl * 0.5, curl * 1.5))
        sting_a = r((-9 + curl * 2.5, 1 + curl * 4))
        sting_b = r((-12 + curl * 5, 2 + curl * 7))
        cv.part(cv.capsule(sting_a, sting_b, 0.8), H_STING)
        cv.part(cv.ellipse(abd, 6.0, 4.4), H_ABDOMEN, deep=True)
        stripes = (cv.right_of(abd[0] - 2.5) & ~cv.right_of(abd[0] - 1.0)) | (cv.right_of(abd[0] + 0.5) & ~cv.right_of(abd[0] + 2.0))
        cv.flat(stripes & cv.ellipse(abd, 5.6, 4.0), DARK)
        for lx in (1.5, 3.5):
            cv.part(cv.capsule(r((lx, 2)), r((lx - 1, 5)), 0.6), mat("night", 2, 1, 1, 0))
        cv.part(cv.ellipse(r((3, -1)), 3.6, 3.4), H_THORAX)
        cv.part(cv.ellipse(r((7.5, -1)), 2.8, 2.6), H_HEAD)
        e = r((8.5, -1.5))
        cv.pixel(e, PAL["ember-3"])
        cv.pixel((e[0] + 1, e[1]), PAL["ember-4"])
        cv.part(cv.ellipse(r(wc), wrx, wry), H_WING)
        img, mask = cv.finish()
        return img, mask, {}
    return render


HORNET = [
    ("fly", [hornet("up"), hornet("down")], [0, 1], 24, True),
    ("windup", [hornet("up", curl=1.0, tilt=-8), hornet("down", curl=1.0, tilt=-8)], [0, 1], 30, True),
    ("swoop", [hornet("back", curl=0.4, tilt=12), hornet("back", curl=0.4, tilt=14)], [0, 1], 16, True),
]


# --- Rot Dwarf -----------------------------------------------------------------

D_SKIN = mat("leaf", 4, 3, 2, 0)
D_SKIN_BACK = mat("leaf", 3, 2, 1, 0)
D_ARMOR = mat("stone", 4, 3, 2, 0)
D_ARMOR_BACK = mat("stone", 3, 2, 1, 0)
D_BEARD = mat("stone", 7, 6, 5, 3)
D_HELM = mat("stone", 5, 4, 3, 1)
D_BOOT = mat("bark", 2, 1, 0, 0)
D_SHIELD = mat("bark", 4, 3, 2, 1)
D_RIM = mat("stone", 7, 6, 5, 3)
D_HAFT = mat("bark", 3, 2, 1, 0)
D_AXE = mat("stone", 7, 6, 5, 3)


def dwarf(hip=(0, -9), lean=0, feet=((4, 0), (-4, 0)), axe_hand=(-6, -14), axe_angle=-100,
          shield=True, shield_hand=(7, -15), bob=0):
    """axe_angle: degrees of the axe haft from the back hand (0 = forward, -90 = up)."""
    def render(_):
        cv = Canvas(48, 48, (24, 45))
        hx, hy = hip
        sx, sy = hx + lean, hy - 12 + bob
        head = (sx + 1, sy - 6)

        def leg(h, foot, m, boot):
            foot = reach(h, foot, 9.3)
            knee = ik(h, foot, 4.8, 4.8, 1)
            cv.part(cv.capsule(h, knee, 2.6) | cv.capsule(knee, foot, 2.4), m)
            cv.part(cv.capsule((foot[0] - 1.5, foot[1] - 2), (foot[0] + 2.5, foot[1] - 1.5), 2.2), boot)

        # The axe, in the back hand.
        a = math.radians(axe_angle)
        hand_b = reach((sx - 3, sy + 2), axe_hand, 11)
        haft_end = (hand_b[0] + math.cos(a) * 14, hand_b[1] + math.sin(a) * 14)
        butt = (hand_b[0] - math.cos(a) * 3, hand_b[1] - math.sin(a) * 3)
        cv.part(cv.capsule(butt, haft_end, 1.1), D_HAFT)
        perp = (-math.sin(a), math.cos(a))
        blade = [(haft_end[0] - math.cos(a) * 5 + perp[0] * 1, haft_end[1] - math.sin(a) * 5 + perp[1] * 1),
                 (haft_end[0] + perp[0] * 1, haft_end[1] + perp[1] * 1),
                 (haft_end[0] + perp[0] * 6 + math.cos(a) * 2, haft_end[1] + perp[1] * 6 + math.sin(a) * 2),
                 (haft_end[0] - math.cos(a) * 7 + perp[0] * 6, haft_end[1] - math.sin(a) * 7 + perp[1] * 6)]
        cv.part(cv.polygon(blade), D_AXE)
        elbow = ik((sx - 3, sy + 2), hand_b, 5.5, 5.5, -1)
        cv.part(cv.capsule((sx - 3, sy + 2), elbow, 2.2) | cv.capsule(elbow, hand_b, 2.0), D_ARMOR_BACK)
        cv.part(cv.ellipse(hand_b, 2.0, 2.0), D_SKIN_BACK)
        leg((hx - 2, hy), feet[1], D_ARMOR_BACK, D_BOOT)
        leg((hx + 2, hy), feet[0], D_ARMOR, D_BOOT)
        torso = cv.polygon([(sx - 6.5, sy), (sx + 6.5, sy), (hx + 7, hy + 1), (hx - 7, hy + 1)]) | cv.ellipse((sx, sy + 2), 7, 3.2)
        cv.part(torso, D_ARMOR, deep=True)
        cv.part(cv.capsule((hx - 6.5, hy - 1), (hx + 6.5, hy - 1), 1.0), mat("bark", 3, 2, 1, 0))
        # Head under a helm, the beard over the chest.
        cv.part(cv.ellipse(head, 5.0, 4.6), D_SKIN)
        cv.part(cv.ellipse((head[0] - 0.5, head[1] - 2.5), 5.8, 3.4) & ~cv.below(head[1] - 1.0), D_HELM)
        cv.part(cv.capsule((head[0] - 5, head[1] - 2), (head[0] + 5, head[1] - 2), 1.0), D_HELM)
        cv.part(cv.capsule((head[0] - 5.5, head[1] - 3), (head[0] - 8, head[1] - 6), 0.9), mat("stone", 7, 6, 5, 3))
        beard = cv.polygon([(head[0] - 3, head[1] + 1), (head[0] + 5, head[1] + 1), (head[0] + 3, sy + 8), (head[0] - 1, sy + 9)])
        cv.part(beard, D_BEARD)
        cv.pixel((head[0] + 2.5, head[1] - 0.5), PAL["gold-5"])
        cv.pixel((head[0] + 3.5, head[1] - 0.5), PAL["gold-4"])
        # Shield arm in front.
        hand_f = reach((sx + 3, sy + 2), shield_hand, 11)
        elbow_f = ik((sx + 3, sy + 2), hand_f, 5.5, 5.5, -1)
        cv.part(cv.capsule((sx + 3, sy + 2), elbow_f, 2.2) | cv.capsule(elbow_f, hand_f, 2.0), D_ARMOR)
        if shield:
            sh = (hand_f[0] + 2, hand_f[1])
            cv.part(cv.ellipse(sh, 4.0, 9.0), D_RIM)
            cv.part(cv.ellipse(sh, 3.0, 8.0), D_SHIELD, deep=True)
            cv.part(cv.ellipse((sh[0] + 0.5, sh[1]), 1.4, 1.6), D_RIM)
        else:
            cv.part(cv.ellipse(hand_f, 2.0, 2.0), D_SKIN)
        img, mask = cv.finish()
        return img, mask, {}
    return render


def dwarf_walk(i):
    t = i / 4 * math.tau
    fx = 3.5 * math.cos(t)
    return dwarf(hip=(0, -9 - (1 if i % 2 else 0)), feet=((fx, -max(0, 2 * math.sin(t))), (-fx, -max(0, -2 * math.sin(t)))),
                 axe_hand=(-6, -14), axe_angle=-100 + 6 * math.cos(t), bob=0)


ROT_DWARF = [
    ("walk", [dwarf_walk(i) for i in range(4)], [0, 1, 2, 3], 6, True),
    ("windup", [dwarf(lean=-2, axe_hand=(-3, -27), axe_angle=-150, shield=False, shield_hand=(5, -14)),
                dwarf(lean=-3, axe_hand=(-4, -28), axe_angle=-160, shield=False, shield_hand=(5, -13))], [0, 1], 8, True),
    ("swing", [dwarf(lean=3, feet=((6, 0), (-5, 0)), axe_hand=(9, -18), axe_angle=-10, shield=False, shield_hand=(2, -12)),
               dwarf(lean=3, feet=((6, 0), (-5, 0)), axe_hand=(10, -12), axe_angle=30, shield=False, shield_hand=(1, -12))],
     [0, 1], 14, False),
    ("recover", [dwarf(lean=1, axe_hand=(5, -8), axe_angle=70)], [0], 1, False),
    ("stagger", [dwarf(lean=-4, feet=((2, 0), (-6, 0)), axe_hand=(-8, -20), axe_angle=-170, shield=False,
                       shield_hand=(6, -24))], [0], 1, False),
]


# --- Iron Dwarf: a Forepaw dwarf in iron plate with a two-handed hammer --------
# Drawn at the 2x render density (Canvas scale 2): world-pixel geometry, half-pixel detail.

I_PLATE = mat("stone", 5, 3, 2, 0)
I_PLATE_BACK = mat("stone", 3, 2, 1, 0)
I_HELM = mat("stone", 6, 5, 3, 1)
I_GOLD = mat("gold", 6, 5, 3, 1)
I_BEARD = mat("bark", 4, 3, 2, 0)
I_SKIN = mat_from("#f0c09a", ["ember", "bark", "gold"])
I_BOOT = mat("bark", 3, 2, 1, 0)
I_HAFT = mat("bark", 5, 4, 3, 1)
I_HEAD = mat("stone", 6, 4, 2, 0)
ID_SCALE = 2


def iron_dwarf(hip=(0, -11), lean=0, feet=((5, 0), (-5, 0)), hands=(6, -20), hammer=-140, bob=0, crouch=0):
    """hammer: degrees of the haft from the hands toward the head (0 = forward, -90 = up)."""
    def render(_):
        cv = Canvas(72, 64, (32, 61), ID_SCALE)
        hx, hy = hip[0], hip[1] + crouch
        sx, sy = hx + lean, hy - 13 + bob
        head = (sx + 1.5, sy - 6)

        def leg(h, foot, m, boot):
            foot = reach(h, foot, 10.5)
            knee = ik(h, foot, 5.5, 5.5, 1)
            cv.part(cv.capsule(h, knee, 3.2) | cv.capsule(knee, foot, 2.8), m)
            cv.part(cv.capsule((foot[0] - 2, foot[1] - 2), (foot[0] + 3, foot[1] - 1.6), 2.5), boot)
            cv.part(cv.ellipse((knee[0] + 0.5, knee[1]), 2.2, 2.0), I_GOLD)

        # The hammer, gripped in both hands.
        a = math.radians(hammer)
        grip = reach((sx, sy + 2), hands, 12)
        tip = (grip[0] + math.cos(a) * 17, grip[1] + math.sin(a) * 17)
        butt = (grip[0] - math.cos(a) * 5, grip[1] - math.sin(a) * 5)
        perp = (-math.sin(a), math.cos(a))
        leg((hx - 3, hy), feet[1], I_PLATE_BACK, I_BOOT)
        # Back arm, then the haft and head over it.
        elbow_b = ik((sx - 4, sy + 2), grip, 6.5, 6.5, -1)
        cv.part(cv.capsule((sx - 4, sy + 2), elbow_b, 2.7) | cv.capsule(elbow_b, grip, 2.4), I_PLATE_BACK)
        cv.part(cv.capsule(butt, tip, 1.2), I_HAFT)
        hw, hl = 4.2, 6.5  # half width across the haft, half length along it
        corners = [(tip[0] + perp[0] * s1 * hl + math.cos(a) * s2 * hw, tip[1] + perp[1] * s1 * hl + math.sin(a) * s2 * hw)
                   for s1, s2 in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
        cv.part(cv.polygon(corners), I_HEAD, deep=True)
        band = [(tip[0] + perp[0] * s1 * (hl - 2.2) + math.cos(a) * s2 * (hw + 0.4),
                 tip[1] + perp[1] * s1 * (hl - 2.2) + math.sin(a) * s2 * (hw + 0.4)) for s1, s2 in ((-1, -1), (-0.55, -1), (-0.55, 1), (-1, 1))]
        cv.part(cv.polygon(band), I_GOLD)
        band2 = [(tip[0] + perp[0] * s1 * (hl - 2.2) + math.cos(a) * s2 * (hw + 0.4),
                  tip[1] + perp[1] * s1 * (hl - 2.2) + math.sin(a) * s2 * (hw + 0.4)) for s1, s2 in ((0.55, -1), (1, -1), (1, 1), (0.55, 1))]
        cv.part(cv.polygon(band2), I_GOLD)
        leg((hx + 3, hy), feet[0], I_PLATE, I_BOOT)
        # A broad torso in plate, with a gold-trimmed belt.
        torso = cv.polygon([(sx - 8, sy), (sx + 8, sy), (hx + 8.5, hy + 1), (hx - 8.5, hy + 1)]) | cv.ellipse((sx, sy + 2), 8.5, 4)
        cv.part(torso, I_PLATE, deep=True)
        cv.part(cv.capsule((hx - 8, hy - 1.5), (hx + 8, hy - 1.5), 1.4), mat("bark", 4, 3, 2, 0))
        cv.part(cv.ellipse((hx + 1, hy - 1.5), 2.0, 1.8), I_GOLD)
        cv.part(cv.ellipse((sx - 5, sy + 1), 4.0, 3.2), I_PLATE)  # pauldron
        # Front arm, both hands on the haft.
        elbow_f = ik((sx + 4, sy + 2), grip, 6.5, 6.5, -1)
        cv.part(cv.capsule((sx + 4, sy + 2), elbow_f, 2.7) | cv.capsule(elbow_f, grip, 2.4), I_PLATE)
        cv.part(cv.ellipse(grip, 2.3, 2.3), I_SKIN)
        # Head, over the arms: a face under a full helm with a nose guard and a ridge.
        cv.part(cv.ellipse(head, 5.2, 4.8), I_SKIN)
        helm = cv.ellipse((head[0] - 0.3, head[1] - 2.2), 6.3, 4.2) & ~cv.below(head[1] - 0.6)
        cv.part(helm, I_HELM)
        cv.part(cv.capsule((head[0] - 6, head[1] - 1.5), (head[0] + 6, head[1] - 1.5), 1.2), I_HELM)
        cv.part(cv.capsule((head[0] + 3.2, head[1] - 1.5), (head[0] + 3.2, head[1] + 1.5), 0.8), I_HELM)
        cv.part(cv.capsule((head[0] - 4.5, head[1] - 5.8), (head[0] + 2, head[1] - 6.6), 1.0), I_GOLD)
        beard = cv.polygon([(head[0] - 1.5, head[1] + 2.2), (head[0] + 5.2, head[1] + 2.2), (head[0] + 4.2, sy + 5.5),
                            (head[0] + 1.6, sy + 7.5), (head[0] - 0.8, sy + 5)])
        cv.part(beard, I_BEARD)
        cv.part(cv.capsule((head[0] + 1.6, sy + 4), (head[0] + 1.8, sy + 8), 0.6), mat("bark", 3, 3, 2, 1))
        cv.part(cv.ellipse((head[0] + 1.8, sy + 8.4), 0.9, 0.7), I_GOLD)
        cv.part(cv.ellipse((head[0] + 4.6, head[1] + 0.8), 1.4, 1.2), I_SKIN)  # nose
        # The eye glints under the brim: something in the iron has hold of him.
        cv.pixel((head[0] + 2, head[1] - 0.4), PAL["ember-6"])
        img, mask = cv.finish()
        return img, mask, {}
    return render


def iron_walk(i):
    t = i / 4 * math.tau
    fx = 4.5 * math.cos(t)
    return iron_dwarf(hip=(0, -11 - (1 if i % 2 else 0)),
                      feet=((fx, -max(0, 2.5 * math.sin(t))), (-fx, -max(0, -2.5 * math.sin(t)))),
                      hands=(6, -13), hammer=-150 + 5 * math.cos(t))


IRON_DWARF = [
    ("walk", [iron_walk(i) for i in range(4)], [0, 1, 2, 3], 5, True),
    ("windup", [iron_dwarf(lean=-3, hands=(-1, -33), hammer=-125, feet=((6, 0), (-6, 0))),
                iron_dwarf(lean=-4, hands=(-2, -34), hammer=-118, feet=((6, 0), (-6, 0)), bob=-1)], [0, 1], 8, True),
    ("slam", [iron_dwarf(lean=3, hands=(10, -26), hammer=-25, feet=((7, 0), (-6, 0))),
              iron_dwarf(lean=5, hands=(13, -12), hammer=60, feet=((8, 0), (-6, 0)), crouch=2)], [0, 1], 16, False),
    ("stuck", [iron_dwarf(lean=6, hands=(13, -10), hammer=72, feet=((8, 0), (-6, 0)), crouch=3),
               iron_dwarf(lean=5, hands=(13, -11), hammer=70, feet=((8, 0), (-6, 0)), crouch=3, bob=1)], [0, 1], 4, True),
    ("recover", [iron_dwarf(lean=2, hands=(9, -16), hammer=10)], [0], 1, False),
    ("stagger", [iron_dwarf(lean=-5, feet=((3, 0), (-7, 0)), hands=(-4, -28), hammer=-170)], [0], 1, False),
]


# --- Rokusutahn: the body parts the boss script chains together ----------------

R_BARK = mat("bark", 3, 2, 1, 0)
R_CROWN = mat("bark", 5, 4, 3, 1)
R_HEAD = mat("bark", 2, 1, 1, 0)
R_MANDIBLE = mat("bark", 6, 5, 4, 2)
R_TAIL = mat("gold", 5, 4, 3, 1)
R_TAIL_HOT = mat("gold", 6, 5, 4, 2)


def roku_plate(cracked):
    """A bark-plated body segment, travelling toward +x (radius 17)."""
    def render(_):
        cv = Canvas(64, 64, (32, 32))
        body = cv.ellipse((0, 0), 17.5, 17.5)
        cv.part(body, R_BARK, deep=True)
        cv.part(cv.ellipse((0.5, 11.5), 7.0, 3.6) & body, mat("bark", 7, 6, 5, 3))
        crown = cv.ellipse((-0.5, -4.5), 14.5, 11.0) & body
        cv.part(crown, R_CROWN)
        for x in (-6.5, 5.5):
            cv.flat(cv.capsule((x, -14), (x + 1, 4), 0.6) & crown, PAL["bark-1"])
        cv.flat(cv.capsule((-12, 2), (12, 2), 0.6) & crown, PAL["bark-2"])
        if cracked:
            pts = [(-11, -9), (-6, -4), (-8, 1), (-1, -2), (3, -9), (6, -3), (11, -6)]
            for a_, b_ in zip(pts, pts[1:]):
                cv.flat(cv.capsule(a_, b_, 0.9) & crown, PAL["gold-6"])
            cv.pixel((-1, -3), PAL["gold-7"])
        img, mask = cv.finish()
        return img, mask, {}
    return render


def roku_tail(hot):
    def render(_):
        cv = Canvas(64, 64, (32, 32))
        body = cv.ellipse((0, 0), 16.5, 16.5)
        cv.part(body, R_TAIL_HOT if hot else R_TAIL, deep=True)
        for x in (-8, 0, 8):
            cv.flat(cv.capsule((x, -15), (x, 15), 0.6) & body & ~cv.ellipse((-4, -5), 6, 5), PAL["gold-3" if not hot else "gold-4"])
        cv.part(cv.ellipse((-4, -5), 5.5, 4.5), mat("gold", 7, 7 if hot else 6, 5, 4))
        cv.pixel((-6, -7), PAL["gold-7"])
        img, mask = cv.finish()
        return img, mask, {}
    return render


def roku_head(step):
    """The mandible wheel turned by `step` tenths of a sixth of a turn."""
    def render(_):
        cv = Canvas(64, 64, (32, 32))
        r = 22.0
        rot = math.radians(step * 10.0)
        mand = None
        for k in range(6):
            a = rot + k * math.tau / 6
            d = (math.cos(a), math.sin(a))
            side = (-d[1], d[0])
            base = (d[0] * (r - 6), d[1] * (r - 6))
            tri = cv.polygon([(base[0] + side[0] * 5, base[1] + side[1] * 5), (d[0] * (r + 7), d[1] * (r + 7)),
                              (base[0] - side[0] * 5, base[1] - side[1] * 5)])
            mand = tri if mand is None else mand | tri
        cv.part(mand, R_MANDIBLE)
        cv.part(cv.ellipse((0, 0), r, r), R_HEAD, deep=True)
        cv.flat(cv.ellipse((0, 0), r * 0.62, r * 0.62), PAL["ember-0"])
        cv.flat(cv.ellipse((0, 0), r * 0.3, r * 0.3), PAL["night-0"])
        for k in range(3):
            a = -rot * 0.5 + k * math.tau / 3
            e = (math.cos(a) * r * 0.45, math.sin(a) * r * 0.45)
            cv.part(cv.ellipse(e, 2.4, 2.4), mat("ember", 5, 4, 3, 1))
        img, mask = cv.finish()
        return img, mask, {}
    return render


ROKUSUTAHN = [
    ("head", [roku_head(i) for i in range(6)], list(range(6)), 12, True),
    ("plate", [roku_plate(False), roku_plate(True)], [0], 1, False),
    ("tail", [roku_tail(False), roku_tail(True)], [0], 1, False),
]


# --- NPCs ---------------------------------------------------------------------

def npc(look, bob=0, hand_dy=0.0):
    robe = mat_from(look.get("robe", "#6b6380"))
    trim = mat_from(look.get("trim", "#c9b98f"))
    skin = mat_from(look.get("skin", "#e8c9a0"), ["bark"])
    hair = mat_from(look.get("hair", "#3a2a1e"))
    hat = look.get("hat", "none")
    dwarf_build = look.get("build", "") == "dwarf"
    beard = look.get("beard", False) or dwarf_build

    def render(_):
        cv = Canvas(32, 48, (16, 46))
        top = (-22 if dwarf_build else -30) + bob
        half_hem = 9.5 if dwarf_build else 8.5
        head = (0.5, top - 5.5)
        # Back arm, robe, front arm.
        cv.part(cv.capsule((-4, top + 3), (-5.5, top + 12 + hand_dy), 2.0), robe)
        body = cv.polygon([(-5, top), (5, top), (half_hem, 0), (-half_hem, 0)]) | cv.ellipse((0, top + 1.5), 5.5, 2.6)
        cv.part(body, robe, deep=True)
        hem = body & cv.below(-3.0)
        cv.part(hem, trim)
        cv.part(cv.capsule((0.5, top + 2), (0.5, -3.5), 0.7), trim)
        cv.part(cv.ellipse(head, 4.4, 4.8), skin)
        if hat != "hood":
            hair_m = cv.ellipse((head[0] - 0.8, head[1] - 2.0), 5.0, 3.6) | cv.capsule((head[0] - 3.4, head[1] - 1), (head[0] - 3.8, head[1] + 3.5), 1.6)
            cv.part(hair_m & ~(cv.right_of(head[0] - 0.5) & cv.below(head[1] - 2.0)), hair)
        if beard:
            cv.part(cv.polygon([(head[0] - 2.5, head[1] + 1.5), (head[0] + 4.5, head[1] + 1.5), (head[0] + 2.5, top + 7),
                                (head[0] - 0.5, top + 8)]), hair)
        cv.pixel((head[0] + 2.0, head[1] - 0.5), DARK)
        cv.pixel((head[0] + 2.0, head[1] + 0.5), DARK)
        if hat == "crown":
            band = cv.polygon([(head[0] - 4.5, head[1] - 6), (head[0] + 4.5, head[1] - 6), (head[0] + 4.5, head[1] - 3.5),
                               (head[0] - 4.5, head[1] - 3.5)])
            spikes = cv.polygon([(head[0] - 4.5, head[1] - 6), (head[0] - 3.5, head[1] - 9), (head[0] - 2, head[1] - 6),
                                 (head[0] - 0.5, head[1] - 9.5), (head[0] + 1, head[1] - 6), (head[0] + 2.5, head[1] - 9),
                                 (head[0] + 4.5, head[1] - 6)])
            cv.part(band | spikes, mat("gold", 6, 5, 4, 2))
            cv.pixel((head[0] - 0.5, head[1] - 5), PAL["ember-3"])
        elif hat == "hood":
            hood = cv.ellipse((head[0] - 0.5, head[1] - 1), 6.0, 6.2) & ~(cv.right_of(head[0] - 1.0) & cv.below(head[1] - 2.5))
            cv.part(hood, robe)
        elif hat == "cap":
            cv.part(cv.ellipse((head[0] - 0.5, head[1] - 4), 5.0, 2.6) | cv.capsule((head[0] + 2, head[1] - 3.5), (head[0] + 6, head[1] - 3), 1.0),
                    trim)
        elif hat == "helm":
            cv.part(cv.ellipse((head[0] - 0.5, head[1] - 3), 5.6, 3.4) & ~cv.below(head[1] - 1.5), mat("stone", 5, 4, 3, 1))
        cv.part(cv.capsule((4, top + 3), (5.5, top + 11 + hand_dy), 2.0), robe)
        cv.part(cv.ellipse((5.8, top + 12 + hand_dy), 1.8, 1.8), skin)
        img, mask = cv.finish()
        return img, mask, {"head": [head[0], head[1]]}
    return render


# --- Sap Spitter: a bark-rooted turret with an amber sac -----------------------

SPIT_ROOT = mat("bark", 3, 2, 1, 0)
SPIT_SAC = mat("gold", 5, 4, 2, 1)
SPIT_SAC_HOT = mat("gold", 6, 5, 4, 2)
SPIT_LIP = mat("bark", 5, 4, 2, 0)


def sap_spitter(sac, hot=False, spout=1.0, lean=0.0):
    """sac: the sac's radius; spout: how far the mouth sticks out; lean tips it back."""
    def render(_):
        cv = Canvas(32, 32, (16, 30))
        # Roots gripping the floor.
        for a, b in (((-9, 0), (-3, -6)), ((9, 0), (3, -6)), ((-5, 0), (-1, -7)), ((5, 0), (1, -7))):
            cv.part(cv.capsule(a, b, 1.4), SPIT_ROOT)
        cv.part(cv.ellipse((0, -6), 6.5, 4.5), SPIT_ROOT, deep=True)
        cy = -8 - sac + lean * 0.3
        cv.part(cv.ellipse((-lean, cy), sac, sac * 0.92), SPIT_SAC_HOT if hot else SPIT_SAC, deep=True)
        # Veins over the sac.
        for vx in (-0.45, 0.2):
            vein = cv.ellipse((-lean + vx * sac, cy + 2), 0.6, sac * 0.45) & cv.ellipse((-lean, cy), sac - 1.5, sac - 1.5)
            cv.flat(vein, PAL["gold-2"])
        # The spout, angled forward and up.
        base = (-lean + sac * 0.55, cy - sac * 0.55)
        tip = (base[0] + 3.5 * spout, base[1] - 3.0 * spout)
        cv.part(cv.capsule(base, tip, 2.2), SPIT_LIP)
        cv.flat(cv.ellipse(tip, 1.1, 1.1), DARK)
        cv.pixel((tip[0] + 0.5, tip[1] + 1.6), PAL["gold-6"])
        img, mask = cv.finish()
        return img, mask, {"mouth": [round(tip[0], 1), round(tip[1], 1)]}
    return render


SAP_SPITTER = [
    ("idle", [sap_spitter(6.0), sap_spitter(6.4)], [0, 1], 3, True),
    ("windup", [sap_spitter(7.4, True, 0.7, 1.0), sap_spitter(8.0, True, 0.6, 1.5)], [0, 1], 8, True),
    ("spit", [sap_spitter(5.0, False, 1.5, -1.5)], [0], 1, False),
]


# --- Grub Lump: a bark-plated grub that crawls over every surface -------------

GRUB_FLESH = mat("leaf", 7, 6, 5, 3)
GRUB_PLATE = mat("bark", 4, 3, 2, 0)
GRUB_JAW = mat("gold", 5, 4, 3, 1)
GRUB_LEG = mat("bark", 2, 1, 1, 0)


def grub_lump(phase=0.0, rear=0.0, jaw=0.5, curl=0.0):
    """Drawn crawling along a floor, head toward +x; the game turns it to cling
    to walls and ceilings. phase: the crawl wave; rear: how far the front half
    lifts (the drop telegraph); jaw: how wide the mandibles open; curl: 0 lying
    flat, 1 balled up (falling)."""
    def render(_):
        cv = Canvas(32, 24, (16, 21))
        segs = []
        for i in range(4):
            x = -8.5 + i * 4.6
            lift = max(0.0, math.sin(phase - i * 1.2)) * 1.4 + rear * i * 0.9
            # Balled up, the segments gather into a ring.
            a = math.pi * (0.95 - i * 0.42)
            cx = x * (1 - curl) + math.cos(a) * 5.0 * curl
            cy = (-4.4 - lift) * (1 - curl) + (-7 - math.sin(a) * 4.5) * curl
            segs.append((cx, cy, 4.8 - abs(i - 1.5) * 0.4))
        for cx, cy, r in segs:
            cv.part(cv.ellipse((cx, cy), r, r * 0.95), GRUB_FLESH, deep=True)
        for cx, cy, r in segs:
            plate = cv.ellipse((cx - 0.6, cy - r * 0.55), r * 0.62, r * 0.42) & cv.ellipse((cx, cy), r - 0.5, r * 0.9)
            cv.part(plate, GRUB_PLATE)
        hx, hy, _ = segs[-1]
        head = (hx + 4.4 * (1 - curl) + 1.5 * curl, hy + 0.6 - rear * 1.2)
        cv.part(cv.ellipse(head, 3.4, 3.0), GRUB_PLATE, deep=True)
        for side in (-1, 1):
            tip = (head[0] + 3.2, head[1] + side * (1.0 + jaw * 2.2))
            cv.part(cv.capsule((head[0] + 1.6, head[1] + side * 0.8), tip, 0.9), GRUB_JAW)
        cv.pixel((head[0] + 0.8, head[1] - 1.2), DARK)
        cv.pixel((head[0] + 1.2, head[1] - 1.8), PAL["gold-6"])
        # Stubby legs under the front segments.
        if curl < 0.5:
            for cx, cy, r in segs[1:]:
                cv.part(cv.capsule((cx, cy + r * 0.6), (cx + 0.6, -0.6), 0.8), GRUB_LEG)
        img, mask = cv.finish()
        return img, mask, {}
    return render


GRUB_LUMP = [
    ("crawl", [grub_lump(p) for p in (0.0, 1.6, 3.2, 4.8)], [0, 1, 2, 3], 6, True),
    ("windup", [grub_lump(0.0, 1.0, 1.0), grub_lump(0.8, 1.3, 1.2)], [0, 1], 10, True),
    ("drop", [grub_lump(0.0, 0.0, 0.9, 1.0)], [0], 1, False),
]


def main():
    write_sheet("monodron", (40, 32), (20, 30), MONODRON, lambda r: r(None))
    write_sheet("hornet", (40, 32), (20, 16), HORNET, lambda r: r(None))
    write_sheet("rot_dwarf", (48, 48), (24, 45), ROT_DWARF, lambda r: r(None))
    write_sheet("rokusutahn", (64, 64), (32, 32), ROKUSUTAHN, lambda r: r(None))
    write_sheet("sap_spitter", (32, 32), (16, 30), SAP_SPITTER, lambda r: r(None))
    write_sheet("grub_lump", (32, 24), (16, 21), GRUB_LUMP, lambda r: r(None))
    write_sheet("iron_dwarf", (72, 64), (32, 61), IRON_DWARF, lambda r: r(None), density=ID_SCALE)
    npcs = json.loads((ROOT / "data" / "npcs.json").read_text())
    for npc_id, info in npcs.items():
        look = info.get("look", {})
        frames = [npc(look, 0, 0), npc(look, 0, 0.5), npc(look, 1, 1), npc(look, 0, 0.5)]
        write_sheet("npc_" + npc_id, (32, 48), (16, 46), [("idle", frames, [0, 1, 2, 3], 3, True)], lambda r: r(None))


if __name__ == "__main__":
    main()
