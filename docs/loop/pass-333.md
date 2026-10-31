# Pass 333: the skill tree's price, added up

Category: Systems (last pass 325).

## Audit

- **Skill points.** `test_the_journey_counts_every_skill_point_the_game_gives` holds bible 9's 34 points: 15 ranks, 12 guardian points and 7 from Mantra Shards and trials. Pass 332 now holds each guardian's point to its Reward line.
- **The tree's price.** Bible 9 says "a tree planned at **54** in all (49 as built, over 27 nodes)". The list below it (three branches of twelve, costs in brackets) adds up to **68**. 54 was the first draft's total; the list was never summed against it. The built half (49 over 27 nodes) is right, but no test held it, or any node's bracket, to `data/skills.json`. The existing tests only hold the tree's cost above 34.
- **Shops and prices** are held by the 10.2 table test and the shelf-price test (pass 277 and earlier). **Saves and settings** are held by the snapshot leak check (327) and the mercy test (325). **Keys** are held by the one-key-per-door tests (245).

## Fix

- Bible 9: "planned at **68**", with a note on the old 54.
- Test: `test_the_bible_prices_the_skill_tree_as_built` (test_economy.gd).
  - It reads the 36 planned nodes and their brackets and sums them against the stated plan.
  - Each built node's bracket must match its cost in the code.
  - The built total and node count must match the code.
- Mutation checks: the old bible fails on the plan's total. Executioner at 4 points fails both its bracket and the built total.

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the tree's plan, its build and each node's cost are now held. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 334 takes Audio (last pass 326).
