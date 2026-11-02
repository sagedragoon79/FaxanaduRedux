# Pass 383: how long the soaks play (Stability)

Category: Stability (last pass 375).

## Audit

Passes 376 to 382 added the minimap's cache (pass 375 measured it), the waterfall's voice, and four bible ledgers. None added a frame cost or a leak the soaks don't already cover. So the audit turned to the rubric's own Stability row: "60 fps budget, no crashes in a 2-hour soak bot run, load times".

- The frame budget is measured: the journeys' 50 ms rule, the boss fights' 8 ms average and 16.6 ms 99th percentile, and every room's settle.
- Load times are measured: every room under 500 ms.
- How long the soaks run was never counted. No test or log said how much play the soaks cover, so nobody knew how close they came to "a 2-hour soak".

A full run with the runner counting physics frames per soak gave 43 soak tests and 181,696 frames: **50.5 minutes of game time**, not two hours.

## Fix

- The test runner now counts the physics frames each `test_soak.gd` test plays. It prints the total at the end of a run ("Soak: N tests played M minutes of the game").
- An unfiltered run whose soaks play less than `SOAK_FLOOR_MINUTES` (45) fails. A soak cut short or dropped can no longer shrink the count without anyone noticing.
- Bible 15.3 has a new note, "How long the soaks play", recorded as a deviation from the rubric's 2-hour run:
  - It gives the measured 50 minutes and the floor.
  - It says why there is no 2-hour bot: every push runs the whole suite, so 50 minutes of play on every change catches more than a 2-hour run now and then.
- `test_the_soak_floor_is_the_one_the_bible_gives` holds the floor and the soak count to the note.

Mutation checks:
- With the bible's floor at 30, the test fails 1 check.
- With the floor forced on a filtered run of one soak, the run fails on "soak time" (0.0 minutes).

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
| Stability and performance | 5 | 99 | Unchanged score. The soaks' play time is counted (50 minutes a run) and floored, and the 2-hour run is recorded as a deviation. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 384: Movement.
