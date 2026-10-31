# Pass 315: every hornet in the gallery is in a throw's reach

Category: World (last pass 307).

## Audit

- **The Hornet Gallery and the off hand.** Since Sean's off-hand change (PRs #347, #349), finding the Rune Dagger here puts it straight into a shield's hand, so the room is often met with no shield and the dagger new in hand. Bible 5.2 says the room teaches it (three hornets overhead, a Sap Spitter across the thorns), but no test held that. **Measured from the nearest ground with no thorns, two of the three hornets hung 161 and 162 px above the throw, just past the dagger's 160 px range.** A throw only grazed them at the end of its flight, so the room's lesson rested on hitbox slack.
- **Shieldless reachability.** The reach checker never uses a guard or a parry, and pass 314 gave every guardian an opening without one. No gap.
- **Drops (passes 307, 308, 311).** Still held by their tests. No gap.
- **Doors, secrets, map.** The reachability and map tests cover them. Nothing has changed since pass 307.

## Fix

- `levels/trunk/hornet_gallery.room`: the hornet over the planks and the one over the west floor are each a tile lower (rows 7 and 11). Both are now about 145 px from their throw. Only foes moved, so no pickup id changes.
- Bible 5.2 (Rune Dagger, Where): the room must be clearable with the dagger alone, and why.
- Test: `test_the_hornet_gallery_can_be_cleared_with_the_dagger` (test_rooms.gd). It finds every spot you can stand on with no thorns. For each foe it picks the nearest spot in line with it (under a hornet, or level with the spitter). It requires that spot to be within `RuneDagger.RANGE`, then throws from there for real and checks the foe is struck. With the old room, two checks fail at 161 px.

Screenshot: `/mnt/project-files/pass-315/hornet-gallery.png` (the hero on the plank under the lowered hornet). The hornets still hang well clear of the planks and the floor.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the dagger's teaching room is now held to its reach. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 316 takes Bosses (last pass 308).
