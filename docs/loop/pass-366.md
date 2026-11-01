# Pass 366: a menu that says no (Audio)

Category: Audio (last pass 358).

## Audit

Passes 359 to 365 added one cue, in pass 365's pad rebinding: a pad button the Controls page keeps played `fizzle`. That led back to an older borrowing. `fizzle` is the spell-fail sound, the one bible 13.3 took off the locks (pass 122) and the wards (pass 358) because a refusal is not a spell gone wrong. Every menu still used it:

- `ListMenu.confirm` on a row you can't choose: a ware you can't afford, an Ointment you don't have, a skill out of reach. This is the most common refusal in the game; every shop visit can make it.
- The map with all 12 pins down.
- The Controls page refusing a pad button (pass 365).

So a shop that said no sounded like a cast short of MP.

## Fix

- A new cue, `menu_refuse` (`sfxgen.py`): the cursor's square blip, lower and dull, twice, falling a fourth from 330 to 247 Hz in 0.17 s. It peaks at -9.9 dBFS with -16.4 dB loudness, inside the mix check. It plays at -4 dB from all three places. `fizzle` is left to the hero's spells and the Hour Glass.
- Bible 13.3: the count goes from 164 to 165 sound effects, with the note "**A menu that says no (pass 366):**".
- `test_a_menu_says_no_in_its_own_voice` checks four things:
  - a disabled row refuses with `menu_refuse` and no fizzle;
  - the Controls page refusing LS does the same;
  - only `player.gd` still plays `fizzle`;
  - the bible tells it.
- The map pin test now expects `menu_refuse`.

Mutation: with `ListMenu` back on `fizzle`, the test fails 2 checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. Menus no longer refuse with the spell-fail sound. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 367: Stability. Trace the soak's frame bursts in full runs (`test_a_journey_after_the_end_stays_lean`, passes 359 and 363).
