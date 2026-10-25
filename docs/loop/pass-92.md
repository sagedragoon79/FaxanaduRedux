# Pass 92: Wind currents in the Branches

The bible gives the Branches "wind currents" as their zone mechanic (section 3), and the Spring of Sky's world-state row has listed "wind currents reverse in the Branches (new routes)" as still to come since pass 62. Movement is the lowest category apart from Art, so this pass builds both.

## What changed

- **`WindCurrent`** (new, `scripts/world/wind_current.gd`): legend `>` (east) and `<` (west); each block is one current.
  - While you are airborne and the middle of your body is in it, it adds 200 px/s to your horizontal target speed (`Player.wind`, set each frame like `updraft`).
  - A fall eases level (2,400 px/s²), so you sail the band. A jump still rises through it.
  - Standing on a floor inside it, you aren't moved. Hold Down to drop out.
  - Drawn as a faint wash with streaks racing downwind and torn leaves.
- **The reversal:** once the Spring of Sky is restored (`spring:sky`), every current blows the other way.
- **Movement numbers:** `wind_speed` and `wind_drag` in `movement_tuning.gd` (Wind group); bible section 6.9 is new.
- **Rooms:**
  - Thicket Road: a current blows east across the open sky past a sealed niche in the canopy wall. The niche opens east, toward the current's far end, so before the Spring you are carried away from it. After the Spring the wind blows west, straight into it, and a chest waits inside.
  - Canopy Bridge: a high current over the thorn pit, a shortcut across in the air, which turns round after the Spring.
- **The checker** (`Reach`): a jump or fall that enters a current rides it downwind (turned by `sky_spring`), adding every spot it can stand on or drop to with Down, and lands or falls on at the band's end. The niche's chest is listed in `WIND_SECRETS`: it is reachable only with the turned wind.

## Tests

`test_movement.gd`:
- `test_a_current_carries_you_and_bears_you_level`
- `test_a_current_doesnt_move_you_on_a_floor`
- `test_the_spring_of_sky_turns_the_wind`
- `test_wind_numbers_match_the_bible`

`test_reachability.gd`:
- `test_checker_rides_wind_currents_downwind_only` (a synthetic room: a ledge reached only downwind)
- `test_the_turned_wind_reaches_the_thicket_niche` (with the full kit and the Spring of Sky). The earlier pickup checks leave the niche out.

Full suite: 1745 checks, all passing.

## Screenshots

`/mnt/project-files/pass-92/`:
- `thicket_current.png`: the Thicket Road current blowing past the sealed niche and its chest.
- `canopy_current.png`: the Canopy Bridge current over the thorns, after the Spring of Sky.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 92.25 | A new traversal verb for the Branches: sailing on the wind. |
| Combat and enemies | 15 | 92.25 | Unchanged. |
| World and level design | 15 | 97 | The Branches finally have their zone mechanic, and the Spring of Sky opens a new route. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.25 | Unchanged. |
| Systems | 10 | 92.25 | Unchanged. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 95 | The bible's wind currents and their reversal are in. |

Weighted score: 92.45 (up from 92.30).

## Next

Combat, Systems and Stability are now the lowest apart from Art. Pass 93 takes the final shop tier (the last deferred Spring of Sky change), which lifts Systems.
