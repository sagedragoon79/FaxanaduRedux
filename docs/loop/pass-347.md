# Pass 347: the charts' prices, and one strict way to read a number

Category: World (last pass 339).

## Audit

- **Passes 340 to 346** changed no rooms, gates or maps. The world claims the earlier passes hold still pass on main:
  - the zone table and the overview's 126 rooms (`test_the_bible_counts_each_zones_rooms`, pass 323);
  - the shrines in each zone (`test_every_zone_has_the_shrines_the_bible_counts`);
  - the room sizes in 3.3 (pass 331);
  - the gates' numbers in 4.5 (pass 339);
  - a chart on sale for every zone the map draws (pass 261).
- **3.3's map line was not held.** It names each cartographer and every chart's price: Eolis 40 g, Trunk Hollows 250 g, Tower 400 g, Mist 500 g, Branches 650 g, Daybreak 700 g, Dartmoor 750 g and the Sunken Spring 800 g. It also says a cartographer stands "in six of the eight towns". No test read that line. A price changed in `data/shops.json` would have left the bible quoting the old one. Today all eight prices and the count are right.
- **The loose reading pass 346 found.** `TestSuite.written_in` still rounded any number under 100 to a whole one. It was used by four checks: all of 5.3 at once (pass 330), all of 6 at once (pass 328), each spell's row, and each 6.14 row. The strict reading (`written_exactly_in`) was used only by the per-row tests of passes 344 and 346.

## Fix

- New test: `test_the_bibles_chart_prices_are_the_shops` (test_rooms.gd). Every chart a `*_charts` shop sells must be written in 3.3's map line at its price. Every zone must have a chart for sale. The line's count of towns with a cartographer must match the shops.
- Mutation check: a Tower chart at 450 g in `shops.json` fails the test (`Tower 450 g`).
- The loose `written_in` is gone. All four of its callers now use `written_exactly_in`, and all still pass, so no number had been passing on a rounded form there. The strict helper also stops a match on the head of a thousands figure (no "60" found in "60,000"). The pass 344 movement test uses the shared helper now, so it has no copy of its own.
- Bible: the 3.3 map line names the new test, and 5.3's pass 346 note says the strict reading is now the only one.

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. The map line's charts and prices are held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. Every bible-number test reads the same strict way. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 348 takes Bosses (last pass 340).
