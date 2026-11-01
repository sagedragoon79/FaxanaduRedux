# Pass 365: the pad, rebound (Systems)

Category: Systems (last pass 357).

## Audit

Bible 14's Accessibility line promises "full remapping", and its interim note (pass 09) said "gamepad remapping comes with controller glyphs". Nothing ever came. The Controls page rebound keyboard keys only: `Settings.REBINDABLE` was commented "the pad keeps its layout", `ListMenu.capture` took only key presses, and the Back row said "The gamepad layout stays as it is." A player on a gamepad who could not reach a shoulder button (the Rune Dagger on RB, Block on LB) had no way to move it. Passes 358 to 364 touched no other system the bible promises without a test.

## Fix

- Every action the Controls page lists takes a pad button as well as a key (`Controls.rebind_button`, `Controls.primary_button`, `Controls.button_name`, `Settings.bind_button`, `Settings.buttons`, saved under `[buttons]`). Choose a row and press a key or a pad button; the row shows both ("Space / A"). Screenshot: `/mnt/project-files/controls/controls-pad.png`.
- A button taken from another action swaps with it. The potion, on the left trigger, has no button of its own, so it may take only a free one. Start, LS and RS (pause, Hour Glass, next spell) are not on the page and are never taken. Start cancels a rebind as Esc does. Reset puts keys and buttons back.
- Buttons read from the file are checked like keys: only a whole number in the pad's range is bound.
- Bible 14 (Accessibility): "**The pad, rebound (pass 365):**".
- `test_the_pad_can_be_rebound` presses real buttons through the input map, checks the swaps and refusals, a save and load, a damaged file, the reset, and the page itself pressed from the pad (Start cancels, RB rebinds and the row says so).

Mutations: with the swap removed, 5 checks fail; with the menu deaf to pad buttons, 3 fail.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The pad can be rebound, as "full remapping" promised. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 366: Audio. Pass 367 (Stability) traces the soak's frame bursts in full runs (passes 359 and 363).
