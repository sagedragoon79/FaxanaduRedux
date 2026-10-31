# Pass 336: the fields that move you, in bible 6

Category: Movement (last pass 328).

## Audit

- **The tuning.** Since pass 328, `test_every_movement_number_is_written_in_bible_6` reads bible 6 for every number in `MovementTuning`, and pass 335's `TestSuite.written_in` ignores pass numbers. The ability play tests hold: wall jump, pogo, double jump, dash, swim, ladders, wind and sap.
- **Mercy (pass 325)** lengthens only the grace after a hit. Pass 320's throw test already holds that a throw leaves movement alone, and nothing in mercy touches movement.
- **Fields outside the tuning.** Five things change how you move from constants outside `MovementTuning`. None was in bible 6, and **no test held any of them to the bible**. Each test read its constant back (`GravityDrift.PULL` in the gravity test, for one), so a changed number moved its test with it.
  - Zenis's wrong gravity: 40% weight, written in 8.9.
  - The Bloom's falling leaf: 85% weight, in 8.5.
  - Borabohra's updraft: 240 px/s at 1,100 px/s², in 8.6, with the acceleration in no section at all.
  - The rise through a floor door: 430 px/s, in 3.3.
  - The big-drop thud: 112 px, written only as "7 tiles" in 6.7.

## Fix

- Bible 6.14, "Fields outside the tuning": a table of the five fields with their settings and constants.
- Test: `test_every_field_number_is_written_in_bible_6_14` (test_movement.gd) finds each constant's row and checks that the row writes its number.
- Mutation checks: `LeafFall.WEIGHT` 0.8 and `UPDRAFT_ACCEL` 1,200 each fail their rows.

No number changed and nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every number that moves you is now in bible 6 and held. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 337 takes Faithfulness (last pass 329).
