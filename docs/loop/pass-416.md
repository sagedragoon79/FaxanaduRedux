# Pass 416: running, sliding and gliding by the buttons

## Category

Movement feel (last pass 408).

## Audit

Every jump, dash, double jump, air dash, wall jump, swim stroke, jump cut, short hop, apex hang, fast fall, ledge and buffer window, drop, ladder and pogo is now pressed through the real controller (passes 384, 392, 400, 408). The moves that read a direction or Jump held over many frames were still driven only by a scripted intent: the run and its turn, the slide down a wall and the short stick before pushing off it, and Feather Fall's glide. The movement numbers in `movement_tuning.gd` still match bible section 6 (the tests that assert them pass).

## Fix

- `test_running_sliding_and_gliding_through_the_real_controller` (test_movement.gd), all through `Input`:
  - Right held runs at 165 px/s within 7 frames; Left held turns at 1.6 times the brake; letting go stops within 5 frames.
  - Right held into a wall slides at 90 px/s; Left held sticks about 5 frames (0.08 s) before letting go.
  - With Feather Fall, Jump in the air spends the double jump, Jump held glides at 60 px/s, and letting go falls.
- Bible 6.7's Input line gains "Running, sliding and gliding, too (pass 416)".

Mutation: making a push away from the wall let go at once fails the new test (stuck 0 frames) as well as the scripted `test_pushing_off_a_wall_sticks_for_0_08_s`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The held moves answer the real controller. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 417: Faithfulness.
