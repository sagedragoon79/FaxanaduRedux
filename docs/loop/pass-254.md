# Pass 254: long sounds keep their voice

Audio's last pass (246) was the oldest apart from Art, so pass 254 takes Audio.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix and levels | `levels.py --check` is clean: 148 effects (median -18.4 dB), 34 tracks and 14 ambiences. | holds |
| Every sound used, every name has a file | Each of the 148 wavs is played by name or by a constant (`WIN_SOUND`, `STAB_SOUND`, `"broad_" + sound`). The runtime name check (pass 207) catches the rest. | holds |
| Loops that outlive their source | `Sfx` plays one-shots only, and music and ambience run through `Music`. | holds |
| **Voice stealing** | `Sfx` has 12 voices and handed them out in turn. The thirteenth sound took the oldest voice whatever it held, so in a running fight (footsteps, cuts, hits, tells) the 2.4 s `boss_won` or the 1.4 s `phase_break` was cut off within about a second. The same sound asked for again in one frame took a voice each time, so a burst of eight coins summed eight copies and took two-thirds of the pool. | **fixed** |

## As built

- `Sfx._ends` keeps when each voice's sound ends, in real time: its length over its pitch. `Sfx._voice` picks a free voice, or else the one nearest its end. A long stinger outlasts a stream of short sounds, and the voice a footstep is about to give up is the one taken.
- `Sfx._started_on`: a sound already started this physics frame isn't started again. It is still recorded in `Sfx.recent`, so a test that listens hears each ask.
- `Sfx.voice_sound(i)` says what voice `i` is playing. It reads the end times, so it works with the silent driver the tests use.
- `test_a_long_sound_keeps_its_voice_through_a_busy_moment` (`test_rooms.gd`, new). The victory keeps its voice through 24 short sounds, eight coins in one frame take one voice and are each recorded, and the next frame's coin sounds again.
- Mutation check: with turn-taking back, the victory's voice holds `slash` and the test fails.
- Bible 13.3 (SFX, Voices).
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the stingers that mark a fight's turns now ring to their end. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 255 takes Stability (last pass 247, now the oldest).
