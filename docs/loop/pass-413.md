# Pass 413: a shop by the buttons

## Category

Systems (last pass 405).

## Audit

These already answer the real controller:

- the list menus, the pause menu and the three flasks (passes 397 and 398);
- the map (pass 405);
- the Guru's menu (pass 409).

Every other system (the skill tree, the Equipment and Inventory pages, Settings, the Mantra Path) is held by its own tests, and every bible 9, 10 and 14 promise names a test.

The gap is the shops. Every shop test called `Shop.buy`, or the shop menu's choose function, itself. So shopping the way a player does had never been played: Up at a shopkeeper, Down to a row, Jump to buy, Dash to leave. Each shop menu maps the row under the cursor to its shelf (`Shop.shelf`). If that mapping slipped by a row, every shop test would still pass while the player paid for the wrong thing.

## Fix

`test_a_shop_answers_the_real_controller` (test_economy.gd) visits the Eolis arms dealer with `Input` alone:

- Up at him opens his shop and pauses the game, with the cursor on the Long Sword.
- Jump buys the sword. 400 gold is paid, the sword is in hand, the coin clinks, and the shop stays open.
- Down moves to armor the hero can't afford. Jump on it buys nothing and plays `menu_refuse`.
- Dash leaves the shop, and the game runs on.

Bible 10.2 gains "A shop by the buttons (pass 413)".

Mutation check: when the shop menu buys the row below the cursor, the test fails 3 checks. The player is charged for a different item, and the Long Sword is not in hand.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. A shop is visited, bought from and left through the real controller. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 414: Audio.
