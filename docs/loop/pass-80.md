# Pass 80: The Dragon Slayer

The Dragon Slayer (bible A10, 5.2) is found in Zenis, and the heart's flesh is the gate it opens (8.9).

## What changed

- **Dragon Slayer** (`data/items.json`, `dragon_slayer`): a tier 4 blade with slash 18, heavy 30 and reach 12.
  - It is an `ItemPickup` with legend `&`, drawn as a pale meteor-steel blade with a cyan light running up the fuller and a gold wing guard.
  - Taking it sets `abilities.dragon_slayer`, equips it and refreshes stats.
  - Shops show every blade as owned from then on, because of tier.
- **HeartSeal** (`scripts/world/heart_seal.gd`, legend `+`): each connected block becomes one wall of living flesh.
  - It has a seam of cyan light and an eye that follows you.
  - Any other blade glances off with a guard spark and a shove back.
  - The Dragon Slayer tears it open for good; this is remembered as collected.
  - `Reach` treats it as solid without `dragon_slayer`.
- **Rooms**:
  - The Drift Well's top platform runs to a new door 2.
  - `zenis/heart_gate` (65,-11, 56x23): a hall with a Shade Knight, a Crystal Dwarf and a Clockwork Hound (all corrupted). A drift pocket lifts you to the altar, and the flesh closes the east end. A sign beyond the flesh marks the heart as next.
  - The room is added to `MATTOCK_ROOMS` and `THUNDER_ROOMS`, and `&` is added to the reachability `PICKUPS`, so the altar is proven reachable.
- **Docs**: bible 8.9 and 5.2 as-built notes; legend entries in `levels/README.md`.

## Tests

`test_rooms.gd`: `test_the_dragon_slayer_cuts_the_flesh_of_the_heart`. It checks that:
- the door leads on, and the flesh is a wall;
- a Long Sword glances off;
- the sword is taken, equipped and stronger;
- one cut tears the seal, you walk through, and it stays open.

## Screenshots

`/mnt/project-files/pass-80/heart_gate.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96 | The way to the heart, with a found-blade gate. |
| Art cohesion | 15 | 84.75 | Unchanged. |
| Bosses | 10 | 93.25 | Unchanged. |
| Systems | 10 | 91 | The fourth blade tier exists. |
| Audio | 5 | 90.5 | Unchanged. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 91.5 | The Dragon Slayer, found in Zenis, as in the original. |

Weighted score: 90.94 (up from 90.76; 90.9375 unrounded).

## Next

The Evil One, phase 1 (The Throne): the armored avatar duel beyond the flesh.
