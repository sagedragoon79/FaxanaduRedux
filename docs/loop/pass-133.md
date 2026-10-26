# Pass 133: the camera looks up

Movement (97.5, weight 20) was tied for the lowest category apart from Art and weighs the most. I audited bible 6 against what is built, and how movement meets the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Run, jump, wall, double jump, dash, pogo (6.1 to 6.6) | every number built and asserted | fine |
| Swimming, wind, Feather Fall, ladders (6.8 to 6.11) | built and asserted; the ladder camera lead came in pass 130 | fine |
| Hidden rooms (pass 131) | floor-level fake walls you walk into; nothing new to move through | fine |
| The Death spell's cast (pass 132) | casts like any spell, with no stop or lunge | fine |
| **The camera (6.7)** | Holding Down while standing still looks down 72 px, but there was no look-up. The world is full of tall shafts climbed by planks (the Tower, the Mine Shaft, the Drowned Stair, Windward Climb). In them, the next landing above was often off the top of the screen, and a jump was a guess. | **built** |

## As built (bible 6.7)

- **`GameCamera.LOOK_UP` (72 px):** holding Up while standing still on the floor for 0.4 s (the look-down's delay) eases the view up 72 px. Letting go eases it back.
- On a ladder, Up climbs instead, and the climb lead from pass 130 takes over. Down wins if both are held.
- Like the look-down, it stays inside the room's bounds, so near the bottom of a room there is no room to look and it shows little.

## Screenshots

In `/mnt/project-files/pass-133/`:
- `mine_shaft_still.png`: standing on the Mine Shaft's west ledge.
- `mine_shaft_look_up.png`: the same spot with Up held, framing the planks and the shelf above.

## Tests

`test_juice_camera_and_feel_numbers_match_the_bible` (`test_abilities.gd`) now also checks:
- look-up is 72 px;
- holding Up for 0.3 s doesn't look up yet;
- holding it longer does;
- letting go eases back.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Tall shafts can be read before the jump. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2501 checks, all passing, with no script errors in the log.

Weighted score: 95.75 (up from 95.7). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Systems, Audio and Stability are tied at 97.5. Combat and World weigh the most (15); pass 134 takes Combat.
