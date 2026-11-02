# Pass 401: the Guru recites the mantra

## Category

Faithfulness (last pass 393).

## Audit

- Passes 394 to 400 added no new game text that names the original. Their new shrines and tests use the remake's own words, and `test_the_rename_list_finds_every_name_it_keeps` passes.
- `test_the_faithfulness_checklist_is_all_here` still covers the original's main beats:
  - the eight towns, each with a Guru;
  - the sixteen ranks and the four rings;
  - the card keys and the Joker Key;
  - the three springs and the nine guardians;
  - the five spells, the relics, and the sword King Grieve swallowed.
- The gap is the one place the original's password survives. Bible 11 says the Guru recites the old password as a mantra when you rest with him: "Your mantra is...". `test_the_guru_gives_a_mantra_for_the_journey` only checked `GameState.mantra()`, the string itself. It never rested with a Guru. If the Guru's rest saved quietly, the way a shrine's does, the original's best-known Guru line would be gone and no test would fail.

## Fix

`test_the_guru_gives_a_mantra_for_the_journey` (test_economy.gd) now goes through the Guru's rest:
- Resting with a Guru shows "Rested. Your mantra is: " followed by the saved journey's mantra, and the save is written to the test's own slot 9.
- Resting at a shrine saves without a mantra, so the mantra stays the Guru's.

Bible 11's Easter egg line says so.

Mutation check: when the Guru's rest shows the shrine's "Rested. Progress saved." instead, the test fails.

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
| Faithfulness | 5 | 99 | Score unchanged. A test now holds that the Guru recites the mantra. |

Weighted: 96.8625.

## Next

Pass 402: Combat.
