# Pass 165: rewards that sound

Pass 164 left Audio, Stability and Faithfulness tied at 98.5, each weighing 5. Audio's last pass (157) was the oldest, so pass 165 takes Audio. I audited audio against bible 13 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix levels | `levels.py --check` is clean: 122 effects (median -18.3 dB), 34 tracks, 14 ambiences | fine |
| The Mantra of Stillness | its falls use the Waterfall's own sounds, and the glass plays `hourglass`; the trials music and ambience carry the room | fine |
| Zenis remixed foes (pass 161) | each family keeps its own voice from its home zone | fine |
| The silhouette wash (pass 161) | purely visual; the hit and tell sounds are unchanged | fine |
| **Executioner hits** | A blow into a boss's opening hit 35% harder (pass 163) but sounded like any cut, so the skill could not be heard working. | **built** |
| **A mantra dye won** | Earning a dye (pass 164) showed a toast, but the moment was silent apart from the bell every clear rings. | **built** |

## As built

- **`execute`** (`sfxgen.py`): a low body thud, a crack and a short hard ring. The player plays it, 3 dB down and under the cut's own sound, when Executioner raises a blow.
- **`dye_won`**: cloth swept open, then the trial bell struck high, three quick notes falling into a held chord. The bell plays it over `trial_bell` when a clear earns a dye.
- Both pass `levels.py --check`: `execute` peaks at -4.4 dB with an rms of -18.3, and `dye_won` peaks at -7.5 with an rms of -24.3. sfxgen rewrote 28 unrelated wavs with tiny byte diffs, and those were restored with `git checkout`.

## Report

- `/mnt/project-files/pass-165/levels.txt`: the full levels table and the check.

## Tests

- `test_economy.gd`, `test_executioner_strikes_harder_into_a_bosss_opening`: the blow into the opening plays `execute`, and a plain one does not.
- `test_systems.gd`, `test_a_won_dye_sounds_over_the_bell` (new): the first quick clear rings `trial_bell` and `dye_won`, and a second rings the bell alone.
- The sound scan in `test_rooms.gd` finds both new names among the generated files.

Full suite: 3144 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | The newest rewards can be heard: Executioner's cleave and the mantra dye's chime. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.625 (up from 96.6125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability and Faithfulness are tied at 98.5 and weigh 5 each. Stability's last pass (158) is the older, so pass 166 takes Stability.
