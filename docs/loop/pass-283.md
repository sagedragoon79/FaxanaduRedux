# Pass 283: a drop never leaves its room

Category: World (last pass 275).

## Audit

Pass 281 made a slain Naga leave a great loaf. Both Nagas float over the Tower's ladder shafts, so I checked where the loaf lands:
- **Mine Shaft:** the Naga's column (col 30) stands right over the gap in the shaft's floor (cols 30 to 32), which drops to the Mine Mouth.
- **Tower Foot:** the Naga floats at col 33, beside the floor gap at cols 34 to 36 that leads to the Spring of Trunk. Door 1 sits low in the east wall.

I placed a loaf at every kill point along the serpent's swing (±40 px) and its strike (up to 105 px toward the ladder), popping left, straight up or right. That is 72 drops per room. **30 of 72 in the Foot and 18 of 72 in the Shaft fell out of the room**, through the gap or out the side door. A third of the reward, gone where you couldn't follow. The same could happen to any foe's drop near a floor gap.

## Fix

- `Drop._keep_in_room` (`scripts/pickups/drop.gd`), every frame:
  - A drop that pops past a side edge stops at it.
  - A drop that falls below the room's floor line (through a gap) comes to rest on the floor at the nearer edge of the gap: the first solid column of the room's bottom row, on top of its floor.
  - If no such column exists, it is freed as before.
- Test: `test_a_nagas_loaf_lands_where_you_can_reach_it` (`test_rooms.gd`).
  - In both rooms, all 72 drops must come to rest on a floor inside the room.
  - The hero waits out of the way and frozen, so no loaf is eaten before it is judged.
  - Mutation check: without `_keep_in_room` it fails, 30 and 18 of 72 lost.
- Bible 7: the Naga's entry.
- No screenshot: this changes where a drop rests, not how anything is drawn, and the test checks the position.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: no drop can fall out of a room through a floor gap or a side door. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 284 takes Bosses (last pass 276).
