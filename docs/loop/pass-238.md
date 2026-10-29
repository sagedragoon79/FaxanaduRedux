# Pass 238: the glove rasps down the wall

Audio's last pass (230) was the oldest apart from Art, so pass 238 takes Audio.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix | `levels.py --check` passes: 145 sound effects (median -18.3 dB), 34 music tracks (-14.7 dB), 14 ambience beds (-21.4 dB). | holds |
| Music per zone and boss | Every boss names its theme, Rokusutahn excepted, and he plays the general `boss` theme he has always had. Every named track exists. | holds |
| Phase-break lift and the guardian's fall | Passes 96 and 222. | holds |
| Missing sound names | The runner fails a test that plays a name with no file (pass 207). | holds |
| **Movement states** | I checked every dust or effect the player spawns for a sound alongside it. Every jump, landing, dash, glide, pogo, step and the Thrust's charge had one. The wall slide, a core Glove move used in every shaft, sheds dust every 0.06 s and was silent. | **fixed** |
| Lesser gaps | Bloodletting's heal and the pod launch's dust (the pod plays its own `pod`) need no sound of their own. | fine |

## As built

- `tools/audio/sfxgen.py`: new `wall_slide`. It is the glove's leather dragged down bark and stone: a 0.22 s rasp of filtered noise falling from 2.6 to 1.5 kHz, with a gritty 37 Hz flutter. Peak -8.0 dB, loudness -21.5 dB, next to the glide's -21.6. Only the new file was kept from the regeneration; the rewritten tracked sound files were restored.
- `Player._apply_wall_slide`: the rasp plays as you catch the wall (-4 dB) and every `WALL_SCRAPE` (0.24 s) after while you slide (-8 dB, a little pitch jitter), so a long slide is a steady scrape under the dust.
- `test_a_wall_slide_rasps_down_the_wall` (`test_abilities.gd`, new). Over a second against the wall, the rasp plays on the catch and every 0.24 s after (within one). Without the Glove there is no slide and no rasp.
- Mutation check: with the play call disabled, the test fails (0 rasps, about 5 expected).
- Bible 6.3 (the slide row) and 13.3 ("The glove on the wall").
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
| Audio | 5 | 99 | Unchanged score: every movement state is now heard. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 239 takes Stability (last pass 231, now the oldest).
