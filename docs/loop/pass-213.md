# Pass 213: a moved pickup stays taken

Systems' last pass (205) was the oldest apart from Art, so pass 213 takes Systems. I audited the save, economy and menu systems against passes 206 to 212.

| Check | Finding | Verdict |
| --- | --- | --- |
| Big coins (206) | Sound only. The purse and its tests are unchanged. | fine |
| Missing sounds (207), hit-stops (208, 210) | No save or menu state is involved. | fine |
| Shops (209) | The stock and its test match the original towns. | fine |
| Zoradohna's health (212) | Her purse and reward don't depend on her health. | fine |
| **The North Bough cache (211)** | A pickup's id is its room and cell (`Room._pickup_id`). Pass 211 moved the Life Fruit from (8,7) to (9,6), so a save that had taken it would find a second Life Fruit, +1 max mask for free. Nothing in the build records a moved pickup. | **built `GameState.MOVED_PICKUPS`, and a test** |

I wrote a script that walks every commit to `levels/` and lists each pickup that vanished from a room in the same commit that the same pickup appeared elsewhere in that room. It found two moves: the Drowned Nave's Mantra Shard (pass 67, (31,5) to (31,6)) and the North Bough's Life Fruit (pass 211).

## As built

- `GameState.MOVED_PICKUPS` maps each old id to its new one. `sanitize` marks the new id as taken and drops the old one.
- `test_a_moved_pickup_stays_taken` (new) runs each move through `sanitize`, and checks that each old cell is empty in its room file and each new cell holds a pickup, so the list can't go stale. It also checks that a save that took nothing still has nothing taken.
- Mutation check: without the carry-over, the test fails.
- Bible 15 ("Saves and settings"): a Moved pickups line. `levels/README.md`'s rules of thumb tell anyone who moves a pickup to add it to the list.
- There is no visual change, so this pass has no screenshot.

Full suite: 4034 of 4034 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: old saves no longer gain a free Life Fruit or Mantra Shard after a pickup moves. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 214 takes Audio (last pass 206, now the oldest).
