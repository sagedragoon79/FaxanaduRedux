# Pass 290: a kill's drop comes at the table's odds

Category: Combat (last pass 282).

## Audit

I read bible 5 and 7 and `combat_tuning.gd` against the tests, and looked at what passes 283 to 289 touched.

**Already sound:**
- **Every `CombatTuning` value is named in a test.**
- **A refused drink (pass 286)** plays its sound and returns. It starts no drink and spends nothing, so a guard, a parry window or a swing goes on as before.
- **A blow that knocks you onto fleeting footing** (pass 288) can't make it your safe spot. A set-back also gives you the 0.8 s of hurt invulnerability, so landing where a foe stands costs nothing more.
- **The Myconid's sure bread (pass 289)** is the original's own rule. A Myconid comes back only when you leave the room and return, as every foe does. It costs a fight in its spore cloud, and +15 is less than one blow in the Mist. Bible 5.5 has no healing budget to change.

**The gap: what a kill drops.** Every kill rolls once:
- bread 8%;
- a mana orb 10%, worth 12 MP;
- poison 7%, from Tower foes on;
- a rare item 2.5%, which is the War Glove 60% of the time, else an Ointment.

These are combat numbers, the sustain you fight on, but bible 5.3's table had no row for them. Only the rare chance was written down (7). The test runner zeroes every chance for every test, so none of them was held to anything, and the order of the roll was never checked. A change to any of them, or a broken threshold in `Drop.roll`, would have passed.

## Fix

- `drop.gd`: the game's odds are now named constants: `BREAD_CHANCE`, `MANA_CHANCE`, `POISON_CHANCE` and `RARE_CHANCE`. The live chances start from them and tests still zero them, so the shipped odds can be read even inside a test. No number changed.
- Bible 5.3: a new "Drops" row with every chance, the mana orb's +12, the Glove's share, and the rule that a sure drop (Naga, Myconid) replaces the roll. The bread row now names the Myconid's bread.
- Tests:
  - `test_the_starting_combat_values_match_bible_5_3` now checks the four chances, `MANA_GAIN` and `GLOVE_SHARE`.
  - New `test_a_kills_drop_comes_at_the_tables_odds` (`test_combat.gd`). It runs 20,000 seeded rolls without poison and 20,000 with it, then checks:
    - each drop lands within a point of its chance;
    - a foe without `poison_drops` never leaves poison;
    - the War Glove is about 60% of the rare items.

    The test sets the chances back to zero afterwards.
- Mutation check: with the Glove and Ointment swapped in the roll, the test fails (192 of 481 and 179 of 473 Gloves).
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the drop odds are now in 5.3's table and held to it. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 291 takes World (last pass 283).
