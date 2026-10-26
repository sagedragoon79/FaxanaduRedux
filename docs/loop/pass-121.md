# Pass 121: a ground stride that hugs the floor

Movement (96.5) tied for lowest apart from Art and weighs the most. Every line of bible 6 is built and tested, so I probed how the newest movement piece, the slopes from pass 115, meets the older moves.

| Move on a slope | Before | Verdict |
| --- | --- | --- |
| Run up and down, stand, jump | full speed, grounded, a normal jump (pass 115) | fine |
| Wall slide and ledge clip | a slope is never a wall (pass 115) | fine |
| Ground stride up a ramp | rides up the ramp, grounded throughout | fine |
| **Ground stride down a ramp** | The dash holds you level with no gravity for 0.15 s, and the 4 px floor snap can't hold its 6 px a frame. So you sailed off the ramp, 16 to 20 frames in the air and up to a tile above the slope, then dropped. A ground move turned into an air move: the stride stops reading as "the ground dash", and you land wherever the drop puts you. | **fixed** |
| Pogo, Feather Fall, wind and swimming near ramps | no slope in a pogo, wind or water room; Feather Fall only changes the fall | fine |

## As built

- **`MovementTuning.ground_dash_snap` = 10 px.** While a dash that began on the ground lasts, the player's floor snap reaches 10 px instead of the run's 4 px (`Player.FLOOR_SNAP`).
- **Down a slope:** 45° at 6.3 px a frame is inside that reach, so the stride rides the ramp down at the dash's full speed along it, the same way it already rode one up.
- **Ledges:** a ledge of a whole tile (16 px) or more is beyond the reach, so a stride off a real ledge still flies level out over the drop.
- **Air dashes:** they never snap.
- **The gym:** the hill's sign now reads "Slopes: run or stride up and down".

## Screenshots

`/mnt/project-files/pass-121/gym_hill_stride.png`: the gym's hill, with the player posed mid-stride at its top, under the new sign.

## Tests

In `test_movement.gd`:
- `test_a_ground_stride_follows_a_slope`:
  - four strides (off the plateau down a ramp, down from mid-ramp, up a ramp, down the west ramp) each keep their footing, with 0 frames in the air;
  - each covers a full stride along the floor and follows the slope;
  - a stride off a real ledge still flies level out over the drop.
- `test_movement_numbers_match_bible_6_2_to_6_6` now checks 6.5 too: dash speed, time, invulnerability, charges, ground cooldown and the new snap.
- The dash and slope tests from passes 97 to 115 pass unchanged.

## Bible

6.5, "Ground dash": it hugs the floor, with a 10 px snap, and still drops off a whole-tile ledge.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97 | Every ground move now holds the ground on a slope. 6.5's numbers are asserted like the rest. |
| Combat and enemies | 15 | 97 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 96.5 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 96.75 | Unchanged. |

Full suite: 2388 checks, all passing.

Weighted score: 95.275 (up from 95.175). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio (96.5) is now the lowest category apart from Art. Pass 122 takes Audio.
