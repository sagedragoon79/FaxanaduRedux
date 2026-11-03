# Pass 411: doors by the buttons

## Category

World (last pass 403).

## Audit

- Reachability (`tests/test_reachability.gd`) holds every room's critical path, pickups and soft-locks.
- Every bible 3 promise names a test.
- The map marks every rest (pass 403), and a guardian's sealed doors were walked through with the real controller (pass 404).
- The gap is the plain doors. Every door test (side, floor and ceiling, inner, card) drove a scripted intent (`move_x`, `up_pressed`), and a scripted Up press lasts one step. A real Up is held for many steps. `PlayerInput` counts a held Up as one press, so a hero who arrives through an inner door with Up still down stays in the new room. That rule, the thing that stops a held Up from bouncing between two rooms, was never tested.

## Fix

`test_the_doors_answer_the_real_controller` (test_rooms.gd) plays the doors with `Input` alone:

- Holding Right walks through a side door into the next room, and holding Left walks back.
- Standing in an inner doorway does nothing.
- Pressing Up goes through.
- With Up still held, the hero stays in the new room for half a second.
- Letting go and pressing again goes back.

Bible 3.3's Camera line gains "Doors by the buttons (pass 411)".

Mutation check: when a held Up counts as a fresh press every step, the test fails. The hero bounces back through the door before the first check ("pressing Up goes through", left in test/b).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The doors answer the real controller, and a held Up goes through one door only. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 412: Bosses.
