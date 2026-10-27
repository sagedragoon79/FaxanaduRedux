# Pass 174: every guardian in the audit, and beaten for good

Pass 173 left Stability and Faithfulness tied at 98.75, both weight 5. Stability's last pass (166) was the older, so pass 174 takes Stability. I audited the newest content (passes 167 to 173) for crashes, soft-locks and save problems.

| Check | Finding | Verdict |
| --- | --- | --- |
| The Proving Scar (pass 170) | the Zenis zone soak reads its rooms from the catalog, so it mashes the Scar too; it loads inside the room budget | fine |
| The Journey page (pass 172) | it reads counts the pause menu already holds; its tests cover an empty and a partly found save | fine |
| Mini-boss sounds (pass 173) | every sound loads with the game, and the boss audit checks nothing loads mid-fight | fine |
| **The boss frame audit** | It walked a hand-kept list of 13 arenas. The Clockwork Alpha's den (pass 169) and the Bark Captain's yard (pass 171) were never on it, so neither fight had been held to the frame budget or checked for loads mid-fight. | **built** |
| **Beaten guardians across a save** | Each boss's win was tested in its own fight, but nothing saved after a win and continued into the arena: the doors, the fight and the prize had never been checked on the way back. | **built** |
| **Key counts in a save** | The new test found that a save's keys came back as floats (`sky: 1.0`), because JSON keeps every number as one. Every read goes through `int()`, so nothing broke, but the save no longer came back as it went. | **fixed** |

## As built

- `_boss_rooms()` reads every room's `boss:` header. `test_every_boss_fight_holds_the_frame_budget` now runs all 15 arenas and checks that their number matches `BossArena.BOSSES`. The two mini-bosses hold the budget: the Alpha's den 0.80 ms on average (1.33 ms at the 99th percentile) and the Captain's yard 0.57 ms (1.52 ms).
- `test_every_beaten_guardian_stays_beaten_through_a_save` (new) first checks that every guardian has exactly one arena. Then it wins each fight, saves, and continues into a fresh world in that room. The doors stay open, no fight starts, and the prize (rings, keys, health, magic, points, abilities and armor) is the same as before the save. The Evil One is left out, because its win starts the ending.
- `GameState.sanitize` turns a key count back into a whole number.

## Tests

- `test_soak.gd`, `test_every_boss_fight_holds_the_frame_budget`: arenas read from the rooms.
- `test_soak.gd`, `test_every_beaten_guardian_stays_beaten_through_a_save` (new).

Full suite: 3294 of 3295 checks passed, with no script errors. The one failure was a single 58.6 ms frame in the long journey soak (tower/ore_vault), which the new code never touches; that test passed twice when run again on its own.

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
| Stability and performance | 5 | 99 | Every arena is now read from the rooms, and every win is checked across a save. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.85 (up from 96.8375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (98.75) is now the lowest category apart from Art, so pass 175 takes Faithfulness.
