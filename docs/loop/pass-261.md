# Pass 261: the sounder's charts

Category: Systems (last pass 253).

## Audit

I read bible 9 to 11 against the shops and the map. Bible 3.3 says "the Cartographer in each town sells the zone outline", and 10.2 lists a Cartographer in every town. Six zones have a chart:
- Eolis
- the Trunk
- the Tower
- the Mist (sold twice)
- the Branches
- Daybreak

Dartmoor had none, though its Drowned Market wakes into a town once King Grieve is at rest, and so did the Sunken Spring below it. Those are the two zones with the most hidden rooms, and the ones a completionist is most likely to be hunting through late in the game. Treasure Sense already marks unfound treasure on charted rooms, so the missing charts also hid those marks there.

## Fix

- Two charts in `data/items.json`: `chart_dartmoor` and `chart_sunken`.
- A shop, `dartmoor_charts` ("Sounding-Line Charts", 750 g and 800 g), kept by **Sounder Hulda**. She is a hooded dwarf who "swam these halls by memory" for forty years. Her sheet comes from `castgen.py`.
- She stands in the Drowned Market (13,16) once `boss:king_grieve` is set, like the rest of the woken town.
- Test: `test_every_zone_on_the_map_has_a_chart_for_sale` (`test_economy.gd`).
  - Every zone the map draws (all but Zenis, the meteor no one has drawn) has a chart sold by a keeper standing in some room.
  - Hulda isn't in the market while Dartmoor is drowned, and is there after.
  - She sells both charts for 1,550 g, and the Sunken Spring then shows on the map, dimmed.
- Screenshots, looked at: `/mnt/project-files/pass-261/sounder.png` shows her on the market floor, and `sounder_shop.png` shows her shop.
- Bible 3.3, the Map line.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: every mapped zone can be charted. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 262 takes Audio (last pass 254).
