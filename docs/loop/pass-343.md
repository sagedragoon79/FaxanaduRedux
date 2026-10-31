# Pass 343: one save slot, as built (Stability)

## Audit

Stability was last audited in pass 335, which added the memory soak. This pass read bible 14 against the code. The performance budget is held:

- load times and frame time by `test_every_room_loads_and_settles_inside_the_budget`;
- memory by the soak (pass 335);
- engine errors and state leaks by the runner.

The structure line still promised a SaveSystem with **3 slots**. The game has always kept one: `Game.SAVE_SLOT` is 1, and the title offers Continue and New game over that single save. Nothing in the bible said so. The safe write (`.tmp`, read back, last good copy kept as `.bak`) and the fallback to the backup are tested, but the bible never named the `.bak`.

The accessibility line gives the options' steps, and none was read by a test. They all match the code:

- game speed 70 to 100% in steps of 10;
- shake full, half or off;
- flashes full, reduced or off;
- the mercy assist's 0.8 s to 1.6 s.

## Fix

- Bible 14: a "One slot (deviation, pass 343)" note. It covers:
  - the single save, `user://save_1.json`, autosaved at every rest;
  - how the safe write works, with its `.bak` fallback;
  - why one journey suits the game;
  - that more slots wait on a slot picker on the title.
- `test_the_bibles_saves_and_options_are_as_built` (test_systems.gd) checks:
  - the slot and its path;
  - that a second write keeps the first as `.bak` and leaves no `.tmp`;
  - the game speed's range and steps;
  - the shake and flash names;
  - the mercy assist's grace, read from `MovementTuning` and `Settings.MERCY_MULT`.

Mutation check: with the save in slot 2, a game speed step of 60%, and a write that drops the old file instead of keeping it as `.bak`, the test fails three times.

## Suggestion for Sean

Three save slots, as the plan had them, would need a slot picker on the title (Continue and New game each choosing a slot), plus `Game.SAVE_SLOT` becoming a choice. It is a small Systems slice when you want it.

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
| Stability and performance | 5 | 99 | Unchanged score: the one save slot and its safe write are written as built, and the options' numbers are held. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 344, Movement: audit passes 337 to 343 for movement facts in bible 6 that no test holds or that the code disagrees with.
