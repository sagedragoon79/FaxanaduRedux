# Pass 339: the gates' numbers, held (World)

## Audit

The World category was last audited in pass 331, which held the room sizes and shrine counts in bible 3.3. This pass read bible 3 and 4 against `levels/` and the world scripts. The zone table's room counts (3.2) have been held since pass 323, and the critical path and gates are held by the reachability checker. Only one test reads a section of 3 or 4 by name (3.2 Zones). Bible 4.5, the gate visual language, gives each gate's numbers:

- the fog's sight (about 7 tiles) and a lantern's light (about 4 tiles);
- the Spring of Mist halving the fog and widening sight by half;
- a fire seal's burn of 10;
- a basin filling over a second;
- a conduit's reach of 72 px;
- time-locked water pushing at 260 px/s, with footholds every three rows;
- card doors three tiles tall.

Bible 3.2 gives the Mist's fog of 0.88, and for Victim and Mascon their fog of 0.6, their lamp posts (four and three) and each lamp's 84 px pocket. Every number matches the code. None was read by a test, so retuning a gate would have left the bible behind.

## Fix

- `test_every_gates_number_is_written_in_bible_4_5` (test_rooms.gd) holds each of these to its constant (`Fog`, `FireSeal`, `DryBasin`, `ThunderBolt.ARC`, `Waterfall`, `KeyDoor.SIZE`, `TownLamp.light_radius`). It counts each town's lamp posts and reads its fog from its room file.
- Bible 4.5 now ends with a "gates' numbers, held (pass 339)" note that names each constant and the test.

Mutation check: with a conduit's reach at 80 px, the water's push at 250 px/s and one Mascon lamp removed, the test fails three times, naming all three.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the gates' numbers and the Mist towns' fog and lamps are held to the code. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 340, Bosses: audit passes 333 to 339 for boss facts in bible 8 that no test holds or that the code disagrees with (zorugeriru.gd stays untouched).
