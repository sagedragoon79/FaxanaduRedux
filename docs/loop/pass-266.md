# Pass 266: a brood that dies with its guardian pays nothing

Category: Combat (last pass 258).

## Audit

I read bible 5 and 7 against the newest combat pieces:
- the Liliths;
- the Rune Dagger's sting;
- shields warding sorcery;
- the brood rules from passes 257 and 258.

Telegraphs, the damage sheet and the ward all hold. The gap was in how a guardian's brood dies with it. Three guardians take their summons down when they fall:
- the Bloom, with its Liliths;
- the Matriarch, with her daughter;
- the Clockwork Alpha, with its hounds.

Each did it the way a blow would. Pakukame and the Matriarch called `take_hit(hp)`, and the Alpha called `die()`. So every one of those deaths went through the full kill path:
- it sprayed gold and rolled a drop (bread, mana, poison, the rare War Glove or Ointment);
- it gave experience;
- it called `Player.on_kill`, so Wanderer's Grace refilled the air dash;
- it added a kill's hitstop and a 0.25 shake on top of the guardian's own death.

None of that was the player's doing. Felling the Alpha with two hounds left, for example, rained two hounds' purses and drops over its death, and froze the moment three times over.

## Fix

- `Enemy.perish()`: the foe dissolves and plays its death sound as usual. But `perished` is set, so `die` pays no gold, drop or experience, does not call `on_kill`, and adds no kill hitstop or shake. `_respawn` clears it.
- The Bloom, the Matriarch and the Alpha now `perish` their brood.
- Test: `test_a_brood_that_dies_with_its_guardian_pays_nothing` (`test_combat.gd`). It checks three things:
  - a Monodron that perishes gives no experience, no coin and no drop (with bread forced to drop), and does not count as a kill for Wanderer's Grace;
  - the same foe struck down pays all of it;
  - no guardian script kills anything with `take_hit(x.hp)` or a bare `x.die()`.
- Mutation check: with Pakukame's old `take_hit(l.hp)` put back, the scan fails.
- Bible 5.5 and 8.5.

No screenshot, since nothing visible changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: only the player's blows pay. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 267 takes World (last pass 259).
