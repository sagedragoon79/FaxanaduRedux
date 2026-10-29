# Pass 248: sap in the spec

Category: Movement (last pass 240).

## Audit

I checked bible 6 against `MovementTuning` and the player's code: every number, the buffers and coyote time, and the moves where they meet (ladders, water, wind, sap, ledges, the Hour Glass). Coyote time and dashing off a ledge agree, the dash and jump buffers hold, and the ladder and water cases are pinned.

The gap found: sap. It is the Trunk Hollows' one movement hazard (and a Sap Spitter's puddles), and it was the one place a movement number lived outside the spec. `Player.SAP_SPEED` (0.5) and `SAP_JUMP` (0.72) were constants in `player.gd`. They were not in `MovementTuning` or in bible 6, so nothing said what sap holds and what it leaves alone. CLAUDE.md asks for every movement number to be in the tuning file and to match bible 6.

## Fix

- `MovementTuning` gains a Sap group: `sap_speed` 0.5 and `sap_jump` 0.72. The player reads them from there, and the constants are gone.
- Bible 6.12, Sap:
  - when you are in it;
  - the run at 50% (82 px/s);
  - the ground jump at 72%, 288 px/s, about 37 px;
  - what it doesn't hold: the double jump, the wall jump and the dash;
  - leaving it, the feel, and the Spring of Trunk hardening the pools.
- The section intro now counts 6.12 among the pinned sections.
- Tests:
  - `test_sap_numbers_match_bible_6_12` (`test_movement.gd`) checks the numbers, the section and the jump height they give.
  - `test_sap_never_holds_a_dash_and_lets_go_at_its_edge` (`test_rooms.gd`) checks that you wade at half a run, a dash in the sap goes at full speed, and the run comes back at once past the pool's edge.
  - `test_sap_slows_running_and_jumping` now reads the tuning.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: the last movement number outside the spec is in it. |
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

Pass 249 takes Faithfulness (last pass 241).
