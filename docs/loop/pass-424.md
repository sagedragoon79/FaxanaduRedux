# Pass 424: swimming by the buttons

## Category

Movement feel (last pass 416).

## Audit

Jumps, dashes, double jumps, wall jumps, the jump cut, short hop, apex hang and fast fall, coyote time and the jump buffer, drops, ladders, the pogo, running, wall sliding and the glide are all pressed through the real controller (passes 384 to 416). In the water only the stroke was (384). Sinking with Down held, floating back up when it is let go, swimming across and climbing out onto a bank were driven only by a scripted intent in `test_swimming_floats_sinks_strokes_and_jumps_out`. The movement numbers still match bible section 6 (`test_swim_numbers_match_the_bible` and the rest pass).

## Fix

- `test_swimming_through_the_real_controller` (test_movement.gd), all through `Input`:
  - With nothing held the hero floats up to the surface.
  - Down held sinks at 120 px/s and no faster; let go, the hero floats back up at 50 px/s.
  - Right held swims across at 0.7 of a run (115.5 px/s).
  - Right and Jump held at the surface by the bank climb out onto it.
- Bible 6.7's Input line gains "Swimming, too (pass 424)".

Mutation: reading Down only on the frame it is pressed fails three of the new test's checks (it sinks at 65 px/s at most), and no other swimming test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The water answers the real controller. |
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

Pass 425: Faithfulness.
