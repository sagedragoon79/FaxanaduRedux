# Pass 96: Phase breaks and the mix

Audio (92) was the lowest category apart from Art. This pass gives every boss fight an audible turn at each phase, and measures the whole mix for the first time.

## What changed

- **Phase breaks** (`BossArena._track_phases`):
  - The arena watches the boss's health against its `PHASES` marks. Every boss has them, as the test added in pass 94 checks.
  - Crossing a mark plays the new `phase_break` stinger: a deep impact, a reversed swell and a ringing fifth. The music ducks 12 dB under it for 1.4 s, the screen shakes, and `phase_broken(level)` is emitted. Each mark sounds once.
- **The music lifts** (`Music.intensify`):
  - Each phase raises the boss theme a semitone, eased over 0.8 s. Its tempo rises about 6% with it, the old key-change lift.
  - Phase 3 is two semitones up. A new track starts back as written (`intensity` 0, pitch 1).
- **The mix** (new `tools/audio/levels.py`):
  - It measures the peak and the loudness of the audible part (above -50 dBFS) of every sound effect, music track and ambience bed. `--check` exits 1 on clipping or on a file more than 9 dB from its group's median.
  - Findings and fixes:
    - **22 of 25 music tracks clipped** after Vorbis encoding (decoded peaks up to +1.6 dBFS). The generator normalized to 0.85 (-1.4 dBFS), which left no room for the encoder's overshoot. It now normalizes to 0.7 (-3.1 dBFS) and every track is regenerated. All decoded peaks are now at -0.2 dBFS or lower.
    - `Music.MUSIC_DB` goes from -10 to -8.3 to keep the music's place against the effects.
    - **The death sound** sat 10 dB above the effects' median. Its gain is lowered from 0.7 to 0.4.
  - The ambience beds were already in range and are unchanged.
- `CLAUDE.md` and bible 13.3 (Audio) document the phase break and the levels check.

## Tests

`test_boss.gd`:
- `test_a_phase_break_stings_and_lifts_the_music`: a break per mark and once each, the music's intensity and pitch reaching a semitone and then two, and a new track resetting.

`levels.py --check` passes on the whole mix.

Full suite: 1799 checks, all passing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 92.5 | Unchanged. |
| Combat and enemies | 15 | 92.75 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.75 | Each phase turn is heard as well as seen. |
| Systems | 10 | 93.25 | Unchanged. |
| Audio | 5 | 93.5 | No clipping anywhere, levels measured and in range, and boss music that builds. |
| Stability and performance | 5 | 92.75 | A repeatable mix check. |
| Faithfulness | 5 | 95.75 | Unchanged. |

Weighted score: 92.88 (up from 92.76; 92.875 unrounded).

## Next

Stability (92.75) and Movement (92.5) are now the lowest apart from Art. Pass 97 takes Movement: a feel review against bible 6.7's juice checklist (rumble, per-surface landings, coyote and buffer edge cases), to fix whatever falls short.
