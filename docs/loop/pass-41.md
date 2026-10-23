# Pass 41: Bound fog and the Lantern Key

Systems was lowest at 82. Ripasheiku dropped the Lantern Key, but nothing in the game used it yet.

## What changed

- **Bound fog** (`scripts/world/mist_curtain.gd`, room legend `Y`): a tile of pale, unmoving mist that blocks like
  a wall, with a drowned soul glinting in it now and then. Drawn in code at 2x.
  - Without the Lantern Key, walking up to it shows one toast for the whole wall ("Bound fog. Only a lantern's light
    will part it.") and a fizzle.
  - Carrying the key within 100 px parts every curtain in the room. They lift and fade over 0.9 s, the new `curtain`
    sound plays, and the flag `curtain:<room id>` keeps them parted. The key is not used up.
- **Lantern Landing** gains an upper east ledge, a step boardwalk up to it and a ceiling shaft sealed by three tiles
  of bound fog.
- **Two new Mist rooms** behind it:
  - **Veiled Rise** (29,-8): a climb of boardwalks from the shaft, past Lantern Ghosts, to a west door. It has a crystal.
  - **Victim Causeway** (28,-8): a spiked dip under the boardwalks on the road west to Victim. It has a gold chest
    (280 g), a fruit and a sign.
- `reach.gd` treats `Y` as solid until the `lantern` ability. Both new rooms are in `MATTOCK_ROOMS`.
- Bible 4.4 (the Ripasheiku row) now describes the bound fog and the rooms behind it.

## Tests

- `test_reachability.gd`: `test_bound_fog_holds_until_the_lantern_key` checks that the shaft is closed without the key
  and that the new rooms are reachable with it.
- `test_world.gd`: `test_bound_fog_parts_for_the_lantern_key`:
  - three curtains seal the shaft;
  - without the key they hold, with one toast that names a lantern;
  - the key parts all three, sets the flag and is kept;
  - the curtains stay parted when you come back into the room.

## Screenshots

`/mnt/project-files/pass-41/`: Lantern Landing with the sealed shaft, Veiled Rise and Victim Causeway.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | Unchanged. |
| World and level design | 15 | 88 | The Mist grows to 6 rooms, and its boss reward now opens new ground. |
| Art cohesion | 15 | 84 | Unchanged. |
| Bosses | 10 | 84 | Unchanged. |
| Systems | 10 | 84 | The Lantern Key is a real gate: it says what it needs and is remembered. |
| Audio | 5 | 84 | One new sound (curtain). |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | Unchanged. |

Weighted score: 85.40 (up from 85.05).

## Lowest categories and next pass

Stability (83) is low but light-weighted. Combat (84) carries more weight, and the Mist has only one regular enemy.
Next: a Mist enemy (Bog Myconid or Drowned Dwarf) placed in the new rooms.
