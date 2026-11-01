# Pass 367: the host's pause, told from a hitch (Stability)

Category: Stability (last pass 359).

## Audit

`test_a_journey_after_the_end_stays_lean` failed twice in full runs and passed alone both times:

- **Pass 359:** three frames of 56 to 65 ms in `eolis/guru_temple`.
- **Pass 363:** 57, 101 and 86 ms in `tower/mine_shaft`.

Pass 363 left a lead: the full run holds about 4,250 live objects, where a run of the test alone holds about 3,335.

- **The objects are caches, not a leak.** The test runner gained `--trace`, which prints the live objects, nodes, orphans and resources after every test. Across a full run the tree stays at 22 nodes and no orphan is ever left. The objects grow in steps where a test first sees a zone: the dust kinds, the blooming Tree, the soaks of each zone. These are sheets, sounds and tiles, cached for good. Nothing alive does work each frame.
- **The slow frames are off the CPU.** Each journey frame now reads the main thread's own CPU clock (`/proc/self/task/<id>/stat`) and the VM's steal counter (`/proc/stat`, the CPU time the host takes back). In a full run, the one slow frame (26 ms, again in `eolis/guru_temple`) had none of its time on the main thread. Another full run had a 12.4 ms frame the same way, with the host stealing 10 ms.
- **The host does it with no game at all.** An empty Godot loop, run for two minutes in the same VM, met a 54.5 ms frame with the main thread off the CPU and 30 ms stolen, plus three more slow frames like it. This VM loses about 1% of its CPU to the host, in bursts. The 50 ms budget could fail on it with no game code running.
- **Caught live.** With the fix in place, a single run of the journeys met a burst like pass 359's and pass 363's in `trunk/shrine_hollow`. Frames of 65.7 and 72.8 ms had 0 ms on the CPU while the host took 70 ms; they were set aside. The third frame, 79.3 ms, had 70 ms on the CPU, so it was judged, as the lone frame a lap allows. A later 115.3 ms frame with 0 ms on the CPU would have broken the 100 ms limit outright.

## Fix

- `_host_paused(dt, cpu, steal)` in `test_soak.gd` sets a frame over the 50 ms budget aside only when both of these hold:
  - the main thread was on the CPU for under half of the frame;
  - the host took time from the VM while it ran.
- Each frame set aside is counted (`paused`) and printed as "host paused". Every other slow frame is judged as before, including:
  - a frame the game spent on the CPU, steal or not;
  - a frame off the CPU with nothing stolen (a lock or a disk the game may own);
  - every frame on a machine without `/proc`.
- `test_a_host_pause_is_told_from_a_hitch` holds the rule case by case and checks that both clocks read. It checks that 60 ms of work shows on the main thread's clock and that steal only counts up.
- Bible 15.3: "**The host's pause, told from a hitch (pass 367):**". The FRAME_BUDGET comment says the same.

Mutation: with the steal condition dropped, the test fails 1 check.

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
| Stability and performance | 5 | 99 | Unchanged score. The soak's full-run bursts are traced to the host and set aside only on evidence; the live objects are caches. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 368: Movement.
