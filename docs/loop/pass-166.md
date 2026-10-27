# Pass 166: every room in budget, and the trials soaked live

Pass 165 left Stability and Faithfulness tied at 98.5, both weight 5. Stability's last pass (158) was the older, so pass 166 takes Stability. I audited the newest content (passes 161 to 165) for broken states and frame cost.

| Check | Finding | Verdict |
| --- | --- | --- |
| The wash shader (pass 161) | one shared material; it never replaces the death's dissolve, and corrupted foes carry no material of their own | fine |
| Zenis remixes (pass 161) | the Heart Stair's 8 foes settle at 0.96 ms a frame, and the Drift Well's 6 at 1.53 ms | fine |
| The Mantra of Stillness (pass 162) | it loads in 46 ms; the frozen-water set-back fix holds | fine |
| Executioner (pass 163) | `_is_boss` reads a segment's boss, which is freed with it; the Dragon Slayer can't be swapped for a lower blade in a shop | fine |
| Mantra dyes (pass 164) | the sanitizer keeps `dyes` and `trials` clean; a dye is kept by the next shrine save, like any find | fine |
| **The trials soak** | It mashed through each trial room as a plain room. No trial clock ran and the Hour Glass was never turned, so the trial rules (a hazard sets you back, never hurts) and Stillness's freezing water had never been soaked. | **built** |
| **Room loads** | Load times were measured only for the 13 rush arenas (pass 158). Nothing checked the other rooms, or what a room costs a frame once it has loaded. | **built** |

## As built

- **The trials soak** (`test_random_input_soak_in_every_trial_room`) now runs each Guru Trial as a live run (`Trials.begin`), and the Hour Glass is turned whenever it is ready. The soak checks that no run is left open after. All 5 trial rooms soak clean at 0.37 ms a frame.
- **`test_every_room_loads_and_settles_inside_the_budget`** (new) enters all 122 rooms in one world. Each must load in under 500 ms, and its next 12 frames must average under 8 ms. Set `ROOM_REPORT=<path>` to write the table. The worst load is the Forepaw Lift at 154 ms, which pays for Zoradohna's warm-up. The heaviest settled room is the Drift Well at 1.53 ms. The sweep takes about 6 s.

## Report

- `/mnt/project-files/pass-166/room-loads.txt`: the load time and settled frame cost of every room.

## Tests

- `test_soak.gd`, `test_random_input_soak_in_every_trial_room`: now live, with the glass.
- `test_soak.gd`, `test_every_room_loads_and_settles_inside_the_budget` (new).

Full suite: 3149 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Every room's load and frame cost is now checked, and the trials are soaked as they are played. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.6375 (up from 96.625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (98.5) is now the lowest category apart from Art, so pass 167 takes Faithfulness.
