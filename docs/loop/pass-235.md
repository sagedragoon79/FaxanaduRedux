# Pass 235: the Feather Hollow's perch needs the Boots

World's last pass (227) was the oldest apart from Art, so pass 235 takes World. Passes 216, 219 and 232 showed that the reach checker can prove "reachable" but never "out of reach". So I went through every secret listed as out of reach without an ability, looking for any that had never been tried with the real controller.

| Check | Finding | Verdict |
| --- | --- | --- |
| Stride secrets | Behind an elven veil, a gate in the physics (pass 216). | holds |
| The Sky Steps' purse | Real-controller test since pass 219. | holds |
| The Windloft Stride (Boots gate) | Real-controller test since pass 232. | holds |
| **The Feather Hollow's perch fruit** | A Boots secret since the room was built, and bible 4.1 said it "holds on the same bound" as the Sky Steps. It was never tried. The perch plank stood 96 px over the lower plank, past the 72 px apex, but a pickup is touched by the head, which rises 116 px. Running off the lower plank's west end, a plain jump took the fruit in 6 of 14 timings. | **fixed** |
| Glove, Mattock, Hour Glass, fire and wind gates | Mechanical gates (wall climb, breakable blocks, falling water, bramble, the turned wind), held by their tests. | hold |

## As built

- `levels/mist/feather_hollow.room`: the perch plank and its Life Fruit move up a row (plank at row 7, fruit at 18,6). The fruit's cell now begins 128 px over the lower plank, past the head's reach. `GameState.MOVED_PICKUPS` carries a save that took it at 18,7.
- `test_the_feather_hollow_perch_needs_the_wing_boots` (`test_abilities.gd`, new), with the real controller:
  - without the Boots, none of 14 running jumps off the plank takes the fruit, and neither do jumps from the floor under it or leaps off the west wall with the Glove;
  - with the Boots, a jump and a second jump off the plank take it in 10 of 14 timings.
- Mutation check: the old layout gave 6 of 14 without the Boots, and the test fails on it.
- `Reach.BOOT_JUMP` gains a seven-row rise across two tiles. In play the double jump lifts the feet 124 px, and seven rows (112 px) keeps the same 12 px margin as the plain jump's four rows under 76 px. Without this the checker could not reach the raised perch even with the Boots.
- Two synthetic checker tests assumed the Boots couldn't climb seven rows. The bounce-pod test now checks a plain jump, and the calm-wind test lays thorns under its ledge.
- `BOOT_SECRETS` points at 18,6.
- Bible 4.1: a correction to pass 219's claim about the perch (for a pickup, the bound to beat is the head's reach, not the apex), plus the Ripasheiku row.
- Screenshot: `/mnt/project-files/pass-235/feather_perch.png`. The raised perch and its fruit sit high over the Boots' plank, clear of the ceiling.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: every Boots secret is now proven with the real controller. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 236 takes Bosses (last pass 228, now the oldest).
