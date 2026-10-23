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
npc: 12, 19, guru  (a person from data/npcs.json standing on tile (12, 19))
secret: 57, 5, 62, 7   (covers tiles 57,5 to 62,7 with fake wall so a hidden room's
                        contents can't be seen until the player walks in)
enemy_respawn: 5   (optional: seconds until defeated enemies return; 0 = never)
chest_gold: 100    (optional: gold in each chest in this room)
prop: 40, 19, fountain   (a set piece standing on tile (40, 19): fountain, spring_trunk)
boss: rokusutahn   (a boss arena: doors seal until the boss is beaten)
music: title       (optional: a track other than the zone's, from assets/music/)
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
| `~` | Sap pool: halves run speed and weakens jumps (Trunk Hollows) |
| `S` | Meditation Shrine (save, refill, respawn point) |
| `J` | Jack door, 3 tiles tall from this cell up (opens with a Jack Key) |
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

## Design rules the tests enforce

`tests/test_reachability.gd` runs the reachability checker (`scripts/world/reach.gd`) on
every room: from the new game spawn, with no abilities, the Climbing Glove must be reachable
and the boss must not be; with the glove (and keys) every room, pickup, chest and shrine must
be reachable; and no reachable spot may be a soft-lock (unable to get back to a save, or on
to the glove). It also boots every room and checks the player lands safely.

Safe numbers for layouts (a little under the real movement): a standing jump clears 4 tiles
up with 2 across, 3 up with 4 across, or 2 up with 5 across. Leave 3 clear tiles of headroom
for the body. Platforms that should be reachable from the floor go 4 rows above it.
