# Pass 408: Down and Up held, through the real controller

## Category

Movement (last pass 400).

## Audit

- Passes 384, 392 and 400 drove the real controller (`Input`) through every press, every hold and release, and the coyote and buffer windows. The stick's tilt and its drift (passes 183 and 368) are tested through `Input` too.
- Every tuning number in `movement_tuning.gd` is asserted against bible section 6, with the ladder and pogo numbers in tests of their own.
- The gap is the moves that read Down or Up held together with another button. These had only ever been scripted:
  - a drop through a one-way floor (Down held, Jump pressed);
  - a ladder (Up or Down held at its rungs);
  - a pogo (Down held, Attack pressed above spikes).
- A scripted intent sets `down` directly, so if `PlayerInput.poll` read Down only on the step it went down rather than while held, every move test would still pass.

## Fix

`test_drops_ladders_and_pogo_through_the_real_controller` (test_movement.gd) plays each move with `Input` alone:

- On a one-way floor, Down alone stays put, and Down held with Jump drops through without rising.
- At a ladder, Up held takes hold and climbs at ladder speed, and letting go hangs. Down held climbs back down, and Jump lets go.
- Over spikes, Down held with Attack pogoes off them unhurt.

Bible 6.7's Input line gains "Down and Up held, too (pass 408)".

Mutation check: when `PlayerInput.poll` reads Down only on the step it is pressed, the test fails 4 of its 13 checks. These include the drop, climbing down and the pogo. Every scripted move test still passes, because each sets the intent directly.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The drop, the ladder and the pogo answer the real controller. |
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

Pass 409: Faithfulness.
