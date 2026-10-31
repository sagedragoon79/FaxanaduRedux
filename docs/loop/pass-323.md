# Pass 323: the bible counts the rooms the game has

Category: World (last pass 315).

## Audit

- **Passes 316 to 322.** No room changed. Pass 315 left the Hornet Gallery clearable with the dagger alone, and `test_the_hornet_gallery_can_be_cleared_with_the_dagger` holds it. Passes 314 and 316 cover a shield build and a dagger build at every guardian, with an opening for each and the dagger's reach. No room asks for the dagger: nothing in `scripts/world/` answers only to a throw.
- **Bible 3 against `levels/`.** The overview (3.1) promised "about 190 rooms", and the zone table (3.2) still carried the plan's counts: Eolis 10, the Mist 34, the Branches 24 and 26, Dartmoor 28, Zenis 14 and the Sunken Spring 8. The game has 126 room files. The Trunk (28), the Tower (26) and the Trials (6) match the plan, and every zone after them came out at a third to two thirds of it, in rooms of about the same size. **No test tied the table to the levels**, so the world's own summary read as a game half again as large as the one built.

## Fix

- Bible 3.1 now says 126 rooms (the plan said about 190). In 3.2, each Rooms cell gives the built count with the planned one beside it where they differ, for example "14 (34 planned)". An "As built (pass 323)" paragraph says where the plan fell short (the filler between beats, not a step of the critical path) and why.
- Test: `test_the_bible_counts_each_zones_rooms` (test_rooms.gd) counts each zone folder's `.room` files against its row, requires every folder (the gym aside) to have a row, and checks the overview's total. Against the old bible it fails 8 checks.

No room changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the bible's world summary now matches the world, and a test keeps it there. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 324 takes Bosses (last pass 316).
