# Pass 465: a hidden room, found once

## Category

World (last audited in pass 459).

## Audit

Of the scheduled leads, a spring's restoration and the fountain (`test_a_spring_answers_the_real_controller`),
cracked stone (`test_cracked_stone_answers_the_real_controller`) and the doors (`test_the_doors_answer_the_real_controller`)
were already played with the real buttons. Hidden rooms were not. Every secret test counted covers or
set the flag, and none walked into one.

Reading `Room._physics_process` turned up the bug. The find's chime and flag are guarded by
`_secret_revealed`, a field of the room node, which a room change builds afresh. So every return to a
hidden room you had already found rang the find's chime again, as if it were new.

## Bug found

The `secret` chime rang every time a found hidden room was entered.

## Fix

`scripts/world/room.gd` now chimes (and sets `secret:<room>`) only when the journey has not found
that room yet. The cover still fades and returns as before.

`test_a_hidden_room_is_found_with_the_buttons` (tests/test_world.gd) builds a town with a `secret:`
cover and uses only real input:
- Right walks the hero into the cover: one chime, the flag kept, the cover faded.
- Left walks him out, and the wall stands again.
- Right in again: it fades, with no second chime.
- He leaves the room and comes back to a freshly built room, then walks in: it fades, with no chime.

A helper, `_walk_counting_chimes`, holds a direction and counts chimes frame by frame, because
footsteps fill the 32-entry sound log faster than the walk ends.

Bible 11 gains "A hidden room, found with the buttons (pass 465)".

Mutation check: without the fix, the return to the room chimes again and the test fails.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. A hidden room's find rings once, proved with the buttons. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 466: Bosses.
