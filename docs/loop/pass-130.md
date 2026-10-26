# Pass 130: the camera looks up the ladder

Movement (97.25, weight 20) was tied for the lowest category apart from Art and weighs the most. I audited how movement meets the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Slopes, wind, water, trials | covered by passes 115 to 121 and their tests | fine |
| Card vaults | plain rooms behind a door; nothing new to move through | fine |
| Spire Sentinel | a pogo off its stone bounces like any foe (pass 124) | fine |
| Ladders: grab, climb, top, bottom, jump, dash, hits | all as bible 6.11, with tests | fine |
| **Ladders: the camera** | While you climbed, the camera kept its 48 px sideways look-ahead and gave no lead up or down. On the Mine Shaft's ladder, 31 tiles tall, you climbed with the deadzone holding you near the edge you were heading toward. You saw more of where you had been than where you were going. | **fixed** |

## As built (bible 6.7 and 6.11)

- **`GameCamera`:**
  - On a ladder, the camera leads 64 px (`CLIMB_LEAD`) the way you climb, eased over 0.5 s (`CLIMB_LEAD_EASE`).
  - The sideways look-ahead eases to the middle, since you are centered on the rungs.
  - Hanging still keeps the lead you had, so you can stop and look.
  - Stepping or jumping off eases it back.
- **Screenshots:** a `--shot-climb=1|-1` game option holds Up or Down from the start.

## Screenshots

`/mnt/project-files/pass-130/mine_shaft_climb.png`: about a second and a half up the Mine Shaft's ladder. The player is in the lower part of the frame, and the shaft above is in view.

## Tests

- `test_the_camera_leads_the_way_up_or_down_a_ladder` (`test_movement.gd`), new:
  - the numbers match the bible;
  - there is no lead off a ladder;
  - climbing up leads up and drops the sideways look-ahead;
  - hanging keeps the lead;
  - climbing down leads down;
  - stepping off eases the lead back.
- The existing camera feel test (`test_abilities.gd`) passes unchanged.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.5 | Ladders frame the climb, the last piece of their feel the camera owed them. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2475 checks, all passing, with no script errors in the log.

Weighted score: 95.6375 (up from 95.5875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World and Faithfulness (97.25) are the lowest apart from Art. World weighs more, so pass 131 takes World.
