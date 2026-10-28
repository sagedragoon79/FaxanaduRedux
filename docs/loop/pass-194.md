# Pass 194: the damage balance sheet, and foes that keep up

Combat's last pass (186) was the oldest apart from Art, so pass 194 takes Combat. I audited combat (bible 5) against passes 185 to 193 and against the rubric's own Combat line (15.3): "telegraph times, hit-stop, every enemy has full animation set, damage balance sheet within targets".

| Check | Finding | Verdict |
| --- | --- | --- |
| **Damage balance sheet** | The rubric names one, but none existed. Drawing it up showed the threat curve upside down. Foes' raw damage stayed flat from the Trunk to Zenis (a Rot Dwarf's swing is 20, a Shade Knight's thrust 18, an Iron Dwarf's slam 24), while the armor you have by then grows from 15% to 45% off and your health from 5 masks to 12 or more. The Trunk's worst blow cost 17 through Leather. Dartmoor's cost 10 through Full Plate, half a mask out of ten. | **built: zone threat, the sheet in bible 5.5, and a test that holds its targets** |
| The Rune Dagger (passes 184, 188, 192) | It is not scaled by the War Glove, which the bible scopes to "blade hits". It gives no MP, being no melee hit. Both are consistent with 5.2 and 5.3. | fine |
| The Broad Sword two-hander (186) | 13 damage per second of swinging against the Long Sword's 11, with no guard. The trade is real, and the sheet's par kit uses the Long Sword, so it is a power-up and not the baseline. | fine |
| Telegraphs and hit-stop | Every foe's wind-up is still at least `Enemy.MIN_TELEGRAPH` (`test_enemies.gd`), and no foe changed since pass 177. | fine |

## As built

- `CombatTuning.ZONE_THREAT`: Trunk 1.0, Tower 1.0, Mist 1.4, Branches 1.5, Daybreak 1.6, Dartmoor 2.0, Sunken Spring 2.0, Zenis 2.0.
- `Room.threat()`: the zone's threat, or 1 in a boss's arena (each boss is tuned on its own) and in zones off the sheet (Eolis, the gym, the trials).
- `Player.receive_attack` multiplies every blow by the room's threat before guard and armor, unless the blow comes from a boss or from the world (a fire seal). Contact, swings and every foe's shot all pass through it, so the change is in one place.
- Bible 5.5 **Damage balance sheet**: each zone's threat, its par kit (what the critical path's shops and finds have put in your hands), the par slash, the hardest blow through par armor and the slashes it takes to fell its foes.
- The targets are:
  - each zone's hardest blow costs 0.75 to 1.4 masks through par armor;
  - no foe hits harder than 1.4 masks;
  - every foe falls in 2 to 7 par slashes;
  - threat never falls along the critical path.
- The sheet's 43 rows, from the code:
  - Trunk: hardest blow 17, foes fall in 2 to 4 slashes.
  - Tower: hardest blow 20, foes fall in 2 to 6 slashes.
  - Mist: hardest blow 18, foes fall in 2 to 4 slashes.
  - Branches: hardest blow 21, foes fall in 2 to 5 slashes.
  - Daybreak: hardest blow 22, foes fall in 2 to 4 slashes.
  - Dartmoor: hardest blow 20, foes fall in 3 to 4 slashes.
  - Sunken Spring: hardest blow 20.
  - Zenis: hardest blow 26, foes fall in 2 to 6 slashes.
- Tests in `test_combat.gd`:
  - `test_the_damage_balance_sheet_stays_within_its_targets` reads every zone's rooms for their foes, and each foe's `*DAMAGE` and `*CONTACT` constants and its shots. It then checks every row against the targets.
  - `test_a_foe_hits_as_hard_as_its_zone_is_deep`: a Dartmoor foe's 10 lands for 20. A fire seal still burns for 10. An arena, the Trunk and Eolis stay at 1.

Full suite: 3671 of 3671 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score, but the rubric's damage balance sheet now exists and holds: the deep zones no longer go soft. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. Bosses keep their own tuning (threat 1 in arenas). |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged: the original's foes hit harder the deeper you went, and now these do too. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 195 takes World (last pass 187, now the oldest). A Bosses pass could draw up the same sheet for the guardians. Arenas are left at threat 1 on purpose until then, so no boss fight changed here.
