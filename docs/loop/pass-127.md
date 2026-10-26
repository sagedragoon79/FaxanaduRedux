# Pass 127: the map remembers locked doors

Systems (97, weight 10) was the heaviest of the lowest categories apart from Art. I audited the systems against the bible and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Saves | ladders, dissolving foes and card doors keep nothing on nodes that a save needs; an opened door is a collected pickup id | fine |
| Shops, keys | every card key is sold on the road to its vault, and the Joker Key lies in the Drowned Market | fine |
| Skill tree, settings, Guru Trials, completion, ending | covered by their tests, unchanged since their passes | fine |
| **Map** | Bible 3.3: "Doors, gates and items get icons once seen." Shrines and Treasure Sense's star were marked, but a key door was not. You meet the Queen vault in the Mist long before you can buy its key in Apolune, and the map gave no hint of where it was once you had the key. | **fixed** |

## As built

- **The catalog:** each room's entry in `World.catalog` now lists its key doors as `locks`: the cell, the kind (`jack` unless a `lock:` line names another card, `sky` for the Sky Gate) and the door's pickup id.
- **The map:** every visited room draws a small slab for each of its doors still shut, in the card's own panel color (the Sky Gate in its shrine stone), with a gold band, standing where the door stands. It goes once the door opens.
  - `MapScreen.locked_doors(info)` and `MapScreen.lock_color(kind)` hold the logic, so tests can read it without drawing.
  - The legend adds "Locked door".
- Charted rooms you have not entered show no doors, as before: the map marks what you have seen.

## Screenshots

`/mnt/project-files/pass-127/map_queen_door.png`: the map in Feather Hollow, with the Mist charted. The Queen door's red slab stands at the room's west end, beside the player, and the legend reads "Locked door".

## Tests

In `test_economy.gd`, `test_the_map_marks_key_doors_still_shut`:
- a test room's Queen and Jack doors are both listed, with their kinds and ids;
- each is marked in its own door's color;
- an opened door leaves the map;
- in the real world, the map knows where the Queen, King, Ace and Joker doors and the Sky Gate are, and the Queen vault is in the Feather Hollow.

## Bible

- 3.3 Map: what the map marks so far.
- 4.5 Key doors: the map's mark for a shut door.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | The map now remembers every locked door you pass, as bible 3.3 asks. |
| Audio | 5 | 97 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2460 checks, all passing, with no script errors in the log.

Weighted score: 95.5375 (up from 95.4875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio and Stability are tied at 97, the lowest apart from Art, and weigh the same. Pass 128 takes Audio.
