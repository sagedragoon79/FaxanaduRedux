# Pass 316: the Rune Dagger reaches every guardian

Category: Bosses (last pass 308).

## Audit

- **Shieldless openings.** Pass 314 gave Shadow Eura and the Evil One an opening without a parry, and its test holds every row of the openings table.
- **Tells.** `test_every_wind_up_in_the_game_is_fair` still holds every guardian's tells, phase-quickened ones included. No boss changed since.
- **Rewards, banners, the Boss Rush.** The rush keeps your gear, so a dagger build fights it with the dagger. Rewards and banners are unchanged since pass 220's test.
- **The dagger's reach.** Bible 8 (pass 188) says the Rune Dagger "reaches every boss that a blade does". **No test held that.** Since Sean's off-hand change, a hero who takes the dagger has given up the shield, so the dagger is the build's whole ranged answer. A guardian it can't reach would leave that build only the blade there. I fought each guardian in the rush's order and threw at it. All of them can be reached. The Drowned Warden can be reached only from the islands: from the ledges and planks every throw flies over its head.

## Fix

- Test: `test_the_rune_dagger_reaches_every_guardian` (test_boss.gd). For each guardian in `BossRush.ORDER` (not the veins or the bound Heart, which the bible already rules out), it starts the fight with no shield and the dagger in hand. It then throws until a throw stings the guardian: from a step to either side, from under it when it is high, and from the ground beside it when it stands below you. A guardian a throw never reaches fails it.
- Mutation check: making the Warden shrug off thrown hits fails the test (2 checks).
- Bible 8: the claim is now held to that test, and the bible says where a dagger fights the Warden.

The game didn't change, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the dagger's reach in every arena is now held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 317 takes Systems (last pass 309).
