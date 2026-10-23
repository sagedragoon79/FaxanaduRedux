# Room files

A room is a text file: `key: value` header lines, a line with `---`, then the tile grid.
One character is one 16x16 tile. The room's size is the grid's size.

```
name: Movement Gym
zone: gym
map: 0, 0          (the room's top-left on the map, in screens)
door: 1, trunk/hollow_02, 3   (door 1 here leads to door 3 of that room)
label: 3, 33, Some text placed at tile (3, 33)
sign: 8, 19, First page|Second page   (a lore tablet at tile (8, 19); | splits pages)
enemy_respawn: 5   (optional: seconds until defeated enemies return; 0 = never)
chest_gold: 100    (optional: gold in each chest in this room)
---
##########
#P.......#
##########
```

| Char | Meaning |
| --- | --- |
| `#` | Solid ground (top-exposed tiles get a moss edge) |
| `-` | One-way platform (jump up through, Down + Jump to drop) |
| `^` | Floor spikes (hazard, pogo-able) |
| `o` | Thorn bulb (hazard, pogo target) |
| `C` | Cracked stone (Mattock breaks it) |
| `E` | Training dummy |
| `M` | Monodron (hopper) |
| `H` | Hornet (flier; placed at the tile center) |
| `D` | Rot Dwarf (shielded walker) |
| `P` | Player spawn (feet at the bottom of the tile) |
| `1`-`9` | Door cells (see below) |
| `%` | Fake wall: looks solid, walk through it (a secret) |
| `S` | Meditation Shrine (save, refill, respawn point) |
| `$` | Treasure chest (gold, opens once) |
| `G` | Climbing Glove (ability pickup) |
| `L` | Life Fruit (+1 mask) |
| `W` | Mana Dew (+10 max MP) |
| `F` | Potion Shard (3 = +1 flask charge) |
| `*` | Mantra Shard (3 = +1 skill point) |
| `.` | Empty |

## Rooms and doors

A room's id is its path under `levels/` without `.room`, e.g. `eolis/gate`. The file's
directory is its zone folder; set `zone:` to match (it picks the map color and the area name).

Rooms are whole screens: 40 tiles wide and 23 tall per screen (two screens tall is 45).
`map: x, y` places the room's top-left corner on the map grid, counted in screens.

Mark a door with a digit, repeated over every cell of the opening, and add a `door:` line.
- A door touching the left or right edge is walked through. Put floor right under it; the
  player arrives standing just inside the matching door.
- A door on the top or bottom edge is a shaft. Coming up through a floor door, the player
  pops up with a small boost, so put a ledge beside the shaft's top.
- A door away from the edges is an inner doorway, used by pressing Up.

Every door must lead to a door that leads back (`tests/test_rooms.gd` checks this).
Pickups, chests and cracked walls remember being taken or broken (by room id and tile), so
moving one in a room file makes it collectable again.
