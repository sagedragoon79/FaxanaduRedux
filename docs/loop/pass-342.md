# Pass 342: the audio engine's numbers, held (Audio)

## Audit

Audio was last audited in pass 334, which counted the game's sounds. `levels.py --check` is clean: 160 sound effects (median -18.6 dB), 34 tracks (-14.7) and 14 beds (-21.4), none clipping or off the spread.

Bible 13.3 gives the audio engine's numbers, and every one matches the code:

- the 12-voice pool;
- the music's level of -8.3 dB;
- the phase lift of a semitone over 0.8 s;
- `Sfx.LIFT` of 3.1 and 2.2 dB on hurt and hit;
- the order a supplied track is looked for in;
- the mix check's limits (-0.1 dBFS clip, 9 dB spread, 1.5 dB headroom).

Tests use the constants, but none reads them from the bible. The ambience's level (`Music.AMBIENCE_DB`, -18 dB) and the crossfade (`Music.FADE`, 1.2 s) were not written at all.

## Fix

- Bible 13.3, Mix: a sentence on the engine's levels, giving the ambience bed's -18 dB under the music and the 1.2 s crossfade, and naming the test.
- `test_the_audio_numbers_are_written_in_bible_13_3` (test_rooms.gd) checks:
  - each of these numbers against its constant;
  - that only hurt and hit are lifted;
  - the supplied-track order;
  - the mix check's limits, read from `tools/audio/levels.py` itself, the script the `mix` CI job runs.

Mutation check: with a pool of 10 voices, a 1.5 s fade, a spread of 8 dB and the ambience at -16 dB, the test fails on each.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the engine's levels and the mix check's limits are written in 13.3 and held to the code. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 343, Stability: audit passes 336 to 342 for stability and performance facts in bible 14 that no test holds or that the code disagrees with.
