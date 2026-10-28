# Pass 231: a clean slate for every test

Stability's last pass (223) was the oldest apart from Art, so pass 231 takes Stability. Since passes 228 and 230 leaned on global state (`TimeStop`, the glass cues), I audited what every test leaves behind for the next one: the game's statics (options, stopped time, trials, the boss rush, forced poses, drop odds, feel switches).

| Check | Finding | Verdict |
| --- | --- | --- |
| Frame budgets, engine errors, missing sounds | Held by the room-budget test (166), the error catcher (215) and the missing-sound check (207). All green. | fine |
| TimeStop between tests | `Player._ready` resets it, and no test left time stopped. | fine |
| **Statics left changed** | A report-only probe over the full suite found 7 tests leaving state changed. The root was `test_the_game_plays_the_secret_ending_for_a_flawless_run`: it starts the real game, which loads and applies the options, and never put them back. The six save tests after it ran with rumble on and the options pointed at a test file, until a later test happened to restore them. | **fixed** |
| **The player's options file** | The suite's `_restore` set `Settings.path` back to `Settings.PATH`, which is the player's real `user://settings.cfg`. Any later test that saved options without pointing them elsewhere first would have overwritten the player's settings. | **fixed** |

## As built

- `test_runner.gd`:
  - `_clean_slate()` puts the options back to their defaults (pointed at `TestSuite.SETTINGS_PATH`), turns off hitstop, rumble, sound and random drops, and clears stopped time, a trial, a rush and a forced pose. It runs at start and after every test.
  - `_leaks()` lists anything a test left changed, and the test fails on it ("left global state changed").
  - The test options file is deleted at the end of the run.
- `test_systems.gd`: the secret-ending test calls `_restore()`, and `_restore` points the options at the tests' file, not the player's.
- `test_every_test_starts_from_a_clean_slate` (new) checks that the options file is the tests' own, that the slate is clean, and that a changed option or stopped time counts as a leak and is wiped.
- Mutation check: without the secret-ending test's `_restore()`, it fails with "left global state changed: settings changed, feel or volume changed".
- `CLAUDE.md` (Settings line) and bible 15.3 (the stability notes) are updated.
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
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: test isolation is now enforced, not assumed. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 232 takes Movement (last pass 224, now the oldest).
