# Pass 227: the Sky Steps' veil

World's last pass (219) was the oldest apart from Art, so pass 227 takes World. Passes 216, 219 and 224 tried the "out of reach" secrets with the real controller. This pass turned to the critical path's ability gates. The Mattock rooms and secrets sit behind cracked stone, Fire's behind bramble and Thunder's behind conduits: all gate tiles, which a real jump cannot cross. The Stride's gate (`STRIDE_ROOMS`) rested on distance alone, the Sky Steps' gaps "past any jump".

| Check | Finding | Verdict |
| --- | --- | --- |
| Mattock, Fire and Thunder gates | Cracked stone, bramble and dead conduits are gate tiles. | fine |
| **The Stride's gate, the Sky Steps** | A probe ran the real controller from the top island toward the exit ledge (row 10). With the Wing Boots, 270 of 300 jump and second-jump timings landed on it, and a single running jump at the island's edge did too, with no boots at all. Daybreak, the Spire, Thunder and everything past them opened without the Stride. The reach checker said otherwise only because its jump envelopes are deliberately short. | **fixed: an elven veil** |

## As built

- `levels/daybreak/sky_steps.room`: an elven veil (`|`, pass 216) in column x33 from row 4 to row 9, from the ceiling down to the ledge's top. That is the only way onto the ledge and to the exit door.
- Reachability is unchanged. The checker already held these rooms shut without the Stride, and it treats `|` as solid until the Stride is found.
- New test `test_the_sky_steps_exit_needs_the_stride` (`test_abilities.gd`). With the boots, 27 jump and second-jump timings from the top island never stand on the ledge. With the Stride, a jump and a dash do. Mutation check: on the old room the first check fails (23 of 27 got there).
- Bible: Daybreak as built (the Sky Steps), and "The Stride's gate on the critical path" in 4.1.
- Screenshot: `/mnt/project-files/pass-227/sky_steps_veil.png`. The veil is a teal column between the last island and the ledge, plain against the storm sky.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the Stride now gates the critical path in play as well as on paper. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 228 takes Bosses (last pass 220, now the oldest). For World later: the Wing Boots' critical-path gate (the Mist's Victim side) could be tried with the real controller the same way.
