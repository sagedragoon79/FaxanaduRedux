# Pass 67: the Hour Glass

Dartmoor's second item (bible A8), with time-locked water and the Waterfall Stair.

## What changed

- **Time stop** (`scripts/world/time_stop.gd`, static `TimeStop`):
  - 2.5 s of stopped time, with an 8 s cooldown counted from when the glass is turned.
  - The player ticks it and resets it when made, so it never outlives a run or a test.
  - `TimeTint` (a CanvasModulate the World adds) drains the world to a cold blue while it holds.
- **What freezes**:
  - Enemy projectiles stop dead and harm no one until time runs again: harpy feathers, gear blades, sap globs, seed
    shots, rubble, crystal spikes, shockwaves and storm bolts.
  - Time-locked water freezes.
  - The enemies themselves go on (bible A8 lists water, crushers, platforms and projectiles), so it is a tool for
    puzzles and for slipping through a volley, not a pause button.
- **Hour Glass** (ItemPickup kind `hourglass`, legend `z`):
  - It has its own action, `hourglass` (T or E; left stick click), and costs no MP.
  - It is drawn as a brass-framed glass with the sand running.
  - Sound: `hourglass.wav`, a clock tick, a drawn-in shimmer and a hanging chime. It is appended at the end of
    sfxgen, so every other wav stays byte-identical.
- **Time-locked water** (`scripts/world/waterfall.gd`, legend `f`; each connected block becomes one Waterfall):
  - Flowing, it bears down at 260 px/s through a new `Player.water_push`, so you can't jump or climb up through it.
  - While time is stopped it stands frozen and pale, with one-way footholds every 3 rows up from its bottom.
  - Clock-glyph droplets drift through it.
- **Reach**:
  - `f` is solid without the `hourglass` ability. With it, `f` is clear and has footholds at the same rows as in
    the game.
  - The fire and thunder flood carries `hourglass`.
- **Rooms**:
  - The Drowned Nave's west end now has the Hour Glass on a plinth by the stopped water-clock, with a shrine. Its west
    door is door 2.
  - **Waterfall Stair** (`levels/dartmoor/waterfall_stair.room`, 52,-10, 40x45): a foyer with a Shade Knight, then
    two shafts of falling water with a landing between them (the glass needs its 8 s to run back there). At the top
    is a gallery with a Life Fruit and a 760-gold chest.
- **Fixes found by the wider flood**:
  - The Drowned Nave's Mantra Shard sat one row too close to the vault to stand by (since pass 66). Its hidden
    planks drop a row.
  - Reach now lets you down through frozen footholds, as the game does when time runs again.
- **`--timestop=N` shot option.**
- **Docs**:
  - Bible A8 has the Hour Glass as built.
  - Bible 4.5 covers time-locked water.
  - The bible's Dartmoor note covers the new rooms.
  - Bible 4.3: the "Hour Glass before Black Onyx" skip is struck out, because the Onyx's illusory wall now leads to the
    Hour Glass.
  - The README legend gains `f` and `z`.

## Tests

- `test_abilities.gd`:
  - `test_hour_glass_stops_time_then_runs_back`: the duration and cooldown, and that it needs the glass.
  - `test_stopped_time_holds_projectiles_in_the_air`.
  - `test_falling_water_beats_you_down_until_time_stops`: a jump barely rises, a frozen foothold holds you, and
    resumed water carries you down.
- `test_rooms.gd`: `test_the_hour_glass_waits_by_the_stopped_water_clock`.
- `test_reachability.gd`:
  - `test_checker_climbs_falling_water_only_with_the_hour_glass`.
  - The fire and thunder flood now checks every pickup past the conduit gate, which covers all of Dartmoor.
  - `dartmoor/waterfall_stair` is in both room lists.

## Screenshots

`/mnt/project-files/pass-67/`:
- `nave_clock.png`: the Hour Glass, the shrine and the sign.
- `stair_flow.png` and `stair_frozen.png`: the falls flowing, then frozen with their footholds.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | A timed climb up frozen water. |
| Combat and enemies | 15 | 89.5 | Unchanged. |
| World and level design | 15 | 93.75 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 90.25 | A new verb with its own button, cooldown and world response. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 87.75 | Unchanged. |
| Faithfulness | 5 | 89.75 | Faxanadu's Hour Glass. |

Weighted score: 89.55 (up from 89.44; 89.55 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). A short stability pass is due:
- A soak with the Hour Glass turned through the Dartmoor rooms.
- A frame-time check on the waterfall drawing.
- An HUD mark for the glass running back.
