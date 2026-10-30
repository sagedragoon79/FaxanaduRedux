# Pass 282: spikes cost a mask, and casts wait their cooldown

Category: Combat (last pass 274).

## Audit

Bible 5.3's "Starting combat values" table is held row by row by `test_the_starting_combat_values_match_bible_5_3`. I read every `@export` in `combat_tuning.gd` against that table and the tests:
- **Two tuning values have neither a row nor a check:**
  - `hazard_damage` (20): what a spike or thorn costs.
  - `cast_cooldown` (0.35 s): the wait between spells.

  No test named either one or played the cooldown. So a change to either would pass unseen, and the bible did not say what spikes cost.
- **Drops have no row either:** pass 281's great loaf (40) and bread (15).

The Naga's coil and loaf (passes 275 and 281), the guardians' tell cues (278) and the ladder rule (280) already have their own tests.

## Fix

- **Bible 5.3, three new rows:**
  - Spikes and thorns: 20 damage (one mask) before armor, and you are set back on the last safe ground.
  - Casting: 0.35 s between casts. A press made sooner casts nothing and isn't saved.
  - Bread and great loaf: +15 and +40 HP.
- **The table test** now checks all three, and that 20 is a mask (`GameHud.MASK_HP`).
- **New play test** `test_spikes_cost_a_mask_and_casts_wait_their_cooldown` (`test_combat.gd`):
  - A spike costs exactly 20 and sets you back where you last stood safe.
  - A cast spends its MP.
  - A second press inside 0.35 s casts nothing, and isn't saved for later.
  - Once the cooldown is over, it casts again.
- Mutation check: with the cooldown never set after a cast, the test fails on both early-press checks.
- No game code changed.
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the spike and cast numbers are now in the bible's table and held to it. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 283 takes World (last pass 275).
