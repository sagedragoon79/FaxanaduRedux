# Pass 371: every zone's three landmarks

Category: World and level design.

## Audit

Bible 3.3 says every zone has at least three visually unique landmark rooms so players can navigate by memory, and names the Tower's three. Nothing checked it, and no other zone's were written down. Counting each zone's set-piece props, guardian arenas and towns, every zone had three except the Sunken Spring: its Wellspring arena stood beside three rooms of plain flooded stone, with only their signs to tell them apart. The rubric's World row names landmarks, so this was the gap.

## Fix

- Two code-drawn set pieces for the Sunken Spring, both the kind of landmark the bible's line names:
  - `DrownedStatue` (`drowned_statue`, Spring Gate): a dwarf king carved in stone, 224 px tall, drowned at the foot of the shaft with his hammer grounded and his crown bowed, weed swaying from crown and beard and a bead of air rising from his lips. Drawn behind the water so the flood tints him.
  - `AqueductSpill` (`aqueduct_spill`, Drowned Aqueduct): the dwarves' channel snapped off under the ceiling, still pouring a white fall into the flood, with streaks running down it, churning foam and spray.
- Both were screenshotted in their rooms; they read at a glance and sit in open water.
- Bible 3.3 now names every zone's three by room and what marks it.
- `test_every_zone_has_its_three_landmarks` (test_rooms): every zone on the map has an entry; each room stands in its zone and carries its mark (a prop, a guardian, a town's houses, or the King); each zone's three are marked differently; the bible paragraph names each room.
- `test_the_sunken_springs_set_pieces_stand_clear`: the king stands on the shaft floor in open water, head to plinth, and the fall hangs under the ceiling and drops clear into the water.

Mutation check: removing the statue's prop line fails the landmarks test; moving the spill three rows down fails the set-piece test (2 checks).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. Every zone's landmarks are written and held; the Sunken Spring gained two. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 372: Bosses.
