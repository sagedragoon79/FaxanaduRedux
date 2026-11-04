# Pass 451: the Mantra Path, walked with the buttons

## Category

World (last audited in pass 443).

## Audit

The Mantra Path (bible 3.3) is the world's main way back between towns. Its test,
`test_the_mantra_path_joins_the_gurus_after_a_spring`, called `guru.interact` and set the menu's cursor
and `confirm()` by hand. Nothing had walked it with the buttons. That leaves out the Up that opens the
Guru's menu, the Down presses across a row that can be greyed out (Unlearn skills), and the two Jump
presses. The last of those could have been taken as a jump on arrival. It also left out whether play
goes on unpaused and under the player's control in the far town.

## Bug found

None.

## Fix

`test_the_mantra_path_is_walked_with_the_buttons` (tests/test_economy.gd) stands at Forepaw's Guru
with the Spring of the Trunk flowing and Apolune's Guru met. With the real buttons, Up opens his menu,
Down walks to the Mantra Path, Jump opens it and Jump on Apolune carries the hero there. The menu is
shut and the game unpaused. The hero stands on the floor a step from Apolune's Guru, with no jump
taken from the press that chose the stop, and the real Right walks him on at once. Bible 3.3's fast
travel line gains "Walked with the buttons (pass 451)".

Mutation check: leaving the hero frozen after the journey fails the test ("the real Right walks on at
once (0 px)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The Mantra Path is proved with the buttons. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 452: Bosses.
