# Pass 215: an engine error fails its test

Stability's last pass (207) was the oldest apart from Art, so pass 215 takes Stability. I audited the suite's log, saves and CI against passes 208 to 214.

| Check | Finding | Verdict |
| --- | --- | --- |
| CI (214) | The new `mix` job and `test` both pass on main. | fine |
| Saves (213) | The moved-pickup carry-over goes through `sanitize`, which every load uses. | fine |
| Missing sounds (207) | The runner fails any test that plays a sound with no file. | fine |
| **Engine errors in the suite log** | The last full run logged 11 engine ERROR lines and no test failed. Most were deliberate: damaged saves and settings files. One was not: `Lambda capture at index 0 was freed`, from a wait in `test_fire_burns_the_captains_bark_off_at_once` that captured a fireball after it was freed. Nothing separated deliberate errors from real ones, so a new one would pass unnoticed. Pass 207 gave sounds this guard; engine errors had none. | **built: the runner fails a test that logs one** |
| Damaged saves | Loading one logged Godot's "Parse JSON failed" ERROR into the player's log ahead of the game's own warning. | **parsed quietly now** |

## As built

- `tests/test_runner.gd` starts an `ErrorCatcher` (errors only, not warnings) around every test. Any error caught fails the test with the first four messages, unless the test called `expect_engine_errors()` (new, in `TestSuite`).
- `ErrorCatcher.start(with_warnings := true)` can now ignore warnings. Its existing callers still catch both.
- Only two tests opt out:
  - `test_damaged_settings_fall_back_to_defaults_or_their_backup`, because Godot's ConfigFile parser logs its own error for a damaged file;
  - `test_older_settings_load_without_errors`, because of the probe at its end that proves the catcher hears errors.
- `GameState.load_game` parses with `JSON.new().parse`, so a damaged save logs only the game's warning. The two damaged-save tests now pass under the guard without opting out, and that is their check.
- Two waits in `test_boss.gd` now hold the fireball and the Shadow Bolt by `weakref`. Only the fireball's had fired; the bolt's was the same latent bug.
- Mutation check: putting back the fireball wait that captured the node fails its test with "logged engine errors: [call: Lambda capture at index 0 was freed ...]".
- Bible 15, "Saves and settings": a "No engine errors" line.
- Noted for a later pass: a compile error in a test file leaves the runner hung until `TEST_TIMEOUT`, instead of failing at once. I hit this while writing the pass.

Full suite: 4039 of 4039 checks passed, with no script errors and, now enforced, no unexpected engine errors.

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
| Stability and performance | 5 | 99 | Unchanged score: every test now fails on an engine error it did not expect, and a damaged save no longer prints an engine error. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 216 takes Movement (last pass 208, now the oldest).
