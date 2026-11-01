# Pass 352: every camera number on its line (Movement)

## Audit

Movement was last audited in pass 344, which held every `MovementTuning` number to its own subsection of bible 6. This pass read the rest of 6.7 (the juice list) against the code that carries its numbers: `GameCamera` and `Feel`.

The movement tuning is held to the bible's text. The camera and the shake were held only by tests that copied their numbers as literals (`test_abilities.gd`: look-ahead, deadzone, look-up, trauma decay; `test_movement.gd`: the climb lead). Changing a number in the code and in its test together would have left 6.7 saying the old one. Beyond that:

| Constant | Value | Gap |
| --- | --- | --- |
| `GameCamera.LOOK_DOWN` | 72 px | no test at all: set to 80, every camera test still passed |
| `GameCamera.FOLLOW_SPEED` | 10/s | in no text; 6.7 said only "lerp smoothing" |
| `GameCamera.FOCUS_OFFSET` | 28 px up | in no text |
| `Feel.MAX_SHAKE_OFFSET` | 10 x 7 px | in no text |
| `Feel.MAX_SHAKE_ROLL` | 0 | defined, never used |

## Fix

- Bible 6.7, Camera: the camera aims 28 px above the feet and closes the gap at a rate of 10 per second (1 - e^(-10t), about 63% in 0.1 s).
- Bible 6.7, Screen shake: full shake moves the view at most 10 px across and 7 px up or down, with no roll.
- Bible 6.7: a note "The camera's numbers (pass 352)" names the gap and the test.
- `Feel.MAX_SHAKE_ROLL` removed (unused).
- `test_every_camera_number_is_written_on_its_line` (test_movement.gd) maps every number `GameCamera` and `Feel` define to its line of 6.7 (Camera, Wide camera, Screen shake, Hit-stop) or to 12.1 (`DETAIL`), and checks it there with `written_exactly_in`, a pair by its two parts. A constant with no line fails it.

Mutation: with `LOOK_DOWN` at 80 the new test fails ("LOOK_DOWN 80 not on Camera") while every other camera test passes; a new unlisted constant fails the second check. No value in play changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. The camera's and the shake's numbers are now held to 6.7's text. |
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

Pass 353 takes Faithfulness (last pass 345).
