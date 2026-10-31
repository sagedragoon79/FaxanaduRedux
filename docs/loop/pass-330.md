# Pass 330: every spell has a row in 5.3

Category: Combat (last pass 322).

## Audit

- **Spells.** Only Deluge had a row in the 5.3 table of starting combat values. Thunder (18 MP, 16, 380 px/s), Fire (20 MP, 18, 170 and 150 px/s), Tilte (22 MP, 14, Swarm 10) and Death (40 MP, 36, guardians 18) were written only in prose in 4.1 and 4.4, and **no test held them to the bible**: the spell tests read each cost back from `Spells.DATA` (`Spells.cost("thunder")`), so a changed cost moved its test with it. Pass 329's ratio check holds Fire against Deluge and Death above the rest, not the numbers.
- **The tuning.** `test_the_starting_combat_values_match_bible_5_3` (pass 202) copies each number into the test. A change made in the tuning and that test together passed with the bible left behind. Movement got a test that reads bible 6 in pass 328; combat had none.
- **The cast cooldown and Death's boss cap** are held by `test_spikes_cost_a_mask_and_casts_wait_their_cooldown` and the Death tests.
- **Mercy (pass 325)** is held by `test_the_mercy_assist_doubles_a_hits_grace`, which plays a hit in a fight. **The dagger and shield builds** are held by passes 326 and 320 and the off-hand tests.

## Fix

- Bible 5.3: rows for Thunder, Fire, Tilte and Death beside Deluge's, and a sentence on the new test.
- Test: `test_every_combat_number_is_written_in_bible_5_3` (test_combat.gd) reads 5.3. Every number in `CombatTuning` (arrays and vectors by element) must be written there, and each spell's row must name its own cost, damage, speed, lift, swarm and guardian damage.
- Pass 328's `_written` helper moved to `TestSuite.written_in`, shared by both bible tests. It now ignores pass numbers: "pass 330" in the new sentence had been enough to pass a `thrust_speed` of 330.
- Mutation checks: Thunder at 25 MP fails its row; `thrust_speed` 330 fails the tuning check.

No number changed and nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: every spell's numbers are now held to the bible. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 331 takes World (last pass 323).
