# Pass 425: a spring by the buttons

## Category

Faithfulness (last pass 417).

## Audit

The original's touches already answering the real controller: the shops (pass 402), the King's gold and the Guru's rest and mantra (pass 404), the card doors (pass 417) and the dwarves' lift (pass 419). The World Tree's springs, which stand in for the original's fountains and drive the whole quest, were still proven only by a scripted Up, which lasts one step. A real Up is held for many steps, and a spring that needs its guardian beaten has a refusal of its own.

## Fix

`test_a_spring_answers_the_real_controller` (test_boss) presses the real Up at the Spring of Mist:

- while Zorugeriru lives, Up does nothing: no flag, no banner, no chime;
- once he is beaten, Up pressed in the air and held to the landing does not restore it;
- one tap on the ground restores it, fills a third of the Eolis fountain, and shows one banner with the chime;
- Up again announces nothing more.

Bible 4.4's Spring of Mist row gains "A spring by the buttons (pass 425)".

Mutation: reading Up as held rather than pressed (`up_pressed = up` in player_input.gd) fails the held-to-the-landing check.

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
| Faithfulness | 5 | 99 | Score unchanged. The springs answer the real controller. |

Weighted: 96.8625.

## Next

Pass 426: Combat.
