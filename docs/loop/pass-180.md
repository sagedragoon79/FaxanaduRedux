# Pass 180: every fruit and dew counted

Every category apart from Art was tied at 99. Systems weighs 10 and its last pass (172) was the oldest at that weight, so pass 180 takes Systems. I audited the systems (bible 9 to 12) against the newest content (passes 172 to 179).

| Check | Finding | Verdict |
| --- | --- | --- |
| Completion and the Journey page | the Matriarch (pass 179) is among `Completion.GUARDIANS` and the guardians total (16) | fine |
| Saves | every guardian stays beaten through a save (pass 174), the Matriarch included, since that test reads the rooms' `boss:` headers | fine |
| Shops | Forepaw's larder and hospital (pass 175) sell and heal as the bible says | fine |
| **Stat ceilings** | Bible 5.1 says 14 Life Fruits (12 masks) and 9 Mana Dews (150 MP). Counting every source gives 18 fruits (13 in rooms, 4 grocers, the Alpha) and 16 dews (9 in rooms, 4 grocers, Ripasheiku, the Captain, the Matriarch): 14 masks and 220 MP. Nothing checked the totals, and the player had no way to see how many remained. | **fixed** |

## As built

- The World catalog counts each room's Life Fruits (`L`) and Mana Dews (`W`).
- `Completion.stat_items(catalog)` counts every fruit and dew in the game: rooms, the shops' stock and the guardians' rewards. It reads a save's share from its max health and magic, which nothing else raises. `Completion.tally` includes it, outside the percent.
- The Journey page shows "Life Fruits 0 / 18" and "Mana Dew 0 / 16" under the guardians beaten.
- The ceilings stay as built (14 masks, 220 MP; 240 with Clear Mind). The tests pass at those numbers, and the extra fruits and dews are spread across optional shops and fights. Bible 5.1 and the section 10 table now give the real counts and where they come from.

## Screenshots

- `/mnt/project-files/pass-180/journey.png`: the Journey page with the two new rows.

## Tests

- `test_systems.gd`, `test_the_journey_counts_every_life_fruit_and_mana_dew` (new): 18 fruits and 16 dews in all, 13 and 9 in the rooms; together they make 14 masks and 220 MP; a new save has none; two fruits and a dew are counted and leave the percent alone; the Journey rows show them.

Full suite: 3386 of 3386 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged: the stat ceilings are counted and pinned, and visible to the player. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 181 takes Audio (weight 5, last pass 173, now the oldest). Stability (174) follows, and should make the journey soaks' 50 ms spike check robust to a lone spike on room entry.
