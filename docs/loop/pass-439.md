# Pass 439: a sign and the other screens take turns

## Category

Stability (last audited in pass 431).

## Audit

Since pass 436 a sign pauses the game, so three screens (a sign, the pause menu and the map) now hold
the same pause, and each lets it go as it closes. If two could be open at once, closing one would
leave the game paused with nothing up, or running under a screen still showing. The code looked
sound: the pause menu won't open over a sign, the map won't open while the game is paused, the box
only unpauses what it paused, and every dialog in play comes from the world, which a paused game
can't reach. Nothing proved it with the real buttons.

## Fix

`test_a_sign_and_the_pause_menu_take_turns` (tests/test_systems.gd) runs the whole game at the East
Gate's tablet. While the sign is up, Map and Pause open nothing over it, and once it is put away
nothing is open and the game runs. Up and Pause pressed in the same frame, landing either side of a
physics step, open exactly one screen, and closing it leaves none up. With the pause menu up, Up at the
tablet reads nothing. All held: no bug. Bible 14 gains "A sign and the other screens take turns
(pass 439)".

Mutation check: letting the pause menu open over a sign fails the test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Score unchanged. The shared pause is proved with the real buttons. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 440: Movement.
