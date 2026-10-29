# Pass 260: the rush wins nothing, really

Category: Bosses (last pass 252).

## Audit

I read bible 8 and the boss rush (bible 11), looking at what pass 257's Liliths changed. The rush promises "nothing is won again: no rings, keys, flags or gold".

`BossArena._on_defeated` honors that for what the arena hands out. But a guardian's real death also pays on its own. Rokusutahn sprays his gold and gives his experience in `_finish`, and every other guardian pays through `Enemy.die`. Neither asked whether a rush was on, and every foe a guardian calls in (Liliths, the Matriarch's daughters, the Alpha's hounds) paid the same way. A rush won some 3,000 experience and a purse of gold each time, which is enough to buy ranks and skill points.

`test_the_boss_rush_runs_every_guardian_again` never saw it, because it ends each fight by emitting the arena's `defeated` signal rather than by a real death.

## Fix

- `Enemy.die` sprays no gold, rolls no drop and gives no experience while `BossRush.active()`. Everything else about a death is unchanged.
- Rokusutahn's `_finish`, which pays on its own, asks the same question.
- New test `test_a_boss_rush_kill_wins_no_gold_or_experience` (`test_systems.gd`):
  - It starts a rush, walks into Rokusutahn's arena and kills him for real, plus a foe beside him.
  - It checks that the rush goes on, no experience is won, and no coins or drops are left.
  - It checks that outside a rush a kill still pays.
  - It checks that every boss or enemy script that pays gold or experience on its own asks `BossRush.active()` first.
- Mutation checks: before the fix the test found 200 experience and 16 coins. With the `Enemy.die` guard removed it fails again.
- Bible 11, the boss rush paragraph.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the rush keeps its promise for real deaths. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 261 takes Systems (last pass 253).
