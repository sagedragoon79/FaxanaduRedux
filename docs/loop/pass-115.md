# Pass 115: slopes

Movement (96) was tied for lowest apart from Art. I audited bible 6 against `movement_tuning.gd` and `player.gd`. Earlier passes had tested every number in 6.2 to 6.6 at the edges of its window (passes 105 to 107 and 111). One line of the spec had never been built at all: 6.1's **slope handling**, "snap to slopes up to 45°, no speed loss going up". The player body was already set up for it (`floor_max_angle` 46°, `floor_constant_speed`, a 4 px floor snap), but no tile in the game was a slope, so every hill in the world was a staircase of square steps.

This pass builds the slopes, the feel rules around them, and the first ramps in the world.

## As built

**Tiles.**
- `tilegen.py` draws two 45° slope tiles for every zone into row 6 of the atlas: (6, 6) `/` rises east, and (7, 6) `\` rises west.
- Each one is the zone's capped ground tile, sheared down column by column, so the zone's moss or stone cap runs along the diagonal. A thin outline sits over the cap.
- `TilesetFactory` gives them triangle collision (`SLOPE_EAST`, `SLOPE_WEST`, `is_slope`).

**Rooms** (`room.gd`).
- Legend `/` and `\`.
- Neighbouring ground counts a slope as ground, so tiles join it without outlines. A slope still counts as open air for wall depth, so the ground under a ramp stays as light as any surface tile. Without that, the cells under a ramp darkened into a checkerboard staircase.
- `Room.is_solid_at` follows the diagonal, so seeds, globs and bolts see the true surface.

**The player.**
- Runs up and down a slope at full run speed measured along it, which is the bible's "no speed loss going up". Running down, the 4 px snap keeps the player on the ground.
- Stands still on a slope with no creep, and jumps from one exactly as from flat ground.
- A slope's face is floor, never a wall. Wall contact (`_wall_at`) and the ledge clip now only answer to a contact whose normal is at least 0.9 horizontal (`WALL_NORMAL`). Before this, falling against a ramp with the Climbing Glove would have caught you in a wall slide, and the ledge clip would have popped you up its face.
- The 12 px box rests on its downhill corner on a slope, up to 6 px above the slope under its middle. A ray finds the slope under the feet, and `_slope_sink` draws the sprite down onto it (with the scarf, which hangs from the sprite's neck). The body itself doesn't move, so no collision or timing changes.

**Enemies** use the same floor angle and snap. Walkers treat a ramp as the end of their patrol: their wall probe meets its face and their floor probe misses a downhill.

**Reachability:** `Reach` counts a slope cell as a whole block. A ramp reads as a stair of one-tile steps, which the model climbs with hops. It can only claim less than the player can really do, never more.

**Where the ramps are:**
- the gym: a hill four tiles up and down, labelled "Slopes: run up and down", in the lower-right combat floor (made by `gen_gym.py`);
- Leaf Landing: a two-tile hump in the bough road;
- the King's Hall: both ends of the dais;
- the Spring of Sky: both ends of its dais;
- the Ore Vault: the mound in the hidden pocket.

The rooms were otherwise flat, so these are the natural places. New rooms can now use slopes.

## Screenshots

In `/mnt/project-files/pass-115/`:
- `gym_hill.png` and `gym_hill_close.png`: the player standing halfway up the gym's hill, feet drawn on the slope.
- `leaf_landing.png`: the Branches hump, with the moss cap following the slope.
- `king_hall.png`: the dais ramps, in Eolis' dressed-stone cap. This shot was taken before the depth fix.

## Tests

In `test_movement.gd`:
- `test_slopes_keep_your_speed_and_your_footing`:
  - zero frames in the air across a ramp up, a plateau and a ramp down;
  - path speed at least 90% of run speed going up, and between 90% and 110% coming down;
  - back on the floor, with the sprite unsunk;
  - standing still on a slope moves less than 0.5 px over 40 frames;
  - the sprite is sunk about 6 px;
  - a jump from the slope matches a flat jump.
- `test_a_slope_is_floor_not_a_wall`: with the glove, falling onto either ramp's face while pushing into it never sets a wall contact or a slide, and it lands. The room's real wall still catches a slide.
- `test_a_slope_is_solid_below_its_diagonal`: `is_solid_at` on both sides of both diagonals.
- The pass 105 to 111 movement tests (wall contact, ledge clip, one-way lips) all still pass with the wall-normal filter.

## Bible

- 6.1: the slope row now describes what was built and where.
- `levels/README.md`: legend `/` and `\`, and a layout note.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | The last unbuilt line of the movement spec is in. Slopes keep speed and footing, are never walls, and the feet sit on them. |
| Combat and enemies | 15 | 96.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 96.5 | Unchanged. |
| Audio | 5 | 96 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2252 checks, all passing.

Weighted score: 94.975 (up from 94.875).

## Next

Audio (96) is now the lowest category apart from Art. Pass 116 takes Audio.
