# Pass 327: every option in the leak check

Category: Stability (last pass 319).

## Audit

- **Passes 320 to 326.** The suite stays clean of engine errors, and pass 319's soaks alternate shield and dagger rooms. Pass 326 added one new `.wav`, which is imported.
- **The mercy assist (pass 325).** It saves, loads and resets with the other options. A file from an older build has no `[assist]` section; it loads mercy off with no engine error, because the loader's default is a bool, not null.
- **The gap: the runner's leak check named each option by hand.** Pass 325 had to add `Settings.mercy` to that list. An option added later without that edit would leak from one test into the next unseen, the very failure pass 231 built the check to stop. Nothing tied the list to the options that exist.

## Fix

- `Settings.snapshot()` returns every option by name. The runner records it after each clean slate, and `_leaks` compares against it, in place of the list kept by hand.
- Test: `test_every_option_is_in_the_snapshot` (test_systems.gd). It reads `settings.gd`'s static vars (all but `path`) and requires each to be in the snapshot. It then flips each option in turn and checks that it counts as a leak and that putting it back clears it. Finally it loads a file without `[assist]`, and one with `mercy=5`: mercy is off both times, with no engine error. As a mutation check, dropping mercy from the snapshot fails it by name.
- Bible 15: a bullet after pass 231's clean slate.

There is no visual change, so there is no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged score: the leak check now covers every option by construction. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 328 takes Movement (last pass 320).
