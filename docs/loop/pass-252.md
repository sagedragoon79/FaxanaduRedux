# Pass 252: the last lantern breaks the phase

Bosses' last pass (244) was the oldest apart from Art, so pass 252 takes Bosses.

| Check | Finding | Verdict |
| --- | --- | --- |
| Phase marks against bible 8 | Every guardian's `PHASES` matches the bible's "below X%" lines. Borabohra is at a half and a quarter, Pakukame at a half and a quarter, King Grieve and Shadow Eura at a half and a fifth, and Zoradohna at 65% and 30%. | holds |
| Tells, dying window, retries, beaten for good | Passes 174, 220, 234, 236, 239 and 244, all still tested. | holds |
| **The phase break against the boss's own phase** | I read where each of the 16 guardians moves its `phase`. Fifteen move it on their `PHASES` marks. Ripasheiku also goes straight to phase 3 when her last lantern breaks (8.3), but `BossArena._track_phases` watched health alone. The four lanterns cost her 72 of 260 HP, which leaves her at 72%, above the first mark. So the fight's biggest turn, the widow coming down for good, played no stinger, no stagger hit-stop and no lift in the music. Then her health crossed 66% and 30% later and rang twice, for phases she was already in. | **fixed** |

## As built

- `BossArena._track_phases`: the marks passed are the larger of the health marks crossed and the boss's own `phase` minus one, capped at the number of marks. The last lantern is one break at level 2, and the health marks after it ring nothing. For the other fifteen guardians, `phase` moves on the same marks, so nothing changes.
- `test_her_last_lantern_breaks_the_phase_as_her_health_would` (`test_boss.gd`, new). Four lanterns leave her above the first mark, and the break comes once, at level 2, with the music at intensity 2. Her health then crossing a half and a fifth rings nothing more.
- Mutation check: without the fix the test fails on three checks. The breaks are `[]` and the intensity is 0, and the later breaks ring `[1, 2]`.
- Bible 13.3 (Phase breaks).
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the Lantern Widow's turn now lands with a phase break. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 253 takes Systems (last pass 245, now the oldest).
