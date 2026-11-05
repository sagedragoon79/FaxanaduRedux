# Pass 476: The music moves in real time

## Category

Audio.

## Audit

Lead: sound under a slower game. The sounds play at their own pitch whatever the time scale, and `Sfx`
keeps each voice's end by the real clock, which matches: no bug there. The music is different. Its
fades (every track and bed change), its ducks (a fanfare, a phase break) and its phase lifts (a semitone
per boss phase) are tweens, and a tween runs on game time by default. `Music` runs while paused, but
that does not undo the time scale.

## Bug found

At 70% Game speed a 1.2 s fade took 1.7 s and a 0.8 s phase lift took 1.1 s. In a boss's slow motion
after the death blow (30%), the fade under it stretched toward four seconds. In hitstop (time scale 0) a
fade or the phase break's duck stopped where it was. With the tweens on game time, a probe found a 1 s
fade-in still at -21 dB after a real second at 70% and at -43 dB at 30%, and a fade begun at a freeze
at -29 dB after 0.6 s.

## Fix

Every tween in `Music` (`_fade`, `duck`, `intensify`) ignores the time scale
(`Tween.set_ignore_time_scale`), so the music is heard in real time, as the sounds always were.

`test_the_music_moves_in_real_time_at_every_game_speed` (test_systems) fades a track in and lifts it a
phase at 70% and 30%, and fades one in through hitstop. Each is whole in its own time. Bible 13.3 (phase
breaks) gains "In real time (pass 476)".

Mutation check: with the tweens back on game time, the test fails four checks (both fades, the 70%
lift and the fade through hitstop).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The music's fades, ducks and lifts now run in real time. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 477: Stability.
