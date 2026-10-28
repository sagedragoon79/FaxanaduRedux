# Pass 221: the Dragon Slayer, held as one

Systems' last pass (213) was the oldest apart from Art, so pass 221 takes Systems. I audited saves and `sanitize`, the shops, the skill tree, the menus, the map, the settings, and gear against passes 214 to 220.

| Check | Finding | Verdict |
| --- | --- | --- |
| Moved pickups (213, 216, 219) | Each move is listed and tested. The Sky Steps' chest carries over. | fine |
| Completion after pass 217 (the altar's sword) | The tally counts the rooms' current treasures, so the stale altar id in an old save is ignored. | fine |
| Supplied music, engine errors (214, 215) | Both are tested. | fine |
| Boss banners (220) | Tested by the arena sweep. | fine |
| **The Dragon Slayer in the save** | It is kept twice, as an ability (the reach checker's gate, and what the pass 217 migration reads) and as gear (the Equipment page, the blade that cuts the flesh). It was the one player ability missing from `GameState.fresh().abilities`. So the full round-trip test, which turns on every listed ability, never carried it. `sanitize` didn't type-check it. Nothing kept the two halves together: a save with the sword in its gear but no ability would fail the migration's check, and the reverse showed no sword on the Equipment page. | **fixed** |

## As built

- `GameState.fresh().abilities` gains `"dragon_slayer": false`. `sanitize` now coerces it to a bool, as it does every listed ability, and the round-trip test carries it.
- `sanitize` keeps the two halves together: the sword in the gear grants the ability, and the ability puts the sword in the gear (not in hand). A damaged value counts as neither.
- New test, `test_the_dragon_slayer_is_held_as_ability_and_gear_together` (`test_systems.gd`).
- Mutation check: without the listing and the pairing, the test fails. Without the listing, a damaged save even logs an engine error.
- Bible 15: a "Dragon Slayer in the save" line beside "Moved pickups".

Full suite: 4094 of 4094 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: every ability the player holds now goes through the save's round trip. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 222 takes Audio (last pass 214, now the oldest).
