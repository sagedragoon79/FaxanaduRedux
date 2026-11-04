# Pass 445: the Equipment page by the buttons, mid-guard

## Category

Systems.

## Audit

Sean's off-hand rule says the off hand holds a shield or the Rune Dagger, and the Dwarvish Broad Sword takes both hands, so the shield stays on your back. The swap had only ever been made by a script (`test_gear_is_kept_and_swapped_and_the_broad_sword_takes_both_hands`), and Block there was a scripted intent. A player changes blades from the pause menu, often with a thumb still on Block. This pass looked for a guard that survives a swap to the two-hander, a guard that fails to come back with the shield, and a parry window opened by the swap.

## Bug found

None. The guard is worked out again every step from `has_shield`, which `refresh_stats` sets on every swap. The held button is read as held, never as a fresh press, so no parry window opens.

## Fix

- `test_the_equipment_page_changes_hands_mid_guard` (test_systems) runs the whole game at the west gate with the Small Shield worn. It holds Block for real, then goes to the Equipment page with Pause, Down and Jump, all through `Input`.
- It puts the Broad Sword in hand and backs out with Pause. With Block still held, the guard is down and the shield is off the arm.
- It then puts the Short Sword back the same way. The held Block guards at once, with no parry window, and letting go drops it.
- Bible 5.2 (Dwarvish Broad Sword) gains "Changed by the buttons mid-guard (pass 445)".
- Mutation: letting `refresh_stats` keep the shield in hand under a two-hander fails the guard-down check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The off-hand swap is now proved through the real menus with a held guard. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 446: Audio.
