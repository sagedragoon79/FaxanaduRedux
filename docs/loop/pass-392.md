# Pass 392: held buttons, through the real controller (Movement)

Category: Movement feel (last pass 384).

## Audit

- Passes 385 to 391 changed no movement number. `movement_tuning.gd` still matches section 6, which its tests hold.
- The Windloft veil (388) is the Stride's existing veil, and its pass through is already tested in `test_abilities.gd`.
- Pass 384 timed every move through `Input` itself, but only by its press. `PlayerInput.poll` also reads two buttons as held: `jump_held` (the jump cut, the apex hang, the held pogo bounce, the Feather Fall) and `down` (the fast fall, the look down). Every test of those scripted the intent, so a bug that read a hold as a press would have passed the suite. 6.7's Input line ("every action responds on the same frame it is pressed") says nothing of a release.

## Fix

`test_every_held_button_answers_on_its_frame` (`test_movement.gd`) holds and lets go of Jump and Down through `Input`:
- a release on the way up cuts the rise to 0.45 in the step it is made;
- a tap, pressed and let go at once, hops 10 to 26 px;
- Jump held over the top hangs at half gravity while |vy| is under 40 px/s;
- Down held falls at 620 px/s, and once let go the fall drops back to 520 px/s in that step.

Bible 6.7's Input line gains "Held and let go, too (pass 392)", and the test checks that line names it.

Mutation checks:
- `jump_held` read as just pressed: 3 checks fail (the hold, the cut, the hang).
- `down` read as just pressed: 2 checks fail (the fast fall and the release).

Full suite: 7080 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. The held and released buttons are timed through the real controller. |
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

Pass 393: Faithfulness.
