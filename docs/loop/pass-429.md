# Pass 429: a journey taken up by the buttons

## Category

Systems (last pass 421).

## Audit

These systems already answered the real controller: a bare menu and the shelf of three flasks (pass 397), a shop (pass 402), the map (pass 405), and the pause menu in play (pass 421). Pass 359 walked the title's real path through the flasks, but it chose with `confirm()`. So no test had pressed the buttons from the title into a saved journey, which is the first thing a returning player does.

## Bug found

Writing that test found a bug. The Jump that takes a flask up is read by the shelf while the game is paused. The world is built in the same frame, and the hero's first physics step read the same press again, still "just pressed". It buffered a jump, and the hero jumped on the first landing: every journey taken up with Jump, saved or new, began with a jump the player never asked for.

## Fix

- A press already under way when the hero wakes is no longer the hero's. On their first physics step the hero drops this frame's presses (`PlayerInput.drop_presses`, which `end_frame` now shares for scripted intents). Held buttons stay held, and scripted intents are untouched.
- `test_a_journey_is_taken_up_with_the_buttons` (test_systems) runs the whole game from the title:
  - Jump on Journeys opens the shelf on the full flask.
  - Jump, held, takes the journey up: the middle flask's, with its 500 gold, in the West Gate where it rested.
  - The hero wakes standing where they rested and does not jump.
  - A fresh press after letting go does jump.
- Bible 14's Testing line gains "A journey taken up by the buttons (pass 429)".

Mutation: without the fix (the first-step drop removed), the new test fails. The hero rises from the second step and is 67 px up by the twentieth.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. A real bug fixed: taking a journey up with Jump no longer starts with a jump. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 430: Audio.
