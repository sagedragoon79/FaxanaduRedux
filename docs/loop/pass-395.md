# Pass 395: no shortcut loops from the Mist up, decided (World)

Category: World and level design (last pass 387).

## Audit

- Passes 388 to 394 changed one room: the Windloft veil (388), which reachability and 8.5 already hold.
- Pass 387 left a question open: the zones from the Mist up are trees (one way into each room), against the plan's shortcut loops. Should they gain loops?
- What a loop would buy. No room is more than 4 doors from a save (3 in the double-threat zones), which `test_no_room_is_far_from_a_rest` holds. The Mantra Path joins every Guru once a spring runs clean. What a dead end still costs is the walk back to a Guru, and nothing wrote that walk down or held it.
- Candidates: the rooms that touch on the map without a door (a scan of `map:` rectangles):
  - Mascon / Dry Cistern: already 2 doors apart.
  - Drowned Nave / Drowned Market: already 2 doors apart.
  - Victim Causeway / Drowned Stair: 3 doors apart.
  - Onyx Crypt / King's Stair: 4 doors apart.
  - Spring of Mist / the Matriarch's Mire: 4 doors apart, but both are sealing boss arenas.
  - Upper Stair / Meteor Rise: 11 doors apart, but a door would let the player drop past King Grieve, and nothing in the game is a door that opens from one side only.
  None makes a good loop.

## Fix

- Bible 3.1: "No shortcut loops from the Mist up: decided (pass 395)". It gives the reasons, the candidates, and a table of each zone's rooms farthest from a Guru's room, in doors walked. Eolis 3, Trunk 6, Tower 8, Mist 5, Branches 4, Daybreak 4, Dartmoor 6, Sunken 8, Zenis 13. The long walks are explained: the Tower's lift and loops, the optional Wellspring's victory lap, the last climb of Zenis, and Dartmoor's Guru arriving with the king's fall.
- `test_the_walk_back_to_a_guru_is_as_3_1_says` (`test_rooms.gd`) finds the eight Guru rooms, walks the door graph from them, and holds every zone's farthest rooms and distance to the table. A room that lengthens a walk back must change the table.

Mutation check: with Mascon's Guru made a smith, the test fails 3 checks (seven Gurus; the Mist's farthest is the Mire at 9; the Branches' at 5).

Full suite: 7111 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. The open loop question is decided, and the walk back to a Guru is written and held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 396: Bosses.
