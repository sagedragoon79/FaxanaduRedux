# Pass 202: the combat table, held to the bible

Combat's last pass (194) was the oldest apart from Art, so pass 202 takes Combat. I audited combat and enemies (bible 5 and 7, `combat_tuning.gd`) against passes 195 to 201.

| Check | Finding | Verdict |
| --- | --- | --- |
| Guardians at zone threat (196) | The guardians' sheet (5.5) holds every guardian to 0.5 to 1.5 masks through par armor, and it passes. | fine |
| The heavy hurt sound (198) | Plays only for a blow of a mask or more. Sound only. | fine |
| The Pendant (201) | It multiplies the blade's damage through `Player.blade_mult`, so tempers, the War Glove and skills stack with it as they do with each other. The damage sheet's par kit leaves it out, so its 2 to 7 slashes are the worst case. | fine |
| The Magical Rod (201) | Deluge goes from 12 to 18 for 15 MP: 1.2 damage per MP, against Thunder's 0.9 and Fire's 0.9. Those two keep their uses (Thunder's chain and conduits, Fire's arc and burning bark). Spells stay flat while the blade tempers. A probe of every zone's foes found Deluge kills in about as many casts as the par blade takes slashes, up to 8 casts for Zenis's Iron Dwarf (6 with the Rod). Spells stay a support, held back by MP. | fine |
| **Bible 5.3's "Starting combat values"** | The table says "asserted by tests", and pass 200 found that 6.1 had not been. Searching for each `CombatTuning` value by name found eleven that no test reads: the air combo, the parry window, the guard's walk speed, the hazard damage, MP regen, the cast cooldown, the Thrust's speed, time and cooldown, the Rod, and death's 60%. Most rows were played, but against the tuning, so a changed number would have moved its test with it. Two rows had no play test at all: the guard's 40% walk and MP regen of 2 a second. | **fixed: every row held to the bible, and the two get a play test** |

## As built

- `test_combat.gd`:
  - `test_the_starting_combat_values_match_bible_5_3` (new) checks every row of the table against the text: the melee numbers, buffers and hit-stops, shield, being hit, low health, MP, the Red Potion, Deluge, the War Glove, the Thrust, coins, the relics and death's 60%.
  - `test_a_guard_walks_slow_and_mp_comes_back_slowly` (new): guarding, you walk at 66 px/s, 40% of a run, and 2 MP comes back in a second.
  - With the guard set to 0.5 and regen to 3, both fail, as they should.
- Bible 5.3: the table names its test and gains two rows, the relics (pass 201) and death's 60% (5.4).
- No combat number changed.

Full suite: 3947 of 3947 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the table of combat values is now held to the bible, as its heading said. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 203 takes World (last pass 195, now the oldest).
