# Pass 66: the Shade Knight and the Drowned Nave

Dartmoor's second enemy (bible 7), and the main-route illusory wall (bible A7) into the lower halls.

## What changed

- **Shade Knight** (`scripts/enemies/shade_knight.gd`, legend `e`). He is code-drawn at 2x and is a parry fight.
  - He is the drowned ghost of one of King Grieve's guard: a dwarf great helm with glowing eyes, a tower shield, and
    mist where his knees should be.
  - **Shield**: it turns every blow from the front. Two blows on it in a row bring a riposte: a 0.36 s tell, then a
    cut for 14.
  - **Combo**: he advances to about four tiles away. Then he draws his blade back, a cold light gathering at its
    point, for 0.55 s, and thrusts, sliding forward, for 18. Then he raises the blade for 0.38 s and cuts down for 14.
  - **Openings**:
    - Both blows can be parried, and a parry leaves him reeling with his shield wide.
    - If the pair finishes, he stands winded for 0.7 s with his shield low.
    - Blows from behind or from above always land.
  - 56 HP, 12 to touch, 28 XP, 10 to 16 gold. A Rising Cut can't launch him.
- **The main-route illusory wall**:
  - The Onyx Crypt's hidden chamber now also hides its west door (the `secret:` cover reaches over the door cells).
  - It leads to the **Drowned Nave** (`levels/dartmoor/drowned_nave.room`, 53,-9, 80x23).
  - The Nave has broken hanging pillars, two galleries, a spiked pit, two Shade Knights and a Crystal Dwarf.
  - A Mantra Shard floats under the vault on hidden planks.
  - The west end, at the stopped water-clock, waits for the Hour Glass.
- **Docs**:
  - Bible 7 has the knight as built, and the Dartmoor note covers the Nave.
  - The README legend gains `e`.

## Tests

- `test_enemies.gd`:
  - `test_shade_knight_shield_turns_blows_from_the_front`: blows from the front are turned. Blows from behind, from
    above, while he is winded and while he is reeling all land.
  - `test_shade_knight_ripostes_when_you_batter_his_shield`.
  - `test_shade_knight_thrusts_then_cuts_and_a_parry_breaks_him`: both tells last at least `MIN_TELEGRAPH`, the pair
    hits a player who stands still, and a parried thrust does no damage and staggers him.
- `test_rooms.gd`: the crypt's door to the Nave sits inside the illusory wall.
- `test_reachability.gd`: `dartmoor/drowned_nave` is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.
- The Dartmoor soak covers the Nave.

## Screenshots

`/mnt/project-files/pass-66/`:
- `nave.png`
- `nave_west.png` (with the Onyx: the hidden planks and the shard)
- `knight_20.png`, `knight_34.png` and `knight_46.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89.5 | An enemy built around the parry. |
| World and level design | 15 | 93.75 | The first main-route illusory wall, and a two-screen hall. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 89.75 | Unchanged. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 87.75 | Unchanged. |
| Faithfulness | 5 | 89.5 | Unchanged. |

Weighted score: 89.44 (up from 89.36; 89.4375 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). Next is the Hour Glass (A8: time stops for 2.5 s with an 8 s
cooldown, freezing falling water, crushers, platforms and projectiles), and the waterfall stair past the Nave's
stopped water-clock.
