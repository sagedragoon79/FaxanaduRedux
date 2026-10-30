# Pass 303: a lone frame is not a load

Category: Stability and performance (last pass 295).

## Audit

I checked stability (bible 15.3, the soaks, the frame budget, leaks) against what passes 296 to 302 touched.
- **The 103.8 ms frame from pass 301.** It came in the full run's first journey lap, in the Gnawed Stair, play frame 9. When I ran the test alone, the worst frame was 5.7 ms. The journey's seed fixes its path, so a first-time load on that frame would come back every run, and it was colder alone than in the full run. To be sure, I probed both journeys (four laps), counting character sheets (`Sheet._cache`) and sounds (`Sfx.loads`) first loaded during play frames. There were none. Every sound loads with the game, and every sheet a room needs loads as the room is built. So it was a host pause, like the lone frames of passes 174 to 179 (pass 182). The 100 ms limit stays.
- **The purse move (pass 300).** `Room._keep_set_back_off` skips a purse already queued for freeing. It updates `GameState.data.purse` in place, the same dictionary the save writes. A load rebuilds that dictionary from the file (`GameState`), and the room places the purse from it. A purse taken on the same frame is skipped, and taking it clears the saved purse.
- **The door soak (pass 299).** It sets `boss:zoradohna` and the Lantern Landing curtain on the test's own GameState, which the runner resets before every test, and the runner's state-leak check passes. The scripted input belongs to that test's player, freed with its world. It runs in about 8 s.
- **Toast connections (passes 301, 302).** Both tests disconnect their listener right after the frames they listen to, with no return in between. A failed check doesn't return, so the disconnect always runs.

## Fix

The probe is now a check. Both journey soaks record any sheet or sound first loaded during a play frame (after a room's first three frames, as the frame budget does) and fail if there is one. A lazy load added later, say a new sheet first fetched mid-room, fails at once instead of showing up months later as a rare spike. To check it fires, I cleared the sound cache in the middle of a lap and the test failed, naming each room and frame.

Bible 15.3: a line in the journey list, and a paragraph after pass 182's.

**This pass's full run** failed the same journey on its 50 ms budget: two frames in the Spring of Trunk on the first lap (69.9 ms at frame 3, 61.6 ms at frame 13). The new check found no load on either. The journey walks a different path in a full run than alone, so I ran the soaks that come before it (every guardian soak, both door walks, the shrine test) and the journey together, twice: worst frames 4.5 to 6.9 ms, none over 33 ms. These lone spikes come only late in a 45-minute full run, which fits the host pausing the process (pass 182). If CI ever shows them too, the next step is a per-frame trace of what is running in that room, not a looser limit.

No screenshot: nothing on screen changed.

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
| Stability and performance | 5 | 99 | Unchanged score: the journeys now prove play loads nothing from disk. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 304 takes Movement (last pass 296).
