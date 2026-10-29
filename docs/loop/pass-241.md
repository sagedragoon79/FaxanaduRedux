# Pass 241: Fraternal Castle

Faithfulness's last pass (233) was the oldest apart from Art, so pass 241 takes Faithfulness.

| Check | Finding | Verdict |
| --- | --- | --- |
| Towns, Gurus, ranks, rings, keys, springs, spells, relics, bosses | `test_the_faithfulness_checklist_is_all_here` covers all of these (pass 201). | holds |
| Gear and goods, town shops | Passes 209 and 233. | holds |
| Bread drops, poison, the King's 1,500 g, Elixir revive | Built and tested (`drop.gd`, `test_economy.gd`). | holds |
| **The original's named places** | Checked against the [StrategyWiki walkthrough](https://strategywiki.org/wiki/Faxanadu/Walkthrough). The Tower of Trunk is kept as a zone. Fraternal Castle, where the original's dwarf king keeps the Dragon Slayer and the Demon Ring, appeared nowhere, though King Grieve gives both up exactly as there. His hall was just "Throne Hall". | **fixed** |
| Tower of Mist, Tower of Suffer, Tower of Fortress | The remake's map moved what these held: the Onyx is in Dartmoor's crypt, the Joker Key in the Drowned Market, and the Pendant in the Matriarch's Mire (the bible 5.2 row already cites the Tower of Suffer). None is a tower here, so giving them the names would mislead. | left as is |

## As built

- `levels/dartmoor/throne_hall.room`: titled **Fraternal Castle**, which shows on the map and in the "Welcome back" toast. Its sign reads "FRATERNAL CASTLE, THE THRONE HALL."
- The King's Stair sign now says it goes "down to Fraternal Castle", and the kennels' throne sign calls the throne "the heart of Fraternal Castle".
- `test_the_faithfulness_checklist_is_all_here` (`test_economy.gd`): King Grieve's arena is titled Fraternal Castle, and the stair's sign names it.
- Mutation check: with the old title, the test fails ("King Grieve's hall is Fraternal Castle").
- Bible 3.2 (Dartmoor), 8.7 and 15.3 Faithfulness.
- Screenshot: `/mnt/project-files/pass-241/fraternal_map.png`. The map's room line reads "Fraternal Castle" and fits.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the original's last named castle is back. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 242 takes Combat (last pass 234, now the oldest).
