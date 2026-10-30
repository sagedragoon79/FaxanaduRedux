# Pass 299: every door up or down ends on footing

Category: World and level design (last pass 291).

## Audit

I checked the world (bible 3 and 4, `levels/README.md`) against what passes 292 to 298 touched.
- **Rooms foes fall out of (pass 291).** Each gap is a shaft, pit or floor door the room needs, not a hole left by mistake. A foe that falls dies just below the room. Its drop is kept inside the room (`keep_in_room`). A player who dies in one of these gaps leaves the purse on the safe spot beside it (pass 293). Nothing is stranded.
- **The ledge corners (pass 295).** In the Winch Hall, Deep Roots, Taproot Vault, Mascon and Alpha Den, no corner is next to spikes or thorns. A set-back onto one lands you on tiles, and `_hazard_near` is false there.
- **Door entry spots.** I rode every door in the game with a probe.
  - All 198 side doors land you standing on tiles, unhurt, with no hazard near. The existing door walk already checks this.
  - All 27 floor doors drop you onto footing with no hazard near. The set-back keeps that spot.
  - Two drops (the Veiled Rise into Lantern Landing, the Old Flue into the Tower's foot) put you inside the bound fog or the flue damper while it is shut. That can't happen in play: the rooms above are reached only through those gates, so they are open by then. The reachability test already holds this.
  - All 27 ceiling doors let you pop out and land beside the floor door if you steer toward the ledge. Nothing tested that until now.
- **The PixelLab hero (#323).** The collision box is unchanged (12 by 40). The sprite is about 47 px tall. In the lowest corridors (three tiles, 48 px, for example the Fungus Shaft) he stands with his hair just under the ceiling (`/mnt/project-files/pass-299/low_ceiling.png`). A jump into a ceiling hides a few pixels of hair behind the tile. That is an art matter, which is deferred.

## Fix

The world held up, so this pass adds the check that was missing. The rule it guards is in the bible.
- Test: `test_every_door_up_or_down_lands_you_on_footing` (`test_soak.gd`) rides every floor and ceiling door with the real controller and no abilities. Down a floor door, you must land on tiles, unhurt, with no hazard near, and the set-back must keep that spot. Up a ceiling door, a steer to one side or the other must land you on footing, not drop you back through. When I cut the rise speed from 430 to 300, the test fails at the Alpha Den. That is the tightest rise in the game.
- Bible 3.3 (room and map rules): a sentence after the camera rule from pass 151.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: every door up or down is now checked to end on footing. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 300 takes Bosses (last pass 292).
