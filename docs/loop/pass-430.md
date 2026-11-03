# Pass 430: a menu closed by its button is not heard as the hero

## Category

Audio (last pass 422).

## Audit

Pass 429 found one press read twice: the Jump that takes a journey up from the title. Its next step asked where else a press is read twice across a pause or a menu. The pause menu is closed by the hero's own buttons: Jump or Attack on Resume, and Dash, Block or Pause to back out. Pass 421's test closed it with Jump and Dash, but it never watched or listened to the hero afterwards.

## Bug found

A new test closes the pause menu with each button held, then watches and listens to the hero. Three of the five were read again:

- Jump on Resume jumped, heard as `jump`.
- Attack swung, heard as `slash`.
- Dash dashed, heard as `dash`.

The menu closes in the process frame of the press. When no physics step falls between the press and the close, the hero's next step still sees the press as just pressed. On a display faster than 60 Hz that is most frames, and in the test runner it is every frame.

## Fix

- The hero drops the presses of their first step after steps were missed while the game was paused (`Player._last_step` counts the gap), as pass 429 did on waking. Held buttons stay held. Hitstop stops time rather than pausing, so no steps are missed during it and it is untouched. The fix covers every pausing screen at once: menus, the map, dialogs, shops and the Guru.
- `test_a_menu_closed_by_its_button_is_not_heard_as_the_hero` (test_systems) runs the whole game. It closes the pause menu with each of Jump, Attack, Dash, Block and Pause, held for a third of a second. Each time:
  - the menu goes and play goes on;
  - the hero does not move;
  - no jump, swing or dash is heard.

  A fresh Jump afterwards still jumps.
- Bible 13.3 gains "A menu closed by its button is not heard as the hero (pass 430)".

Mutation: without the missed-step drop, the test fails 6 checks: Jump, Attack and Dash are each seen and heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. A real bug fixed: a menu closed by Jump, Attack or Dash no longer jumps, swings or dashes. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 431: Stability.
