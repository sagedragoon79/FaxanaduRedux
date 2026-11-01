# Pass 359: the title's path through the flasks, walked for real (Stability)

Category: Stability (last pass 351).

## Audit

Passes 352 to 358 changed constants, draw code, a test fixture and three sound cues. None of them added a node, a load or a save path, and the full suite (engine errors, state leaks, missing sounds) passed on each.

The gap was older and bigger. Sean's three flasks (passes 343 to 357) are the only way into a journey, but only the picker had tests (`SlotPicker`). The game's side of it had never run in a test:
- `Game._journeys` opens the shelf and wires its signals.
- `_take_up` loads a journey or begins a new one in the chosen slot.
- `_end_of_ending` frees the world, saves, and goes back to the title.

Every soak and journey test builds its world directly. So nothing checked that a journey begun from the title rests in the flask it was taken from, or that a second trip through the same shelf leaves no world, paused tree or doubled listener behind. A slip in any of these would cost the player a save, and no test would catch it.

## Fix

`test_the_title_takes_journeys_up_and_back_in_their_own_flasks` drives the real `Game` through two trips:
1. The title's Journeys row opens the shelf over a paused tree, with one listener on each of its signals.
2. A full flask is taken up where it rested, with its gold.
3. The ending saves and goes back to the title, leaving no world.
4. On the same shelf, an empty flask begins anew at the West Gate, in its own slot.

At the end, the first journey's save (with the gold earned since) is in its own flask, and the other two are empty.

Nothing was broken. Mutations: with `_take_up` not setting the new journey's slot, 1 check fails. With `_end_of_ending` leaving the world behind, 3 fail.

Bible 15.3: a note "The title's path, walked as the game drives it (pass 359)".

## The full run

The full suite ran 6,045 checks and failed 1. `test_a_journey_after_the_end_stays_lean` had three frames over 50 ms (56.1, 65.3 and 60.7 ms) in `eolis/guru_temple`, at frames 5, 8 and 11 of the first lap. The same room on the second lap stayed under 8 ms. This pass's changes can't be the cause: they touch only `test_systems.gd` and the docs, and the soak suite runs before `test_systems`. Run again alone, the test passed (worst frame 5.4 ms, in `eolis/east_gate`), so this was a hitch in the host, like the ones in passes 182 and 303. This time it was a short burst rather than one frame. CI runs the full suite again as the gate. If a burst like this comes back, the next Stability pass should trace that room frame by frame, as pass 182 did.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score. The title's real path is now held. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 360 takes Movement (last pass 352).
