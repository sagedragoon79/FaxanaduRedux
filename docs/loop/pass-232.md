# Pass 232: the Stride waits on the Boots

Movement's last pass (224) was the oldest apart from Art, so pass 232 takes Movement. Passes 216, 219, 224 and 227 showed that the reach checker can prove "reachable" but never "out of reach", so I checked each movement ability's gate on the critical path. For each ability, I listed the rooms the checker opens with it but not without it.

| Check | Finding | Verdict |
| --- | --- | --- |
| The Climbing Glove | It opens the whole game past the Trunk, starting at the Fungus Shaft: 25 rows of flush walls with no ledge and no foe to pogo, and the Mattock and Boots come later. No jump can cross it. | holds |
| The Elven Stride | Gated at the Sky Steps' exit since pass 227 (real-controller test). | holds |
| **The Wing Boots** | With every earlier ability and no Boots, the checker reached exactly the same rooms as with them. A core movement ability opened nothing on the critical path and only reached two secrets. The bible lists the Boots for "wide gaps, high ledges". | **fixed** |
| Movement numbers | `movement_tuning.gd` matches bible 6, and the asserting tests pass. | fine |

## As built

- `levels/branches/windloft.room`: the Elven Stride hangs in open air at (24,11), its centre 136 px over the floor. It is 15 tiles from the entry ledge's edge and 14 from the east wall. The old plinth block and the one-way plank above it are gone. With only a plain jump (head at 112 px) it is out of reach; with the second jump (160 px) it is not. The sign now says the wardens hung it where only a second step in the air can reach it.
- `test_the_stride_in_the_windloft_needs_the_wing_boots` (`test_abilities.gd`, new), with the real controller. Without the Boots, none of 13 timings each reaches it from four starts: under it, from a run, off the entry ledge, and wall-jumping off the east wall near the vault with the Glove. With the Boots, a jump and a second jump under it take it (9 of 13).
- Mutation check: with the Stride two rows lower, 13 of 13 plain jumps under it and 5 of 13 running jumps took it, and the test fails.
- The reach checker touched pickups only up to 6 rows over a standing cell, Boots or not, so it couldn't take the new Stride even with them. With the Boots it now reaches 8 rows (`Reach.BOOT_TOUCH_RISE`; the real second jump covers about 9.5), and 6 without (`TOUCH_RISE`; the real plain jump covers about 6.75). Both stay short of real play, so the checker can still only prove "reachable".
- `test_reachability.gd`: `BOOT_GATES` lists the Stride as out of the checker's reach without the Boots. The Mattock flood skips it, and the Stride test points at its new cell.
- Screenshot: `/mnt/project-files/pass-232/windloft_stride.png`. The feather hangs high over the shrine and the sign, clear against the sky.
- Bible 4.1: "The Wing Boots' gate on the critical path", and the A3 row.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every movement ability now gates the critical path, which the checker and the real controller agree on. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 233 takes Faithfulness (last pass 225, now the oldest).
