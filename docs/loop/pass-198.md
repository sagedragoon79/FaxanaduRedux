# Pass 198: a blow you can hear

Audio's last pass (190) was the oldest apart from Art, so pass 198 takes Audio. I audited sound against passes 189 to 197, where the big change was zone threat. Since passes 194 to 197, foes and bosses hit harder and pay more the deeper you go.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix levels (`tools/audio/levels.py --check`) | 137 effects, 34 tracks and 14 ambience beds, all inside the limits, no clipping. | fine |
| **Hits since zone threat** | Every hit played the same `hurt` yelp, whether it cost 6 HP or 26. Since passes 194 and 196 the deep zones' worst blows cost a whole mask or more through par armor, and the Trunk's never do. The masks and the red edge show it, but the ear could not tell a graze from a blow. | **built: `hurt_heavy` under any hit of a mask or more** |
| Gold (pass 197) | Coins already chime on pickup, one per coin, so a fatter drop already sounds fuller. | fine |
| The Crown Lookout's shrine (pass 195) | A shrine is a shrine: it uses the same rest and save sounds as the others. | fine |
| The Rune Dagger and the Broad Sword (passes 188 to 192) | They have had their own voices since pass 190. | fine |

## As built

- `tools/audio/sfxgen.py`: `hurt_heavy` is a 0.32 s low body thud (a sine sliding 110 to 45 Hz) with a short crunch of filtered grit. It peaks at -3.1 dB with an RMS of -13.3 dB, under the yelp's -9.5 dB RMS, so the two layer. Only `hurt_heavy.wav` and its import are committed. The other regenerated files were checked out unchanged.
- `Player.take_damage` plays `hurt_heavy` beside `hurt` when the blow, after armor and guard, costs a whole mask or more (`GameHud.MASK_HP`, 20).
- Bible 5.3, Damage taken: the two hurt sounds and when each plays.
- `test_combat.gd`, `test_a_blow_that_costs_a_mask_sounds_heavier` (new): a 19 only yelps, a 20 thuds too, and the file exists.

Full suite: 3832 of 3832 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: a heavy blow now reads by ear, which matters more now that the deep zones hit harder. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 199 takes Stability (last pass 191, now the oldest). The soaks should be rechecked under zone threat, since foes now hit up to twice as hard.
