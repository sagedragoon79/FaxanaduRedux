# Pass 161: Zenis remixes and silhouette flashes

Combat, World, Bosses, Systems, Audio, Stability and Faithfulness were tied at 98.5. Combat and World weigh 15, and Combat's last pass (154) was the older, so pass 161 takes Combat. I audited combat against bible 5 and 7 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs at least `Enemy.MIN_TELEGRAPH` | covered by the enemy and boss tests; nothing new since pass 154 | fine |
| Damage numbers, rare drops | unchanged since passes 152 and 154; the soak stays lean | fine |
| The woken Drowned Market | `calm:` frees its foes once King Grieve falls (pass 159) | fine |
| The boss rush's back-to-back fights | mending, the 2.5 s gap and the falls are tested (passes 156 and 158) | fine |
| **Enemy variety in Zenis** | Bible 7 says Zenis holds "remixes of every family", but its rooms held only the Dartmoor guard (crystal dwarves, hounds, shade knights, slugs). The last zone was the least varied fight in the game. | **built** |
| **The hurt flash and the tells** | While checking screenshots, a Storm Harpy winding up drew a large translucent white rectangle over herself. Fourteen code-drawn foes and bosses did the same: a white box or disc laid over the body for the hit flash and the tell pulse. It read as a rendering glitch and hid the pose the tell is meant to show. | **fixed** |

## As built

- **Zenis remixes:** ten more corrupted foes, one or more from every zone:
  - The Threshold gains two Gear Bats, a Storm Harpy and a Rot Dwarf.
  - The Heart Stair gains a Leaf Mantis, an Iron Dwarf and a Thunder Beetle.
  - The Drift Well gains a Lantern Ghost, which drifts through the wrong gravity.
  - The Heart Gate gains a Bog Myconid and a Seed Bomber.

  Each is corrupted (tougher, richer, and it bursts a Meteor Seed), as every foe in Zenis is.
- **`Enemy.wash(on)`:** a code-drawn foe calls it from `_draw`. While it is on, the foe's material is a shared `shaders/wash.gdshader` that mixes everything it draws toward white, so the flash follows its own silhouette (wings, legs and blades included). It never touches the death's dissolve material. Converted: Storm Harpy, Clockwork Hound, Meteor Slug, Shade Knight, Spire Sentinel, Thunder Beetle, Spring Eel, Crystal Dwarf, Leaf Mantis, Borabohra, Pakukame, Ripasheiku, the Drowned Warden and King Grieve. Sheet-drawn foes already flashed their own silhouette through `Enemy.draw_sheet`.

## Screenshots

- `/mnt/project-files/pass-161/threshold-remix.png`: the Threshold with its bats, harpy and dwarf among the Dartmoor guard.
- `/mnt/project-files/pass-161/heart-stair-remix.png`: the Heart Stair's mantis, iron dwarf and beetle.
- `/mnt/project-files/pass-161/harpy-90.png` and `harpy-120.png`: the Storm Harpy on the Fallen Bridge, with no box around her.

## Tests

- `test_enemies.gd`, `test_zenis_holds_a_remix_of_every_zones_foes` (new). It checks that every foe in the four Zenis rooms is corrupted, that each of the six earlier zones has a family there, and that at least 12 families appear.
- `test_enemies.gd`, `test_a_flash_whitens_the_foe_not_a_box` (new). It checks that:
  - a harpy at rest is not washed, a hit washes her, and the wash ends with the flash;
  - her screech tell pulses the wash;
  - her death keeps its dissolve material;
  - no script in `scripts/enemies/` or `scripts/bosses/` lays a white rect or circle over itself under a flash.

Full suite: 3058 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Zenis is a true remix of every zone's foes, and flashes and tells follow the foe's own shape. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.525 (up from 96.4875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.5. World weighs the most (15), so pass 162 takes World. Unbuilt: Guru Trials Stillness and Falling.
