# Pass 223: the Hydra soak, made certain

Stability's last pass (215) was the oldest apart from Art, so pass 223 takes Stability. I audited the soaks, engine errors, saves and test reliability against passes 216 to 222, starting with the Hydra soak, which failed once in pass 220 and passed on rerun.

| Check | Finding | Verdict |
| --- | --- | --- |
| Full suite on main | Green on CI for every pass since 215. Engine errors still fail a test. | fine |
| Pass 222's win sting | Covered in every arena by the win sweep. Effects stay under the node ceiling. | fine |
| **Hydra soak flake** | Seed 23 passed 40 of 40 runs alone and 6 of 6 after the other fight soaks, so I seeded the soak 1 to 30. 13 of 30 failed, every one ending in phase 2 at exactly 30,000 of 99,999 HP. The soak pushes health onto the 0.3 mark with `roundi`, which gives 30,000. That is 0.300003, just above the mark, so phase 3 came only if a mashed blow happened to land afterwards. The engine's global random rolls (unseeded) decide that, hence the rare failure. | **fixed** |

## As built

- `test_soak.gd`: new helper `_push_to_mark(boss, mark)`, which rounds down. The Hydra soak and the soak before it push their phases with it, reading the Hydra's marks from `Zorugeriru.PHASES`.
- The Hydra soak now checks that the push at two thirds floods the arena right there, so a miss names its cause.
- Verified: with seeds 1 to 30, 30 of 30 pass (17 of 30 before).
- No game code changed. The game's own phase checks use "at or below the mark" and are sound.
- Bible 15: "A soak that pushes a phase lands on it".

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
| Stability and performance | 5 | 99 | Unchanged score: the suite's one known flake is gone. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 224 takes Movement (last pass 216, now the oldest).
