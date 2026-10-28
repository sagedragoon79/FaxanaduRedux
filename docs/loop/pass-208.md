# Pass 208: the last movement numbers pinned

Movement's last pass (200) was the oldest apart from Art, so pass 208 takes Movement. I audited `movement_tuning.gd` against bible 6, number by number. For each number I checked whether a test holds it to the bible's text, or only reads it back from the tuning, in which case changing the number would quietly move its test along with it.

| Check | Finding | Verdict |
| --- | --- | --- |
| 6.1, 6.2, ground and jump | Pinned in passes 107 and 200, and in 183 for the analog walk. | fine |
| 6.3 to 6.5, wall, double jump, dash | Pinned in pass 107. | fine |
| 6.8, 6.9, 6.11, swim, wind, ladders | Each has its own numbers test. | fine |
| Passes 201 to 207 | None of them touched movement. The Pendant and the Rod only change damage, and no new ability changes how you move. | fine |
| **6.6, the pogo's hit-stop** | The bible says 45 ms, but it was a bare `0.045` in `player.gd`, outside `movement_tuning.gd`. CLAUDE.md says movement numbers live in the tuning. | **moved: `MovementTuning.pogo_hitstop`** |
| **6.6, the bounce-pod; 6.10, the glide** | The pod's 600 px/s and the glide's 60 px/s and 1,500 px/s² were checked only by play tests that read the tuning back. | **pinned** |

## As built

- New `MovementTuning.pogo_hitstop` (0.045). The pogo bounce now uses it.
- `test_movement_numbers_match_bible_6_2_to_6_6` now also holds the pogo hit-stop, the pod's launch, the glide's fall speed and brake, and the slash recoil (5.3) to the bible's numbers.
- Mutation check: a 60 ms `pogo_hitstop` fails `test_pogo_numbers_match_the_bible`, which shows the bounce reads the tuning.
- Bible 6 intro: every number in 6.1 to 6.6 and 6.8 to 6.11 is now pinned, with a note on what this pass added.
- No numbers changed, so the feel is unchanged.

Full suite: 4011 of 4011 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every number in bible 6 is now held to the text. |
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

Pass 209 takes Faithfulness (last pass 201, now the oldest).
