# Pass 162: the Mantra of Stillness

Pass 161 left World, Bosses, Systems, Audio, Stability and Faithfulness tied at 98.5. World weighs the most (15), so pass 162 takes World. I audited the world against bible 3 and 4, `levels/README.md` and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Critical path and soft-locks | `test_reachability.gd` passes for every room, with the Zenis remixes and the woken Drowned Market | fine |
| Backtracking gates | unchanged; ladders never open a gated room (pass 125 test) | fine |
| The boss rush | it is entered through door 1 of each arena and lands on the floor in all 13 (pass 156) | fine |
| **The Guru Trials** | Bible 3.1 plans six. Four were built (Walls, Edges, Thorns and Winds). The Hour Glass, the last traversal tool, had no course of its own. | **built: Stillness** |
| **Frozen water as safe footing** | While building Stillness, I found that a frozen foothold counted as safe footing. Standing on one set the place a hazard puts you back. Once time ran on, a fall onto spikes could put you back inside the flowing water, which carried you down onto the spikes again. It mattered most in a trial, where hazards cost time and never health. | **fixed** |

## As built

- **`levels/trials/stillness.room`** (72 x 56), the Mantra of Stillness. It is opened by the third spring and built for the Glove and the Hour Glass (`Trials.LIST` gains its `needs` and a description). The course:
  1. Still the first fall and climb its four footholds.
  2. Cross a spiked pit on a curtain of water that hangs from the void: still it, climb three of its footholds, and jump to the far ledge.
  3. Climb a long fall of seven footholds. A dry niche halfway lets you wait for the glass to run back.
  4. Reach the bell on the top ledge.

  The waits between turns of the glass (2.5 s still, 8 s cooldown) are part of the mantra.
- **`Player._on_stilled_water()`:** standing on a Waterfall foothold no longer updates `safe_position`. This also covers Dartmoor's frozen falls.

## Screenshots

- `/mnt/project-files/pass-162/stillness-curtain.png`: ledge B, the first fall below it, and the curtain hanging over the pit.
- `/mnt/project-files/pass-162/stillness-niche.png`: the dry niche halfway up the long fall, with the bell's frame on the ledge above.

## Tests

- `test_systems.gd`, `test_the_mantra_of_stillness_is_climbed_in_frozen_moments` (new). It checks that:
  - the trial is built, for the Glove and the Hour Glass, with a description;
  - the checker reaches the bell and the dry niche;
  - without the glass, not even the first ledge is reached, even with the Boots, the Stride and the Mattock;
  - three springs open the trial, but it wants the Hour Glass;
  - in the real game, the Guru sends you there and the room holds three falls;
  - short hops climb the stilled first fall to its top foothold;
  - the safe footing stays at the bottom while you stand on frozen water. This check fails without the fix.
  - you step off onto the ledge.
- `test_every_guru_trial_can_be_cleared_with_the_glove` now covers Stillness too: no spot in it is cut off from the bell.

Full suite: 3073 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Five of the six Guru Trials are built; the Hour Glass gets its mastery course, and frozen water no longer traps a set-back. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.5625 (up from 96.525). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.5. Bosses and Systems weigh 10. Bosses' last pass (104) is older than Systems' (156), so pass 163 takes Bosses. Unbuilt: the Mantra of Falling.
