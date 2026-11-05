# Pass 481: A bounce-pod at every game speed

## Category

World.

## Audit

Leads: world timers, platforms and hazards under a slower game and in hitstop.

- Every world object that moves or times something runs on the frame's `delta` (game time), in
  `_physics_process` or `_process`, so it slows with the hero and stands still in hitstop. None reads the
  wall clock for play (passes 474 to 477 moved the last ones), and none counts physics frames.
- `Room.splash_sap`'s timer and the boss rush's `_later` use `create_timer(seconds, false)`, which runs on
  game time and stops with the pause menu, as their comments say.
- No world node runs while paused: only menus, the dialog box, the map and the title are
  `PROCESS_MODE_ALWAYS`; `Game` sets its view back to pausable.
- One gate depends on a catch by step: the High Boughs' bounce-pod catches the feet as they step through
  its top. A step is shorter at a slower speed, and the catch had been seen only at full speed.

## Bug found

None. A proof.

## Fix

`test_a_bounce_pod_throws_as_high_at_every_game_speed` (test_abilities) hops on a pod with the real Jump
at 100, 90, 80 and 70%. It catches every time and throws 147, 149, 150 and 152 px, within 6 px of each
other, so the ledges it opens are open at every speed. Bible 6.6's bounce-pod row gains "At every game
speed (pass 481)".

Mutation check: with the throw weakened by the time scale (`velocity.y *= sqrt(Engine.time_scale)`), the
test fails at 90, 80 and 70%.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The bounce-pod gate is proved with the buttons at every speed. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 482: Bosses.
