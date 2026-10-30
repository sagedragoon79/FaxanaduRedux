# Pass 307: no drop rests at a side door

Category: World and level design (last pass 299).

## Audit

I checked the world (bible 3, 4 and `levels/README.md`) against what passes 300 to 306 touched.
- **Where poison flasks land (pass 306).** I walked the floor under all 87 poison-dropping foes (the Tower's Iron Dwarves, Gear Bats and Minecart Riders, Dartmoor's Crystal Dwarves, every corrupted foe in Zenis). Each stands on a run of floor with at least 6 tiles of headroom somewhere near it, so a flask in the open can be hopped over or walked around. Low spots exist (the Rafters' far bat roost, 3 tiles; a Meteor Slug in the Heart Stair's 2-tile den, where the hero can't follow it anyway). Every flask also lasts only 10 s. **The one place a flask was a toll is a side door.** A drop that reached the room's edge stopped 8 px in, inside the door's cell, and one could also rest on the tile just inside. A door is three tiles tall. I swept hops of every timing and three heights at a flask one tile in, and none got through: a jump meets the wall above the door and drops you on the flask. With poison at 4 a second in the deep zones, a foe killed by a door left you 32 health to pay or 10 s to wait.
- **Floor and ceiling doors (passes 299, 304).** Every one lands on footing with a quarter second to steer (`test_every_door_up_or_down_lands_you_on_footing`). A rise lands you at the foot of the room above, the way any climb arrives, and the reachability test proves the way on from there.
- **The moved purse (pass 300).** `Room._beside_pit` moves it to the floor tile beside the tear, on the same row, where the set-back also puts you, so it is never anywhere you can't stand. Rokusutahn's arena has open floor on both sides of its tear (columns 6 and 33). Pakukame never tears within a tile of an earlier gap, so the tile a purse moves to is never torn later.
- **Shrines, signs and doors off-screen.** No rule in the bible asks for these to show on arrival, and a 40x45 room is two screens by design. The Proving Scar's "Rest first." sign stands four tiles from the throne door it speaks of. I found nothing to change.

## Fix

- `Drop.keep_in_room` (drops and coins): where the two tiles inside a side edge are open, it stops a drop on the second of them (`Drop.DOOR_CLEAR`, 40 px in), not in the doorway. Where they're walled (a tunnel), it keeps the old 8 px.
- Test: `test_a_drop_never_rests_in_a_doorway` (`test_rooms.gd`) knocks a flask into a door's cell. It must rest 40 px in, and a hop from 20, 28, 36 or 44 px short of it must clear it and take the door with no poison. With the old clamp, the flask rests at 8 px and the test fails.
- Bible 10.1 (Currency): a paragraph after pass 285's.

No screenshot: a drop sits two tiles further in, which a still frame wouldn't show.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: no flask can bar a door. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 308 takes Bosses (last pass 300).
