# Pass 200: the run and the jump, held to the bible

Movement's last pass (192) was the oldest apart from Art, so pass 200 takes Movement. I audited movement and game feel (bible 6) against passes 193 to 199, and checked that the tests hold every movement number to the bible, as CLAUDE.md asks.

| Check | Finding | Verdict |
| --- | --- | --- |
| Zone threat (passes 194 and 196) | Deeper zones hit harder, but a hit moves you the same everywhere: 0.8 s of invulnerability, the same knockback and a 0.18 s lock on steering only. Jump, double jump and dash still work during the lock. Damage changed, movement did not. | fine |
| The coins (pass 199) | Coins fly to you at 320 px/s from 100 px away, faster than a run (165), so a dash past a purse still collects it. | fine |
| The heavy hurt sound (pass 198) | Sound only. | fine |
| **The tests hold the numbers** | `test_movement_numbers_match_bible_6_2_to_6_6` and the ladder, wind and swim checks hold their numbers to the bible. Section 6.1 and the core of 6.2 had no such check: run speed, acceleration, deceleration, the turn, jump height and apex time, the fall gravity, the jump cut, the fall limits, and air acceleration and deceleration. Their play tests read the values back from `MovementTuning`, so a changed number would have moved its test with it. Four of these numbers had no play test at all: the turn's 1.6x brake, the jump cut's 0.45, the fall's 1.6x pull and the 620 px/s fall while holding Down. | **fixed: the numbers are checked against the bible, and the four get play tests** |

## As built

- `test_movement.gd`:
  - `test_movement_numbers_match_bible_6_1_and_6_2` (new) checks all sixteen numbers in 6.1 and 6.2 against the bible, including the derived gravity and jump velocity and the apex hang. It also checks 5.3's 0.8 s of invulnerability after a hit.
  - `test_a_turn_brakes_harder_than_letting_go` (new): letting go brakes at 2,600 px/s², pushing the other way brakes at 1.6x that, and you reach full speed the other way within 9 frames. With the multiplier set to 1.0 it fails, as it should.
  - `test_letting_go_of_jump_cuts_the_rise` (new): releasing Jump keeps 0.45 of the rise.
  - `test_a_fall_pulls_harder_and_down_falls_faster` (new): a fall pulls at 1.6x the rising gravity, tops out at 520 px/s, and at 620 px/s holding Down.
- Bible 6, introduction: which tests hold the numbers.
- No movement number changed. Every new play test passed on the first run, so the game already matched the bible.

Full suite: 3872 of 3872 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: the core run and jump numbers are now held to the bible, not just read back from the tuning. |
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

Pass 201 takes Faithfulness (last pass 193, now the oldest).
