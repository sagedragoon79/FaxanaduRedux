# Pass 387: how the zones meet (World)

Category: World and level design (last pass 379).

## Audit

Passes 380 to 386 added no room or door. The audit read bible 3 for claims no test reads. The first picture in the section is the overview's diagram of the World Tree, and nothing held it. Built from the rooms' doors, the zones meet differently than it drew:

- The diagram had the Tower meet Mascon, Conflate meet the Canopy Spires, and the Spires meet Dartmoor. Mascon and the Spires are parts of the Mist and Daybreak, not zones, and none of those links is a door.
- The zones meet in a single chain, each pair at exactly one doorway: Eolis, Trunk Hollows, the Tower, the Mist, Branches, Daybreak, Dartmoor and Zenis, with the Sunken Spring off Dartmoor.
- The sentence over the diagram said each zone "loops back on earlier zones through shortcuts". No door joins zones that are not neighbours. The ways back that skip the chain are the Forepaw lift (the Tower Foot, Forepaw and Eolis's East Gate), the Mantra Path between Gurus, and the Guru's road to the Trials.
- Inside the zones, only the first two loop: Trunk Hollows 8 times (35 links among 28 rooms) and the Tower 4 times (29 among 26). In Eolis and every zone from the Mist up, the rooms form a tree, so the way back is the way you came, a lift, or the Mantra Path. Pass 195's rest-distance rule keeps those zones playable: no room is more than 4 doors from a shrine or Guru, and 3 where blows hit double.

## Fix

- Bible 3.1's diagram is redrawn as built, naming the doorway between each pair of zones and the lift and Guru roads.
- "**How the zones meet, as built (pass 387)**" records the deviation, gives a table of the eight doorways, and counts the loops in each zone.
- `test_the_zones_meet_as_the_bible_draws` (test_rooms) checks, from `World.catalog`, that:
  - every doorway between zones is the one in the table, and every row of the table is a real doorway (both ways);
  - Trunk Hollows has 8 loops and the Tower 4, with the counts of links and rooms the bible gives;
  - every other zone's rooms form a tree;
  - the Forepaw lift stops at the three rooms named.

Mutation check: a table row naming the wrong Tower room, and a loop count of 7, each fail.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. The overview now draws the tree as built, and the chain and its loops are held to the doors. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 388: Bosses. A later World pass could weigh whether the zones from the Mist up want a shortcut loop each. Today their way back is the Mantra Path and the shrines.
