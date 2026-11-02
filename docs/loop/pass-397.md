# Pass 397: the menus, by the real controller (Systems)

Category: Systems (last pass 389).

## Audit

- Passes 390 to 396 added three Meditation Shrines (396). The map and minimap draw shrines from each room's grid (`info.shrines`), and a shrine saves the same way wherever it stands, so the new ones need nothing more. The shrine counts in 3.3 were updated in pass 396.
- `Sfx.heard` (390) and the runner's held-button release (391) are test-side state, and neither is saved.
- Passes 384 to 394 drove every move and combat button through `Input` itself. The menus never were. `ListMenu` (pause, shops, skills, options, the Equipment page) and the shelf of flasks (`SlotPicker`, Sean's three save flasks) read their buttons in `_process` with `Input.is_action_just_pressed`. Every menu test called `move`, `adjust`, `confirm` and `back` directly. A menu that read the wrong action, or none, would have passed.

## Fix

`test_the_menus_answer_the_real_controller` (`test_systems.gd`) presses the buttons through `Input`:
- On a `ListMenu`: Down and Up move the cursor and wrap; Right and Left change the row's value; Jump and Attack each choose; Dash, Block and Pause each back out, and the game unpauses.
- On the shelf of flasks: Right and Left walk the shelf; Jump uncorks the focused empty flask for a new journey; Dash puts the shelf away.

Bible 14, Testing: "The menus, by the real controller (pass 397)", and the test checks the bible names it.

Mutation checks:
- Dash dropped from a menu's Back: 1 check fails.
- The flasks' Right read from Up: 3 checks fail.

Full suite: 7144 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The menus and the save flasks answer the real controller, and a test holds it. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 398: Audio.
