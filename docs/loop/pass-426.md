# Pass 426: being hit with the buttons

## Category

Combat (last pass 418).

## Audit

Every combat button answers the real controller on the frame it is pressed (pass 386). The combo windows (pass 402), King Grieve's parry (pass 412), an ordinary parry and the held guard (pass 418), and the fight's sounds (pass 422) do too. Being hit was still proven only standing still with a scripted intent (`test_being_hit_matches_the_bible`). A player is usually holding a direction when a blow lands, and often drinking. A held direction is the one input the control lock exists to override, and a hit spoiling a drink had no test at all: removing `_drink_timer = 0.0` from `take_damage` failed nothing.

## Fix

`test_being_hit_answers_the_real_controller` (test_combat) presses Heal for real, holds Right toward the Rot Dwarf and lets his swing land. It checks four things:

- the blow spoils the drink and keeps the flask's charge;
- it knocks you back against the held Right;
- for the whole 0.18 s control lock, Right never turns you;
- once the lock is over, the same held Right (never pressed again) steers you while the i-frames still run.

Bible 5.3 gains "Being hit with the buttons (pass 426)".

Mutations:

- Removing the drink reset from `take_damage` is caught only by this test.
- Dropping the hurt control lock is caught by this test and by `test_being_hit_matches_the_bible`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. Being hit answers the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 427: World.
