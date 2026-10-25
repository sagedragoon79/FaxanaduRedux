# Pass 82: The Veins

This pass builds phase 2 of the Evil One, The Veins (bible 8.9).

## What changed

- **EvilCore** (`scripts/bosses/evil_core.gd`, boss id `evil_veins`): the meteor's core, a crystal eye-flower hung at the vault of the shaft, code-drawn.
  - No blade reaches it (`_modify_damage` returns 0). It gathers the uncut light veins in the room when the fight begins, and its health is 10 per vein still lit.
  - Every 2.2 s it fires a **CoreBeam** at you: the line flickers for 0.6 s, then burns for 0.35 s (1400 px long, 12 wide, 16 damage, unparryable).
  - Phase 2 (half its veins cut): tell 0.45 s, a volley every 1.6 s, and every other volley is two beams fanned 0.18 rad to either side of you.
  - The Hour Glass holds it and its beams. With the last vein cut it gutters for 2 s and is gone.
- **LightVein** (`scripts/bosses/light_vein.gd`, legend `x`): a vein of light on the shaft wall. One hit cuts it. It is in the `pogo` group, so a down-slash bounces off it. It is drawn dark once `boss:evil_veins` is set.
- **CoreBeam** (`scripts/bosses/core_beam.gd`): a telegraphed line beam.
- **BossArena**: the `evil_veins` entry, titled "The Veins Go Dark", with 1 skill point and the `evil_one` music. The core spawns at the vault.
- **Room**: `zenis/veins` (69,-13, 40x68): zigzag one-way ledges every three rows from the floor to the vault, six veins above them, and a sign. The throne gains door 2, high on its east wall.
- **Docs**: bible 8.9 has an as-built note, including the deviation (a ledge climb, with wall jump and dash optional).

## Tests

- `test_boss.gd`:
  - `test_the_veins_wake_the_core`
  - `test_the_cores_beams_are_telegraphed_and_burn_the_line`
  - `test_the_hour_glass_holds_the_cores_beams`
  - `test_cutting_the_veins_starves_the_core`
  - `test_a_pogo_bounces_off_a_vein`
- `test_soak.gd`: `test_evil_core_fight_soak_stays_lean` (0.47 ms a frame, 22 beams).
- `test_reachability.gd`: the Veins is in the mattock and thunder room lists.

## Screenshots

`/mnt/project-files/pass-82/`:
- `veins_low.png`
- `veins_top.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96.25 | A vertical climb arena that reads at a glance. |
| Art cohesion | 15 | 84.75 | Unchanged. |
| Bosses | 10 | 94.75 | A phase that is a climb, not a duel. |
| Systems | 10 | 91 | Unchanged. |
| Audio | 5 | 91 | Unchanged. |
| Stability and performance | 5 | 89 | One more boss soak. |
| Faithfulness | 5 | 92 | Unchanged. |

Weighted score: 91.18 (up from 91.06; 91.175 unrounded).

## Next

Phase 3, The Core: only the Dragon Slayer hurts it, each strike restores a spring's light and the Tree's roots lash the core. Then the ending and credits.
