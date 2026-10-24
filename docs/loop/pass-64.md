# Pass 64: the Crystal Dwarf

Dartmoor's first enemy (bible 7), code-drawn at 2x, with a hall to fight it in.

## What changed

- **Crystal Dwarf** (`scripts/enemies/crystal_dwarf.gd`, legend `q`):
  - A dwarf fused with the meteor. Crystal shards jut from his back like a shell, and his right arm is a crystal
    fist.
  - He trudges toward you, then turns if you stay behind him for 0.6 s.
  - **Tell**: with you ahead of him and within 120 px, he raises the fist, pulsing, for 0.6 s (`swell.wav`).
  - **Eruption**: the fist drives into the floor (16 at close range). Six **crystal spikes**
    (`scripts/enemies/crystal_spike.gd`) erupt along the floor toward you, one every 0.09 s and 20 px apart. Each
    glows on the floor for 0.18 s before it stabs 26 px up for 12, unparryable. The chain stops at a wall or a ledge.
  - **Rooted**: his fist stays in the floor for 0.9 s, and every blow lands. Otherwise his crystal back turns any
    blow from behind; only a pogo from above gets through.
  - 48 HP, 14 to touch, 24 XP, 9 to 15 gold, and he can drop poison.
- **Flooded Hall** (`levels/dartmoor/flooded_hall.room`, 57,-10, 60x23), the old hall of audience:
  - The Gate-Hall's west way now leads here, and its "choked" sign is gone.
  - The hall has broken pillars, a crystal-spiked pit, a gallery with a chest (640 gold) and two Crystal Dwarves.
- **Docs**: bible 7 has the dwarf as built, and the Dartmoor note mentions the hall. The README legend gains `q`.

## Tests

- `test_enemies.gd`:
  - `test_crystal_dwarf_raises_his_fist_then_erupts_spikes`: he walks, his tell is at least `MIN_TELEGRAPH`, at
    least four spikes rise, and a player standing still is hit.
  - `test_crystal_spikes_hug_the_floor`: a spike rises after its warning, a jump over it clears it, and standing on
    it hurts.
  - `test_crystal_dwarf_back_turns_blows_until_his_fist_is_rooted`: covers the back, the front, from above, and
    rooted.
- `test_reachability.gd`: `dartmoor/flooded_hall` is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`. The existing fire and
  thunder flood reaches it and its chest with no soft-locks.
- The Dartmoor soak covers the hall, its dwarves and the pit.

## Screenshots

`/mnt/project-files/pass-64/`:
- `dwarf_28.png`: the fist raised.
- `dwarf_52.png` and `dwarf_62.png`: rooted, with the spikes erupting toward the player.
- `dwarf_72.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89.25 | A ground hazard that travels toward you, read on the floor and jumped. |
| World and level design | 15 | 93.25 | Dartmoor's third room. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 89.5 | Unchanged. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 87.75 | Unchanged. |
| Faithfulness | 5 | 89.25 | Unchanged. |

Weighted score: 89.29 (up from 89.21; 89.2875 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). Next is the drowned stair down from the Flooded Hall into the
water-filled lower halls, and Black Onyx (A7: illusory walls shimmer, hidden platforms show faintly). Its illusory
walls gate secrets and one main route.
