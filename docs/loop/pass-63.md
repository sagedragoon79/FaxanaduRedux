# Pass 63: Dartmoor begins (M5)

Act III starts. Dartmoor, the drowned dwarf capital (bible zone 6), gets its look, sound and first two rooms. You
reach it down a shaft past the upper gate that Borabohra's Sky Key opens.

## What changed

- **Zone art**, all generated at 2x:
  - **Tiles** (`tilegen.py`, `paint_drowned`): squat dark dwarf masonry with iron-dark joints and a teal tide line
    across every block. Magenta meteor-crystal veins run only through tiles with an open face (`crystal_vein`), so
    the solid fill never repeats one. Teal waterweed caps the tops, with crystal glints.
  - **Parallax** (`dartmoor_far`, `dartmoor_mid`):
    - Far: a sunken great hall of colossal pillars and arches over dark water, with crystal clusters glowing on the
      walls.
    - Mid: broken colonnades run through with crystal spears, and hanging chains.
  - **Decor** (`decorgen.py`): waterweed, fallen masonry, crystal shards (lit), drowned horned helms, drips, crystal
    stalactites, chains, wall crystals and dead braziers.
  - **Motes**: crystal dust hanging in the air. Glow colour: magenta.
- **Zone registration**:
  - Map name and colour, footsteps on stone.
  - Boss seals in Dartmoor are iron.
- **Music**:
  - `dartmoor`: D phrygian at 70. A dirge of deep hall pads, an octave bass, a tolling low bell and sparse crystal
    chimes.
  - `amb_dartmoor`: a still water drone, drops into pools with echoes, a trickle and a faint crystal hum.
- **Rooms** (`levels/dartmoor/`):
  - The Spring of Sky gets a floor shaft past the upper gate.
  - **Upper Stair** (60,-11, 40x45): nine switchback landings, each at most four rows apart, down a drowned colonnade.
    The top landing sits three rows below the ceiling shaft, so you can climb back out.
  - **Upper Gate-Hall** (59,-10): broken pillars, a shrine, two signs. The west way is choked for now.
- **Bible**: a "Dartmoor begins" note under the zone table.

## Tests

- `test_world.gd`:
  - `test_the_upper_gate_drops_you_into_dartmoor`: past the gate, the shaft drops you onto the top landing. Dartmoor's
    theme, ambience and motes play, and the map knows the zone.
  - `test_the_gate_hall_has_a_shrine`.
- `test_soak.gd`: `test_random_input_soak_in_every_dartmoor_room`.
- `test_reachability.gd`:
  - The new rooms are in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.
  - The fire and thunder flood now also carries `sky_key`: a boss reward, like the floods' other post-boss abilities.
    It reaches both rooms with no soft-locks.
  - `test_dartmoors_upper_gate_needs_the_sky_key` checks the gate tile both ways without another flood.
- The music test lists both new tracks. The tileset and decor tests cover the new zone automatically.

## Screenshots

`/mnt/project-files/pass-63/`:
- `upper_stair_top.png` and `upper_stair_foot.png`: the stair.
- `gate_hall.png`: the hall and its shrine.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89 | Unchanged. |
| World and level design | 15 | 93 | A seventh zone begun, with a distinct mood. |
| Art cohesion | 15 | 84.5 | The new zone's generated art reads as one place. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 89.5 | Unchanged. |
| Audio | 5 | 89.25 | A new zone theme and ambience. |
| Stability and performance | 5 | 87.75 | The new rooms are soaked. |
| Faithfulness | 5 | 89.25 | Unchanged. |

Weighted score: 89.21 (up from 89.13).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). Next is Dartmoor's first enemy, the Crystal Dwarf (bible 7: a
meteor-fused dwarf). Then the flooded halls west of the Gate-Hall, toward Black Onyx and its illusory walls.
