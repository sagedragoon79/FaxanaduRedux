# Pass 334: the game's sounds, counted

Category: Audio (last pass 326).

## Audit

- **The mix.** `python3 tools/audio/levels.py --check` passes: 160 effects with a median of -18.6 dB, 34 music files at -14.7 dB, and 14 ambience beds at -21.4 dB.
- **Code to files.** `test_every_sound_the_code_plays_exists` holds every `Sfx.play`, `Music.play` and `BossArena.BOSSES` track to a file. A scan of room headers finds every `music:` and `ambience:` named (the gym's `none` aside).
- **Files to code.** No test asked the reverse. A script found that every effect on disk is played, the broad-sword cuts (`"broad_" +`) and the footsteps (`"step_" +`) through a prefix built at runtime. So nothing is dead today, but nothing would catch a sound left behind when its caller goes.
- **Bible 13.3** still gave the plan's counts: "about 180 effects" and "about 22 tracks". The game has 160 effects, 34 tracks and 14 ambience beds, and nothing said so. The plan's Guru and shrine track was never made: a Guru's room keeps its zone's theme. The ending plays under the credits.

## Fix

- Bible 13.3: an "As built (pass 334)" line with the three counts. It lists the 34 tracks by kind: 10 area themes, 6 town themes, 5 variants, `boss`, `miniboss`, 9 guardian themes, the title and the ending. It also notes there is no Guru track.
- Test: `test_the_bible_counts_the_games_sounds` (test_rooms.gd) checks four things:
  - the effect count matches `assets/sfx`;
  - the track and bed counts match `assets/music`;
  - the bible's list of tracks by kind adds up to the folder;
  - every effect on disk is named in the code, whole or after a runtime prefix.
- Mutation check: an orphan `zzq_orphan.wav` fails both the count and the played check.

Nothing on screen or in the mix changed, so there is no screenshot and no sound was regenerated.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the bible says what was built, and an unplayed sound now fails. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 335 takes Stability (last pass 327).
