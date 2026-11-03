# Pass 427: cracked stone by the buttons

## Category

World (last pass 419).

## Audit

These world features already answer the real controller: the doors (pass 411), the shops (pass 402), the King and the Guru (pass 404), the card doors (pass 417), the lift (pass 419) and the springs (pass 425). Cracked stone holds a secret in every large zone (pass 135), but the three tests that break it all used a scripted intent that lasts one step. A real Attack can be held, and nothing showed that a held Attack does not break a wall once the Mattock arrives. Nothing showed that the down-strike breaks a floor when Down and Attack come from the buttons, either.

## Fix

`test_cracked_stone_answers_the_real_controller` (test_world) uses the real buttons on a cracked wall:

- Attack held with no Mattock leaves the wall whole and silent;
- gaining the Mattock with Attack still held breaks nothing;
- a fresh tap breaks it, and the break is heard.

It then does the same on a cracked floor:

- Down held alone lands on it and leaves it whole;
- Down held with a tap of Attack on the way down breaks it, and you fall through.

Bible 11 gains "Cracked stone by the buttons (pass 427)" after the cracked-stone caches.

Mutation: reading Attack as held rather than pressed in player_input.gd fails this test, and none of the other cracked-stone tests.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. Cracked stone answers the real controller. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 428: Bosses.
