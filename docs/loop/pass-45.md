# Pass 45: Dry basins

Deluge had one gate, the fire seal. Bible 4.5 gives it a second, the dry basin, and Zorugeriru's second phase
(bible 8.4) is built on basins. So the basin comes first, tested on its own.

## What changed

- **Dry basins** (`scripts/world/dry_basin.gd`). In a room file, a run of `=` tiles marks the water-line stain across
  a tank, and `u` tiles mark its cracked mud bed below.
  - The basin is a `water_target` area covering the tank and a little above its rims, so a bolt cast at chest
    height from the rim fills it.
  - The water rises over 1 s with a raft riding it. At the stain the raft becomes one-way platform tiles
    (`Room.float_raft`), so it behaves like any other boardwalk, drop-through included.
  - The flag `basin:<room>:<x>` keeps it full. Several basins can share a room, which Zorugeriru will need.
  - Enemies left in the tank drown when it fills, with the usual reward. If you come back to a room whose basin is
    already full, nothing spawns in the water.
- **DelugeBolt** checks water targets before walls, since a basin overlaps its own tank walls.
- **The Dry Cistern** (mist 34,-7) is reached through a new east door in the Scorched Hall: the waystation's long
  stone tank, with two Bog Myconids on the dry bed. A Mana Dew sits on a shelf over the tank's middle. The shelf is
  too far from either rim to jump to, even with the Wing Boots, so you can only reach it from the raft.
- **`reach.gd`:** `u` is solid. `=` is standing ground only with `deluge`.
- Bible 4.5 (dry basins) gives the rules. `levels/README.md` has the `u` and `=` legend rows.

## Tests

- `test_reachability.gd`:
  - `test_checker_floats_the_basin_raft_only_with_deluge` uses a synthetic tank. The shelf is out of reach with the
    glove, and with the glove and Wing Boots. With Deluge it can be reached.
  - `test_fire_seal_and_dry_basin_hold_until_deluge` also checks that the raft reaches the cistern shelf in the real
    rooms.
- `test_world.gd`: `test_deluge_fills_the_dry_basin_and_floats_a_raft` checks that:
  - a dry stain is nothing to stand on;
  - a cast from the rim fills the basin and sets the flag;
  - the raft is a one-way platform the player can stand on;
  - the tank's myconids drown;
  - coming back keeps the basin full, with nothing spawned in the water.

## Screenshots

`/mnt/project-files/pass-45/`: the Dry Cistern dry, and full with the player on the raft.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 89 | Unchanged. |
| Combat and enemies | 15 | 86 | Unchanged. |
| World and level design | 15 | 90 | The Mist has 10 rooms. The cistern is the first room built around changing the terrain. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 84 | Unchanged. The basins Zorugeriru's arena needs now exist. |
| Systems | 10 | 87 | Deluge has both of its bible gates, and they persist. |
| Audio | 5 | 84 | Unchanged. |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | Unchanged. |

Weighted score: 86.50 (up from 86.40).

## Lowest categories and next pass

Leaving Art aside, which is on hold, the lowest categories are Stability (83) and Bosses (84). Next: Zorugeriru
(bible 8.4), the three-headed Mist Hydra:

- in a spring-basin arena past the Dry Cistern;
- phase 1: heads take turns being solid, and sweep with mist breath;
- phase 2: Deluge fills three basins so rafts reach the hidden fourth head;
- phase 3: the arena floods.

His reward is the Dworf Ring, and beating him restores the Spring of Mist.
