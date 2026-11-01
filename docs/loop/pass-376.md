# Pass 376: swimming keeps the land's moves (Movement)

Category: Movement feel (last pass 368).

## Audit

Passes 369 to 375 changed no movement number. Pass 371 put the two new set pieces in the Sunken Spring's deep water, where the hero swims. The Spring Gate shaft and the Drowned Aqueduct are mostly water, so swimming is how most of the zone is played.

Bible 6.8 makes promises about swimming that tests already held: the float, the sink, the stroke, the slower swim across, the jump out, and the bob's coyote time. Its "Attacks, dash" row was never held. It says they "work as on land; the dash ignores the water". The "Jump out" row also says the water hands back the double jump and the air dash, and no test held that either. A dash slowed by the swim multiplier or floated by the water, or a refresh lost, would have passed every test. Reading the controller also turned up something the row didn't say: the Thrust's charge (bible 9) is dropped while swimming (`_try_thrust`, since pass 149).

## Fix

- The probe found the controller already keeps these promises, so no code changed.
- Bible 6.8's row now gives the dash under water (the land's 380 px/s for 0.15 s, on a level line). It also names the one land move the water takes, the Thrust's charge: a lunge along a floor that a swimmer has not got.
- `test_swimming_keeps_the_lands_moves` (test_movement) checks, in a pool:
  - a spent double jump and air dash come back;
  - a dash under water runs at the land's dash speed and holds its line within a pixel;
  - the dash carries the land's distance;
  - a swing cuts a training dummy in the water;
  - holding Attack does not charge a Thrust;
  - 6.8 names the test.

Mutation checks:
- Without the refresh, 4 checks failed.
- With the swim drift and slowdown applied to the dash, 3 checks failed: the speed, the line and the distance.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. Swimming's "work as on land" is held, and the Thrust's exception is written. |
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

Pass 377: Faithfulness.
