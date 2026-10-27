# Pass 173: the mini-bosses' voices

Audio, Stability and Faithfulness were tied at 98.75, all weight 5. Audio's last pass (165) was the oldest, so pass 173 takes Audio. I audited the music, ambience, sound effects and the mix (bible 13.3 and the levels check) against the newest content (passes 166 to 172).

| Check | Finding | Verdict |
| --- | --- | --- |
| The mix | `levels.py --check` passes: 126 sound effects, median -18.2 dB; 34 music tracks, median -14.7 dB; 14 ambiences, median -21.4 dB | fine |
| The farewell and the trials (passes 167, 168) | the ending plays its own track, and the Falling trial uses the trials' own bell and set-back sounds | fine |
| The Proving Scar (pass 170) | plays Zenis's heartbeat track and ambience; its gates are the same objects as elsewhere, with the same sounds | fine |
| The Journey page (pass 172) | uses the menu's own sounds | fine |
| **The mini-bosses** | Both new mini-bosses were voiced with borrowed sounds. The Alpha's tells were the common hound's ratchet and its wall-jam was the generic `break`. The Captain's vault, his one move no knight has, used the generic `tell_charge`. Off screen, neither fight could be told by ear from a common foe. | **built** |

## As built

`tools/audio/sfxgen.py` makes four new sounds:

| Sound | What it is | When it plays |
| --- | --- | --- |
| `key_wind` | a great key turned through four heavy detents, with a spring groan climbing behind | the Alpha's intro, its pounce and howl tells, and its turn to phase 2 |
| `spring_jam` | a hard clang, then a mainspring buzzing loose and gear teeth skittering | the Alpha jamming against a wall |
| `bough_vault` | a deep woody groan as the lance flexes, then a rush as it throws him up | the Captain's vault tell |
| `lance_plant` | a deep wooden boom with roots tearing the floor | the Captain landing lance-first |

All four pass the levels check. `bough_vault` was turned down to -16 dB RMS so it sits with the other tells. Only the four new files were added: the generator's byte-level rewrites of other sounds were reverted.

## Report

- `/mnt/project-files/pass-173/levels.txt`: the peak and RMS of every sound, track and ambience.

## Tests

`test_enemies.gd`, `test_the_newer_foes_have_voices_of_their_own`, now holds both mini-bosses to their own sounds:

- the Alpha to `key_wind` and `spring_jam`;
- the Captain to `bough_vault` and `lance_plant`.

Each file must exist, and no other script may play it. The sound-scan test still finds a sound beside every tell and strike.

Full suite: 3290 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | The mini-bosses can be told by ear: a clockwork key and a jammed spring, and a flexing bough and a lance driven into the floor. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.8375 (up from 96.825). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability and Faithfulness are tied at 98.75, both weight 5. Stability's last pass (166) is the older, so pass 174 takes Stability.
