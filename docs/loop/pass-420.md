# Pass 420: the Foreman's rock by the buttons

## Category

Bosses (last pass 412).

## Audit

The guardians answer the real controller in two places: the Root Chamber fought and won with `Input` (404) and King Grieve parried with real Block (412). Every other opening is driven by a scripted intent or by calling the boss's `take_hit` with a direction. The Foreman's rock, which halves every blow except one from above, was held only by `test_foreman_rock_halves_blows_unless_from_above` calling `take_hit` with `Vector2.RIGHT` and `Vector2(0, 1)`, and no pogo had ever landed on a guardian's head through the buttons. Every guardian's numbers still match bible 8 (`test_every_guardians_numbers_are_written_in_bible_8` passes).

## Fix

- `test_the_foremans_rock_answers_the_real_controller` (test_boss.gd), in the Foreman's hall, mid-floor clear of the ledges:
  - Attack pressed for real beside the Foreman: the rock halves the slash (4 of 8).
  - Down held and Attack pressed for real as the hero falls onto the helm: the pogo lands in full (8) and bounces him back up.
- Bible 8's Rock Golem entry gains "The rock by the buttons (pass 420)".

While writing it: a fresh journey (pass 415) has no Mattock, and the down-strike is the Mattock's, so the test gives it as a revisit would have it.

Mutation: making the rock halve blows from above as well fails the new test (the pogo lands 4 of 8).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A pogo lands on a guardian by the buttons. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 421: Systems.
