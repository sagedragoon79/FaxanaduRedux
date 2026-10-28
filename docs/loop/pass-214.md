# Pass 214: Sean's own music plays

Audio's last pass (206) was the oldest apart from Art, so pass 214 takes Audio. I audited the sound against passes 207 to 213 and bible 13, ran the mix check, and traced how a supplied track reaches the speakers.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix (`levels.py --check`) | It passes: 139 effects at a median of -18.3 dB, music at -14.7 dB, ambience at -21.4 dB. | fine |
| Sound coverage | Every literal sound name has a file (`test_every_sound_the_code_plays_exists`), runtime names are caught by `Sfx.missing` (207), and a scan found no sound file that the code never asks for. | fine |
| Passes 207 to 213 | The pogo and kill hit-stops, the Stride cache's Life Fruit, Zoradohna's shorter fight and moved pickups all use sounds that were already there. | fine |
| **Supplied music** | Bible 13.1 has the soundtrack coming from Sean's library, and CLAUDE.md and `musicgen.py` both say a supplied `.ogg`, `.mp3` or `.wav` of the same name replaces a placeholder. But `Music` looked for `.ogg` first, and every placeholder is an `.ogg`, so a supplied `.mp3` or `.wav` never played. `levels.py` measured only `.ogg` files, and CI didn't run it at all. | **fixed, tested and checked in CI** |

## As built

- `Music.EXTENSIONS` is now mp3, wav, ogg, so a supplied file comes before the placeholder. The lookup is `Music.path_for(name)`, and a test can pass its own `exists` check.
- `musicgen.py` skips any track that has a supplied `.mp3` or `.wav`.
- `levels.py` measures the file each track actually plays from, decoding any of the three formats with ffmpeg.
- `.github/workflows/ci.yml` has a new `mix` job that runs `levels.py --check`.
- Tests:
  - `test_a_supplied_track_replaces_its_placeholder` (new) checks the order with a stand-in file list, and that the real placeholder still loads. Putting `.ogg` first again fails it.
  - Checking the mix check itself: a supplied `mist.mp3` 14 dB quieter than the placeholder was flagged as an outlier ("-13.6 from the median"), and the check exited 1. I then removed the file.
- Bible 13: a "Supplied music" line, after "Mix".

Full suite: 4039 of 4039 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the bible's music plan (Sean's library) now works for every format, and CI guards the mix. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 215 takes Stability (last pass 207, now the oldest).
