# Pass 320: a throw is drawn, not done

Category: Movement (last pass 312).

## Audit

- **The Rune Dagger throw.** Sean's flick (2026-10-30) plays a low ready crouch over the legs. Since his off-hand change, a dagger build throws all through a fight. `throw_dagger` only squashes the sprite and starts the flick. **No test held that a throw leaves movement alone**, so a change to the flick, such as a crouch that set a crouch state or a pose that braked, could have stalled a run or cost a wall slide without anything noticing.
- **Guarding.** `guard_move_multiplier` 0.4 is held by `test_a_guard_walks_slow_and_mp_comes_back_slowly`. Pass 319's soaks now mash the guard in real rooms.
- **Swimming and wading.** Nothing has changed there since pass 312, and their tests (`test_swimming_floats_sinks_strokes_and_jumps_out` and others) hold.
- **Buffers and coyote time.** The throw buffer (0.15 s, pass 192) and pass 296's clearing on a setback are held by their tests.

## Fix

- Test: `test_a_dagger_throw_never_touches_movement` (test_movement.gd). One hero throws on the run (frame 6), at the top of a jump (50) and in a wall slide (100). The other never throws. Every throw must fly and land in the state named, and the two paths must match frame for frame. As a mutation check, a throw that adds 20 px/s of fall parts the paths at frame 54.
- Bible 6: a paragraph after pass 312's "Poison is no blow".

No movement number changed, and nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: the flick is held to leave movement alone. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 321 takes Faithfulness (last pass 313).
