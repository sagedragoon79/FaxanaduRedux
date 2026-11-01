# Pass 356: every guardian's kill flashes white (Bosses)

Category: Bosses (last pass 348).

## Audit

Bible 8 opens with what every boss has: "a pre-fight arena reveal, 2 or 3 phases, an ability it tests, a 'stagger' window, a cinematic kill (slow-mo, white flash, shatter), and a reward". Pass 348 held the kill's dying window for all sixteen guardians. This pass read the kill itself.

Every guardian calls `Feel.boss_kill` as it falls, which freezes for 350 ms and ramps out of slow motion. Only Rokusutahn also flashed the screen white (`GameState.flash.emit(1.0)`). The other fifteen fell without the white flash the bible promises, from the Foreman to the Evil One's heart.

## Fix

- `Feel.boss_kill` now throws the white flash itself (`Feel.BOSS_KILL_FLASH`, 1.0), through the same signal and the same flashes option (14) as every other flash. No guardian can now be written without it. Rokusutahn's own flash is gone, since it would only repeat this one. `zorugeriru.gd` is untouched and gets the flash through `Feel`.
- Bible 8: "The kill's white flash (pass 356)". Bible 6.7, Hit-stop: the boss kill's flash at 1.0 (`BOSS_KILL_FLASH`). This is the line pass 352's camera-numbers test asks for, and that test flagged the new constant until it had one.
- `test_every_guardian_falls_within_the_bibles_dying_window` also listens for the flash as each of the sixteen falls, and checks it reaches full strength.

Mutation: without the flash in `boss_kill`, all sixteen guardians fail the new check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. Every kill now has its white flash. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 357 takes Systems (last pass 349).
