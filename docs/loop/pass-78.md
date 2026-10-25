# Pass 78: The corrupted

The foes of Zenis are corrupted remixes of every family (bible section 7 table, 8.9).

## What changed

- **Corruption** (`Enemy.corrupted`, `scripts/enemies/enemy.gd`):
  - A flag on the base class, so every family gets it at once.
  - `Room._spawn_enemy` sets it for any foe in zone `zenis`. A `corrupted:` header overrides that either way (documented in `levels/README.md`).
  - A corrupted foe has x1.5 health (`CORRUPT_HP`), double gold and experience, can drop poison, and has a violet cast. Bosses are never corrupted.
- **CorruptionGrowth** (`scripts/enemies/corruption_growth.gd`): a child drawn over the foe. Cyan crystal shards jut from its back, and red veins and a cyan eye pulse on the meteor's heartbeat. It follows the foe's facing.
- **MeteorSeed** (`scripts/enemies/meteor_seed.gd`): what a corrupted foe leaves where it dies.
  - It hangs in the air and swells for 0.7 s (the tell). Then it bursts in a 30 px ring for 10 damage, unparryable.
  - One blow or a pogo cracks it harmlessly, with no gold. That rewards pressing on and gives Zenis fights pogo chains.
  - The Hour Glass holds it.
- **Bible**: 8.9 has an as-built note.

## Tests

`test_enemies.gd`:
- `test_zenis_foes_are_corrupted_with_meteor_crystal`
- `test_a_corrupted_foe_leaves_a_seed_that_bursts`
- `test_a_struck_seed_cracks_without_bursting`
- `test_a_seed_holds_in_stopped_time`

The Zenis soak now runs with corrupted foes and their seeds.

## Screenshots

`/mnt/project-files/pass-78/threshold.png`: a corrupted Shade Knight and Crystal Dwarf.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 91 | Zenis foes are remixed, and seeds reward aggression. |
| World and level design | 15 | 95 | Unchanged. |
| Art cohesion | 15 | 84.75 | The crystal growths are serviceable code art. |
| Bosses | 10 | 93.25 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 90.5 | Unchanged. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 90.5 | Unchanged. |

Weighted score: 90.54 (up from 90.46; 90.5375 unrounded).

## Next

The "gravity wrong" mechanic for Zenis, then the Dragon Slayer and the heart.
