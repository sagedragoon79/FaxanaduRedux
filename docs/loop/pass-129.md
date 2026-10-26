# Pass 129: no errors in the log

Stability (97, weight 5) was the lowest category apart from Art. I read the whole log of pass 128's full run and grouped every warning and error.

| Log line | Where from | Verdict |
| --- | --- | --- |
| Save "is not a save", "damaged; loaded its backup", "Could not write", JSON parse errors, "Exponent too high" | the save robustness tests, which damage files on purpose | expected |
| ConfigFile parse error in `test_settings.cfg` | the damaged-settings test, on purpose | expected |
| **"Couldn't find the given section "keys" and key …", 50 lines** | `Settings.load_settings` read each rebindable action with a `null` default. Godot treats a null default as no default, so every action the file lacks logged an engine error. A player whose `settings.cfg` came from an older build, before some actions existed, would get these in their log on every start. | **fixed** |
| **"Lambda capture at index 0 was freed"** | a Shadow Eura test waited on a lambda that held the false shadow after it was freed | **fixed** |

Ladders, card doors and the map's lock marks, the Spire Sentinel, the dissolve and the map sounds logged nothing.

## As built

- **`Settings.load_settings`:** reads each key with a default of 0, which it already treats as unbound. An older file now loads silently, with the actions it lacks on their default keys.
- **`ErrorCatcher` (`tests/error_catcher.gd`):** a `Logger` a test can start and stop around a moment. It returns every engine error logged in between, so a test can check that the moment logs nothing. The new test also checks that the catcher sees a real engine error, so its clean result means something.
- **The Shadow Eura test:** now waits on a weak reference.

## Tests

In `test_systems.gd`, `test_older_settings_load_without_errors`:
- a file with only a shake level and a jump key loads with no engine errors;
- what it holds is kept;
- the newer actions keep their defaults;
- the catcher hears a deliberate engine error.

## Bible

Section 15.3, the save and settings robustness list: "Older files (pass 129)", and the `ErrorCatcher` helper.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Every error left in the full run's log is one a test makes on purpose. Older settings files load silently, and tests can now assert that a moment logs no errors. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2468 checks, all passing. The only engine errors left in its log are ones tests make on purpose (damaged saves and settings, and the catcher's own probe).

Weighted score: 95.5875 (up from 95.5625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement and World (97.25) are now the lowest apart from Art, along with Faithfulness. Movement weighs the most, so pass 130 takes Movement.
