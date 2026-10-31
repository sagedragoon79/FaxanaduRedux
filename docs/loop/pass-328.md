# Pass 328: bible 6 is read, not copied

Category: Movement (last pass 320).

## Audit

- **Passes 321 to 327.** No movement code changed. The mercy assist (pass 325) doubles only a hit's grace. Knockback (160 and 220 px/s) and the 0.18 s control lock are unchanged, and the hurt pose still lets go at 0.25 s; `test_the_mercy_assist_doubles_a_hits_grace` holds that.
- **`movement_tuning.gd` against bible 6.** Every exported number is read by a test. Most are pinned in `test_movement_numbers_match_bible_6_1_and_6_2`, `_6_2_to_6_6` and others, but **as literals copied from the bible**. Only sap (6.12) and ladders (6.11) read the bible's own text. Retuning a number together with its pin would leave section 6 saying the old value, and the bible is the source of truth (CLAUDE.md asks that the two change together). A scan found every one of the 62 values written in section 6 today, so nothing has drifted yet. Nothing would have caught it if it did.

## Fix

- Test: `test_every_movement_number_is_written_in_bible_6` (test_movement.gd). It reads section 6 and requires every number `MovementTuning` exports to appear there as a standalone number. It accepts the bible's forms: 165, 1,800, 0.10 s, 45 ms, 40%, and derived values to the whole px, such as gravity's 1,111 and the double jump's 326. As a mutation check, ground acceleration at 1,850 fails it by name. Small numbers such as 2 match almost anywhere, so the check bites on the distinctive values, which are most of them.
- Bible 6: the intro paragraph says what the new test holds.

No number changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: section 6 is now held to the tuning by its own text. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 329 takes Faithfulness (last pass 321).
