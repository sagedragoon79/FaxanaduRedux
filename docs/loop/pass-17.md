# Pass 17: the Tower of Trunk begins

Date: 2026-10-23. Scope: M4 (Act I complete) starts. The Tower of Trunk is zone 2 (Forepaw,
26 rooms): a dwarven mining tower bolted into the trunk. This pass builds the zone's look and
sound and its first three rooms. The Mattock, Zoradohna and the Iron Dwarf come later.

## What was built

- **Tileset** (`tools/art/tilegen.py`, zone `tower`, 2x): a new `paint_plates` material of
  riveted iron plates 8 world pixels square. They are bevelled and lit from the top left, with
  brushed grain and rust bleeding from the odd rivet. A new `cap_girder` top edge is a lit
  girder rim with a riveted web and specks of rust.
- **Parallax** (`tower_far`, `tower_mid`, 2x): far stone shafts with lit slit windows and great
  gears in the dark over an ember-tinted gradient, with sparks. The mid layer has
  cross-braced girders, chains and hanging lamps with rings of light.
- **Decor** (`tools/art/decorgen.py`, 2x): rubble, a floor lantern, a mattock leaning on a crate
  of ore, crates, chains, hanging lamps, a dripping pipe, wall lamps and a wall cog. The lamps
  glow orange (`Decor.GLOW_COLORS`). Rising embers drift in the air (`Motes`).
- **Audio** (`tools/audio/musicgen.py`, placeholders): `tower`, a G phrygian theme at 92 bpm
  with a plodding fifths bass, hammer kicks and an anvil ring on each fourth beat (a new
  `anvil` voice). `amb_tower` is machinery in the walls: a low hum, distant hammer strikes
  and chain rattles.
- **Map name:** "Tower of Trunk", in rust orange (`World.ZONES`).
- **Rooms** (`levels/tower/`):
  - **Tower Foot** (14,-3, two screens tall): reached by a new platform climb and ceiling
    shaft in the Spring of Trunk, so the tower opens after Rokusutahn as in bible 4.2. It is
    a scaffold climb to a chest. Dwarf-cut stone (`C`) teases the Mattock.
  - **Winch Hall** (15,-3, two screens): the zone's first Meditation Shrine, the winch housing
    with a Potion Shard above it, and a cut-stone seal east toward Forepaw.
  - **Ore Chute** (15,-2): it drops from the hall and loops back to the Foot.

## Automated verification

New tests: every zone with rooms has a map name, a decor atlas and glow color, motes, and two
parallax layers. The tower theme and ambience load as looping tracks. Reachability passes:
the tower is reachable with the glove, and every pickup, chest and shrine in it can be
reached. The first layout failed it twice: the spring's top platform wasn't under the shaft,
and the Potion Shard's platform was out of jump range. Full suite: 430 checks pass.
Screenshots reviewed: the Tower Foot's upper landing and the Winch Hall.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged; the tower still uses Trunk enemies. |
| World and level design | 15 | 73 | Zone 2 begun, 3 of 26 rooms. |
| Art cohesion | 15 | 72 | A third zone with its own material, backdrop, decor and particles, all at 2x. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 64 | A zone theme and an ambience for the tower. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 74 (73.95, up from 73.40).

## Lowest categories and next pass

1. **Faithfulness (60)**: lightly weighted.
2. **Combat (75)** and **World (73)**: the tower needs its own enemies (Iron Dwarf with a
   telegraphed hammer slam, Gear Bat) and more rooms toward the Foreman and the Mattock.
3. **Bosses (68)**: Zoradohna once the Mattock is in.
