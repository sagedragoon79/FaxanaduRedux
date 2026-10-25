#!/usr/bin/env python3
"""Generates levels/gym/gym.room, the movement and combat test gym.

Edit this script rather than the room file, then run: python3 tools/levels/gen_gym.py
"""
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "levels" / "gym" / "gym.room"
W, H = 170, 46
g = [['.'] * W for _ in range(H)]
def rect(x0, y0, x1, y1, ch='#'):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            g[y][x] = ch
labels = []
def label(x, y, t): labels.append(f"label: {x}, {y}, {t}")

# Shell
rect(0, 0, W-1, 1); rect(0, 0, 1, H-1); rect(W-2, 0, W-1, H-1)
rect(0, 40, W-1, H-1)                      # lower floor surface row 40
g[39][5] = 'P'
label(3, 33, "MOVEMENT GYM - run, jump, measure")
# Height pillars: 2,3,4,5 tiles
for i, h in enumerate([2, 3, 4, 5]):
    x = 11 + i * 4
    rect(x, 40 - h, x + 1, 39)
label(10, 30, "2  3  4  5 tiles")
# Dummies
g[39][29] = 'E'; g[39][33] = 'E'
label(27, 35, "Slash / up-slash")
# Spike corridor pit x 38..60: remove floor rows 40-41, spikes at 42, solid below
rect(38, 40, 60, 42, '.')
for x in range(38, 61): g[42][x] = '^'
label(40, 34, "Pogo the spikes (attack+down in air)")
# Cracked floor patch over a pocket
rect(64, 42, 70, 44, '.')
for x in range(66, 69): g[40][x] = 'C'; g[41][x] = 'C'
g[44][69] = 'E'
label(62, 35, "Mattock: break cracked stone")
# Cracked wall
for y in range(36, 40): g[y][74] = 'C'
# Wall-jump shaft: left wall cols 80-81 rows 20..35, right wall 86-87 rows 20..39
rect(80, 18, 81, 35); rect(86, 20, 87, 39)
label(76, 21, "Wall jump shaft")
# Upper floor row 18-19 from x 86 to W-3, with gaps
rect(86, 18, W-3, 19)
rect(82, 18, 85, 19, '.')
# Double-jump block x 92..94 rows 12..17
rect(92, 12, 94, 17)
label(89, 9, "Double jump (6 tiles)")
# Gap 1 x 100..109
rect(100, 18, 109, 19, '.')
label(99, 12, "Gap: 10 tiles")
# Dash gap x 116..129
rect(116, 18, 129, 19, '.')
label(114, 12, "Dash gap: 14 tiles")
g[14][123] = 'r'                           # a stride seed over the dash gap
label(118, 8, "Stride seed: dash, touch it, dash again")
# Thorn bulb chain over gap x 136..156
rect(136, 18, 156, 19, '.')
for x in (140, 146, 152): g[16][x] = 'o'
label(134, 10, "Pogo the thorn bulbs")
label(158, 13, "Drop down to loop")
# Lower right: one-way stairs back up under gap 1
for (x0, y) in [(92, 36), (98, 32), (92, 28), (98, 24), (102, 21)]:
    rect(x0, y, x0 + 4, y, '-')
label(90, 38, "One-way stairs (down+jump drops)")
# Lower right: combat arena
g[39][118] = 'M'
g[33][132] = 'H'
g[39][152] = 'D'
label(112, 36, "Combat: combo X X X, parry V, Deluge F, potion Q")

rows = ["".join(r) for r in g]
hdr = ["name: Movement Gym", "zone: gym", "music: none", "enemy_respawn: 5"] + labels + ["---"]
OUT.write_text("\n".join(hdr + rows) + "\n")
