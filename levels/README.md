# Room files

A room is a text file: `key: value` header lines, a line with `---`, then the tile grid.
One character is one 16x16 tile. The room's size is the grid's size.

```
name: Movement Gym
zone: gym
label: 3, 33, Some text placed at tile (3, 33)
enemy_respawn: 5   (optional: seconds until defeated enemies return; 0 = never)
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
| `.` | Empty |
