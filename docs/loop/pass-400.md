# Pass 400: the timing windows, through the real controller

## Category

Movement (last pass 392).

## Audit

- `movement_tuning.gd` matches the bible 6 table. The tests that pin each value pass.
- The real-controller tests from passes 384 and 392 cover these moves through `Input`:
  - every press: jump, dash, slash, up-slash, double jump, air dash, down-strike, wall jump, stroke;
  - every held button: the jump cut, a tap hop, the apex hang, the fast fall.
- The gap is the two timing windows the bible sets to the frame: coyote time (0.10 s, 6 frames) and the jump buffer (0.12 s, 7 frames). Both were held only with a scripted intent, which the player reads directly. A real button goes through `Input` and `PlayerInput.poll`, so a window counted in frames could have come out a frame short on a real pad without any test noticing.

## Fix

`test_the_timing_windows_hold_through_the_real_controller` (test_movement.gd) gives the player a real `PlayerInput`:

- It runs off a ledge holding Right through `Input` and presses Jump on airborne frames 4 to 9. The last press that still jumps is the 6th.
- It drops the player onto a floor and presses Jump 7, 1 and 8 frames before landing. The 7 and 1 frame presses jump; the 8 frame press is dropped.

Each window is counted from the step the game first sees the press. The helper checks that step with `Input.is_action_just_pressed`. A first draft counted from the moment the button went down. That came out one frame short, because a test's press is seen one step after it goes down (as `press_for_real` notes). A real pad's event is flushed before the step it lands in.

Bible 6.7's Input line gains "Timing windows, too (pass 400)".

Mutation check: with coyote time at 0.085 s and the buffer at 0.105 s, the test fails twice. The last ledge jump comes on frame 5, and the 7 frame buffer press is lost.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. Coyote time and the jump buffer hold to the frame through the real controller. |
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

Pass 401: Faithfulness.
