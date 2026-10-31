# Pass 326: a dagger on stone pings

Category: Audio (last pass 318).

## Audit

- **Mix.** `levels.py --check` passes: 160 sound effects (median -18.6 dB), 34 music tracks and 14 ambience beds.
- **Coverage.** Every sound the code plays has a file. Every `.wav` is played, the surface steps and broad-sword swings by name built at runtime. Every test the bible names exists.
- **Passes 319 to 325.** The mercy assist (325) needs no sound of its own: its longer blink is the cue. Taking the Rune Dagger in hand on the Equipment page plays the buckle `gear_on`, and a Throw pressed with a shield worn is silent. Both are Sean's off-hand code (#349), so they stay as they are and go to him as suggestions.
- **The gap: a dagger that struck a wall borrowed the shield's `guard` clank** (at -8 dB). A throw at stone sounded like a block, which misleads most on a dagger build, which since the off hand can never block. Pass 190 had given the dagger its own strike (`dagger_hit`) and left the wall on the borrowed sound.

## Fix

- `sfxgen.py`: new `dagger_ping`. A glancing steel ping (2.86 and 4.17 kHz, decaying over 0.14 s) over a gritty tick, peak -8 dB. It was the only new file; the regenerated others were checked out, and it is imported.
- `RuneDagger.WALL_SOUND` ("dagger_ping") plays at -4 dB where `guard` had played.
- Test: `test_a_dagger_on_stone_pings_and_never_clanks_like_a_shield` (test_combat.gd). A throw at a wall plays the ping and never `guard`. As a mutation check, restoring `guard` fails it.
- Bible 13.3: a bullet after pass 190's gear sounds.

There is no visual change, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the dagger's last borrowed sound is its own. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 327 takes Stability (last pass 319).
