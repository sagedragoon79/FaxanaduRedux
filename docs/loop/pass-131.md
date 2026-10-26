# Pass 131: a hidden room in every zone

World (97.25, weight 15) was tied with Faithfulness as the lowest category apart from Art, and weighs more. I counted each zone's secrets against bible 11 ("at least 3 secrets per zone room-cluster").

| Zone | Rooms | Hidden rooms (`secret:`) | Fake walls, hidden planks, cracked walls | Verdict |
| --- | --- | --- | --- | --- |
| Eolis | 6 | 1 | 6 fake walls | fine |
| Trunk | 28 | 2 | 24 fake walls, cracked walls | fine |
| Tower | 26 | 2 | 12 fake walls, cracked walls | fine |
| **Mist** | 11 | **0** | **none** | **built** |
| **Branches** | 9 | **0** | **none** | **built** |
| **Daybreak** | 9 | **0** | 4 bramble cells | **built** |
| Dartmoor | 13 | 2 | 13 fake walls, 36 hidden planks | fine |
| Zenis | 7 | 1 |  | fine |
| Sunken Spring | 4 |  | a short side area | fine |

Three whole zones, 29 rooms, had nothing hidden: every reward in them was a chest or a pickup in plain sight. The Black Onyx, found in Dartmoor, had nothing to show when you went back to them.

## As built

Each new hidden room is a pocket behind a fake wall at floor level, where a curious player walks into the stone. A `secret:` cover hides what is inside until you step in, and a `chest:` line sets its gold:

| Room | The pocket | Chest |
| --- | --- | --- |
| Veiled Rise (the Mist) | the stone block in the bottom-left corner is hollow, entered from its east face | 500 g |
| Sunlit Bough (the Branches) | the foot of the west buttress, under the doorway ledge | 600 g |
| Broken Shrine (Daybreak) | a cell in the cliff east of the shrine | 700 g |

Each sits on the main floor of its room, so no ability is needed, and the reachability checker reaches each chest. Finding one sets `secret:<room>` and counts toward the completion screen's hidden rooms.

## Screenshots

In `/mnt/project-files/pass-131/`:
- `veiled_rise_outside.png`: the corner block as it looks from the floor.
- `veiled_rise_inside.png`, `sunlit_bough_inside.png`, `broken_shrine_inside.png`: inside each pocket, the cover faded and the chest there.

## Tests

- `test_every_large_zone_hides_a_room` (`test_rooms.gd`), new: every zone of five rooms or more in the catalog hides at least one room. Before this pass, it would have failed for the Mist, the Branches and Daybreak.
- `test_reachability.gd` passes with the three rooms, including their chests.

## Bible

Section 11: "Hidden rooms in every zone (pass 131)".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.5 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.5 | Every zone now rewards a closer look, and a test keeps it so. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2486 checks, all passing, with no script errors in the log.

Weighted score: 95.675 (up from 95.6375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (97.25) is the lowest apart from Art. Pass 132 takes Faithfulness.
