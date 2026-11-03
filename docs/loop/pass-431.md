# Pass 431: a sign put away with the buttons

## Category

Stability (last pass 423).

## Audit

Passes 429 and 430 found presses read twice: the Jump that takes a journey up from the title, and the button that closes a pausing menu. Both were fixed in the hero's first step back: on waking, and after steps missed while paused. Other screens take the same buttons:

- **The map, shops and the Guru** pause the game, so the pass 430 fix covers them.
- **The dialog box** for signs and people is different. It does not pause the game; it freezes the hero, so no steps are missed. Its buttons are Jump, Attack and Up.
- **Deaths** hold the hero the same way, still and stepping.

## Bug found

`test_a_sign_is_read_and_put_away_with_the_buttons` reads a tablet with a real Up and puts the box away with each of its buttons, held. The box reads the press in the frame it is made, and the hero's first unfrozen step read it again:

- Jump jumped (heard as `jump`).
- Attack swung (heard as `slash`).
- Up read the sign straight back open, so a one-page sign could not be put away with Up at all.

## Fix

- The hero drops the presses of their first step after being frozen or dead (`Player._held_still`), as on waking and after a pause. Held buttons stay held. Scripted intents are untouched.
- The test puts the box away with each of Jump, Attack and Up, held. Each time the box goes and stays away, and the hero does not move or make a sound. A fresh Up reads the sign again.
- Bible 14's Testing line gains "A sign put away with the buttons (pass 431)".

Mutation: without the frozen-step drop, the test fails 5 checks: the jump, the swing and the sign that reopens.

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
| Stability and performance | 5 | 99 | Score unchanged. A real bug fixed: a sign put away with Up no longer reopens, and Jump or Attack no longer jump or swing. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 432: Movement.
