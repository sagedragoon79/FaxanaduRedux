# Pass 391: no button held into the next test (Stability)

Category: Stability and performance (last pass 383).

## Audit

- The last full run's engine warnings are all expected: the damaged and unwritable save cases (slot 8), one old options file, and a corrupt number in a damaged save. Each sits in a test that allows engine errors.
- No test grew slow or flaky: the soaks still play 50.5 minutes, and the run time held.
- New global state since pass 383: `Sfx.heard` (pass 390) is meant to build up over the whole run. Passes 384 and 386 added something else. Tests now press the real controller (`Input.action_press`, the suite's `press_for_real`), and a pressed action is engine state that outlives a test. `_leaks` read options, time, trials, rushes, poses, drops and feel, but not held buttons. A test that forgot a release, or stopped before it, would pass and hand the next test a hero already holding Left or Attack.

## Fix

- `held_actions()` in the runner lists every game action still down (the engine's `ui_` actions aside). `_leaks` reports them as "buttons held (...)", and `_clean_slate` releases them.
- `test_every_test_starts_from_a_clean_slate` presses Jump and Attack, checks both count as a leak, wipes the slate and checks both are let go.
- Bible 15.3, clean slate: "Buttons held (pass 391)".

Mutation check: with the stick test's release of Left removed, `test_the_stick_walks_into_a_run_the_farther_it_leans` fails with "left global state changed: buttons held (move_left)".

Full suite: 7070 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score. A button left held fails its test and is released before the next. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 392: Movement.
