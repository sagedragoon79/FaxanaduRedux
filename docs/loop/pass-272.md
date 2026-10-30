# Pass 272: wading keeps its promise

Category: Movement feel (last pass 264).

## Audit

I read bible section 6 against `movement_tuning.gd`. The numbers still match, and the section 6 tests assert them. Then I checked how movement meets what recent passes added:
- King Grieve's guard (268) rises at the end of the hall farther from you, so it never lands on the hero.
- The Mascon tavern (265) is two talk NPCs on an existing floor.
- Dartmoor's standing water (259, 262, 264) is the gap. Bible 4.4 promises the water "is not deep enough to swim, and it neither slows you nor hides a hazard". The tests checked that the water is there, that a step sloshes, that a landing throws spray, and that it drains, but nothing held those three promises. A tide cell that read as swimming water, a drag on the wade, or water that covered the spikes' hurt would have passed every test.

## Fix

New test `test_wading_neither_slows_nor_floats_nor_hides_the_spikes` (test_movement). It runs in the Flooded Hall with its foes cleared:
- The hero stands in the water (the surface reads `wade`).
- A run east through the water reaches `run_speed` (165 px/s, within 1).
- A full jump out of the water rises `jump_height` (72 px, within 3).
- Dropped into the flooded spike pit, the hero is hurt.
- At no point does the hero swim.

No game code changed: the water already keeps its promise, and now a test holds it.

Mutation check: slowing the run in `wade` the way swimming does fails the test ("got 115.50, want 165.00").

Bible 4.4: the King Grieve row now names the test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: wading is now held to its promise. |
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

Pass 273 takes Faithfulness (last pass 265).
