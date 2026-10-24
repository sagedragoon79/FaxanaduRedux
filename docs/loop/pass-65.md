# Pass 65: the Black Onyx

Dartmoor's first item (bible A7), plus the two rooms west of the Flooded Hall where it is found and first used.

## What changed

- **Black Onyx** (ItemPickup kind `onyx`, legend `n`). It is a passive ability (`abilities.onyx`) drawn as a black
  faceted stone with a violet light sliding across it.
- **Onyx sheen** (`scripts/world/onyx_sheen.gd`). Any room with fake walls or hidden planks gets one.
  - With the Onyx, a thin violet seam shimmers round every illusory wall (`%`, or a `secret:` cover). The seam
    breathes, and a pulse of light sweeps along it.
  - It fades in over about 0.4 s.
  - Without the Onyx it draws nothing.
- **Hidden planks** (legend `i`, `Room.phantoms`). These are one-way planks that are always solid.
  - Without the Onyx they are invisible.
  - With it they show at about 40% opacity, with a slow pulse.
  - The reach checker stands on them, and you can drop through them, because they are always there. A leap of faith
    finds them without the Onyx, so they only guard secrets.
- **Sunken Stair** (`levels/dartmoor/sunken_stair.room`, 56,-10, 40x45).
  - It is entered through the Flooded Hall's west wall, which is now door 2.
  - Five landings zigzag down a drowned colonnade over a crystal-spiked trench to a Crystal Dwarf at the bottom.
  - High on the west wall, hidden planks climb to a Mantra Shard alcove behind an illusory wall.
- **Onyx Crypt** (`levels/dartmoor/onyx_crypt.room`, 55,-9), the masons' crypt below the stair.
  - The Black Onyx lies on a dais, with a Crystal Dwarf guarding it.
  - A chamber behind an illusory wall holds a 520-gold chest.
  - Hidden planks climb to a ledge with a Potion Shard.
  - So the Onyx pays off at once: both rooms' secrets light up on the way back.
- **`--give=a,b` shot option**: hands the player abilities on frame 2, for screenshots.
- **Docs**:
  - Bible 4.5 has illusory walls and hidden planks as built.
  - The Dartmoor note covers the new rooms.
  - The README legend gains `i` and `n`.

## Tests

- `test_rooms.gd`:
  - `test_black_onyx_shows_seams_and_hidden_planks`: nothing shows without the Onyx. With it, the seam is at full
    strength and the planks are faint.
  - `test_hidden_planks_hold_you_up_unseen`: the player lands on an invisible plank, and it is one-way.
  - `test_the_onyx_waits_in_the_crypt_below_the_flooded_hall`: taking the Onyx gives it for good, and the hall's
    west door leads down.
- `test_reachability.gd`:
  - `test_checker_stands_on_hidden_planks_without_the_onyx`.
  - Both new rooms are in `MATTOCK_ROOMS` and `THUNDER_ROOMS`, so every pickup and chest is reachable with no
    soft-locks.
- The Dartmoor soak covers both rooms.

## Screenshots

`/mnt/project-files/pass-65/`:
- `onyx_crypt.png`: the crypt before the secret cover.
- `crypt_plain.png`: the crypt without the Onyx.
- `crypt_onyx.png`: the crypt with the Onyx (the seam round the hidden chamber, two faint planks).
- `stair_onyx.png`: the hidden planks on the stair.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89.25 | Unchanged. |
| World and level design | 15 | 93.5 | Two rooms, and secrets you see differently once you have the Onyx. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 89.75 | A passive item that changes what the world shows. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 87.75 | Unchanged. |
| Faithfulness | 5 | 89.5 | Faxanadu's Black Onyx is back as a secret-finder. |

Weighted score: 89.36 (up from 89.29; 89.3625 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). Next is the lower halls: the water-filled halls under the crypt,
reached through the main-route illusory wall, with a second Dartmoor enemy.
