# Pass 99: The journey soak

Stability (93) was the lowest category apart from Art. The existing soaks each covered one slice: a zone's rooms one at a time, a single boss fight, every door, every shrine. This pass adds a soak that plays the game the way a player strings it together, and fixes what it found.

## The journey soak

`test_a_long_journey_through_the_whole_game_stays_lean` (`test_soak.gd`):
- It walks 160 doors from the West Gate. Four times in five it leans toward a room it hasn't seen.
- Between doors it plays 40 frames of mashed input, with the foes left in. A mashing player often walks out through an edge door too, so the walk covers more than the doors chosen.
- Every 20 doors it rests, frees the world, loads the save and Continues into a brand-new world. It checks that it wakes in the room where it rested.
- Every 7 doors it opens and shuts the pause and skills screens.
- It runs twice with different seeds. The first lap may fill caches (sprite sheets, sounds, music); the second must leave nothing behind.

## Findings

| Measure | Result |
| --- | --- |
| Script errors and warnings | None in either lap. |
| Rests and Continues | 8 per lap, each in the room it was taken. |
| Live objects, second lap | 2935 -> 2922 (no growth). |
| Orphan nodes | 0 -> 0. |
| Tree nodes | 23 -> 23. |
| Rooms seen | 60 and 31. |
| Worst frame of play, before the fix | **138 to 158 ms**, every run, in `tower/forepaw_lift` when Zoradohna's fight starts. |
| Worst frame of play, after the fix | 9.5 ms (first lap), 6.6 ms (second). None over 33 ms. |

Two false alarms on the way are worth recording:
- The first lap's object count rose about 500 after freeing the world. A second lap showed it was caches filling, not a leak.
- Most early "spikes" were room loads: a mashing player walking out through an edge door mid-play. The soak now notices the room change and judges play frames, not loads.

## The fix: a boss fight no longer hitches when it starts

A boss is spawned when the player walks into its arena, mid-play. Its sprite sheet (the PNG, its mask and the manifest) and its music were loaded on that frame. For Zoradohna the frame took about 140 ms, a visible hitch just as the fight begins.

`BossArena.warm()` now runs while the room loads, which is already a load frame. It loads the boss's sheet and its music stream. If the boss was already beaten, it loads nothing.

This covers Rokusutahn, the Foreman, Zoradohna and Ripasheiku, whose sheets are drawn from sprite sheets. The music part covers every boss. Bosses drawn in code had no sheet to load.

## Tests

`test_soak.gd`:
- `test_a_long_journey_through_the_whole_game_stays_lean`: two laps, with the checks above.
- `test_a_boss_arena_loads_the_fight_before_it_starts`: the arena warms with the room, the sheet and theme are cached before the fight, the fight starts on the walk in, and no frame passes 33 ms. Without the fix this test fails, with an 82.5 ms frame.

Full suite: 1847 checks, all passing.

Bible 15.3 now records the stability measures.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 93.25 | Unchanged. |
| Combat and enemies | 15 | 93.75 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.25 | Fights open without a hitch. |
| Systems | 10 | 93.25 | Unchanged. |
| Audio | 5 | 93.75 | Unchanged. |
| Stability and performance | 5 | 94 | A whole-game soak with save and Continue, leak-free on the second lap, and the one real hitch fixed. |
| Faithfulness | 5 | 96 | Unchanged. |

Weighted score: 93.31 (up from 93.24; 93.3125 unrounded).

## Next

Systems (93.25) and Movement (93.25) are now the lowest apart from Art. Pass 100 takes Systems: an audit of save and load round trips (every field of `GameState.data`), shops, the skill tree, the map, fast travel and settings, against bible sections 9 to 12.
