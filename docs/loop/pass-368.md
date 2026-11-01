# Pass 368: a sideways stick is not Down (Movement)

Category: Movement (last pass 360).

## Audit

Pass 365 made the pad fully rebindable, so this pass played movement through a real gamepad path. Every movement test scripts `PlayerInput` directly, and only the analog walk (pass 183) had ever fed it real stick input. Bible 6.1 says the stick's lean is read "past the 0.35 deadzone", and the engine does rescale it that way. But the deadzone applies to each direction on its own. A thumb pushing a stick hard sideways drifts up or down by 20 to 30 degrees, and at 25 degrees under level the down component is 0.42, past the deadzone. So the drift read as Down:

- A running jump on a one-way platform dropped through it instead. This was proven with the real controller: with the angle check removed, the hero falls 39 px through the platform.
- A fall became a fast fall.
- An air slash with the Mattock became a pogo.

Drift the other way read as Up:

- A slash became an up-slash.
- A run past an inner door walked in through it (`move_up` just pressed).

Keys and the d-pad never had this problem, because they are digital.

## Fix

- `MovementTuning.stick_vertical_angle` is 35 degrees, homed in 6.1. A stick counts as Up or Down only at that angle from level or more, which means within 55 degrees of straight up or down. The check is `PlayerInput.vertical`: the vertical strength must be at least tan(35°) times the stronger of left and right. Keys and the d-pad press at full strength, so a digital diagonal always counts.
- Up is pressed as it is pressed, or as a stick held in a drift swings on to vertical, so a door still opens that way. Up held through a door or a dialog is not pressed again, as before.
- `Player` passes its tuning to `input.poll`.
- Bible 6.1 has a new row, "Stick angle (pass 368)".
- `test_a_sideways_stick_drifting_down_is_not_down` drives the real input map with joypad events:
  - 25 degrees under or over level is neither Down nor Up;
  - 40 degrees and straight down are Down;
  - the swing on to Up presses once, and Up held after `clear()` does not press again;
  - the d-pad diagonal counts;
  - with the real controller on a one-way platform, a 25-degree drift and Jump jumps, while 60 degrees and Jump drops through.

Mutation: with the angle check removed, 4 checks fail, including the drop through the platform.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. A pad's sideways drift no longer drops, pogoes or walks through doors. |
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

Pass 369: Faithfulness.
