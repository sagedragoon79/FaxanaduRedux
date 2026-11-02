# Pass 404: a guardian fought with the buttons

## Category

Bosses (last pass 396).

## Audit

- The bosses section (bible 8) is well held. Every guardian has tests for its moves, phases and reward, and `test_telegraphs_are_fair` and its siblings check each tell against `Enemy.MIN_TELEGRAPH`. The rush and the arena seals are tested too.
- The pass 396 rests are held by `test_every_guardian_is_a_door_from_a_rest`. Since pass 403, the map marks them.
- The gap: no boss fight had ever been driven by the real controller. Passes 384 to 402 drove the hero's moves, the fight's buttons and the menus through `Input`. Every boss test still scripted the hero's intent or called the boss's own `hit_segment`. So the path from a pad to a fight was never driven by the buttons a player presses: walking in, the doors sealing, a sealed door refusing you, the last blow, the doors opening, and the way on.

## Fix

`test_a_guardian_falls_to_the_real_controller` (test_boss.gd) fights Rokusutahn, the first guardian, with `Input` alone:

- Holding Right walks into the Root Chamber, wakes it, and seals both doors.
- Holding Left into the sealed way in does not leave the room.
- When a stuck lunge leaves the tail by the wall, Attack pressed beside it lands the last blow.
- It shatters and the doors open. The Elf Ring is won.
- Holding Right walks out through the opened door, high in the east wall, to the Spring of Trunk.

The test sets `GameState.slot` to its own slot 9 and puts it back afterwards, and it leaves no save file behind.

Bible 8 gains "A guardian fought with the buttons (pass 404)". `zorugeriru.gd` is untouched.

Mutation check: with `BossArena._open_doors` doing nothing, the test fails twice: the doors never open and Right cannot walk out.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A guardian is fought start to finish through the real controller. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 405: Systems.
