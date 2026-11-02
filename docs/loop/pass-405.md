# Pass 405: the map, by its buttons

## Category

Systems (last pass 397).

## Audit

- These systems are already tested, by direct calls or through the real controller since pass 397: the skill tree, the shops' buy and sell, the Equipment page, the three flasks and their saves, Settings and the rebinding page.
- The pause menu and the list menus answer the real controller (passes 397 and 398).
- The map's "Rest" marks from pass 403 are held by `test_the_map_marks_every_rest`.
- The gap is the map's own buttons. The map reads them as input events (`_unhandled_input`), not by polling `Input` as the menus do. So the presses that passes 384 to 404 made through `Input.action_press` never reached it. Every map test called `toggle` and `pin` directly. Map to open and close, Jump to pin, and Pause to close had never been sent by the engine's input. A wrong action name there, or a handler that never fired, would have passed every test.

## Fix

`test_the_map_answers_its_buttons` (test_systems.gd) sends each button through `Input.parse_input_event` as an `InputEventAction`:

- Map opens the map, pausing the game, with `map_open`.
- Jump drops a pin where you stand, and Jump again lifts it.
- Map closes it, with `map_close`, and the game runs again.
- With the map shut, Jump drops no pin.
- Pause closes it too.
- A frozen hero cannot open it.

Bible 14's Testing bullet gains "The map, by its buttons (pass 405)".

Mutation check: when the map pins on Attack instead of Jump, the test fails ("Jump drops a pin where you stand").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The map opens, pins and closes through its real buttons. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 406: Audio.
