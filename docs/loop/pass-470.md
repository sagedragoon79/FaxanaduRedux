# Pass 470: The dash keeps its stride at every game speed

## Category

Movement.

## Audit

Followed the lead of movement under the Game speed option (bible 14: 70% to 100%), which pass 467
proved is kept through a restart. No test moved the hero at any speed but 100%. A probe drove the real
controller at 100% and 70%. The game speed shortens each physics step (`Engine.time_scale`): a run
covered 70% of the ground per frame, a held jump rose to the same height, and a one-frame tap of Jump
was caught at every frame offset. The dash was the exception.

## Bug found

A dash at 70% game speed covered 53.2 px at dash speed, against its 57 px stride (380 px/s for 0.15 s).
The dash ran on a timer whose last step moved a whole step at a run. At 100% the timer ends on a
step's edge, so the dash is exact. At 70% (a step of 0.7 of a frame) it stopped 0.01 s early, and the
whole dash, with its run-out, went 4 px less far. A player who slows the game to cope found every
dash gap 7% wider.

## Fix

`Player._dash_step`: the last step moves at dash speed for the time the dash had left and at a run
for the rest, then the velocity settles to the run after the move (a wall that stopped it keeps the
stop). At 100% and 90% nothing changes; at 80% and 70% the dash now covers its 57 px.

`test_the_dash_keeps_its_stride_at_every_game_speed` presses a real Dash at each of the four speeds
(`Settings.SPEED_STEPS`). Each one reaches at least 57 px, and no more than one run step beyond it.
Bible 6.5 gains "The dash at every game speed (pass 470)".

Mutation check: without the blended last step the test fails at 70% (55.13 px).

The slide after a dash still differs by up to 2 px between speeds (a coarser step slides a little
further). That is the fixed step itself, and it is the same for every move that eases to a stop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The dash now keeps its stride under the game speed option. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 471: Story and world.
