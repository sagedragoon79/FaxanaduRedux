# Pass 240: a dash press keeps you on the ladder

Movement's last pass (232) was the oldest apart from Art, so pass 240 takes Movement.

| Check | Finding | Verdict |
| --- | --- | --- |
| Numbers | `movement_tuning.gd` matches bible 6, and `test_movement.gd` asserts every group. | holds |
| Coyote time, jump and dash buffers | Passes 111 and 146. Water counts as footing, and a dash press is held only with the Stride. | holds |
| Wall, double jump, pogo, glide, wind, swimming | Each has its own tests, and pass 238 gave the wall slide its rasp. | holds |
| **Ladders and the dash** | Bible 6.11 says a stride leaves the ladder and dashes. The code let go on any dash press, so before the Elven Stride (most of the early game, where every ladder is), the Dash button dropped you off the rungs with no dash. The same happened on the ground dash's 0.25 s cooldown, for example when you dashed up to a ladder and grabbed it. | **fixed** |
| Ladders and attacks, throws, drinking | These are never reached on the rungs: the ladder step returns before them. | holds |

## As built

- `Player`: the ladder lets go for a dash only when one is held in the dash buffer (which needs the Stride) and the cooldown is over. A press on the cooldown waits in the buffer and goes when the cooldown ends.
- `test_a_dash_only_lets_go_of_a_ladder_when_it_dashes` (`test_movement.gd`, new). Without the Stride, a dash press keeps you hanging where you were. With it, you leave the ladder dashing, more than 40 px to the side.
- Mutation check: with the old condition, the test fails (you fall 45 px off the ladder).
- Bible 6.11 (the Dash row).
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: one more ability edge closed. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 241 takes Faithfulness (last pass 233, now the oldest).
