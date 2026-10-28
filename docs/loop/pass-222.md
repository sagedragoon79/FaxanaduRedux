# Pass 222: a guardian's fall rings a fanfare

Audio's last pass (214) was the oldest apart from Art, so pass 222 takes Audio. I audited sound coverage, music, ambience and the mix against passes 215 to 221 and bible 13.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix (`levels.py --check`) | 140 effects, 34 tracks and 14 beds; nothing clips or strays. | fine |
| Unreferenced effects | The 12 wavs with no literal `Sfx.play` name are all played by name at runtime (`swing_sound`'s `broad_`, the map's pin, the minecart, big coins, the Equipment page, the fields, the steps). | fine |
| Telegraphs and foe voices | Held by the existing scans. | fine |
| King Grieve's sword (217), the skill-point toast (220) | Both play under the win's sound. | see below |
| **The win itself** | Every guardian's fall played `item`, the chime of a bread loaf or any find, while the boss theme faded out over 2.5 s on top of it. The climax of every fight sounded like a pickup. | **fixed** |

## As built

- New effect `boss_won` (`sfxgen.py`): three quick brassy G's over a timpani roll, then a held C major chord with a low root, 2.4 s. Peak -4.4 dBFS, loudness -20.2 dB against the effects' median of -18.3.
- `BossArena.WIN_SOUND` plays it on every win, including the rush's falls. `BossArena.WIN_FADE` (0.4 s) drops the boss theme away under it, where it had faded over 2.5 s.
- New test `test_a_guardians_fall_rings_a_fanfare_of_its_own` (`test_boss.gd`) checks the file's length against `item` and that King Grieve's fall plays it and stops the music. `test_every_guardians_win_says_what_it_gave` now listens for it in every arena.
- Mutation check: with `item` back in place, the test fails.
- Bible 13 Audio: "A guardian's fall".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the biggest moment in each fight now has a sound of its own. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 223 takes Stability (last pass 215, now the oldest). The hydra soak failed once locally in pass 220 and passed on rerun; worth a look.
