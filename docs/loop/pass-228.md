# Pass 228: the Hour Glass holds every hazard

Bosses' last pass (220) was the oldest apart from Art, so pass 228 takes Bosses. I audited bible 8 and section A8 against passes 221 to 227 (the boss_won sting, the shield's ward, the Matriarch's hex at 16).

| Check | Finding | Verdict |
| --- | --- | --- |
| The boss_won sting (222) | It plays on every guardian's fall, the rush included. Tested. | fine |
| Sorcery and the ward (225, 226) | The hex, Eura's bolts, Grieve's shards and the core's beam are `Player.MAGIC`. The avatar's and the heart's crystal bursts are blasts of the meteor's body, like Grieve's spikes, so they stay unwarded. | fine |
| Telegraphs | The `*_telegraphs_are_fair` tests pass and no tell changed. | fine |
| **The Hour Glass and boss hazards** | Bible A8 says the glass stops enemy projectiles, and most of them ask `TimeStop.active()`. Rokusutahn's sap clump (dripping and falling), Zorugeriru's mist breath and a Bog Myconid's spore cloud never asked, so they went on moving and hurting while time stood still. The glass let a player slip through Zoradohna's rubble but not through the Root-Gnawer's sap. | **fixed** |

## As built

- `SapClump`, `MistBreath` and `SporeCloud` return at the top of `_physics_process` while time is stopped, as every other loosed hazard does. A clump's drip holds its tell too.
- `test_the_hour_glass_holds_every_loosed_hazard` (`test_boss.gd`, new): with time stopped, a clump over the player, a breath rolling at them and a cloud on them stay where they are for 1.5 s and do no harm; when time runs again they hurt. It then reads every script under `scripts/bosses/` and `scripts/enemies/`: anything that calls `receive_attack(` and is not a foe itself must ask `TimeStop.active()`.
- Mutation check: on the old scripts it fails 7 of 8 checks, naming all three files.
- Bible A8 (Hour Glass as built): the three hazards join the list, and the rule is written down.
- No visual change (a held hazard is drawn as it was the frame time stopped), so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the glass now works the same in every arena. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 229 takes Systems (last pass 221, now the oldest).
