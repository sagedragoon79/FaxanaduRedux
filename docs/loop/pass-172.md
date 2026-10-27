# Pass 172: the Journey page

Systems, Audio, Stability and Faithfulness were tied at 98.75. Systems weighs the most (10), so pass 172 takes Systems. I audited skills, shops, the economy, saves, the map and completion (bible 9, 10, 11 and 14) against the newest content (passes 164 to 171).

| Check | Finding | Verdict |
| --- | --- | --- |
| Mantra dyes (pass 164) | the dye shelf, the sanitizer and the shrine save all keep them | fine |
| Mini-boss rewards (passes 169, 171) | the Life Fruit and the Mana Dew go through `GameState.grant_stat_item` like any find, and no skill point is given | fine |
| The Proving Scar (pass 170) | its shrine is a Mantra Path stop like any other; the map shows it, and the throne's move east | fine |
| Completion (bible 11) | the two new mini-bosses count among the guardians (15), and the Scar's and the yard's rooms count among the rooms | fine |
| **Completion in play** | The percent and its four shares were shown only on the ending's card. Yet 100% is what earns the Lord's Gold and opens the boss rush, and with each new mini-boss and room the target moves. A player hunting the last few percent had no way to see what was missing until they beat the game again. | **built** |

## As built

- **The Journey page:** a new pause menu row, between Controls and Quit (`Menus.open_journey`). It opens a read-only page built by `Completion.journey_rows` from the same `Completion.tally` the ending uses:
  - the percent of the world;
  - rooms explored, hidden rooms, treasures and guardians beaten, each as found / total;
  - "Guardians found": every guardian whose arena you have entered, in climb order, marked Beaten or Waits;
  - a count of those not yet found.
- **No spoilers:** an arena you have not entered is never named.
- **Supporting changes:**
  - `Completion.GUARDIANS` lists all 15 guardians with their names, in climb order.
  - The world catalog now records each room's `boss:` header, so the page knows which rooms are arenas.
  - `--open=journey` screenshots the page.

## Screenshots

- `/mnt/project-files/pass-172/journey.png`: the page on a fresh save, standing in the Thorn Yard.

## Tests

- `test_systems.gd`, `test_the_journey_page_counts_the_world_and_the_guardians_found` (new) checks that:
  - the guardian list matches `BossArena.BOSSES`;
  - the catalog marks arenas;
  - only entered arenas are named, in climb order, beaten or waiting;
  - the rows match the tally;
  - the not-yet-found count is right;
  - the menu opens with those rows, and each label fits the panel.
- `test_pause_menu_and_its_sub_menus`: Journey opens in place and backs out to the pause menu. Quit moved down one row.

Full suite: 3282 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | The road to 100% can be read in play: the shares, and the guardians found and still waiting. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.825 (up from 96.8). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio, Stability and Faithfulness are tied at 98.75, all weight 5. Audio's last pass (165) is the oldest, so pass 173 takes Audio.
