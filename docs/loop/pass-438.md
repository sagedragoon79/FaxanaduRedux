# Pass 438: the moves heard through the buttons

## Category

Audio (last audited in pass 430).

## Audit

The lead from pass 437 was what sound does now that a sign pauses the world (pass 436). A probe read
a long sign: the box's typing blips are all heard (physics frames run on while the tree is paused,
so `Sfx`'s one-per-step guard does not swallow them), and the music and `Sfx` run on as they do under
the pause menu. Nothing to fix there.

The gap was elsewhere. Bible 6.7 promises distinct jump, double jump, wall jump, dash, pogo and land
sounds. Pass 422 heard the fight through the real controller, but these six had only ever been heard
under a scripted intent, so a move that sounded twice, or borrowed another's sound, when made with the
buttons would have passed.

## Fix

`test_the_moves_are_heard_through_the_buttons` (tests/test_movement.gd) presses each through `Input`:
Jump, Jump again in the air, Jump off a wall with Left held, Dash, and Down with Attack over spikes are
each heard once and alone, in the step of the move. A landing is heard once, with only the surface's
step layered under it (6.7's layered footsteps). All six held: no bug. Bible 6.7's Sound line gains
"Heard through the buttons (pass 438)".

Mutation check: the double jump playing the plain jump sound fails the test, and so does a landing
that thuds twice.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The six move sounds are proved through the real controller. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 439: Stability.
