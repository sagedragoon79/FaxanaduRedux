# Pass 456: the rise, by the buttons

## Category

Movement (last audited in pass 448).

## Audit

Passes 449, 452 and 455 worked on deaths and rests, but the hero's movement through a rise had only
been driven by scripted intents. A probe let the hero die swimming, on a ladder, mid-swing, mid-thrust,
in a knockback and mid-drink, then rise. Every state was cleared (`teleport` and `_respawn`), the hero
stood still, and a scripted Right walked him on. Not yet proven: the real controller across the rise.
A player falls holding a direction and often keeps holding it, presses Jump the moment they can, and
relies on the rise's 1.0 s of i-frames.

## Bug found

None.

## Fix

`test_the_rise_answers_the_real_controller` (tests/test_rooms.gd) falls with the real Right held. It
moves nothing while the hero lies dead. Once he rises at the shrine, the same held Right, never pressed
again, walks him on at a run. A real Jump in the first step after a rise jumps. Spikes touched at once
do no harm for the rise's 1.0 s, and then they do. Bible 5.4 gains "The rise, by the buttons
(pass 456)".

Mutation check: a rise with no i-frames fails the test ("spikes touched in the rise's first half second
do no harm (80)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. The rise is proved with the buttons. |
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

Pass 457: Faithfulness.
