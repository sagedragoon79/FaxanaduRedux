# Pass 07: Rokusutahn

Date: 2026-10-23. Scope: Bosses (55), the second-lowest category after pass 06. The first boss
had no reveal, no stagger window (both required by bible 8) and was drawn as flat circles.

## What was built

- **Sheet** (`tools/art/castgen.py`, `assets/sprites/rokusutahn.*`): a mandible-wheel head with
  6 rotation frames, bark plates (normal and cracked with gold seams), and a tail segment
  (normal and hot). The game rotates and flips plates along his rail.
- **Reveal** (`Rokusutahn.begin()`): screen shake and rumble, the name banner, then he bursts
  out of the wall across from the player, holds and roars, and withdraws before the first
  move. Harmless throughout. The arena no longer emits its own banner (it showed twice).
- **Stagger:** tail hits while he is stuck in a wall or dangling build poise; at 48 he staggers
  for 2 s with hitstop and dust, his plates show cracked and every segment takes full damage.
  Poise resets each time he gets stuck or dangles.

## Automated verification

323 checks pass. New: the reveal emerges, deals no damage and withdraws; tail damage while stuck
staggers him and opens his body to full damage. Screenshots reviewed of the reveal (frames
75-130 after walking in) and the first lunge.

## Review against the bible

- 8: pre-fight reveal and stagger window now met for Rokusutahn; bible 8.1 records the details.
- 7: the reveal is harmless and every lunge still telegraphs with the wall rumble.
- 12.3: the boss now uses the shared outlined, ramp-shaded style.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 70 | Unchanged. |
| World and level design | 15 | 52 | Unchanged. |
| Art cohesion | 15 | 65 | The boss matches the cast style. Props remain simpler. |
| Bosses | 10 | 68 | Reveal, stagger, sprite. No cinematic intro camera yet; only one boss built. |
| Systems | 10 | 63 | Unchanged. |
| Audio | 5 | 60 | Unchanged. |
| Stability and performance | 5 | 60 | Unchanged. |
| Faithfulness | 5 | 52 | Unchanged. |

Weighted score: 67 (up from 66).

## Lowest categories and next pass

1. **World (52):** more Trunk rooms toward 28, a landmark, a second shrine.
2. **Faithfulness (52):** Faxanadu touches in the Trunk (Meat drops, Mattock gate payoff).
3. **Systems (63):** options menu (shake, flash, volume, rebinding).
