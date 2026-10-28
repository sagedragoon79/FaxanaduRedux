# Pass 212: Zoradohna no longer outlasts the bosses after her

Bosses' last pass (204) was the oldest apart from Art, so pass 212 takes Bosses. I audited the bosses against bible 8 and 15.3, and against passes 205 to 211.

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs | Every boss's `*_telegraphs_are_fair` test passes, each tell is clamped to `Enemy.MIN_TELEGRAPH`, and no boss changed after pass 204. | fine |
| Hit-stops (208, 210) | The pogo and kill hit-stops moved into the tuning without changing value. Boss kills keep `Feel.boss_kill`, and their own blows keep their bespoke hit-stops. | fine |
| The Inventory page (205), big coins (206), missing sounds (207) | Boss purses drop as coins, and the coin sound test and the missing-sound guard cover every fight in the suite. | fine |
| The Stride secret (211) | No arena changed. | fine |
| **Zoradohna's health** | Pass 204 flagged her as long for the Tower: 360 HP is 33 par slashes. That made the second guardian longer than every required fight before the finale (the next longest is 24), and her hull lets only a quarter of a side blow through, so the real fight ran longer still. Nothing held the guardians' lengths to the order of the game. | **cut to 260 HP (24 slashes), and a test** |

## As built

- `zoradohna.gd`: `MAX_HP` goes from 360 to 260. Her phase thresholds (65% and 30%) are fractions, so each phase still opens at the same point in the fight. She stays above the Tower's Foreman (20) and level with Zorugeriru (24), the longest later guardian.
- `test_the_guardians_last_as_long_as_their_place` checks one more thing: no required guardian outlasts the longest guardian of every later zone by more than two slashes. The finale, the mini-bosses and the optional Warden are left out of the comparison.
  - The two slashes of slack let Zorugeriru (24) sit one slash above Daybreak and Dartmoor (23). His script is not to be edited.
- Mutation check: putting 360 back fails the test with "Zoradohna (33) ... (24)".
- Bible 5.5: the health table shows 24, and the rules add the later-zone limit and why it exists.
- There is no visual change, so this pass has no screenshot.

Full suite: 4029 of 4029 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the outlier pass 204 noted is fixed, and the guardians' lengths now follow the order of the game. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 213 takes Systems (last pass 205, now the oldest).
