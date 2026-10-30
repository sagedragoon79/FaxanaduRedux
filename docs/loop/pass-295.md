# Pass 295: a ledge's corner is footing

Category: Stability and performance (last pass 287).

## Audit

I checked stability and performance (bible 15.3) against what passes 288 to 294 touched.
- **The gone-tile check (pass 292).** Its cost is a few cell lookups for each floor contact in a frame. Every room's frame-budget soak still passes. **But I walked the player both ways through every room of five zones (Tower, Trunk, Mist, Branches, Dartmoor) and counted floor contacts on tiles that the check read as gone.** It got 150 of 63,792 wrong, in five rooms. Each one was a contact on a ledge's corner. That point lies exactly on the line between two cells, and the check read the empty cell to the right. So standing on that corner never kept a safe spot, and a spike set you back further than your last footing.
- **The purse and the set-back spot (passes 292, 293).** `safe_position` is set when the player is made and every time the World places them: entering a room, respawning, after a load. So it is never left at zero or in another room. `_keep_set_back_off` moves it only onto a solid tile inside the room.
- **A fall out of the room (pass 291).** A dead foe returns at the top of `_physics_process`, so it can't fall-die twice. A foe that respawns comes back at `home`. A corrupted foe's seed bursts and frees itself after 0.88 s. A brood that perishes is already dead.
- **New sounds (passes 286, 294).** `flask_empty` and `mana_orb` load with the game. `test_every_boss_fight_holds_the_frame_budget` requires every wav to load at start.

## Fix

`Player._on_fleeting_ground` reads the cells half a pixel to either side of the contact. The floor counts as gone only when both are empty.

Test: `test_a_ledge_corner_is_footing_for_the_set_back` (`test_soak.gd`) walks the player both ways through the five rooms where it went wrong. No tile floor may read as gone. With the old single read put back, it fails in the Winch Hall.

Bible 6.13: a sentence after pass 292's.

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
| Stability and performance | 5 | 99 | Unchanged score: the set-back reads ledge corners as footing again. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 296 takes Movement (last pass 288).
