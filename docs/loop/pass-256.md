# Pass 256: the swing's timing in the spec

Movement's last pass (248) was the oldest apart from Art, so pass 256 takes Movement.

| Check | Finding | Verdict |
| --- | --- | --- |
| Input through a freeze | A probe held Jump while `Engine.time_scale` was 0, as in a hit-stop. Physics frames still run in Godot 4.7, with a delta of 0, so the player reads the press, sets its buffers, and the buffers wait out the freeze. Nothing is dropped. | holds |
| Input across menus, dialogs and doors | The press that closes a menu is eaten (`closed_frame`). A dialog's closing press lands in the physics frame before the player is unfrozen. A frozen player clears its input through a door. | holds |
| **Every `MovementTuning` number in bible 6** | I checked each of the 60 numbers against the bible's text and the tests. All but two are in a table and held by a test. `slash_active` (0.10 s) and `attack_cooldown` (0.28 s, the up-slash's and down-strike's recovery) were in no table. No test asserted `attack_cooldown`, and only one read `slash_active` back. Section 6's intro says every number is held to the text, and these two were not. | **fixed** |

## As built

- Bible 6.6 gains a "Swing timing" row. A slash or up-slash cuts for 0.10 s and the down-strike for 0.14 s. An up-slash or down-strike recovers for 0.28 s. A press in the last 0.15 s is held. The side combo's recoveries are 5.3's `combo_cooldowns`, and the blade's swing speed scales them all (5.2).
- `test_movement_numbers_match_bible_6_2_to_6_6` now asserts `slash_active` 0.10 and `attack_cooldown` 0.28.
- `test_an_up_slash_cuts_then_recovers_as_6_6_says` (`test_movement.gd`, new). Up and Attack on the floor is an up-slash. It cuts for 6 frames, and with Attack pressed every frame the next swing comes 17 frames on.
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every number in the tuning is now in the bible and held by a test. |
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

Pass 257 takes Faithfulness (last pass 249, now the oldest).
