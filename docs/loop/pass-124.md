# Pass 124: ladders

Movement (97) was tied for the lowest category apart from Art and weighs the most. Every number in bible 6.1 to 6.10 is built and asserted, so I audited how movement meets the newest content and the original game.

| Check | Finding | Verdict |
| --- | --- | --- |
| Pogo on the Spire Sentinel | its stone turns the blow, but the bounce still lands, so you can pogo off it like any foe | fine |
| Turning to face the Sentinel mid-climb | it freezes at once; nothing it does pushes or pins you | fine |
| Card vaults, slopes, trials, wind, water | covered by passes 115 to 121 and their tests | fine |
| **Ladders** | The original Faxanadu is a game of ladders: every climb between floors went up one. The remake had none, though bible 13.3 lists ladders in every tileset. Its wall jumps, double jumps and pods do the hard climbs, but there was no plain way up between floors that needs no ability. | **built** |

## As built (bible 6.11)

- **Legend `"`:** a column of ladder cells. The top cell is also a plank (a one-way platform), so you can stand on a ladder's top.
- **Taking hold:**
  - Up with your body on a ladder, on the ground or in the air;
  - or Down while standing on its top.
  - Not mid-dash, mid-swing, swimming or drinking.
  - Taking hold refreshes the double jump and the air dash.
- **Climbing:**
  - 90 px/s up or down, with no gravity, so you hang when you let go.
  - You slide onto the middle of the rungs at 240 px/s.
- **Leaving:**
  - Climbing past the top steps you onto its plank.
  - Climbing down onto a floor lets go, and climbing off the bottom of a hanging ladder lets you fall.
  - Jump leaves with a full ground jump the way you hold, and a stride leaves and dashes.
  - Any damage knocks you off.
  - The same ladder can't be grabbed again for 0.25 s.
- **No attacks while climbing,** as in the original.
- **Feel:**
  - the wall pose's reach, which cycles only while you move;
  - `ladder`, a hollow knock and a creak of the rungs, about every 8 px climbed.
- **Look:** two wooden rails and two rungs a tile, drawn in code behind the tiles so the top plank caps them.
- **Numbers:** `MovementTuning`, Ladders group: `ladder_speed` 90, `ladder_snap` 240, `ladder_regrab` 0.25.
- **Reachability:** the checker (`Reach.LADDER`) climbs ladders. A spot with the feet on a ladder is a standing spot, the top is a plank, and a jump from a ladder is a floor jump.
- **Placed:**
  - the Hollow Mouth, the first room of the Trunk, as in the original's first screen out of Eolis: a ladder from the floor up to the high plank under the way to the Mossy Overhang;
  - the gym, a ladder from the lower floor up through the upper one.
- **Sound:** `ladder` was rendered with `sfxgen.py` (-13.8 dB RMS). `levels.py --check` passes, and I checked out the unrelated sound effects that `sfxgen.py` rewrote.

## Screenshots

`/mnt/project-files/pass-124/hollow_mouth_ladder.png`: the Hollow Mouth with its ladder up to the high plank.

## Tests

In `test_movement.gd`:
- `test_ladders_climb_hang_and_step_off_the_top`:
  - Up takes hold;
  - you climb at ladder speed with no gravity, centered, in the climbing pose;
  - you hang when you let go;
  - you step onto the top plank;
  - Down on the top takes hold again;
  - climbing down onto the floor lets go.
- `test_ladders_jump_off_hits_and_hanging_ends`:
  - a jump off is a full jump to the side;
  - there's no instant regrab;
  - a blow knocks you off;
  - a hanging ladder is caught from the air, and climbing off its bottom drops you.
- `test_ladder_numbers_match_bible_6_11`.

In `test_reachability.gd`:
- `test_checker_climbs_ladders`: a loft is reachable only with its ladder, and the ladder is the way back down.

## Bible

- 6.11 Ladders (new).
- `levels/README.md`: legend `"`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | A new traversal verb, the original's own, with its numbers asserted. |
| Combat and enemies | 15 | 97 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). The climb reuses the wall frames; an Autosprite climb clip is noted for the art phase. |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 97 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97.25 | Ladders are back, starting from the first room out of Eolis. |

Full suite: 2440 checks. One frame-time check (`test_a_long_journey_through_the_whole_game_stays_lean`) spiked once under the full run's load, at 58.6 ms in the Eolis market, a room with no ladder. It passed on two reruns alone, and CI runs it again.

Weighted score: 95.375 (up from 95.3125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Systems, Audio and Stability are tied at 97. Combat and World weigh the most; pass 125 takes World: placing ladders where the original had them, in rooms where they read better than one-way stairs.
