# Pass 233: the original's gear, held as a whole

Faithfulness's last pass (225) was the oldest apart from Art, so pass 233 takes it. I checked the original's checklist against the game and against what the tests hold.

| Check | Finding | Verdict |
| --- | --- | --- |
| Towns, Gurus, ranks, rings, keys, springs, bosses, spells, relics | Held as a whole by `test_the_faithfulness_checklist_is_all_here` (pass 201, extended in 217). | holds |
| Town tool and key shops | Held by `test_every_town_keeps_the_originals_shops` (pass 209). | holds |
| Progression order | The Glove, Stride and Boots each gate the critical path (passes 227 and 232); the Dragon Slayer comes only from King Grieve (217). | holds |
| **Gear and goods** | Every one of the original's blades, armors, shields, the Battle Helmet, the Elixir and the Ointment is in the game, but no test held them. A rename, a dropped shop shelf or a reordered ladder would slip through. | **fixed** |
| Consumables | Red Potion (flask charges), bread, poison and the War Glove drop are each tested on their own. | holds |

## As built

- `test_the_originals_gear_is_all_here` (`test_economy.gd`, new). It checks that:
  - all 14 items keep the original's names (or Sean's renames: the Short Sword and the Dwarvish Broad Sword);
  - each can be had: sold by a keeper who stands in a room, laid in a room, given by a guardian (the Battle Suit, the Dragon Slayer) or worn from the start;
  - each ladder climbs: blades by slash damage, armors by defense, shields by ward;
  - `GameState.RENAMED_ITEMS` still carries old saves' Hand Dagger and Giant Blade across.
- Mutation check: renaming the Long Sword and taking the Magic Shield off its shelf each fail the test.
- Bible 15.3's Faithfulness row names the new test.
- No visual change, so no screenshot.

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
| Faithfulness | 5 | 99 | Unchanged score: the whole checklist, gear included, is now held by tests. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 234 takes Combat (last pass 226, now the oldest).
