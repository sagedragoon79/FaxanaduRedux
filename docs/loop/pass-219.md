# Pass 219: the Sky Steps' purse needs the boots

World's last pass (211) was the oldest apart from Art, so pass 219 takes World. I audited the world and level rules (bible 3 and 4, `levels/README.md`) against passes 212 to 218. I also took up the follow-up that pass 216 noted: every secret that is out of reach only because of distance, checked with real jumps.

| Check | Finding | Verdict |
| --- | --- | --- |
| Pass 217: the Heart Gate's altar is bare | The drift pocket still lifts you to it, and the sign there explains it. The reachability sweeps already granted the Dragon Slayer as an ability. | fine |
| Passes 212 to 215, 218 | Numbers, saves, music and engine errors. No room changed. | fine |
| Gate-tile secrets (amber, cracked stone, the veil, bramble) | A tile in the physics holds each one. | fine |
| The Thicket Road's wind niche | A current, not a distance. The pass 160 tests turn it both ways. | fine |
| Feather Hollow's Life Fruit (boots) | Six rows (96 px) over the nearest plank, far from any wall. A single jump peaks at 72 px. | fine |
| **The Sky Steps' purse (boots)** | Its island stood four rows (64 px) over the island below. `levels/README.md` itself says a platform four rows up is reachable. A scripted run in the real room jumped off the lower island's edge and landed on it with no boots. | **fixed: raised a row** |

## As built

- `levels/daybreak/sky_steps.room`: the purse's island moved from row 21 to row 20, and the purse from 6,20 to 6,19. It now stands 80 px over the island below, past the 72 px apex of a single jump. The thorn bulbs lining the wall beside it leave nothing to climb. Screenshot: `/mnt/project-files/pass-219/sky_steps_purse.png`.
- `GameState.MOVED_PICKUPS` gains `daybreak/sky_steps:6,20` to `6,19`, so a save that opened the chest doesn't find it again.
- `BOOT_SECRETS` names the new cell.
- New test, `test_the_sky_steps_purse_needs_the_wing_boots` (`test_abilities.gd`): a running jump off the lower island's edge. Without the boots it falls short; with a second jump it lands.
- Mutation check: on the old room the test fails, because the plain jump lands.
- Bible 4.1: a "boots secrets checked" note after the pass 216 correction. A rise past the apex, with no wall to climb, is the one distance that makes a real gate. Bible 15's moved-pickups line names the purse.
- `levels/README.md` gains a rule: a secret needs a gate tile, or for the boots a rise of 5 rows or more, proved with a real jump.

Full suite: 4076 of 4076 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: every secret that is out of reach only by distance now has a real-physics bound or test. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 220 takes Bosses (last pass 212, now the oldest).
