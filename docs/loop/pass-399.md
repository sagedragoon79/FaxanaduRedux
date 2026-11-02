# Pass 399: saves and pauses left behind

## Category

Stability (last pass 391).

## Audit

- The real-controller tests from passes 392, 394, 397 and 398 release every button they press. The pass 391 leak check would name any button still held.
- The last full run passed all 7161 checks and played 50.5 minutes of soak, above the 45-minute floor. Its 27 logged errors and warnings all come from tests that break a save or the options file on purpose and allow it.
- Two things a test can leave behind were not caught:
  - **The player's own saves.** The suite shares `user://` with the game. The tests keep to slots 7 to 9 and 96 to 99, but only by habit. A test that saved to or poured out slot 1, 2 or 3 would take one of Sean's own three flasks the next time he ran the tests, and nothing would say so. A test that forgot to pour out its own flask would also leave the file behind for every later test and run.
  - **A paused game.** Since passes 397 and 398, tests open real menus, and an open menu pauses the game. A test that stopped short of closing one would hand the next test a world that stands still.

## Fix

- `_leaks` in `tests/test_runner.gd` now hashes every `save_*` file in `user://` when a test begins. When the test ends, it names any file the test wrote, changed or removed (`changed_saves`). It also names a game left paused.
- `_clean_slate` unpauses the game.
- After each test, the runner removes any save file the test made and left behind. A file that was there before the test began is never touched.
- `test_every_test_starts_from_a_clean_slate` writes and then pours out a flask of its own, and pauses and unpauses the game, to show that each is caught.
- Bible 15.3 gains "Saves and pauses left behind (pass 399)".

The first full run found a real case: `test_deaths_are_counted_and_kept_in_the_save` left its journey in slot 9 for every later test and run. It now pours it out.

Mutation check: with the closing pour taken out of `test_three_flasks_hold_three_journeys`, the runner fails it with `saves changed (save_8.json, save_9.json)` and then sweeps both files away.

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
| Stability and performance | 5 | 99 | Score unchanged. A test can no longer touch the player's saves or leave the game paused without failing. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 400: Movement.
