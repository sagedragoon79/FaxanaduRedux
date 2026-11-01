# Pass 351: Stability

## Audit

Stability last had a pass at 335. Since then, passes 344 to 350 added the three save flasks on the title (`SlotPicker`, `GameState.read_slot`, `slot_time`) and their sounds. The audit fed hostile saves through `sanitize` and the shelf's `summary` and `details`: flags of a string, a number, a list and null; gold in the millions; play time of a trillion seconds; a rank of 99; strings where numbers belong; a save room that is not a room.

Two faults turned up:

- **A flag of "yes" broke the flask.** `sanitize` kept every entry of `flags` (and of the other yes-or-no maps) as it came, and the shelf counts springs with `bool()`, which stops with a script error on a string or null. The summary never returned, so the flask read as empty. Taking it up then began a new journey in that slot, which overwrites the old one on its first rest. The game reads the same maps with `bool()` everywhere (`GameState.flag`, `has`, Trials, the dresser), so the same save would have errored in play too.
- **A million gold read as "1000,000".** The shelf grouped only the last three digits.

Everything else held: numbers came back finite and not negative, the rank was clamped, unknown rooms read "somewhere forgotten", and a damaged file read as an empty flask, as pass 343's tests ask.

## Fix

- `GameState.BOOL_MAPS` names the maps the game reads as yes or no: abilities, flags, charts, collected and visited. `sanitize` keeps only true and false in each. An ability with a damaged value had already fallen back to false through `_coerce`; an unknown key with a non-bool value is now dropped as well.
- `SlotPicker.grouped(n)` writes any whole number with a comma between each three digits.
- Bible 15.3, Sanitizing, gains the rule.
- `test_a_hand_edited_save_still_fills_its_flask` writes such a save, reads it back, checks that every entry of every yes-or-no map is a bool, and checks that the flask is full, tells its journey (with "1,234,567 gold" and one spring), and that taking it up continues it. It also checks the grouping from 0 to a million and a negative number.

Mutation: with the filter in `sanitize` turned off, the test fails 15 checks (the script error and every map check).

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
| Stability and performance | 5 | 99 | Unchanged score. A hand-edited save can no longer turn a full flask into an empty one. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 352 takes Movement (last pass 344).
