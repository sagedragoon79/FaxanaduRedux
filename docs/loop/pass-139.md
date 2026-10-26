# Pass 139: a dash slides into a tunnel's mouth

Movement (97.75, weight 20) was tied for the lowest category apart from Art, and weighs the most. I checked bible 6 row by row against `movement_tuning.gd` and the player, and how movement meets the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Run, slopes, jump, wall, double jump, dash, pogo, swim, wind, Feather Fall, ladders (6.1 to 6.11) | built and asserted | fine |
| Physics interpolation, 60 Hz physics (6.7) | on in `project.godot` | fine |
| Footsteps per surface (6.7) | stone, moss, plank, iron, sap | fine |
| Camera look-up and ladder lead (passes 130, 133), wind and drift cues (137) | built | fine |
| **Corner forgiveness** | Three of the four edges were forgiven: a rising head slides around a ceiling corner (6 px), and the feet step onto a lip (4 px), solid or one-way. The fourth wasn't. Moving across in the air, a head that clipped the top edge of an opening stopped dead, even by 1 px. That is exactly the dash aimed at a tunnel mouth. | **built** |

## As built (bible 6.2)

- **Head correction (`head_correction_px`, 4 px):** moving across in the air, level or falling, a head that clips the top edge of an opening is nudged down by up to 4 px and slides into the gap.
- A rising jump keeps the corner correction it already had.
- A wall met below the head (a real wall) is left alone, because lowered it still blocks. Wall slides are left alone too.
- `Player._apply_head_correction` mirrors `_apply_ledge_correction`.

## Report

The new test against the old code and against the new, in `/mnt/project-files/pass-139/`:
- `before.txt`: the 2 px and 4 px dashes stop on the lip.
- `after.txt`: they slide in, and 5 px still stops.

## Tests

- `test_head_correction_slides_a_dash_into_a_tunnel` (`test_movement.gd`), new: a mid-air dash at a tunnel mouth slides in when the head clips its top by 2 or 4 px, and stops on the lip at 5 px.
- `test_movement_numbers_match_bible_6_2_to_6_6` asserts `head_correction_px == 4`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.0 | Every edge of the body is now forgiven. |
| Combat and enemies | 15 | 97.75 | Unchanged. |
| World and level design | 15 | 97.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Unchanged. |
| Audio | 5 | 97.75 | Unchanged. |
| Stability and performance | 5 | 97.75 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2550 checks, all passing, with no script errors in the log.

Weighted score: 95.925 (up from 95.875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Systems, Audio, Stability and Faithfulness are tied at 97.75. Combat and World weigh the most (15); pass 140 takes Combat.
