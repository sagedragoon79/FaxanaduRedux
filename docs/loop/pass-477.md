# Pass 477: A door fades in real time

## Category

Stability.

## Audit

Leads: time scale left behind, and tweens on game time. `Feel` has no reset in game code, but it ends
its own hitstop and slow motion by the real clock, so quitting to the title mid-freeze leaves no slow
game behind (at most the 1.5 s the slow motion had left). The only tweens left on game time after
pass 476 were the World's: a door's fade and an edge's scroll.

## Bug found

At 70% Game speed a door's fade (0.12 s out, 0.18 s in) took 26 frames in place of 18, and in a
guardian's slow motion after its death blow (30%), the walk out of the arena faded over 58 frames, more
than three times as long. Hitstop would stall a fade mid-way. The way between rooms is presentation,
like the music (pass 476), and should not stretch.

## Fix

`World._fade` and `World._scroll` ignore the time scale (`Tween.set_ignore_time_scale`).
`test_a_door_fades_in_real_time_at_every_game_speed` (test_world) takes the East Gate's door into the
Heartwood at 100, 70 and 30%, and each fade ends within four frames of its 18. Bible 3 (Camera) gains
"In real time (pass 477)".

Mutation check: with the tweens back on game time, the test fails at 70% (26 frames) and 30% (58).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Score unchanged. Door fades and scrolls now take real time at every speed. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 478: Movement.
