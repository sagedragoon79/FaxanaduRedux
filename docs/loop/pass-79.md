# Pass 79: Wrong gravity

Zenis gets its "gravity wrong" mechanic (bible section 3 world table, 8.9).

## What changed

- **GravityDrift** (`scripts/world/gravity_drift.gd`, legend `v`): each connected block of `v` cells becomes one pocket. `Room._blocks` now gathers both waterfalls and drifts.
  - Inside a pocket the player keeps `PULL` 0.4 of their weight. The pocket sets `Player.gravity_scale` each frame, the same pattern as `water_push`, and it is cleared every frame.
  - Gravity and top fall speed both scale, so a plain jump rises about 11 tiles and a fall drifts down.
  - Drawn as a violet column with shimmering cyan edges, climbing bands of light and rising motes.
- **Reach**: `DRIFT_JUMP` allows rises up to 9 tiles from a spot inside a pocket. Past the plain envelope, the column must be drift up to the landing.
- **Drift Well** (`levels/zenis/drift_well.room`, 64,-11, 40x45): reached by a new upper door on the Heart Stair.
  - Three pockets lift you up nine-tile ledges.
  - Spikes by the door, then a slug, a hound, a Crystal Dwarf, a hornet hanging in the second pocket, and a Shade Knight.
  - A shrine at the top, with the "heart not open yet" sign moved here.
  - The room is added to `MATTOCK_ROOMS` and `THUNDER_ROOMS`. The reachability tests prove the top shrine can only be reached through the drift.
- **Docs**: bible 8.9 as-built notes; the legend entry in `levels/README.md`.

## Tests

- `test_movement.gd`: `test_wrong_gravity_lifts_a_jump_and_slows_a_fall`. The rise is at least 9.5 tiles, more than twice a normal jump, the fall is capped at 40%, and outside the pocket a jump is normal.
- `test_rooms.gd`: `test_the_drift_well_lifts_you_up_its_ledges`. The door leads on, there are three pockets, and a real jump in the room lands on the ledge nine tiles up.
- Reachability and the Zenis soak cover the new room.

## Screenshots

`/mnt/project-files/pass-79/`:
- `drift_well_low.png`
- `drift_well_high.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Drift pockets change how a jump feels in the last zone. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 95.5 | A room built around the mechanic. |
| Art cohesion | 15 | 84.75 | Unchanged. |
| Bosses | 10 | 93.25 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 90.5 | Unchanged. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 90.5 | Unchanged. |

Weighted score: 90.76 (up from 90.54; 90.7625 unrounded).

## Next

The Dragon Slayer (A10) and the way into the heart, then the Evil One's three arenas.
