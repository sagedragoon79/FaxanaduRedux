# Pass 247: the ending waits for you

Category: Stability (last pass 239).

## Audit

I checked every timer and wall-clock read in the game scripts against the pause and against room teardown:
- `create_timer` calls, `PROCESS_MODE_ALWAYS` nodes and `Time.get_ticks_*` reads in play.
- Nodes that run on while paused are all UI or autoloads, as they should be.
- The wall-clock reads in foes and bosses only draw, or set a velocity that eases back, so a pause costs nothing.

The gap found is the one timer in play that ran while paused: the four seconds between the Evil One's fall and the ending. `BossArena` made it with `process_always` true and connected it straight to `GameState.begin_ending`.
- **Pausing:** if you paused in those four seconds, the ending came on under the pause menu and shut it.
- **Teardown:** the timer belonged to no node, so a world torn down in those seconds (a test, or any future way out to the title) would still mark the save cleared and start the ending with no world under it.

## Fix

- The timer now stops while the game is paused (`process_always` false). It still ignores the time scale, so the kill's slow motion doesn't stretch it.
- It calls `BossArena._begin_ending`, a method of the arena. A freed arena's connection goes with it, and the method checks that the arena is still in the tree.
- Test: `test_the_ending_waits_out_a_pause_and_dies_with_its_world` (`test_boss.gd`). It checks that:
  - while paused for the delay plus a second, there is no ending and the save is not cleared;
  - unpaused, the ending comes, with one clear;
  - with the world freed right after a second win, there is no ending and no clear.
- Mutation check: the old timer fails both the pause and the teardown checks.
- Bible 8, the ending as built.

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
| Stability and performance | 5 | 99 | Unchanged score: the last timer in play that ran through a pause now waits. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 248 takes Movement (last pass 240).
