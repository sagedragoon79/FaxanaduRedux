# Pass 90: Pakukame's third phase

The last deferred boss phase. Bible 8.5 says that below a quarter of its health the Devouring Bloom "uproots and chases you along a falling leaf (short chase sequence)".

## What changed

- **Phase 3** (`Pakukame.PHASES` is now `[0.5, 0.25]`):
  - **The tell:** when its head next draws back (open jaws stay open), it spends 1.2 s wrenching its root out of the leaf. The head shudders up and the screen shakes.
  - **`LeafFall`** (new, `scripts/bosses/leaf_fall.gd`): the crown-leaf, cut loose, falls through the sky.
    - Wind streaks and torn leaves and petals rush up across the arena.
    - The player weighs 85% while it falls (`gravity_scale`, like the GravityDrift pockets), so jumps hang longer.
    - `settle()` on the Bloom's death fades it out.
  - **The chase:** uprooted, it scuttles after you on a tangle of roots (drawn in place of its root leaves).
    - It moves at 80 px/s, a walk slower than your run.
    - It keeps 48 px from the walls and stops 40 px short of you.
  - **Lunging bites:** the whole plant hops up to 80 px in behind its jaws, so backing off isn't enough. Get past it: run under its head or stride through it, then strike the jaws where they land.
  - Phase 3 keeps phase 2's shorter tells, still never under `Enemy.MIN_TELEGRAPH`. Every other bite still tears the leaf.
- `--boss-hp` puts Pakukame straight into phase 3 below a quarter, for screenshots.
- Bible 8.5 is updated with a deviation note: the chase stays in the Crown-Leaf arena, because the whole leaf is falling. That keeps the fight in one sealed room instead of a separate scrolling sequence.

## Tests

`test_boss.gd`:
- `test_pakukame_uproots_below_a_quarter`: the jaws stay open, the uproot tell, the leaf falling, and fair tells.
- `test_the_uprooted_bloom_chases_you`: its speed is below a run, and it keeps clear of the walls.
- `test_the_uprooted_bloom_lunges_behind_its_bite`
- `test_the_falling_leaf_lightens_you`: a higher jump, and the wind dying away when it dies.

The telegraph test also covers phase 3.

Full suite: 1710 checks, all passing.

## Screenshots

`/mnt/project-files/pass-90/uprooted_chase.png`: the uprooted Bloom scuttling after the player, with the wind and torn leaves rising.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.75 | Unchanged. |
| Combat and enemies | 15 | 91.75 | A chasing boss you have to get past rather than wait out. |
| World and level design | 15 | 96.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.25 | Every boss now has all of its bible phases. |
| Systems | 10 | 92 | Unchanged. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 94.5 | The last deferred boss phase is built. |

Weighted score: 92.19 (up from 92.09; 92.1875 unrounded).

## Next

Combat and Movement are tied lowest apart from Art. Pass 91 takes the Magic Shield's reflect (deferred), which adds combat depth.
