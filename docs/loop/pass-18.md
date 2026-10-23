# Pass 18: the Iron Dwarf

Date: 2026-10-23. Scope: Combat (75). The tower opened in pass 17 with Trunk enemies. This
pass gives it its first enemy of its own.

## What was built

- **Iron Dwarf** (`scripts/enemies/iron_dwarf.gd`, legend `I`): a Forepaw dwarf in iron plate
  with a two-handed hammer on his shoulder. He plods on patrol and turns at walls and ledges,
  and turns toward you if you linger behind him.
  - **Telegraph:** with you in front of him, he heaves the hammer overhead for 0.65 s
    (the windup pulses white).
  - **Attack:** he slams it down, crushing what is in front of him (24 damage, can't be
    parried). The slam shakes the screen and sends a **Shockwave**
    (`scripts/enemies/shockwave.gd`) rolling along the floor at 170 px/s. It is a low crest
    of rubble that a small hop clears, and it breaks up at a wall or a ledge.
  - **The opening:** the hammer bites into the floor and stays stuck for 0.95 s. His plate
    halves every blow except a pogo from above or a hit while the hammer is stuck, so the
    fight is about baiting the slam, jumping the wave and punishing.
  - He replaces the Rot Dwarves in the three tower rooms.
- **True 2x code-drawn sheets:** `pixelrig.Canvas` takes a `scale`. Geometry stays in world
  pixels but is rasterized at 2 pixels per world pixel, so outlines, shading and small
  details are half a world pixel. `write_sheet(..., density=2)` writes it as a `"density": 2`
  sheet. The Iron Dwarf is the first enemy drawn this way. All existing sheets regenerate
  byte-identical. The Autosprite thread will replace it with an HD sheet under the same
  animation names.
- Bible 7 records the Iron Dwarf's numbers. `levels/README.md` lists `I`.

The Gear Bat is left for a later pass, to keep this slice to one well-tuned enemy.

## Automated verification

New tests:
- the windup lasts at least `Enemy.MIN_TELEGRAPH`;
- a player out of the hammer's reach is still hit by the shockwave;
- the hammer sticks after the slam;
- plate halves a blow, but it lands in full while stuck or from above;
- the wave hits a body on the floor, misses one 14 px up, and breaks at a wall;
- the sheet has all six animations.

Full suite: 440 checks pass. Screenshots reviewed: the sheet at 2x, and a slam in the Winch Hall
(the player caught in reach, the dwarf bent over his stuck hammer).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 78 | A heavy enemy with a bait-and-punish rhythm and a ground wave to jump; new for the game. |
| World and level design | 15 | 73 | Unchanged. |
| Art cohesion | 15 | 72 | Code-drawn enemies can now be 2x; only one is so far. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 64 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 74 (74.40, up from 73.95).

## Lowest categories and next pass

1. **Faithfulness (60)**, then **Stability (63)** and **Audio (64)**: lightly weighted.
2. **Bosses (68)**: the Foreman (Rock Golem mini-boss) guards the Mattock; Zoradohna after.
3. **World (73)**: more tower rooms toward the Foreman.
