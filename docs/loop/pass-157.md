# Pass 157: the rush is heard

Audio, Stability and Faithfulness were tied at 98.25, the lowest apart from Art, all weight 5. Audio's last pass (150) was the oldest, so pass 157 takes Audio. I audited audio against bible 13.3, the newest content and the mix.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix (`levels.py --check`) | 117 sound effects, 34 tracks, 14 beds; no clipping or stray levels | fine |
| Eolis of Old chip track (pass 152) | -14.6 dB RMS, in line with the other tracks | fine |
| Mantra of Thorns (pass 155) | the trials' theme, bed, shimmer and bell, like the other trials | fine |
| Damage numbers (pass 154) | silent by design: every hit already has its sound | fine |
| **Boss rush win (pass 156)** | A rush won without a new best played `trial_clear`, which doesn't exist, so it was silent. The sound scan missed it because it only read the first name in `Sfx.play("a" if x else "b")`. | **fixed** |
| **Boss rush between fights** | Each arena played its zone's music until the boss rose, so the rush jumped from the Trunk's track to the Mist's. A fall made no sound. A boss down cut the music to silence. | **given a voice** |

## As built

- **Three new sounds** (`tools/audio/sfxgen.py`), all built on the trials' bronze bell so the rush sounds like the mantra:
  - `rush_mend`: when a boss falls and the mantra mends you, the bell is struck soft with a warm swell rising a fourth (G to C).
  - `rush_won`: the bell rung three times up the C major chord, the last left ringing. A new best adds the record sting over it.
  - `rush_fall`: the bell low (G3) and muffled, with a sinking drone under it. The music stops.
- **Music:** in a rush, `Music.for_room` gives every arena the trials' theme (`BossRush.MUSIC`) in place of its zone track. The boss brings its own track when it rises, and the theme returns when it falls.
- **The sound scan** (`test_every_sound_the_code_plays_exists`) now also reads the second name of a choice in `Sfx.play`'s first argument.

## Report

- `/mnt/project-files/pass-157/levels.txt`: the full levels table and the mix check. The new sounds peak between -6.9 and -5.2 dB, with RMS between -23.0 and -21.8 dB, beside `trial_bell` (-20.6 dB RMS).

## Tests

- `test_systems.gd`, `test_the_boss_rush_runs_every_guardian_again` gains checks that:
  - the arenas wait under the trials' theme;
  - the boss brings its own music;
  - each fall rings `rush_mend` and brings the theme back;
  - the last fall rings `rush_won` with the record sting;
  - a killing blow tolls `rush_fall`.
- `test_rooms.gd`, `test_every_sound_the_code_plays_exists` catches a missing sound in either branch of a choice. It would have caught `trial_clear`.

Full suite: 2914 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | The boss rush has its own sound: a theme between fights and a bell for each turn. A silent win is fixed, and the scan that missed it is wider. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.4125 (up from 96.4). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability and Faithfulness are tied at 98.25, the lowest apart from Art, both weight 5. Stability's last pass (151) is the older, so pass 158 takes Stability. Unbuilt: Guru Trials Winds, Stillness and Falling.
