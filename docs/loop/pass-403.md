# Pass 403: every rest on the map

## Category

World (last pass 395).

## Audit

- Bible 3's world rules are each held by a test:
  - the room bounds;
  - doors that lead back (`test_every_real_door_has_a_matching_door`);
  - rooms within 4 doors of a rest, or 3 in the deep zones (`test_no_room_is_far_from_a_rest`);
  - the shrine count per zone after pass 396;
  - the walk back to a Guru (pass 395);
  - the landmarks, the secrets, and the zones' meeting points.
- Reachability passes with the new shrines.
- The gap was on the map, the tool a player uses to find the nearest rest. The map and the minimap marked every Meditation Shrine but no Guru. Bible 3.3 says each town's Guru rests and saves, and two zones (The Mist, Daybreak) rely on their Gurus for the distance rule. Even so, Eolis, Apolune and every other town showed no rest at all. A player who wanted to save could not see the nearest place to do it.

## Fix

- `World.build_catalog` lists each Guru's cell with the shrines (`info.shrines`, now documented as every place to rest and save). The map and the minimap draw both with the same mark.
- The map's legend now says "Rest" instead of "Shrine".
- `test_the_map_marks_every_rest` (test_rooms.gd) checks each real room. Every `S` shrine and every Guru must be on the map, with no extra marks. It counts all eight towns' Gurus, checks that Eolis (no shrine) shows its Guru, and checks the legend's word.
- Bible 3.3's Map line gains "Every rest on the map (pass 403)".

Screenshot: `/mnt/project-files/pass-403/apolune-map.png`, the map in Apolune with the Guru's rest marked and the legend reading "Rest".

Mutation check: without the Guru loop in `build_catalog`, the test fails twice. The rooms missing a mark include Conflate and the Drowned Market, and Eolis shows no rest.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The map shows every place to rest, town Gurus included. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 404: Bosses.
