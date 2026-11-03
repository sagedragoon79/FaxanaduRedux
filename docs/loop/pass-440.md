# Pass 440: a press made with the Up that reads a sign

## Category

Movement (last audited in pass 432).

## Audit

Pass 434 found a Thrust's charge carried across a pause or a hold. The same question applies to the
move buffers (6.7): Jump, Dash, Attack and Throw wait up to 0.12 to 0.15 s for their moment. Up opens
a sign, a shop or an inner door, and the buffers are filled earlier in the same step than Up is read.

## Bug found

Up and Jump (or Attack, or Dash) pressed in one frame at a sign read it, and the other press sat in its
buffer. The buffers don't run down while the game is paused or the hero is held, so when the sign was
put away the hero leapt, swung or dashed with no press of their own. The same happened leaving a shop
and arriving through an inner door. Pass 431 dropped the press that puts a sign away, but not one
buffered as it opened.

## Fix

`Player.forget_buffers()` drops all four buffers (set-backs did this inline since pass 296 and now call
it). Setting `frozen` forgets them as the hold begins, since a hold may end before any step runs (an
instant door in the tests), and the first step after a pause forgets them, as it already drops presses
(pass 430). `test_a_press_made_with_the_up_that_reads_a_sign_is_dropped` (tests/test_rooms.gd) presses
Up with Jump, Attack and Dash at a tablet, Up with Jump at the arms dealer, and Up with Jump and Attack
at an inner door, all with the real controller: nothing fires afterwards, and a fresh press is the
hero's. Bible 6.7 gains "A press made with the Up that reads a sign is dropped (pass 440)".

Mutation check: without the forget on freezing, the door cases fail; without it after a pause, the
shop case fails.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. A real bug fixed: no move fires on its own after a sign, a shop or a door. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 441: Faithfulness.
