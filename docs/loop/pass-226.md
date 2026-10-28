# Pass 226: the shield on the damage sheet

Combat's last pass (218) was the oldest apart from Art, so pass 226 takes Combat. I audited the combat numbers, the damage sheet (bible 5.5), telegraphs, parry and guard against passes 219 to 225.

| Check | Finding | Verdict |
| --- | --- | --- |
| `CombatTuning` against bible 5.3, telegraphs, hit-stops | Still pinned by their tests. No combat code changed apart from pass 225's ward. | fine |
| The win sting (222), the wind (224) | Neither changes a blow. | fine |
| **The damage sheet after pass 225** | The sheet weighed every blow through armor alone, but since pass 225 a shield wards sorcery. Weighed the way the game takes it (threat, ward, armor) with the shield each zone's par player carries, the Marsh Hag Matriarch's hardest blow, her hex, fell to 8. That is under the guardians' floor of 10 (half a mask), and the bible calls the hex her whole threat. | **fixed** |

## As built

- `PAR_KIT` in `test_combat.gd` gains a shield: Small in the Trunk and the Tower, Large from the Mist, Magic from Dartmoor. Each is the town shield the path has put in reach by then.
- New `_through_par` weighs a blow as `Player.receive_attack` does. `_is_sorcery` reads whether a script joins `Player.MAGIC`. Both sheet tests (foes and guardians) use them.
- `MireGrasp.DAMAGE` (the hags' and the Matriarch's hex) goes from 12 to 16. Through the par kit it costs 11 (up from 8), and 15 with no shield. The Marsh Hags' row stays well under the Mist's hardest blow (18).
- The other sorcery holds. Eura's bolts and Grieve's shards were never their hardest blows. The core's beam costs 10 through the Magic Shield and Full Plate.
- Mutation check: with the hex back at 12, `test_the_guardians_hit_as_hard_as_their_zone` fails on the Matriarch (8).
- Bible 5.5: "The shield on the sheet" and the guardians' table (Matriarch 11, the Evil One's heart 15 and veins 10). The hex's 16 is also written into the Marsh Hag (7) and the Matriarch (8) entries.

No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the sheet weighs every blow the way the game lands it. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 227 takes World (last pass 219, now the oldest).
