# Pass 244: the beam is heard

Bosses' last pass (236) was the oldest apart from Art, so pass 244 takes Bosses.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Dying mid-fight** (probe, all 16 arenas) | Each guardian was knocked below a phase mark, the hero was killed, and the hero came back through the door. Every arena restarted with its guardian whole, no phase passed and its own theme from the first note. The rest's music played in between, and no arena was left behind. Alpha's Den only seemed not to restart: you fall in onto the plank under the shaft, and you drop through it (the same plank you jump back up by), as you did through the kennels' lid to get there. | holds |
| **The dying window (pass 239) for every guardian** (probe) | Every guardian the probe could kill outright (11 of them) opened `BossArena.falling()` on its killing blow. The rest (King Grieve, Shadow Eura, Zoradohna, Rokusutahn, the veins and the heart) need their fights' own openings. Each sets `dead` in its death (`dead = true` in `die`/`_die`), and King Grieve's is tested (pass 239). | holds |
| Tells, phases, rewards | Passes 220, 234 and 236. | holds |
| **Strike sounds of tell-then-strike hazards** | Every guardian hazard that shows a tell sounds its strike: storm bolts (`zap`), rubble and roots (`crumble`), the warden's wave (`flood`). The Evil One's core beam was the exception. The `zap` played when its line was drawn, then the lance fired in silence. This is the last fight's main pressure, and the strike, the moment to be out of the line, had nothing for the ear. | **fixed** |

## As built

- `tools/audio/sfxgen.py`: new `core_beam` (0.42 s). It is a whoomph of light tearing open, a searing whine falling from 2.6 to 1.4 kHz, and a 90 Hz thrum. Peak -5.2 dB, rms -19.3 dB. The wavs the generator rewrote were restored.
- `CoreBeam`: `FIRE_SOUND` plays on the frame the tell ends and the lance fires. It plays once per beam, so a fanned pair sounds together. The Hour Glass still holds the beam, and the sound with it.
- `test_a_cores_beam_sears_as_it_fires` (`test_boss.gd`, new). The `zap` marks the line, nothing more sounds during the flicker, and `core_beam` plays as it fires.
- Mutation check: with the play removed, the test fails.
- Bible 8.9 (the Veins).
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the final fight's beam is heard, and retries hold for every guardian. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 245 takes Systems (last pass 237, now the oldest).
