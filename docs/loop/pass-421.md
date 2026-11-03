# Pass 421: the pause menu by the buttons

## Category

Systems (last pass 413).

## Audit

A bare ListMenu (397), the three flasks on the title shelf (397, 398), the map (405), a shop (413), the King and the Guru (409) and the lift's stops (419) all answer the real controller. No test had pressed Pause in play: the game's own `_check_pause` and the pause menu's rows were only reached by calling `Menus.open_pause`, and the Ointment "rubbed on from the pause menu" (bible 10.2) was only used by calling `use_ointment`.

## Fix

- `test_the_pause_menu_answers_the_real_controller` (test_systems.gd) runs the whole game in the West Gate of Eolis:
  - Pause opens "Paused" over a frozen world, on Resume.
  - Down to Use Ointment, and Jump rubs it on: none left, 10 s of safety, its shimmer, the menu closes and play goes on.
  - Pause again, Down and Jump on the row while one is on: it says no.
  - Dash backs out and the game runs on.
- Bible 14's Testing line gains "The pause menu by the buttons (pass 421)".

Mutation: leaving the menu open after the Ointment is rubbed on fails only the new test; the tests named for the Ointment still pass.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The pause menu answers the real controller. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 422: Audio.
