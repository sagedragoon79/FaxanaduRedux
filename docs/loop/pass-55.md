# Pass 55: the Thunder Beetle

Daybreak's first enemy (bible 7), code-drawn at 2x. It makes the pogo a decision. The shell wants you on top, and
the lightning wants you off.

## What changed

- **Thunder Beetle** (`scripts/enemies/thunder_beetle.gd`, legend `t`):
  - A beetle as big as a dog: a storm-violet dome with a gold stripe and copper horns. It trundles the floor at
    28 px/s and turns at ledges and walls. HP 44, 12 to touch, 14 XP, 6 to 12 gold.
  - **Shell**: side blows deal 30%, and a pogo or any blow from above lands in full.
  - **Charge**: come within 64 px and its back wing case lifts while sparks jump across the shell. It crackles
    (`static.wav`) and flashes for 0.6 s.
  - **Discharge**: a ring of lightning 46 px around the shell for 14 (`zap.wav`, a little screen shake). It can't be
    parried and reaches above the shell, so a player still pogoing on top gets hit.
  - **Spent**: its cases hang open for 1.1 s and every blow lands in full. It then walks for 1.4 s before it can
    charge again.
- **Placed** on the Storm Ledge causeway (replacing the high hornet), on the Sky Steps storm floor, and in the Broken
  Shrine's yard.
- **Sound**: `static` and `zap` are appended at the end of `sfxgen.py`, so every existing wav is byte-identical.
- **Bible 7** describes the beetle as built, and the legend table in `levels/README.md` adds `t`.

## Tests

- `test_enemies.gd`:
  - `test_thunder_beetle_crackles_then_discharges_a_ring`: it walks when you are far off. It crackles for at least
    `MIN_TELEGRAPH`. The discharge gets through a raised shield, once. It is left spent, and a side blow then lands in
    full.
  - `test_thunder_beetle_shell_and_the_ring_above_it`: 3 of 10 through the shell from the side and 10 of 10 from
    above. The ring reaches a player on top of the shell but not one well clear, and the beetle is a pogo target.
- The existing room, soak and sound-file tests cover the placements and the new sounds.

## Screenshots

`/mnt/project-files/pass-55/`: `beetle_20.png` (the telegraph flash with sparks), `beetle_36.png` (charging) and
`beetle_50.png` (the discharge striking the player).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 88 | A new enemy that changes how the pogo is used. |
| World and level design | 15 | 92 | Unchanged. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 88.5 | Unchanged. |
| Audio | 5 | 88.25 | Two new effects. |
| Stability and performance | 5 | 86 | Unchanged. |
| Faithfulness | 5 | 88.25 | Unchanged. |

Weighted score: 88.47 (up from 88.38).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (86). Next is a stability pass:
- an Act II-to-Daybreak save round trip;
- a soak of a full Daybreak run with beetles;
- frame-time checks on the rain motes and the lightning backdrop.

Then Daybreak town past the fallen bridge.
