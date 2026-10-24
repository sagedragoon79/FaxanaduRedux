# Pass 54: Daybreak opens

The way past Pakukame. This pass adds a new zone folder (`levels/daybreak/`, bible 3.2 zone 5) with its own tiles,
backdrop, decor, music and ambience, and three rooms that make the Elven Stride the key to the sky.

## What changed

- **Crown-Leaf east door** (door 2, rows 17-19) leads to Daybreak. The arena seals it with the rest of the room
  until the Bloom falls.
- **Storm Ledge** (`daybreak/storm_ledge`, 49,-10):
  - The bough gives out into open sky, and an old elf causeway runs on.
  - Its middle span has fallen into a bed of thorns. Pogo across with the Mattock or stride it.
  - A chest sits on a masonry ledge, and hornets ride the wind.
- **Sky Steps** (`daybreak/sky_steps`, 50,-11, 40x45):
  - Eight island shelves are stacked up a tall room.
  - Most gaps are wider than any jump, so an air dash at the top of the leap is the way up.
  - The shelves are one-way, so their sides have nothing to cling to. Storm crystals (thorns) bristle on both cliffs,
    so the glove can't climb around them.
  - Falling lands you on the storm floor, back at the start.
  - A chest on the far-left island is only reachable with the Stride.
- **Broken Shrine** (`daybreak/broken_shrine`, 51,-11):
  - A roofless elf shrine with a save shrine.
  - A Life Fruit on the old belfry ledge.
  - A stair up to the fallen bridge to Daybreak town. Its sign says something circles in the clouds, setting up
    Borabohra.
- **Art** (all code-generated at 2x):
  - `tilegen.py`: `paint_shrine` draws pale ashlar blocks with grooves of gold inlay and cracks. It has a moss cap
    with gold glints.
  - `daybreak_far` is a violet storm sky with storm banks, lightning and far spires.
  - `daybreak_mid` has floating islands, some with broken towers.
  - `decorgen.py` adds wind-bent gold-tipped grass, shrine rubble, pillar stumps, dead lightning conduits (the
    Thunder spell's future targets), air-roots, storm crystals, rune plaques and cornices.
  - Existing zones' outputs are byte-identical.
- **Motes**: Daybreak's are rain, drawn as short streaks along the wind. The optional sixth field of a `Motes.ZONES`
  entry sets the streak length.
- **Audio** (`musicgen.py`):
  - `daybreak`: E dorian at 116, with a pulsing bass, open-fifth pads, wind-blown plucks, thunder tom rolls and a
    bell lead.
  - `amb_daybreak`: gusting wind, rain and three thunder rolls.
  - Loudness matches the Branches pair (-17.5 / -22.5 dB mean).
- **Engine**: zone name and color in `World.ZONES`, surface `stone`, and a decor glow color.
- **Bible**: section 3.2 now describes Daybreak as built, and the 8.5 reward line is updated.

## Tests

- `test_reachability.gd`:
  - The three rooms are added to `MATTOCK_ROOMS`.
  - New `STRIDE_ROOMS` (the Broken Shrine).
  - The Sky Steps chest is added to `STRIDE_SECRETS`.
  - The Mattock test checks that the shrine is out of reach without the Stride, and the Stride test checks that it
    reaches it.
- **Checker fix** (`scripts/world/reach.gd`): the glove climb could carry a body up a wall through thorn bulbs, so
  the Sky Steps cliffs were "climbable" to the left island. `_body_hurts` now stops a climb that would touch a
  hazard. `test_checker_wont_climb_through_thorns` covers it.
- `test_soak.gd`: `test_random_input_soak_in_every_daybreak_room`.
- `test_boss.gd`: the music list includes `daybreak` and `amb_daybreak`.
- The existing checks also cover the new rooms: every zone needs a tileset, every room boots, every door has a
  matching door, and there are no soft-locks.

## Screenshots

`/mnt/project-files/pass-54/`: `storm_ledge.png`, `sky_steps.png` and `broken_shrine.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 87.5 | Unchanged (no new enemy yet). |
| World and level design | 15 | 92 | A new zone, with an ability gate the checker proves. |
| Art cohesion | 15 | 84.25 | A full new zone set, generated (on hold otherwise). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 88.5 | Unchanged. |
| Audio | 5 | 88 | A zone theme and a storm bed. |
| Stability and performance | 5 | 86 | Daybreak soak. |
| Faithfulness | 5 | 88.25 | Daybreak and its storm, as in the original's upper Branches. |

Weighted score: 88.38 (up from 88.23).

## Lowest categories and next pass

Leaving Art aside, the lowest are Stability (86), then Combat (87.5). Next is Daybreak's first enemy, the Thunder
Beetle (bible 7: a pogo-able shell), placed in these rooms. Then Daybreak town past the fallen bridge.
