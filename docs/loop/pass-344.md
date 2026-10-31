# Pass 344: every movement number in its own subsection (Movement)

## Audit

Movement was last audited in pass 336, which wrote the fields outside the tuning into 6.14. This pass read bible 6 against `MovementTuning`.

`test_every_movement_number_is_written_in_bible_6` (pass 328) looks for each tuning number anywhere in section 6, in any form `written_in` allows. Those forms include the rounded whole number and the percent, so 0.8 also matches "1" and "80%". Two numbers section 6 never names passed only on coincidence:

| Number | Value | Where 6 actually says it | What the check matched |
| --- | --- | --- | --- |
| `hurt_invuln` | 0.8 s | nowhere (only 5.3 says it) | the land squash's "1.25x0.8" |
| `slash_recoil` | 120 px/s | nowhere (only 5.3 says it) | an unrelated 120 in the section |

The check is also too loose to catch changes. With `ground_dash_snap` changed from 10 to 12, it still passed.

## Fix

- Bible 6.7: a "Hurt and recoil (pass 344)" line names both numbers (`hurt_invuln` 0.8 s, doubled by the mercy assist; `slash_recoil` 120 px/s), says why the old check missed them, and names the new test.
- `test_every_movement_number_is_written_where_it_belongs` (test_movement.gd):
  - maps every `MovementTuning` number, including the derived gravity and jump velocities, to its own subsection (6.1 to 6.12, and the 6.7 line for the two above);
  - holds each number there in the forms the bible writes: the number, two places, a whole px, a thousands comma, ms or a percent;
  - fails if a tuning number has no home subsection.

Mutation check: with `ground_dash_snap` at 12, the old test passes and the new one fails. Without the new 6.7 line, the new test fails on both `hurt_invuln` and `slash_recoil`. No tuning value changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every tuning number is held to its own subsection, and two that 6 never named are written. |
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

Pass 345, Faithfulness: audit passes 338 to 344 for the original's facts (manual quotes, deviations) in the bible that no test holds or that the code disagrees with.
