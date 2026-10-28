# Pass 205: the Inventory page

Systems' last pass (197) was the oldest apart from Art, so pass 205 takes Systems. I audited the pause menu and what it shows against the rubric (15.3: save/load, shop, skill tree, map, fast travel, settings) and against passes 198 to 204.

| Check | Finding | Verdict |
| --- | --- | --- |
| Coin denominations (199) | Coins are picked up into `GameState.data.gold` like before, and a save keeps the sum. | fine |
| Relics in saves (201) | `pendant` and `magical_rod` are in `fresh()` abilities, so old saves gain them as false. | fine |
| Equipment page (186, 189) | Lists gear by slot, with numbers, tempers and dyes. | fine |
| **What you carry** | Nothing in the game listed found abilities, spells, relics, rings, keys or shards. Each was shown once, as the banner at its pickup. After pass 201 you could carry the Pendant all game and never see that you had it, or what it did. The bible's UI list (12) names an "inventory grid" that was never built. | **built: the Inventory page** |

## As built

- The pause menu gains **Inventory**, under Equipment (`Menus.open_inventory`, `Menus.inventory_rows`). It is read only and lists, under headers and in a fixed order:
  - Abilities, Spells (the readied spell marked Ready), and Relics;
  - Rings, with how many of the four you hold;
  - Keys, with counts;
  - Potion and Mantra Shards toward their next whole, and the Meteor Shards you carry.
- Each row's line says what the thing does. It reuses the pickup banner's line, the Foreman's line for the Mattock, and the scroll's line for Fire and Tilte.
- Nothing you lack is shown, so the page spoils no find. A new game shows "Nothing yet".
- `game.gd`: `--open=inventory` and `--carry=` (rings, keys and shards) for screenshots. `--open` now runs after `--give`, `--equip` and `--skills`, so a menu screenshot shows them.
- Tests:
  - `test_the_inventory_page_lists_what_you_have_found` (new) checks the empty page, the order and grouping, the Ready mark, the key and shard counts, and that every row has a line. It also checks that every ability in the game has a place on the page, and that with everything found each line fits the menu's three-line box.
  - `test_pause_menu_and_its_sub_menus` opens the Inventory and follows the shifted rows.
  - A mutation check (marking the wrong spell Ready) fails the new test.
- Bible 5.2: "The Inventory page".
- Screenshots: [inventory_10.png](/mnt/project-files/pass-205/inventory_10.png) and [inventory_17.png](/mnt/project-files/pass-205/inventory_17.png). The page uses the shared `ListMenu`, with gold Ready and count marks, and with the detail box showing each line.

Full suite: 4000 of 4000 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the gap was a missing page, now built and tested. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 206 takes Audio (last pass 198, now the oldest).
