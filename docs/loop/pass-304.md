# Pass 304: a ceiling door gives you time to steer

Category: Movement feel (last pass 296).

## Audit

I checked movement (bible 6, `movement_tuning.gd`) against what passes 297 to 303 touched.
- **Rising out of a floor door (pass 299).** I ran the door ride at lower rise speeds (`World.RISE_SPEED`, 430 px/s). Every ceiling door still lands at 400 and 370. The Alpha Den fails first, at 340, so the rise has about 20% to spare. The rise is a launch, not a snap: you arrive inside the floor door moving up at 430, normal gravity takes over, the apex hang (half gravity under 40 px/s) softens the top, and air control works the whole way. **But the test steered on the first frame after arrival, which no player can do.** I delayed the steer: every ceiling door still lands with the steer begun 9 or 15 frames (0.25 s) after arrival. At 21 frames (0.35 s) the Old Flue's rise drops back into the Tower's foot. A quarter second is a player's time to see the new room and react, so that is the margin to hold.
- **The pit-edge spot (passes 292, 300).** `Room._beside_pit` puts the set-back spot and a moved purse at the centre of the tile next to the pit. The 12 px body then sits fully on that tile, 2 px from its edge, with no part over the gap. A set-back zeroes velocity, so you don't slide off. Rokusutahn's own spot is three tiles back.
- **Pickups mid-move (passes 301, 302).** `Drop._collect`, coins and the purse never touch hitstop, control lock or velocity. The War Glove's `put_on_glove` doesn't either. Poison ticks health only. Walking over any drop leaves a dash, a wall jump or a pogo alone.
- **The PixelLab hero's clips (#323, #325, #327 to #332).** The run plays at `|vx| / run_speed` times its own speed (`PlayerVisual`), so it slows with the stick. Tracking the planted foot in the base sheet's run (17 frames at 24 fps), the art moves about 4.5 px a frame, roughly 110 px/s, against a run speed of 165. So at full speed the feet slide forward about a third. The armor sets' 8-frame runs are too coarse for my foot tracker to measure. This is in Sean's active PixelLab work, so I'm noting it for the art pass rather than changing playback under it. The rise, apex and fall clips are single frames picked by vertical speed, so they can't fall out of step with the jump arc.

## Fix

- `test_every_door_up_or_down_lands_you_on_footing` now waits `REACT_FRAMES` (15 frames, 0.25 s) after arrival before steering out of a ceiling door. It passes. With the wait set to 21 frames, it fails at the Old Flue.
- Bible 3.3: the reaction margin and the rise's spare speed, in pass 299's sentence.

No movement numbers changed. No screenshot: nothing on screen changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every ceiling door gives a quarter second to steer. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). The run's foot slide is noted above. |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 305 takes Faithfulness (last pass 297).
