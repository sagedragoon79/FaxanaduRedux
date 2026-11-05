# Pass 478: Timing windows at every game speed

## Category

Movement.

## Audit

Lead: the hero's timed moves under a slower game. Pass 470 fixed the dash at 70% and pass 472 proved
combat's windows. The jump's windows (coyote time 0.10 s, jump buffer 0.12 s) were held through the
real controller at full speed only (pass 400).

A probe with the real Jump at 100, 90, 80 and 70%:

- A full jump rose 69.1, 69.6, 69.8 and 70.3 px (72 px design height, within the 3 px the jump test
  allows). A double jump from the apex rose 44.9 to 46.1 px (48 design).
- A jump pressed during hitstop (time scale 0) is kept by the buffer and taken as the freeze ends. Held
  past it, it rises as a jump pressed outside the freeze does (2 frames held: 18.3 px, a tap's hop).
- Coyote time and the buffer, counted in frames on screen, only grow as the game slows.

## Bug found

None. A proof.

## Fix

`test_the_timing_windows_only_widen_as_the_game_slows` (test_movement) reuses pass 400's real-controller
helpers at every step of `Settings.SPEED_STEPS`. Coyote time is 6, 6, 7 and 8 frames and the buffer 7, 7,
8 and 10, each within a frame of its game time, and neither narrows as the game slows. Bible 6.7 (Input)
gains "Timing windows at every game speed (pass 478)".

Mutation check: with coyote time counted in real time (`delta / Engine.time_scale`), the test fails at
80 and 70% (6 frames where 7.5 and 8.6 are due).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The jump's windows are proved with the buttons at every speed. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 479: Story and world.
