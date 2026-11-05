# Pass 467: Options by the buttons, kept through a restart

## Category

Systems.

## Audit

Pass 421 pressed Pause in play, but the Options and Controls pages had only been reached with
`confirm()` and `adjust()`. No test changed an option with the real buttons, quit, and started the
game again to see the option come back from the file.

## Bug found

Backing out of a page put the cursor on the menu's first row. In play, Dash out of Options landed on
Resume, so the next Jump (meant for Controls, the row below) closed the menu and resumed the game. On
the title, the same Jump opened the flasks instead.

## Fix

Backing out of a page now lands on the row that opened it: the pause menu's pages reopen it on their
own row (`Menus.open_pause`), and the title's Options and Controls go back through `_title_on(row)`.

`test_options_are_changed_with_the_buttons_and_kept_through_a_restart` runs the whole game with the
real buttons. Pause, Down to Options, Jump; Right turns the shake up, Jump turns mercy on, Left three
times lowers the sound to 5; Dash lands on Options; Down and Jump open Controls; Jump on Map and a real
N key rebind it. The game is quit, the options in memory go back to their defaults, and a new game
reads the file alone: shake, mercy, the Sfx bus level and the N key are all back. On that game's title,
Options backs out onto Options. Bible 14 gains "Options by the buttons, kept through a restart (pass 467)".

Mutation check: without the pause menu's fix the test fails 7 checks (Dash lands on Resume, row 0);
without the title's, 1 check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. Backing out of a page keeps your place; options proved through a restart. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 468: Audio.
