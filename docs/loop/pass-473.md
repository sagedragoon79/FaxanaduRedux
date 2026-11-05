# Pass 473: The Sky Steps' gap at every game speed

## Category

World.

## Audit

Lead: a gap that only works at full game speed. Pass 470 found the dash 4 px short at 70%. The
critical path has one gap that only an air dash crosses: the Sky Steps' exit, behind an elven veil
(bible 3.2, 8.5). It had only been crossed by a scripted intent at full speed
(`test_the_sky_steps_exit_needs_the_stride`), never with the buttons and never at a slower speed.

A probe crossed it with the real controller at 100, 90, 80 and 70% game speed, and every crossing
landed. Mutations of the dash's length found how much margin the gap has. A dash of 0.07 s (under half
of its 0.15 s) still crosses at every speed, and one of 0.04 s does not. The veil, not the gap's width,
is the gate, so no game speed can close the way out. The reachability model (`Reach.STRIDE_REACH`,
3 tiles, "a little under" the real dash) agrees.

## Bug found

None. A proof.

## Fix

`test_the_sky_steps_gap_is_crossed_with_the_buttons_at_every_game_speed` holds a real Right, presses
Jump at the island's edge and Dash at the jump's top, at each of `Settings.SPEED_STEPS`. It checks that
the hero lands on the exit ledge each time, and that without the Stride the same presses never do.
Bible 3.2 gains "The Sky Steps' gap at every game speed (pass 473)".

Mutation check: a 0.04 s dash fails the test at every speed (4 checks); 0.07 s still passes, as above.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The critical path's stride gap is proved with the buttons at every speed. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 474: Bosses.
