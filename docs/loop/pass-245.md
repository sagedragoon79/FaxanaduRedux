# Pass 245: one key per door

Category: Systems (last pass 237).

## Audit

Bible 9 and 10 against the build: the skill tree, ranks and Gurus, the shops, gold, saves, the pause and Equipment pages, settings and the Journey page. The gap found: the key shops. The world has exactly one door of each card (Jack in the Deep Roots, Queen in the Feather Hollow, King in the North Bough, Ace on the Spire Stair, Joker on the Meteor Rise), and all eight towns' grocers cut Jack Keys. Nothing stopped a player from buying a second Jack Key, or a fifth, at 150 g each, or a Queen Key after the Queen vault was open. Each one was gold spent on a reward that could never arrive.

## Fix

- `World.locks_in` (pulled out of the catalog) reads a room's key doors, and `World.world_locks()` reads them for every room once.
- `Shop.doors_shut(kind)` counts a card's doors still shut. `Shop.status` returns "enough" for a key when the keys you hold already cover them, so `Shop.buy` refuses it.
- `Menus.shop_rows` (pulled out of `open_shop` so a test can read it) shows "Enough". The detail adds "Enough for every Jack door left.", or "Its door stands open." once it is open.
- Test `test_a_key_shop_sells_no_key_without_a_door` (`test_economy.gd`). It checks that:
  - the world has one door of each card;
  - the first Jack Key sells and a second does not, at no cost;
  - the row says why, before and after the door opens;
  - the other cards stay on sale;
  - every key row fits three lines.
- `test_once_only_stock_sells_out` had asserted that Jack Keys could be bought again and again; it now buys one and finds the next says "Enough".
- Mutation check: with the "enough" check removed, four checks fail.
- Screenshot: `/mnt/project-files/pass-245/key_shop.png` (Sigrun's Locks holding a Jack Key: "Enough", greyed, with the reason in two lines).
- Bible 10.2, Key master row: "One key per door".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: a key shop no longer sells a key with no door to open. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 246 takes Audio (last pass 238).
