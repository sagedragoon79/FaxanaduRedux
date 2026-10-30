# Pass 276: the openings table, held to the fights

Category: Bosses (last pass 268).

## Audit

I checked the guardians against bible 8:
- **Summons and broods:** none outlives its master. Pass 266 covered the Bloom, the Matriarch and the Alpha, pass 271 the King's guard, and the Heart clears its seeds, spikes and beams.
- **Phase-quickened tells:** held to the minimum by pass 234's test.
- **Kills and reveals:** every guardian has a cinematic kill, a reveal and a dying window.

Then the stagger windows. Bible 8's openings table (pass 163) names each guardian's opening, which Executioner and Bloodletting read through `punishable()`. The only test reads each script for a `punishable` function; nothing checks that the windows the table names actually open in a fight. I started every guardian in its own arena, let it wake, and sent it reeling as a parry does (`stagger()`):
- The Bark Knight Captain, the Matriarch, the Alpha, King Grieve, Shadow Eura, the Evil One's avatar and the Drowned Warden all stood open, as their rows say.
- **The Foreman did not.** Its row said "stunned, or reeling from a parry", and `Foreman.punishable()` read `stunned() or is_staggered()`. But its `stagger()` does nothing ("Rock never staggers from a parry"), and none of its blows can be parried. So the second half of its window never existed, and the table had promised Executioner and Bloodletting a window that was never there.

## Fix

- Bible 8's table: the Foreman's opening is "stunned against a wall (rock never reels from a parry: none of its blows can be parried, pass 276)". A paragraph under the table explains the change and names the test.
- `Foreman.punishable()` is now `stunned()`, without the branch that could never be true. Its comment says why.
- New test `test_every_opening_the_table_names_a_parry_for_opens_on_a_parry` (test_boss). It reads the table from the bible and checks it has at least 15 rows. Every row that names a parry must be mapped to a guardian. Each such guardian is started in its own arena, checked shut while on its guard, then sent reeling, and must stand open. The Foreman's row is the exception, and it must stay shut. Had the Foreman's row kept its old wording, the test would expect it to open and fail.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the openings table now matches the fights, and a test holds it. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 277 takes Systems (last pass 269).
