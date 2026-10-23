# Pass 35: Into the Mist

The Tower of Trunk is complete, and Faithfulness (77) and Bosses (78) now wait on Act II. This pass lays the
groundwork for the Mist (bible 3, zone 3): its art, music and ambience, and the first three rooms, reached by the ore
road out of the Smelter. It also widens the soak test, since Stability (76) was the lowest category.

## What changed

- **Soak every zone.** The random-input soak used to cover every Tower room. It now covers every Eolis and Trunk
  room as well, through a shared `_soak_zone`. For each room it checks four things:
  - the player doesn't escape the room;
  - the player doesn't get embedded in walls;
  - nothing breaks;
  - the node count stays bounded.
- **Mist art.**
  - `tilegen.py` paints the Mist's tiles with `paint_limb`: drowned limbs of the Tree in fog-bleached, bone-pale
    grain, wet streaks and grey-green lichen, under a mossy cap flecked with lantern-gold.
  - New parallax backgrounds:
    - `mist_far`: a green murk, far bare limbs, three-step dithered fog bands and distant will-o'-lanterns.
    - `mist_mid`: near limbs hung with moss beards, corded lanterns with halos, and wisps of near fog.
  - `decorgen.py` adds a Mist decor atlas:
    - floor: reeds with bone-bead seed heads, pale toadstools, boardwalk lantern posts (the zone's light), and
      snapped stakes;
    - ceiling: moss beards, corded lanterns, and dripping rootlets;
    - walls: bracket fungus and wall lanterns.
  - The Mist has its own map name and color, a lantern-yellow glow, and drifting fog motes.
- **Mist audio.**
  - `musicgen.py` adds `mist`, a drowned waltz in B minor and 3/4. It has muffled pads, a music-box pluck on beats two
    and three, a lantern-bell melody, and only a heartbeat thump for drums.
  - It also adds `amb_mist`: a damp hush, water lapping at the boardwalks, frogs, a far bird, and lanterns creaking on
    their cords.
- **Mist ground.** The Mist's footsteps are moss, and its boardwalks are planks.
- **Three rooms.** The Smelter's east wall opens (door 3) onto:
  - **Fog Cut** (`mist/fog_cut`, 27,-6): the rails end in a drowned hollow of snags, crossed on boardwalks. A chest
    sits on a boardwalk, and a Mantra Shard sits high on the west side.
  - **Drowned Stair** (`mist/drowned_stair`, 28,-7): a hollow limb two screens tall, climbed on pegged boardwalk
    landings. It has a Potion Shard on a west ledge and a chest on an east landing.
  - **Lantern Landing** (`mist/lantern_landing`, 29,-7): a Meditation Shrine on a landing, with a chest. The
    boardwalk east to Victim is out ("Something has been cutting the planks").
- The Mist rooms join `MATTOCK_ROOMS`, because they lie past the Deep Workings.
- Bible 4.4 is updated.

## Tests

- `test_random_input_soak_in_every_eolis_and_trunk_room` (test_soak): 37 more rooms soaked.
- The music test now loads `mist` and `amb_mist`. The Fog Cut must play the Mist theme over the marsh bed.
- The per-zone checks in test_rooms now cover the Mist automatically: tileset at 2x, map name, decor atlas, glow
  color and motes.
- Reachability: with the Mattock, all three rooms and their pickups are reachable, with no soft-locks. Every room
  boots with the player landing safely.

## Screenshots

`/mnt/project-files/pass-35/`: the Fog Cut, the Drowned Stair (bottom and middle) and Lantern Landing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. The Mist has no enemies yet. |
| World and level design | 15 | 86 | Act II begins: three Mist rooms off the ore road. |
| Art cohesion | 15 | 80 | A fourth zone with its own tiles, fog parallax, decor and motes. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 81 | Unchanged. |
| Audio | 5 | 80 | The Mist's waltz and marsh ambience. |
| Stability and performance | 5 | 78 | The soak now covers every room in every zone. |
| Faithfulness | 5 | 78 | The Mist, its lanterns and boardwalks, as the original's second land. |

Weighted score: 82.65 (up from 82.30).

## Lowest categories and next pass

1. **Bosses (78)** and **Combat (83)**: the Mist's enemies, starting with the Lantern Ghost (visible only near
   light) and the Mist Wisp, then Ripasheiku.
2. **Faithfulness (78)**: the fog itself, which limits vision around the player, with lanterns that push it back.
   This is the zone's key mechanic (bible 3.2).
3. **Art (80)**: a bitmap pixel font.
