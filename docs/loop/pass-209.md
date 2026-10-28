# Pass 209: the towns' shops, held to the original

Faithfulness's last pass (201) was the oldest apart from Art, so pass 209 takes Faithfulness. I audited the bible's checklist (15.3) and the original's towns, people, items and story beats against what is built, and against passes 202 to 208.

| Check | Finding | Verdict |
| --- | --- | --- |
| Checklist (201) | Towns with Gurus, ranks, rings, keys, springs, bosses, spells and relics are held by `test_the_faithfulness_checklist_is_all_here`. | fine |
| The King's 1,500 gold, the return to the King in the ending | Both are in `npcs.json` and the ending's text. | fine |
| Forepaw's hospital and larder (175) | Both are built: the physician and Dagny. | fine |
| Passes 202 to 208 | Tests, numbers and sounds only. Nothing touched the original's content. | fine |
| **The towns' shops** | In the original every town had a tool shop, and keys were bought. No test held this. A town whose grocer was moved or cut would have lost its shop without anything failing. Bible 10.2's item-shop row was also stale: it promised a Poison cure (80 g) that no shelf sells and the items table doesn't have, and it put Mana Dew and Life Fruit in every town. | **held: a test, and the row corrected** |

## As built

- `test_every_town_keeps_the_originals_shops` (new) reads the shops through the keepers who stand in the rooms. It checks:
  - each of the eight towns has someone selling an Ointment or an Elixir, and someone selling Jack Keys;
  - the Queen, King and Ace Keys are each sold somewhere;
  - the Joker Key is never sold;
  - every shelf names a real item.

  A mutation (a misspelled Jack Key in Mascon) fails it twice.
- Bible 10.2: the item-shop row now matches what is built. Mana Dew and Life Fruit are sold in the four larger towns. The Poison cure is dropped, because poison lasts only 8 s and bread, the hospital and any rest at a shrine or Guru already clear it.
- Bible 15.3: the Faithfulness row names the new test.
- No content changed: every town already passed.

Full suite: 4018 of 4018 checks passed, with no script errors.

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
| Faithfulness | 5 | 99 | Unchanged score: the towns' shops are now held, and the bible's shop row is true. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 210 takes Combat (last pass 202, now the oldest).
