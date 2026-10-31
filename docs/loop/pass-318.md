# Pass 318: Bloodletting is heard

Category: Audio (last pass 310).

## Audit

- **Mix.** `tools/audio/levels.py --check` passes (158 sound effects, median -18.5 dB; nothing clips).
- **Executioner on the new openings (pass 314).** `execute` plays on any blow into a boss's `punishable()` window. Shadow Eura's and the Evil One's new windows are part of that, so they are heard.
- **The Equipment page.** Choosing the Rune Dagger for the off hand plays `gear_on`, the same sound as putting on any other gear.
- **The Off Hand banner (pass 317).** It arrives with the Continue toast and is read, not heard, the same as the other notices. No gap.
- **Bloodletting.** **Its heal was silent.** Since pass 314 it works in every fight, and a dagger build with no parry leans on it. Executioner has had its own `execute` since pass 165, but Bloodletting's heal showed only as a number on the masks.
- **Throw with a shield worn.** The press does nothing and makes no sound, much like a spell cast without enough magic did before it got `fizzle`. That branch is in Sean's off-hand code (PRs #347, #349), which this loop leaves alone. Pass 317's load banner covers old saves. A refusal sound there is a suggestion for Sean, not a change made here.

## Fix

- `tools/audio/sfxgen.py`: `bloodlet`, a warm, quiet double pulse like a heartbeat, two soft sine swells rising 180 to 260 Hz with a faint octave above (peak -10.5 dB). I put back the 110 files that sfxgen rewrites, kept only the new wav, and imported it.
- `Player`: `BLOODLET_SOUND`, played at -4 dB whenever Bloodletting actually gives health back.
- Bible 13.3: a bullet after pass 165's "Rewards that sound".
- Test: `test_bloodletting_heals_on_a_staggered_foe` now checks three things: no sound on a hit that heals nothing, the sound on the heal, and a peak under 0.6 of `hit`.

No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: Bloodletting's heal now has a voice. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 319 takes Stability (last pass 311).
