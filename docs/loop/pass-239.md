# Pass 239: a won fight stays won

Stability's last pass (231) was the oldest apart from Art, so pass 239 takes Stability.

| Check | Finding | Verdict |
| --- | --- | --- |
| Frame budget and soaks | The journey soaks, every-room budget and boss-fight frame audit (passes 99, 166, 174, 182) all pass in the full run. | holds |
| Saves | Damaged saves, old ids (`RENAMED_ITEMS`, `MOVED_PICKUPS`) and settings isolation (passes 215, 231) are covered. | holds |
| Engine errors and test isolation | The runner fails a test that logs an engine error or leaves global state changed. | holds |
| **Dying during a boss win** | A guardian takes 1.2 to 2.5 s to die before its arena opens. Leftover hazards and blows already swung stayed live in that window. A probe showed a trade at the killing blow: the king dead, the hero dead, then a respawn at the last rest with no flag and no Dragon Slayer. The win was lost. | **fixed** |

## As built

- `BossArena.falling()`: true from the guardian's killing blow until the arena opens. `BossArena.any_falling(tree)` asks every arena.
- `Player.take_damage` (the only place the hero loses health; `receive_attack` goes through it) returns early while any guardian falls.
- `test_a_guardians_win_cant_be_lost_while_it_falls` (`test_boss.gd`, new). In King Grieve's throne hall, his blow lands before the killing blow. After it, `falling()` is true and a 500 damage blow does nothing. Once the doors open, the flag and the Dragon Slayer are kept and `falling()` is false again.
- Mutation check: with the guard disabled, the test fails (hp 0, dead).
- Bible 8 ("A won fight stays won") and 15.3 Stability measures.
- No visual change, so no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged score: a boss win can no longer be lost to a trade. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 240 takes Movement (last pass 232, now the oldest).
