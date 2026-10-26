# Pass 153: the lunge on ramps and lips

Every category apart from Art was tied at 98.25, so pass 153 took Movement, which weighs the most (20). I checked bible 6 against `movement_tuning.gd` and the player, and how movement meets the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Tuning against bible 6 | `movement_tuning.gd` matches every table, and the tests assert them | fine |
| Eolis of Old (pass 152) | a plain room: a block stair, two planks, all within a jump; the reachability checker walks it | fine |
| Dash buffer (pass 146) | unchanged; the soaks dash through every zone | fine |
| **Thrust's lunge (pass 149) on a ramp** | The lunge is as fast as a ground dash (320 px/s, 5.3 px a frame), but it kept the run's 4 px floor snap. Down a 45° ramp it left the floor on its third frame and sailed over the slope for the rest of the lunge, the same fault pass 121 fixed for the dash. | **fixed** |
| **Thrust's lunge at a lip** | "Off a ledge it ends" stopped the push, but the lunge's 320 px/s carried on through the air. Thrust at the edge of a pit and you landed 67 px past the lip, four times as far as a run's step. A thrust aimed at a foe near an edge threw you off it. | **fixed** |

## As built (bible 6.5, 9)

- **The lunge hugs the floor:** while a thrust lunges, the floor snap is the ground dash's 10 px (`ground_dash_snap`), so it rides a ramp down. A ledge of a whole tile still drops away.
- **So does the slide out of it:** any slide on the floor still faster than a run (165 px/s) keeps the 10 px snap. Without this, a lunge that ran out halfway down a ramp still hopped off it on the frame it ended. The ground dash's slide-out shares the rule, though the probe found it already held the ramp.
- **Off a lip, at a run:** the frame the lunge finds no floor under it, it ends and the speed is clamped to the run's 165 px/s. You step off the edge as if you had run off it. You land 27 px past the lip, where a full-speed lunge used to land 67 px past.

## Report

`/mnt/project-files/pass-153/lunge.txt` has the probe's numbers before and after:

| Case | Before | After |
| --- | --- | --- |
| Lunge down a ramp | 9 of 12 frames in the air, 21 px down | 0 frames in the air, 36 px down |
| Lunge at a lip | leaves at 320 px/s, lands 67 px out | leaves at 165 px/s, lands 27 px out |
| Ground dash down the ramp | on the floor every frame | the same |

## Tests

`test_economy.gd`, `test_thrust_lunge_rides_slopes_and_steps_off_ledges` (new):
- a thrust down a ramp never leaves it and still lunges more than 35 px;
- a ground dash and its slide-out stay on the same ramp;
- at a lip the lunge ends and you step off at no more than run speed, landing within two tiles.

Against the old code it fails on three checks: 11 frames in the air, 305 px/s off the lip, 67 px out.

Full suite: 2787 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | The newest move now meets the ground the way the dash does: it rides ramps, and it never flings you off an edge. |
| Combat and enemies | 15 | 98.25 | Unchanged. |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.3 (up from 96.25). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Systems, Audio, Stability and Faithfulness are tied at 98.25, the lowest apart from Art. Combat and World both weigh 15; Combat's last pass (147) is the older of the two, so pass 154 takes Combat.
