# Pass 346: every combat number in its own row

Category: Combat (last pass 338).

## Audit

- **Passes 339 to 345** changed one thing in combat: the Elixir now refills magic (pass 345), and its test holds that. Every foe's numbers (pass 338) and every guardian's (pass 340) are held in tables.
- **Bible 5.3 against `combat_tuning.gd`.** `test_every_combat_number_is_written_in_bible_5_3` (pass 330) checks that each tuning number appears somewhere in 5.3. It uses `written_in`, which rounds any number under 100 to a whole one. So 0.09 counts as found wherever a "0" stands alone, and 1.35 wherever a "1" does. Read strictly, six numbers were **written nowhere in 5.3** and passed anyway:
  - the five hit-stops: `hit_hitstop` 0.05, `heavy_hitstop` 0.09, `kill_hitstop` 0.08, `death_hitstop` 0.35, and `hurt_hitstop` 0.15, which was matched only through prose;
  - Executioner's `executioner_mult` 1.35;
  - `respawn_delay` 1.2 s.
  The hit-stops are written in 6.7 and Executioner's number in 9, but 5.3's table claims to list the starting combat values, and it did not have them.

## Fix

- Bible 5.3 gains two rows. **Hit-stop (6.7)** gives 50, 90, 80, 150 and 350 ms. **Executioner (skill, 9)** gives x1.35. The **Death (5.4)** row now says you rise at the last rest 1.2 s after you fall. A sentence after "Starting combat values" names the new test and what the old reading let through.
- `TestSuite.written_exactly_in` is the strict reading pass 344 used for movement, now shared by both tests. It finds a number only as itself or its ms or % form, never rounded.
- Test: `test_every_combat_number_is_written_in_its_own_row` (test_combat.gd) maps each tuning number to the 5.3 row or move bullet that writes it, and reads it there strictly. It also checks that every tuning number has a home and that the strict reading takes no rounded form.
- Mutation check: changing the heavy hit-stop row to 95 ms and dropping the 1.2 s fails the new test (`heavy_hitstop 0.09 not in | Hit-stop (6.7) |`, `respawn_delay 1.2 not in | Death (5.4) |`). The old test still passes under the same mutation.

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. Every combat number is now in its own row of 5.3 and held there exactly. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 347 takes World (last pass 339). The same rounding still runs in `written_in` wherever other tests use it. A later pass could move those tests to the strict reading.
