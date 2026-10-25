# Pass 76: Shadow Eura, two of you

Phase 3 of the shadow before the gate of Zenis (bible 8.8). This completes the fight.

## What changed

- **Phase 3** (`scripts/bosses/shadow_eura.gd`, `PHASES` [0.5, 0.2]):
  - Below a fifth it splits in two (`_split()`, `SPLIT_TIME` 0.8 s, both untouchable). The false double is a
    `ShadowEura` with `decoy = true`. It is not in the boss group, so the boss bar and the arena follow the real one.
  - The double appears on your far side (`_clear_at` keeps it out of the walls). Half the time the two trade places
    as they part, so where they came from tells you nothing.
  - Both fight with the phase 2 moves of your strongest branch.
  - Only the real one casts a reflection: a faint, upside-down silhouette in the floor under its feet
    (`reflects()`).
  - The false one has no health. Strike it and it swells for `BURST_TELL` (0.45 s), then bursts for 10 damage
    (unparryable) in a 72x60 box around itself. The real one splits again `RESPLIT` (3.5 s) later.
  - Beating the real one ends the false one with it.
- **Options**: `--boss-hp=F` at 0.2 or below starts the fight split in two.
- **Docs**: bible 8.8 has a phase 3 as-built note.

## Tests

- `test_boss.gd`:
  - `test_shadow_eura_splits_in_two_below_a_fifth`: two shadows, the boss bar on the real one, only the real one
    reflected, parted, untouchable while splitting, then both come on.
  - `test_striking_the_false_shadow_makes_it_burst`: the swell is told, the real one is unharmed, the burst hurts a
    player beside it, and the real one splits again.
  - `test_beating_the_real_shadow_ends_the_false_one`.
- `test_soak.gd`: the Eura soak runs 3000 frames through all three phases (0.52 ms a frame).

## Screenshots

`/mnt/project-files/pass-76/split.png`: the two shadows, with the reflection under the real one.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90.5 | Unchanged. |
| World and level design | 15 | 94.5 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 93.25 | Shadow Eura is complete: mirror, its own fight, then a reading test. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 90 | Unchanged. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 90.25 | Unchanged. |

Weighted score: 90.31 (up from 90.24; 90.3125 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (89). The bosses before the final one are complete except for deferred
phases (Borabohra 3, Pakukame 3). Next: the gate opens onto Zenis (bible 8.9), starting with the first rooms of the
final zone.
