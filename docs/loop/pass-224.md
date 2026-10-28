# Pass 224: the wind lets go at a wall

Movement's last pass (216) was the oldest apart from Art, so pass 224 takes Movement. Pass 216 left a follow-up: every "out of reach without X" claim that rests on distance rather than height or a gate tile should be tried with the real controller, because the reach checker can prove "reachable" but never "out of reach". Pass 219 did the Sky Steps' purse. This pass did the other two.

| Check | Finding | Verdict |
| --- | --- | --- |
| Tuning against bible 6 | Every number is still pinned by a test. No movement code had changed since 216. | fine |
| Amber Falls' alcove (`AMBER_SECRETS`) | A height gate. The nearest floor that leads under it (the shaft at row 22) is 128 px below its floor, and a double jump peaks at 120. I probed 768 runs from the shaft; none got there. | fine |
| Thicket Road's wind-niche (`WIND_SECRETS`), against the wind | I probed 624 runs from the shelf with the Wing Boots and the Stride (jump, second jump and air dash west at every timing in 3-frame steps). None got in: the closest stopped 6.7 tiles short. | fine |
| **The niche once the wind turns** | With the Spring of Sky restored, a jump into the band rode west to the niche and stopped dead. The body is 40 px tall, the wind holds you level, and it held the head 16 px up against the niche's lintel. The player hung there forever, out of reach of the 4 px head correction. Only holding Down (dropping out of the wind) let you in. The reach checker counts that drop, so the secret passed its test, but in play the reward looked blocked. | **fixed** |

## As built

- `Player._pinned_by_wind()`: a current pressing you into a wall no longer bears you up. Gravity takes over and you slide down the face. Below the lintel the wind carries you in, and you land on the niche's floor.
- New test `test_the_wind_niche_needs_the_spring_of_sky` (`test_abilities.gd`). Against the wind, 42 timings with the boots and the Stride never get in. With the wind turned, one jump and a second jump do. Without the fix, the second check fails: the player hangs at x 43.4.
- Every wind test still passes (`current` and `wind` filters, including the Mantra of Winds trial).
- Bible 6.9: an "Against a wall" row.

No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: a current no longer pins you to a wall. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 225 takes Faithfulness (last pass 217, now the oldest).
