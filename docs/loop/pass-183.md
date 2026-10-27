# Pass 183: the stick walks into a run

Sean asked for analog movement: "a walk into a run the farther you move the joystick". That takes this pass ahead of the rotation, and it counts as a Movement pass, Movement's last being 176. Before it, `PlayerInput.poll` rounded the stick's axis to -1, 0 or 1, so any lean at all ran at the full 165 px/s.

## As built

- **Input.** `PlayerInput.tilt` is how far the stick leans, from 0 to 1 past the 0.35 deadzone. Keys and the d-pad are always 1. Scripted tests set it as they set `move_x`.
- **Pace.** `MovementTuning.speed_fraction(tilt)` sets the share of a full run (bible 6.1):

  | Tilt | Pace |
  | --- | --- |
  | Up to 0.45 | A walk: 40% of a run (66 px/s) |
  | 0.45 to 0.9 | Climbs evenly from a walk to a run |
  | 0.9 and up | A full run |

  `_horizontal_step` scales its target speed by it, on the ground and in the air.
- **Full tilt is untouched.** At full tilt, and on keys and the d-pad, every number is the same as before: jumps, dashes, wall jumps and the reach the level checker assumes. The ladder jump-off and the dash keep the full run.
- **Look.** Under 70% of a run, the hero's pose is `walk`.
  - The sheet has no walk clip yet, so `anim_for` plays the run clip, slowed to the pace (0.4x at a walk).
  - Once Sean's Autosprite walk is imported as a `walk` entry in `art/autosprite/manifest.json`, it plays instead at a rate matched to the pace.
- **Sound.** Footsteps slow with the pace: the run's 0.26 s stretches up to 1.6x at a walk.

## Tests

- `test_movement.gd`, `test_the_stick_walks_into_a_run_the_farther_it_leans` (new). It checks:
  - the bible numbers;
  - the curve walks low, climbs evenly and runs high;
  - a key reads as full tilt and a stick pressed 0.3 reads as 0.3;
  - on the floor, a light lean settles at 66 px/s with the walk pose and the run clip as fallback, and a full lean is the full run.

Full suite: 3413 of 3413 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged: analog precision for pads, with nothing changed at full tilt. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged).

## Next

Pass 184 takes Faithfulness (last pass 175, now the oldest).
