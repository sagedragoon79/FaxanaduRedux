# Pass 475: The time played is real time at every game speed

## Category

Systems.

## Audit

Lead: clocks that run on the wrong time. Pass 474 moved three guardians' sways from the wall clock to
game time. This pass looked the other way: a system that counts game time where it means the player's
time. The game keeps three clocks: the time played (`GameState.play_time`, shown on each flask and on
the ending's thanks card), an Inner Ring's run (`Trials.tick`) and the boss rush (`BossRush.tick`).
All three added the frame's `delta`, which is game time. It shrinks with the Game speed option, slows in
a boss's slow motion and stops in hitstop.

For a trial or a rush that is right: a run is timed by the game it plays. The time played is not. It is
the player's own time.

## Bug found

At 70% Game speed, three seconds of play added 2.1 to the time played, so a ten-hour journey showed as
seven hours on the flask and on the ending's card. A boss's slow motion (30%) all but stopped the clock.

## Fix

`Feel.unscaled(delta)` turns a frame's delta back into real time: it divides by the time scale, and in
hitstop (time scale 0) it gives the real frame Feel already measures (`Feel.real_delta`). The time played
adds it. It still stops while the game is paused (pass 437). The trial and rush clocks are unchanged.

`test_the_time_played_is_real_time_at_every_game_speed` (test_systems) plays three seconds at 100, 90,
80 and 70% and a second of slow motion, and each counts in full. Bible 8 (the ending's thanks card) gains "Real
time at every game speed (pass 475)".

Mutation check: with the clock back on `delta`, the test fails at 90, 80 and 70% (2.70, 2.40 and
2.10 s) and in slow motion (0.30 s).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The time played is now real time at every game speed. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 476: Audio.
