# Pass 104: the juice checklist, item by item

Movement (94) was the lowest category apart from Art. This pass checks every line of the juice checklist in bible 6.7 against the code and in scripted runs, fixes what was off, and adds tests, because until now no test covered the checklist itself.

## Audit

| Item | Bible | Found | Result |
| --- | --- | --- | --- |
| Jump squash | 0.85x1.2 | 0.85x1.2, easing back at 16/s | OK. New test. |
| Land squash | 1.25x0.8 by fall speed | 1 + 0.25k by 1 - 0.2k, k = impact / max fall | OK. New test. |
| Wall-jump stretch | toward the leap | 1.15x0.9, facing the leap | OK. New test. |
| Dust: run start, turnaround, land, wall jump | yes | yes | OK. New tests. |
| Dust: wall slide | every 0.06 s | every 4 frames (0.067 s): the timer was reset to 0.06, so the overshoot was lost | **Fixed**: the overshoot carries over, giving 10 puffs in 36 frames. |
| Dash | (not listed) | squash, sound, afterimages, no dust | **Added**: a kick of dust thrown back off the heel on the ground (`dash`), and a pale puff of air in midair (`airdash`). |
| Hit-stop | 50 / 90 / 140 / 200 ms | 0.05 / 0.09 / 0.14 / 0.2 | OK. New test. |
| Boss-kill hit-stop | 350 ms with a slow-mo ramp | 120 to 200 ms, then 0.3x slow motion that ended in a step | **Fixed**: `Feel.boss_kill(seconds)`. |
| Shake | trauma², decays 1.5/s | yes | OK. Pinned. |
| Camera | look-ahead 48 px over 0.4 s, look-down after 0.4 s, deadzone 16x24 | yes | OK. New test drives it. |
| Rumble, flashes, coins, sounds | | covered by earlier passes' tests | OK. |

## Boss kills

Every one of the 13 bosses now dies through `Feel.boss_kill(seconds)`:
1. The game freezes for 350 ms (`Feel.BOSS_KILL_HITSTOP`).
2. Then it runs at 0.3x and eases back up to full speed. The ease is quadratic: it stays slow and then picks up.
3. The slow motion lasts the boss's own time: 1 s for most, 1.2 to 1.5 s for the Warden, Rokusutahn and the Evil One's three forms.

Before this pass, kills held only 120 to 200 ms, and the slow motion snapped back to full speed in one step. The Hitstop setting still turns the freeze off.

## Dash dust

Screenshots are in `/mnt/project-files/pass-104/` (`--dash=FRAME` is a new screenshot flag that dashes right on that frame):
- `dash_43.png`: 3 frames into a ground dash. The puff is at the heel and the first afterimage sits behind.
- `dash_47.png`: 7 frames in. The puff is left behind with two afterimages.

The puff is small, about the size of the landing dust. It reads as a kick without covering the afterimages.

## Tests

`test_abilities.gd` (juice checklist):
- `test_juice_on_the_ground_dust_and_squash`: run-start and turnaround dust; the jump puff and stretch; the landing puff and squash; ground-dash dust and the afterimage trail.
- `test_juice_on_walls_and_in_the_air`: wall-slide dust on a 0.06 s beat (9 to 11 puffs in 36 frames); the wall-jump burst and stretch; an air dash puffs air, not floor dust.
- `test_juice_camera_and_feel_numbers_match_the_bible`: the camera constants, shake decay and hit-stops. It also drives a real camera: the look-ahead is more than 90% of the way over 0.4 s after a turn, there is no look-down at 0.3 s, and the camera looks down after 1 s.
- `test_a_boss_kill_freezes_then_ramps_back_from_slow_motion`: 350 ms, then a second of slow motion that starts at 0.3x and ramps up.

Full suite: 1973 checks, all passing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94.75 | The whole juice checklist is verified and pinned by tests; wall-slide dust keeps its beat; the dash kicks dust. |
| Combat and enemies | 15 | 94.25 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Every kill lands with the full 350 ms freeze and a slow-motion ramp. |
| Systems | 10 | 94.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.01 (up from 93.84; 94.0125 unrounded).

## Next

Combat (94.25) is now the lowest apart from Art. Pass 105 audits combat against bible 5.3 in scripted fights: the combo windows, the parry window, knockback and i-frames, and how each enemy reacts to the heavy finisher. Anything off gets fixed and tested.
