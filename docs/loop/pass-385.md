# Pass 385: the rename list (Faithfulness)

Category: Faithfulness (last pass 377).

## Audit

Passes 378 to 384 added no place, person or item, and 3.2's ledgers still match the game (pass 377's test). The audit read the bible's claims about the original that no test reads. One near the top was plainly untrue: bible 1's IP note said that for a public release "we rename people and places in one pass (all names live in a single localization table to make that trivial)". No such table was ever built. The original's names are written into dialog, signs, room files and code: Eolis alone is in 25 files. A rename would have had to start by finding out which names were the original's, and the bible gave no list.

Building a real localization table would mean pulling every line of dialog out of the rooms and NPC data. That is a large refactor for a release Sean has not asked for. What the note actually needs is the list, and proof that the list is whole.

## Fix

- `data/original_names.json` is the rename list: the original's 74 names the remake keeps. It holds the title, 13 places, King Grieve, the nine guardians, 29 things (rings, keys, the original's arms and armor, the tools and potions), the five spells and the sixteen ranks.
- `test_the_rename_list_finds_every_name_it_keeps` (test_rooms) checks that:
  - every name on the list is written in the game's own text (data, levels and scripts) as a whole word. It also prints how many files hold each name: 182 files in all;
  - every zone 3.2's ledger marks as the original's has a listed place in its name;
  - every guardian the ledger marks as the original's is on the list, and there are nine of them;
  - every spell in `Spells.DATA` is on the list;
  - the list's ranks are exactly `GameState.RANKS`, in order;
  - bible 1's note names the list and its count.
- Bible 1's IP note now points at the list, says how many names it holds and where they are written, and records that the single table was never built.

Mutation check: a list missing Borabohra fails the guardian check, and a name the game never writes ("Frostbite") fails the written check.

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
| Faithfulness | 5 | 99 | Unchanged score. The original's names are listed and found, and the IP note no longer promises a table that doesn't exist. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 386: Combat.
