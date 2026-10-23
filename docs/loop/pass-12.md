# Pass 12: Faxanadu touches

Date: 2026-10-23. Scope: Faithfulness (54), the lowest category after pass 11. Built on top of
the 2x render density change (PR #20), so the new art is drawn at 2x.

## What was built

- **The Guru's mantra** (`GameState.mantra()`): resting with a Guru now ends with "Your mantra
  is: ...", sixteen letters from the original's password alphabet, made from your progress
  (rank, XP, gold, gear, abilities, rings, pickups, rooms, flags, save room). The same journey
  always gives the same mantra; any progress changes it. Saving stays automatic: it is the
  original's password screen as a wink (design bible 11, easter eggs). Shrines keep the plain
  "Progress saved".
- **Bread and mana drops** (`scripts/pickups/drop.gd`): besides gold, about 1 kill in 12 leaves
  a loaf of bread (+15 health), as enemies did in Faxanadu, and 1 in 10 a mana orb (+12 MP), the
  MP orbs bible 7 always listed. They pop out, settle on the floor and wait 10 s, blinking before
  they go. Drawn at 2x density in half-pixels. The test runner turns the chances off so other
  tests stay deterministic. Debug flag `--drops` puts one of each beside the player.

## Automated verification

393 checks pass. New: a kill can leave bread that settles, heals by `BREAD_HEAL` when walked
over and is eaten; a mana orb refills magic; an uneaten drop fades; the mantra has four groups
of four, is stable for the same journey and changes with progress. Screenshot reviewed: the
loaf and the orb on the Burrow Drop floor beside the player at 2x.

## Review against the bible

- 15.3 faithfulness checklist: towns, Gurus (now with mantras), ranks, rings, keys, springs,
  Rokusutahn are in; the other bosses and the Evil One come with their zones.
- 7: drops are gold, MP orbs and rare items: met (bread is the rare item for now).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged; drops make kills worth a little more. |
| World and level design | 15 | 65 | Unchanged. |
| Art cohesion | 15 | 65 | 2x density landed (#20); the hero and older art still to be redrawn. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | The Guru's mantra and the bread. |

Weighted score: 72 (up from 71).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Audio (62)**: lightly weighted.
2. **World (65):** the last 8 Trunk rooms, then the Tower of Trunk.
3. **Art (65):** bring tiles and decor to 2x density, alongside the character work in the
   Autosprite thread.
