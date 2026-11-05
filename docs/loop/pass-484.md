# Pass 484: The red edge on the beat

## Category

Audio.

## Audit

Leads: sounds played from screens, sounds under slow motion and hitstop, and the mix.

- `tools/audio/levels.py --check` is clean: 166 sounds (median -18.5 dB), 34 tracks (-14.7 dB),
  14 ambience beds (-21.4 dB).
- Sounds play at their own pitch at every Game speed: `Sfx` sets only its small jitter, and nothing ties
  `AudioServer.playback_speed_scale` or a player's pitch to the time scale. The music's phase lifts
  tween in real time (pass 476).
- The screens' sounds (the dialog's blip every third letter, the menu blips) follow their screens, which
  run in real time since pass 483.
- The low-health heartbeat (5.3) sounds every 0.85 s from the player's own timer, which starts when you
  fall to one mask. The bible says the screen's red edge pulses "in time with it", but the HUD drew the
  pulse from `_pulse_t`, a clock of its own that starts when the HUD is made.

## Bug found

The red edge's pulse and the heartbeat were out of step by chance: how far apart depended on how long
the HUD had been up when health fell. In the test's case the edge was at its dimmest just as each beat
sounded (0.12, with the pulse running 0.10 to 0.24), so the warning you hear and the one you see fought
each other.

## Fix

`Player.heartbeat_phase` gives how far through the heartbeat you are (0 as it sounds), and
`GameHud.edge_strength` reads it, so the edge is brightest in the frame the beat sounds and dimmest
halfway to the next. `test_the_red_edge_swells_on_the_heartbeat_at_every_game_speed` (test_combat)
waits an odd 17 frames, falls to one mask, waits out the hurt flash and listens for each beat at 100 and
70%: the edge is at its brightest on every one. Bible 5.3's low-health line gains "On the beat (pass 484)".

Mutation check: with the pulse back on `_pulse_t`, the test fails at both speeds (0.12 and 0.16 on the
beat against a peak of 0.24).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The heartbeat you hear and the pulse you see now beat together. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 485: Stability.
