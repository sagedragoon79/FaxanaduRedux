# Pass 146: the dash buffer

Movement (98, weight 20) was tied for the lowest category apart from Art, and weighs the most. I checked bible 6 against `movement_tuning.gd` and the player, and how movement meets the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 6.1 to 6.11: run, slopes, jump, wall, double jump, dash, pogo, swim, wind, Feather Fall, ladders | built and asserted number by number | fine |
| Corner forgiveness on all four edges (passes 107, 111, 139) | built | fine |
| Victim (pass 145) | a flat boardwalk street, a plank loft one jump up, and a landing at the door; every person reachable (`test_everyone_in_victim_can_be_reached`) | fine |
| **Input buffering (6.2, 6.5, 6.7)** | The jump has a 0.12 s buffer and attacks have one, but the dash read only the frame it was pressed. A dash pressed a beat early was simply lost: on the 0.25 s cooldown after a dash, or in the air a frame before landing. It was also lost a frame before Wanderer's Grace (pass 142) gave the air dash back on a kill. The game was eating presses that players make on rhythm, and chaining two strides (Second Stride) took a frame-perfect second press. The existing `test_second_stride_gives_two_air_dashes` showed it: its second press fell on the cooldown and was dropped, and it counted two dashes only because the third press went. | **built** |

## As built (bible 6.5)

- **`dash_buffer_time` (0.10 s)** in `movement_tuning.gd`, under Dash. A press sets `Player._dash_buffer_timer`, and `_try_dash` reads the timer instead of the press. It spends the timer when the dash goes.
- A held press goes the first frame it can:
  - at the cooldown's end;
  - on a landing (as a ground dash);
  - when a kill with Wanderer's Grace, or a stride seed, gives the air dash back.
- Pressed more than 0.10 s early, it's dropped, not saved up.
- **No stale dashes:** without the Elven Stride a press isn't held. Otherwise a press made just before taking the Stride fired a dash the moment it was granted (`test_elven_stride_grants_the_dash` caught this on the first try).

## Found by the soak: falling back down a shaft

The Tower soak caught a second bug. The buffer changed its random walk, and it came up the Mine Vault's shaft into the Rail Gallery. You arrive inside the floor door you came up through, rising, and that door is ignored until you leave it so it doesn't send you straight back. The soak dashed into the shaft's wall, stalled and fell back, still inside the door. The door stayed ignored, so it fell out of the bottom of the room. In play, the fall rescue would then have set you back at your last safe footing, as if you had fallen into a pit. Any short hop up a shaft could do it.

`World._falling_back_through(n)` now takes a floor door you are falling through, even the one you came in by, so you drop back into the room below. `test_falling_back_down_a_shaft_takes_the_door_down` (`test_world.gd`) arrives in the Rail Gallery from the vault, stalls and falls. Against the old code it fails: you drop out of the room and stay in the gallery. Now it returns you to the vault. Bible 3.3 has a line on it.

## Report

`/mnt/project-files/pass-146/report.txt`: the windows where a press used to be dropped, and what happens to it now.

## Tests

- `test_abilities.gd`, `test_a_dash_pressed_early_is_held_for_a_moment` (new):
  - a press 4 frames before the cooldown ends waits, then goes as it ends without a second press;
  - a press 0.2 s too early is dropped;
  - with the air dash spent, a press just before landing is a ground dash on the landing;
  - with Wanderer's Grace and no dash left, a press waits, and `on_kill()` gives the dash back and the held press dashes in midair.
- `test_economy.gd`, `test_second_stride_gives_two_air_dashes`: the presses now wait out the dash and its cooldown, so the test counts what it means to.
- `test_movement.gd`: the bible-numbers test asserts `dash_buffer_time == 0.10`.

Full suite: 2685 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Every move now forgives an early press, as the jump and the attack already did. |
| Combat and enemies | 15 | 98 | Unchanged. |
| World and level design | 15 | 98 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | Unchanged. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Unchanged. |

Weighted score: 96.1125 (up from 96.0625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Systems, Audio, Stability and Faithfulness are tied at 98. Combat and World weigh the most (15 each), so pass 147 takes Combat.
