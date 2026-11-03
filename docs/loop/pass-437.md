# Pass 437: the time played is time in play

## Category

Systems (last audited in pass 429).

## Audit

The time played shows in two places: a flask's details on the journey shelf (14) and the thanks card
at the ending (8.9). Nothing tested how it is counted. `GameState` runs while the game is paused (it
must, for its signals and saves), and its `_process` added every frame to the clock.

## Bug found

Every second the game sat paused counted as played: the pause menu, the map, the flask shelf, and
since pass 436 a sign being read. A pause menu left open overnight would show on the flask and at the
ending as hours of play.

## Fix

The clock only runs while the game does (`if not get_tree().paused`). The time spent on the title
before a journey is taken up was already thrown away on load. `test_the_time_played_stops_while_the_game_is_paused`
(tests/test_systems.gd) runs the whole game: three seconds in the pause menu opened with the real
Pause add nothing, three seconds reading a sign add nothing, and three seconds of play add three.
Bible 8.9's thanks card line gains "The time played is time in play (pass 437)".

Mutation check: letting the clock run while paused fails the menu and sign checks (2.98 s each).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The time played no longer counts paused time. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 438: Audio.
