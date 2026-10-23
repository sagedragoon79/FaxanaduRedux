# Pass 32: A HUD soak, the Crown Lookout and the Bell Loft

Stability was the lowest category (73). Pass 30's 2x HUD clipped polygons on every frame for every mask, so this
pass measures it and makes it cheaper. It also adds two Tower rooms, which makes 23 of 26.

## What changed

- **HUD cost.**
  - `GameHud._mask_polys()` builds each mask shape's five polygons once (full and half), relative to the mask's
    corner. Each mask is drawn through `draw_set_transform`.
  - Full and empty masks no longer clip. Only a part-filled mask runs `Geometry2D.intersect_polygons`.
  - `GameHud.draws` counts frames drawn.
- **HUD soak** (`test_hud_soak_draws_every_frame_and_stays_lean`): 600 frames of health draining and refilling
  through every part-filled state, with a Life Fruit's half mask. Poison toggles each second, and MP and flasks
  change.
  - The HUD draws all 600 frames.
  - A frame averages 0.76 ms in headless CI conditions.
- **Crown Lookout** (`tower/crown_lookout`, 17,-7): the tower's crown, reached by a new ceiling shaft from the
  Rafters (door 3, with a two-beam climb).
  - A sign looks east over the fog of the Mist, foreshadowing the next zone.
  - It has two Gear Bats, a chest, and a beam climb to a high sill with a Potion Shard.
  - It uses the heights ambience.
- **Bell Loft** (`tower/bell_loft`, 16,-7): west of the Lookout. The shift bell lies cracked on the floor (a sign).
  - It has an Iron Dwarf and a Gear Bat.
  - A fake wall hides a cubby with a chest (`secret:`).
- `test_soak`'s every-tower-room soak picks the new rooms up automatically.

## Tests

- The new HUD soak above.
- Reach `MATTOCK_ROOMS` gains both rooms. Every pickup is reachable with the Mattock and the turning winch, with no
  soft-locks.

622 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-32/`:
- `crown_lookout.png`: the sill climb and the fog sign.
- `bell_loft.png`: the fake wall reads as solid stone at the west end.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 84 | The Rafters now branch up to the crown, with a secret, and there are 23 of 26 Tower rooms. |
| Art cohesion | 15 | 78 | Unchanged. The fallen bell is only told by a sign; a prop would be better. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 80 | Unchanged. |
| Audio | 5 | 75 | Unchanged. |
| Stability and performance | 5 | 76 | The HUD is measured and cheap, and the soak now covers it as well as every room. |
| Faithfulness | 5 | 74 | Unchanged. |

Weighted score: 81 (81.40, up from 81.10).

## Lowest categories and next pass

1. **Faithfulness (74)**: the last 3 Tower rooms. The bible's "elevator shortcut back to Eolis" is still open: the
   lift reaches only the Tower Foot.
2. **Audio (75)**: per-surface footsteps (bible 11).
3. **Art (78)**: a pixel font, and props for the bell and the lookout's window.
