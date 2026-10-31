# Pass 312: poison is no blow

Category: Movement feel (last pass 304).

## Audit

I checked movement (bible 6, `movement_tuning.gd`) against what passes 305 to 311 touched.
- **A hop over a flask before a door (pass 307).** Pass 307 tested only one short hop at a run. I swept the jump's start point from 10 to 94 px short of the flask with three jump heights, at a run and at a walk. At a run, a short hop clears it from 22 to 58 px short, and a full jump (the natural press-and-hold) from 22 to at least 94 px. At a walk (half tilt), a full jump clears from 16 to 40 px and a short hop only from 16 to 22, because a short hop at walking speed comes down on the flask. That is the right answer to the input, and a full jump is what a walking player would do. The Elven Stride's dash runs along the floor, so it takes the flask like walking would, as dashing through any pickup does. The jump's clip is the PixelLab hero's, picked by vertical speed, so it can't fall out of step with the arc.
- **Drops beside a pit (pass 308).** Taking a drop runs `Drop._collect`, which changes health, magic, gold or the pouch and nothing else. A drop on a pit's lip can't stop a pogo or a wall jump.
- **Poison ticks (passes 306, 309, 310).** `_tick_poison` changes health, spawns a number and plays a sound. It never calls `take_damage`, so there's no knockback, hurt flash or invulnerability. **But nothing proved it.** A later change that sent the tick through the blow's path would make poison stop a dash or knock you off a wall, and no test would notice.
- **Run playback (pass 304).** `PlayerVisual` plays the run at `|vx| / run_speed`, clamped 0.4 to 1.3, so it slows in sap and with a light tilt. A wind current pushes only an airborne hero, and the Stride's dash has its own pose, so neither speeds the run past its clamp. The run's foot slide stays with Sean's art.

## Fix

- Test: `test_a_poison_tick_never_touches_movement` (`test_movement.gd`) runs a poisoned hero and a well one through the same inputs: a dash, a jump onto a wall and a slide down it, then a ladder climb, with a tick forced inside each. Both must move frame for frame alike. With a tick that nudges the hero's fall speed, it fails at the jump.
- Bible 6: a paragraph at the end of the section, with the hop windows from the sweep.

No movement numbers changed. No screenshot: nothing on screen changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: poison is held to never touching movement. |
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

Pass 313 takes Faithfulness (last pass 305).
