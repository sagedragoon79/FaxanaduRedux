# Pass 182: one lone frame forgiven

Every category apart from Art was tied at 99, and Stability's last pass (174) was the oldest, so pass 182 takes Stability. Its main job was the one flaky check in the suite.

| Check | Finding | Verdict |
| --- | --- | --- |
| The Matriarch (pass 179) | the boss frame audit and the beaten-for-good save test read arenas from the rooms' `boss:` headers, so both cover her mire with no change | fine |
| The Journey rows and the mud steps (passes 180, 181) | no new nodes or loads per frame; full suites in both passes were clean | fine |
| **The journeys' 50 ms check** | It failed in three full runs (58.6 ms in pass 174, 51.2 ms in `zenis/heart_gate` in pass 178, 51.5 ms in `sunken/source_hall` in pass 179). Each time it was a single frame in a room no change had touched, and each passed when run again alone. | **fixed** |

## Root cause

I traced every play frame of the post-game journey (about 4,000 frames), grouped by how many frames had passed since entering the room:

| Frames since entering | Frames | Median | 95th percentile | Max |
| --- | --- | --- | --- | --- |
| 0 (the load, not judged) | 598 | 5.1 ms | 26.2 ms | 66.2 ms |
| 1 | 598 | 0.8 ms | 1.3 ms | 2.7 ms |
| 2 | 562 | 0.7 ms | 1.2 ms | 4.8 ms |
| 3 (judging starts) | 530 | 0.6 ms | 1.1 ms | 4.3 ms |
| 4 to 7 | about 2,000 | 0.6 ms | 1.1 ms | 4.3 ms |

Nothing in the game is behind a 50 ms frame:
- Loads end on the entry frame.
- Every judged frame stays under 5 ms.
- The suite runs in one process, so no other Godot competes with it.

What is left is the host pausing the process, which in a long full run happens once or so per hour and lands on whatever frame is being timed.

## As built

- Each journey lap tracks its worst and second-worst play frames, and `_merge` keeps both across the two halves of a post-game lap.
- `_check_frames`: the second-worst frame must stay under 50 ms (`FRAME_BUDGET`) and the worst under 100 ms (`LONE_FRAME_LIMIT`). A lone frame over 50 ms is printed.
- Real regressions are still caught. A real hitch (a lazy load, a slow room, a leak) comes back every time its room is entered, so it makes several slow frames and fails. A hitch of 100 ms or more fails even once.
- Bible 15.3 now describes this rule under "One lone frame forgiven" and in the pass 99 and pass 144 notes.

## Tests

- `test_soak.gd`, `test_the_journey_frame_budget_forgives_one_lone_frame` (new): the tally keeps the worst and second-worst frames across two halves, so one slow frame is forgiven and two are not.
- Both journeys use `_check_frames`.

Full suite: 3400 of 3400 checks passed, with no script errors. That run shows the noise again: the first journey's second lap had one frame of 28.2 ms, deep in `trunk/hollow_knot` at frame 39, while every other judged frame across the four laps stayed under 6 ms.

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
| Stability and performance | 5 | 99 | Unchanged: the suite's one flaky check now tests the game, not the host. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 183 takes Faithfulness (last pass 175, now the oldest).
