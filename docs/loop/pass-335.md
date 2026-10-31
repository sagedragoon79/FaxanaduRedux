# Pass 335: walking the world holds its memory

Category: Stability (last pass 327).

## Audit

- **The runner.** It fails a test on engine errors and on leaked state. Since pass 327 the leaked state includes every option, through `Settings.snapshot()`.
- **Saves.** `test_every_save_field_survives_a_round_trip`, the old-save, damaged-save, backup and failed-write tests, and the soaks' shrine and beaten-guardian round trips all hold.
- **Bible 14's performance budget** is "60 fps on a mid-2018 laptop GPU; under 1.5 GB RAM; rooms load in under 100 ms (preload neighbors)".
  - **Load time:** `test_every_room_loads_and_settles_inside_the_budget` holds 500 ms and 8 ms a frame. The measured times are 9 to 89 ms a load (median 19 ms; the gym is the slowest) and about 1 ms a frame. Nothing said the test's ceiling is five times the budget, or that neighbors are not preloaded.
  - **Memory:** **no test measured it**, and none asked whether walking the world leaks. The runner's leak check covers global state between tests, not memory or objects left behind by room changes within one.

## Fix

- Test: `test_walking_the_world_holds_its_memory` (test_soak.gd) enters all 126 rooms three times. The first lap fills the caches. It checks three things:
  - the peak static memory stays under 1.5 GB (it is about 285 MB);
  - the third lap needs less than 4 MB more than the second;
  - the third lap leaves as many live objects as the second, within 50.

  It takes about 12 s.
- Mutation check: a `Node.new()` leaked in `World.start` grows the object count by 127 a lap and fails.
- Bible 14: an "As measured (pass 335)" note. It gives the load and frame times, why the test allows 500 ms, that neighbors are not preloaded, and the memory test and what it measures headless.

Nothing on screen changed, so there is no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged score: memory and room-change leaks are now held. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 336 takes Movement (last pass 328).
