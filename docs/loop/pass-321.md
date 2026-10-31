# Pass 321: the Red Potion says what it was

Category: Faithfulness (last pass 313).

## Audit

- **Passes 314 to 320.** None of them touched the original's rules. The guardians' openings (314), the hornet gallery (315), the dagger's reach (316), the old-save notice (317), Bloodletting's sound (318), the soaks (319) and the throw (320) are the remake's own.
- **The manual's items.** The Glove (the War Glove, timed), the Hour Glass, the Mattock, the sixteen ranks, the Mantra, Poison and Ointment (pass 305) and "food and money" (pass 297) each have their deviation note or match. **The Red Potion did not.** The manual says: "It will completely restore the hero's power." The remake's flask sips 40 HP a charge, and the bible never said that this strays from the original.
- **A stale row.** While checking, the flask's row in 5.1 said its most was "5 charges, heals 70 HP". Nothing raises the heal (`CombatTuning.flask_heal` 40 is read as is), and nine Potion Shards plus Deep Pockets make 6 charges.

## Fix

- Bible 5.1: a deviation paragraph quoting the manual's Red Potion and saying why the remake keeps a fixed sip (masks keep their meaning, a drink is a choice in a lull, the flask's growth rewards exploring), with the full restore kept at the Guru's rest and the Elixir. The flask's row now says 6 charges, each still 40 HP.
- Test: `test_the_faithfulness_checklist_is_all_here` (test_economy.gd) requires the quote, that a drink is less than even the starting 100 HP, and that the row names the flask's real most (charges from the fresh save, the shards and Deep Pockets; the heal from `CombatTuning`). Against the old bible it fails 2 checks.

No number changed, and nothing on screen changed, so there is no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the Red Potion's deviation is written down, and the flask's row is held to the code. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 322 takes Combat (last pass 314).
