# Pass 381: the Options page, as the bible lists it (Systems)

Category: Systems (last pass 373).

## Audit

Passes 374 to 380 added the waterfall's sound, the minimap cache and four bible ledgers. None of them changed a save, shop, rank or menu. So the audit read 14's accessibility line, which is the bible's only list of what the Options page holds, against `Menus.OPTIONS` and `Settings`.

The list was still the one from pass 09's interim build:
- It named shake, flashes, rumble, the volumes and game speed.
- It did not list Damage numbers (built in pass 154) or Assist: mercy (built in pass 325). Each had its own note further on, but the list itself was never updated.
- It said gamepad remapping "comes with controller glyphs", but pass 365 built pad remapping without them.
- No test read the list.

The game's own words had drifted the same way:
- The pause menu's Options row left out the mercy assist.
- The title's Options row left out the mercy assist and damage numbers.
- The title's Controls row still said "Rebind the keyboard" six passes after the pad could be rebound.

## Fix

- Bible 14: the interim sentence is replaced by "The Options page, as built (pass 381)":
  - its eight rows, in order;
  - the shake and flash steps;
  - the starting value of each row.
  - It also records the drift.
- `Menus.OPTIONS_DETAIL` and `Menus.CONTROLS_DETAIL` are now the one line each that both the pause menu and the title read. Options names every row, and Controls says the pad rebinds as well.
- `test_the_options_page_is_the_one_the_bible_lists` (`test_systems.gd`) checks these against `Menus.OPTIONS` and `Settings`:
  - the row count, labels and order;
  - the steps, and the starting values at a fresh reset;
  - that the Options line names every row;
  - that both menus' Options and Controls rows read those constants.

Mutation checks:
- With the title's old Options words put back, the test fails 1 check.
- With Rumble off at the start, it fails 1 check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The Options page is listed as built, and the menus' own descriptions of it are true. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 382: Audio.
