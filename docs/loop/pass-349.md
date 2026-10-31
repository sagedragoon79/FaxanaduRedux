# Pass 349: the secrets table counts the rooms

Category: Systems (last pass 343).

## Audit

- **Passes 344 to 348** changed no system. The checks already holding the systems sections still pass on main:
  - section 9: the skill tree's cost and its 34 points;
  - section 10: the gold sheet (pass 341) and the prices;
  - section 11: the finds (pass 243) and the Journey page;
  - section 14: the one save slot (pass 343).
- **Bible 11's secrets table** gives a count for each kind of secret. The finds rows (Life Fruit, Mana Dew, Potion Shards, Mantra and Meteor Shards) are held by `test_the_rooms_hold_the_finds_the_bible_counts`. **Four rows were still the plan's, and no test read them.** Counted from `levels/`:
  - **Breakable walls (Mattock):** the table said 18. The rooms hold 14 cracked-stone walls.
  - **Illusory walls (Black Onyx):** the table said 10. The Onyx's seam shows in 14 rooms, and 12 of them hide a room (the Journey's hidden rooms).
  - **Key doors:** the table said 12, guarding "equipment, spells, shortcuts". There are 5, one of each card. Since pass 117 they guard gold vaults and never the way on (4.5).
  - **Lore tablets:** the table said 12, in the dwarf ruins. Every sign is a carved tablet (`LoreTablet`), 142 of them in every zone.

## Fix

- Bible 11: each of the four rows now gives the built count with the plan's count beside it ("14 (18 planned)"). The key doors' Reward column says what they guard. A new note, **The table, as built (pass 349)**, explains the change and names the test.
- Test: `test_the_secrets_table_counts_the_rooms` (test_economy.gd) counts each kind from the rooms and holds the table's cells to the counts:
  - cracked-stone patches (`_clusters`);
  - rooms with a `%` or a `secret:` cover, and those with a `secret:` line;
  - `J` doors, and checks there is one per card;
  - the cells that `sign:` lines carve.
- Mutation check: putting back the plan's 18 walls and 12 doors fails the test on both rows.

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. Every count in the secrets table is the rooms', and held. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 350 takes Audio (last pass 342).
