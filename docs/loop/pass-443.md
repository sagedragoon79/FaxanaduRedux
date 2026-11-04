# Pass 443: a dash through a door goes on in the next room

## Category

World and level design.

## Audit

Doors had been walked through with the real controller (pass 384's `test_the_doors_answer_the_real_controller`). No test took one with a move already under way. A dash is the move a player most often carries into the next room, so this pass dashed into a side door with the real Dash button.

## Bug found

The door cut the dash short and dropped its rules.

- `World._place_at_door` used `Player.teleport`, which zeroes the dash timer. That ended the dash at the door without `_finish_dash`, so no cooldown was set and the speed was not brought back to a run.
- The World then gave back the 380 px/s it had saved, so the hero skidded into the next room at dash speed for 8 frames with no dash.
- The dash was 3 steps short of its 0.15 s, and the hero could dash again at once.

## Fix

- `Player.arrive_through_door(pos, vel, side)` replaces the teleport. A dash taken through a side door goes on in the next room for the time it had left, then ends as usual: at a run, on its 0.25 s cooldown. Through any other door it ends the same way.
- The door's hold stops the dash clock, so a scroll costs the dash nothing.
- Bible 6.5 gains the row "Through a door (pass 443)".
- `test_a_dash_through_a_door_goes_on_in_the_next_room` presses Dash for real into the side door and checks four things:
  - the hero is still dashing in the next room;
  - the dash runs the same 9 steps as on open ground;
  - it ends at 165 px/s, with no skid;
  - a press right after it is held by the cooldown.
  A scripted arrival through any other door ends the dash at a run, on its cooldown.
- Mutation: restoring the teleport fails four checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. A dash carries through a door whole. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 444: Bosses.
