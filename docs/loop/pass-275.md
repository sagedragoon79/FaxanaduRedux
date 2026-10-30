# Pass 275: a climb past the Naga is timed to its strike

Category: World and level design (last pass 267).

## Audit

I checked how passes 265 to 274 sit in their rooms. Mascon's tavern and the `[boss:id]` sign lines are held by tests from passes 265 and 267. The new Naga in the Mine Shaft and the Tower Foot was not.

Bible 7 says a climb past the Naga "is timed to its swing". To check, I swept climbs up each Naga's ladder from 16 points of its swing, with the climber holding Up. **Not one was bitten**, in either room. The Naga did hood and strike every time, but its coil froze it where it was. In the 0.5 s of the tell, a climber at 90 px/s rose about 45 px, above the bite, and the strike passed below their feet. On a ladder you can't attack or block, so the Naga was a picture beside the climb, not a part of it.

## Fix

`scripts/enemies/naga.gd`:
- **Coil:** it now follows the climber's height along its column at up to `COIL_TRACK` (60 px/s). That is slower than a climb, so it reads as a lean, not a chase, and it never goes past its swing. A climber who holds Up is still met by the bite.
- **Recovery:** it glides back at 120 px/s (was 90) and waits 2 s (was 1.2) before it hoods again. That gives the safe way past: bait the strike, then climb while it recovers.

New test `test_a_climb_past_a_naga_is_timed_to_its_strike` (test_rooms). In both rooms, for climbs started at eight points of the Naga's swing:
- holding Up straight past is bitten at least 6 times in 8: 8 in the Tower Foot and 6 in the Mine Shaft;
- baiting it gets past unbitten every time. To bait, climb into its level, drop back down as it hoods, then climb again once it has glided more than 40 px off the ladder.

Without the coil tracking, the straight climbs go unbitten (0 of 16 in the sweep), so the test fails.

The pass 273 and 274 Naga tests still pass.

Bible 7: the Naga entry now describes the coil's tracking, the recovery and the timed climb.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the Tower's two Naga ladders are now a timing puzzle, as the bible promised. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 276 takes Bosses (last pass 268).
