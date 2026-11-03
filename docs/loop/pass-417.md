# Pass 417: a card door by the buttons

## Category

Faithfulness (last pass 409).

## Audit

The original's touches that answer a button are now pressed for real: the King's gold and the Guru's rest (409), a shop (413), doors between rooms (411). The items work on their own (the Elixir revives, poison ticks), so they need no button. One signature of the original was still walked only by a scripted intent: the card-key doors, which open when you walk into one holding its key. The "once per touch" rattle (pass 122) was held by a single lean, so nothing checked that stepping back and leaning again rattles again.

## Fix

- `test_a_card_door_answers_the_real_controller` (test_economy.gd), with Right held through `Input`:
  - A Queen door stops the hero holding only a Jack Key and rattles once however long he leans; the Jack Key is not spent.
  - Stepping back with Left and leaning again rattles again.
  - Given the Queen Key, the held Right opens it (key_turn, no rattle) and walks straight through; only the Queen Key is spent.
- Bible 4.5's key-door line gains "A card door by the buttons (pass 417)".

Mutation: never re-arming the latch when the hero steps away (`_told` kept true) fails only the new test (no second rattle).

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
| Faithfulness | 5 | 99 | Score unchanged. The card doors answer the real controller. |

Weighted: 96.8625.

## Next

Pass 418: Combat.
