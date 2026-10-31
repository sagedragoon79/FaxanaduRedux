# Pass 348: every guardian falls within the bible's dying window

Category: Bosses (last pass 340).

## Audit

- **Passes 341 to 347** changed no guardian. These section 8 checks already pass on main:
  - each guardian's numbers (pass 340);
  - each Reward line (pass 332);
  - the openings table and its parries (pass 276).
- **The dying window was not held.** "A won fight stays won (pass 239)" says a guardian "dies in a dying window of 1.2 to 2.5 s (the slow-mo, flash and shatter) before its arena opens". No test timed a fall. Each script keeps its own `DYING_TIME`, from 1.2 to 2.5 s across fifteen scripts. Rokusutahn has none: his 26 segments shatter one by one, which takes about 2.1 s. A new guardian, or a changed `DYING_TIME`, could fall outside the range with nothing to catch it.
- **What the range measures.** The bible did not say game seconds. The kill's 350 ms freeze and its slow motion (6.7, `Feel.boss_kill`) run on the wall clock, so to the eye the window is longer than its game time.

## Fix

- Test: `test_every_guardian_falls_within_the_bibles_dying_window` (test_boss.gd). It fells each of the 16 guardians in its own arena (`die()`, or Rokusutahn's `_die()`). It times the fall from the killing blow to `defeated`, in game seconds (each frame's scaled delta). It checks that every guardian falls in 1 to 2.7 s. It also checks that the bible's range is the shortest and longest as played, to a tenth: 1.2 s (the Foreman) and 2.5 s (the Evil One's heart).
- Bible 8: the paragraph says the range is in game seconds and that the freeze and slow motion stretch it to the eye. It names the quickest and slowest guardian, Rokusutahn's case, and the test.
- Mutation check: a Foreman with `DYING_TIME` 1.0 fails the test (range 1.0 to 2.5).

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. Every guardian's fall is timed and held to the bible. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 349 takes Systems (last pass 343).
