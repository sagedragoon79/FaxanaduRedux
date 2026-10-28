# Pass 206: big coins sound big

Audio's last pass (198) was the oldest apart from Art, so pass 206 takes Audio. I audited what passes 199 to 205 added for sound, and ran the mix check.

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix (`levels.py --check`) | It passes: 139 effects at a median of -18.3 dB, music at -14.7 dB, ambience at -21.4 dB. | fine |
| The Pendant and the Magical Rod (201) | Both play the `item` sting and the 0.12 s hit-stop, like every found ability. | fine |
| The Inventory page (205) | It uses the shared `ListMenu`, so it has the same cursor and choose blips as every page. | fine |
| Guardians' health, the faithfulness and movement tests (200 to 204) | These passes only added tests and docs, with no new events to be heard. | fine |
| **Coin denominations (199)** | Pass 199 brought in 25 and 100 g coins, drawn bigger, but every coin still chimed the same `coin`. So a 5,000 g chest's few big coins sounded the same as a foe's 5 g. The sound did not match the size the eye sees. | **built: `coin_big`** |

## As built

- `sfxgen.py` makes `coin_big`, 0.3 s long. It is the small coin's rising square-wave chime a fourth lower (990, then 1320 Hz), then a third note (1980 Hz) with a sine bell tail. Its peak is -6.0 dB and its RMS -12.3 dB, against `coin`'s -8.0 and -13.8. The other effects sfxgen rewrote were restored, so only the new file is added.
- `Coin.sound(value)` picks `coin_big` for 25 and 100 g coins, and `coin` for 1 and 5 g. `_collect` plays it.
- Test: `test_a_big_coin_rings_lower_and_longer` (new). It checks:
  - the pick by value;
  - that the big file is more than twice as long;
  - that taking a 100 g coin in a live room plays `coin_big`.
  
  A mutation (raising the threshold) fails it.
- Bible 13 (Audio): "Big coins".

Full suite: 4004 of 4004 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the newest pickups' sizes are now heard. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 207 takes Stability (last pass 199, now the oldest).
