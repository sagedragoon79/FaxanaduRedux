# Pass 144: a journey after the end

Stability (97.75, weight 5) was tied for lowest apart from Art with Faithfulness. I audited stability against bible 15.3 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Soaks, frame budget, boss fights, saves | The journey soak, per-zone mashing soaks, boss-fight budgets and save round trips all pass (pass 99 on) | fine |
| `Player.on_kill` (pass 142) | Every foe's death goes through `Enemy.die`, bosses included, so there is one path to cover | fine |
| **The post-game world (passes 141 and 143)** | Every soak starts from a fresh save. A cleared save had never been walked: one with a second particle layer in the World, music swapped by `Music.after_the_end`, every boss arena idle and Wanderer's Grace firing on every kill. Saves were never continued with the `cleared` flag mid-journey either. That is the state a player who finishes the game lives in for the whole 100% cleanup. | **soaked** |

## As built

`test_soak.gd`, `test_a_journey_after_the_end_stays_lean`:
- `_journey` takes a post-game switch, a door count and a start room. `_clear_the_game` sets every boss flag, the three springs and `cleared`, and learns the whole Wanderer branch with Wanderer's Grace. The first room is entered again so it blooms.
- **The laps:** each lap walks 100 doors out of Eolis and 50 out of the meteor's Threshold. Along the way it mashes, rests and Continues into a fresh world every 20 rooms, and opens the pause and skills screens. Two laps run with different seeds.
- **The checks:**
  - no engine or script error is logged over both laps (`ErrorCatcher`);
  - every Continue lands where it rested and is still cleared;
  - no frame of play passes 50 ms;
  - the second lap leaves no orphan nodes and no bigger tree, and fewer than 50 live objects behind;
  - blossom drifted (101 room stays a lap), Zenis played `zenis_still`, and Eolis played `eolis_bloom`.

## Results

In `/mnt/project-files/pass-144/soak.txt`:

| Lap | Rooms | Reloads | Worst frame | Bloom | Still meteor | Festival |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 59 | 7 | 6.3 ms | 101 | 1 | 12 |
| 2 | 66 | 7 | 4.8 ms | 101 | 33 | 6 |

- **Second lap:** objects 4,076 -> 4,076, orphans 0 -> 0, nodes 23 -> 23.
- **Errors:** none.
- **Nothing to fix:** the post-game world holds, so this pass adds coverage, not a repair.

Full suite: 2630 checks, all passing, with no script errors in the log.

## Bible

15.3 gains "After the end (pass 144)" under the stability measures.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98 | Unchanged. |
| Combat and enemies | 15 | 98 | Unchanged. |
| World and level design | 15 | 98 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | Unchanged. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | The post-game world is soaked like the main game: no leaks, no errors and no spikes over two laps. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Weighted score: 96.05 (up from 96.0375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (97.75) is now the lowest apart from Art. Pass 145 takes Faithfulness.
