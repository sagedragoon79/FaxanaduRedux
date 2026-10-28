# Pass 230: the glass runs out by ear

Audio's last pass (222) was the oldest apart from Art, so pass 230 takes Audio. I audited the zone and boss music, the boss_won sting (222), sound coverage for the mechanics added since (the shield's ward, 225; the Hour Glass holding every hazard, 228) and the mix (`tools/audio/levels.py --check`).

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix | `levels.py --check` is clean: 141 effects (median -18.3 dB), 34 music tracks, 14 ambiences. | fine |
| The boss_won sting (222) | It plays on every guardian's fall and in the rush. Tested. | fine |
| **The Hour Glass running out** | It rang when turned and then went silent. Since pass 228 every loosed hazard holds while it runs, so the moment time starts again (held shots fly on, frozen footholds melt) matters more, and the only sign of it was the sand in the HUD. | **fixed** |
| **The ward** | A shield or helmet turning part of a hex (225) made no sound. A guard rings `guard`; a ward rang nothing. | **fixed** |

## As built

- `glass_tick` (a dry clock tick with a faint high tock) plays at each of stopped time's last three quarter-seconds, and `glass_end` (a rush of air let go forward over a low thunk) when it runs again (`Player._glass_cues`, called from `_tick_timers` with `TimeStop.left` before and after the tick; `GLASS_TICKS` 3, `GLASS_TICK` 0.25 s). The Time Thief's longer stop ticks the same way, since the cues count back from the end.
- `ward` (a bright glassy ring with a sparkle on the front) plays in `receive_attack` whenever the ward cuts a hex, under the hurt and the guard. A blow rings nothing.
- All three come from `tools/audio/sfxgen.py`. Levels: peaks -6.0 to -6.9 dB, RMS -20.6 to -22.4 dB, near `hourglass` (-24.3) and under `guard` (-13.6). The check is clean. The generator rewrote every other wav; those were restored.
- Tests: `test_the_hour_glass_ticks_before_time_runs_again` (`test_abilities.gd`, new) checks three ticks at 0.75, 0.5 and 0.25 s left, the rush at the end, and nothing while the glass runs back. `test_a_shield_wards_a_foes_sorcery` now checks that the ring plays for a hex and not for a blow. Mutation check: with the cues removed, 3 of 5 and 1 of 11 checks fail.
- Bible A8 and the sound notes in 13.3.
- No visual change, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the two newest mechanics now sound. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 231 takes Stability (last pass 223, now the oldest).
