# Pass 432: a press the player means is kept

## Category

Movement (last pass 424).

## Audit

Passes 429 to 431 stopped a press from being read twice. Each fix drops the presses of the hero's first step back, in three cases: on waking, after a pause, and after a freeze. This pass asked the opposite question: does any of them swallow a press the player meant?

Pass 431 dropped presses after any freeze or death, and not only after the dialog box. But a door's scroll and fade freeze the hero too, and so does dying, and no screen reads a press during those holds. A Jump pressed in the very frame the hold ends belongs to the player, who is waiting to act.

## Bug found

`test_a_jump_pressed_as_a_hold_ends_is_kept` (test_movement) ends each kind of hold and presses Jump in the same frame. It presses during a frame's process step, which is where a real hold ends (a door's scroll is awaited there). Against pass 431's code, both jumps were swallowed:

- Jump pressed as a door's freeze let go did nothing.
- Jump pressed the moment the hero rose after a death did nothing.

## Fix

- The drop is now asked for by the screen that read the press. The dialog box sets `Player.drop_next_presses` as it closes, and the hero's next step drops its presses.
- A door's hold and dying no longer drop anything. Pass 429's waking drop and pass 430's after-a-pause drop are unchanged, since a screen always read those presses.
- The test ends a door's freeze and a respawn, presses Jump in the same frame, and the hero jumps both times. Pass 431's sign test still passes: the box keeps its press.
- Bible 6.7 gains "A press the player means is kept (pass 432)". The pass 431 line in 14 now names the explicit drop.

Mutation: restoring pass 431's drop on every freeze or death fails both jumps.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. A real regression fixed: a jump pressed as a door or a respawn lets go is kept. |
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

Pass 433: Faithfulness.
