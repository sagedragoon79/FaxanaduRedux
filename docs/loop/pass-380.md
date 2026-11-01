# Pass 380: what a guardian pays (Bosses)

Category: Bosses (last pass 372).

## Audit

Passes 373 to 379 changed no guardian. Pass 377's ledger names each guardian's prize, and pass 378 wrote down what every foe pays. That left the same gap in section 8.

Pass 340's numbers table gives each guardian's health, phase marks and wind-ups, and its test holds them to the scripts. Nothing gave what a guardian pays. Each purse and its experience lived only in the scripts (`gold_min`, `gold_max`, `xp`, or Rokusutahn's `GOLD` and `XP`), yet two claims rest on them:

- 10.1's "A boss's purse (60 to 500 g)", which no test read;
- the ranks (9), where a guardian's experience is the biggest single step. Nothing said how far the guardians alone carry you. They give 5,190 in all, which falls short of Lord's 5,500.

## Fix

- Bible 8's numbers table has two new columns, Gold and XP, for all 16 rows.
- A new note, "What a guardian pays (pass 380)", gives these figures:
  - Rokusutahn's set purse of 120;
  - 4,090 XP from the original's nine guardians, 1,900 of it from the Evil One's three parts;
  - 1,100 XP from the remake's own five;
  - 5,190 in all, short of Lord, so the last titles are the foes' to give.
- `test_every_guardians_numbers_are_written_in_bible_8` now checks:
  - both columns against the scripts;
  - the note's three totals and that they fall short of Lord;
  - 10.1's purse range against the smallest and largest purse.

The first draft of the bible edit matched each guardian's name in the first table it found, and that was pass 377's ledger. The edit was undone there and made in the numbers table, and the ledger test still passes.

Mutation checks:
- With the Drowned Warden's experience at 2,000, the test fails 3 checks: the row, the total, and the shortfall from Lord.
- With the heart's purse at 480 at most, it fails 2 checks: the row and 10.1's range.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. What every guardian pays is written and held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 381: Systems.
