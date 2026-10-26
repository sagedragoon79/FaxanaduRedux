# Pass 138: a save that names what this build lacks

Stability (97.5, weight 5) was the lowest category apart from Art. I checked the newest code and the edges a long-lived save hits.

| Check | Finding | Verdict |
| --- | --- | --- |
| Cloak dye shader, field cues, Completion.award, Mantra of Death | covered by their tests; no script errors in the full suite's log | fine |
| An older save without `dyes` and `dye` | `GameState.sanitize` fills them from a new game | fine |
| Soak test, room boot | pass | fine |
| **A save naming a skill this build lacks** | Unlearning skills hit a script error on it (`skills.gd:43`, `.cost` of an empty dictionary). It had already taken the gold, and it refunded no points. | **fixed** |
| **A skill listed twice** | sanitize kept both, so a respec would refund it twice | **fixed** |
| **An unknown blade** | fell back to the Hand Dagger but kept the missing blade's temper (10 slash, not 8) | **fixed** |
| Dyes saved as non-strings | kept as they were | **fixed** |

A save meets these whenever a node, item or dye is renamed between builds.

## As built (bible 15.3)

- `Skills.respec`: an unknown node refunds nothing, and the respec completes.
- `GameState.sanitize`: `skills` and `dyes` keep each string once (`_unique_strings`).
- `GameState.refresh_stats`: a blade this build lacks becomes the Hand Dagger, untempered.

## Report

In `/mnt/project-files/pass-138/`:
- `before.txt`: the new test against the old code. 7 of 8 checks fail, including the engine error the respec logged.
- `after.txt`: all 8 pass.

## Tests

`test_a_save_naming_things_this_build_lacks_plays_on` (`test_systems.gd`), new. It loads a save naming a missing skill, blade, armor, shield, ring, temper and dye, with duplicates and a non-string. With `ErrorCatcher` listening, it then:
- dresses the player;
- reads every skill's status and the dyer's shelf;
- unlearns.

It checks the cleaned lists, the fallback blade, the untouched cloak, the respec's price and refund, and that no engine error was logged.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Unchanged. |
| Combat and enemies | 15 | 97.75 | Unchanged. |
| World and level design | 15 | 97.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Unchanged. |
| Audio | 5 | 97.75 | Unchanged. |
| Stability and performance | 5 | 97.75 | Saves survive renamed content. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2546 checks, all passing, with no script errors in the log.

Weighted score: 95.875 (up from 95.8625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, World, Systems, Audio, Stability and Faithfulness are all at 97.75. Movement weighs the most (20), so pass 139 takes Movement.
