# Pass 44: Deluge and the fire seal

Sean's new priority is gameplay and design first, with graphics polish later. Art stays code-drawn and serviceable.
The Mist's second ability, Deluge, was in the controller but nowhere in the world. Zorugeriru's fight (bible 8.4)
depends on it, so it comes before him.

## What changed

- **The Marsh Road** (mist 32,-7) runs east from a new east door in the Sunken Chapel. The arena seals that door until
  Ripasheiku falls.
  - A drowned scribe's **Deluge scroll** (legend `O`) lies on a perch over a spiked dip.
  - The road east runs under a stone gatehouse whose arch is closed by a **fire seal**.
- **Fire seals** (`scripts/world/fire_seal.gd`, legend `Z`):
  - The flames block like a wall, burn for 10 on touch (at most every 0.6 s) and light the fog around them.
  - A Deluge bolt calls `douse()` on the seal. Every seal in the room goes out in a hiss of steam, and the flag
    `seal:<room id>` keeps them out.
  - There is a new `douse` sound, appended at the end of sfxgen so the old wavs stay identical.
- **The Scorched Hall** (mist 33,-7) lies behind the seal: a charred dwarf waystation with a chest (240 g), a Life
  Fruit on the loft, two Bog Myconids and a ghost. The Mascon road beyond is still under water. A later pass will let
  the restored Spring of Mist bring it back.
- **The Deluge scroll** grants the `deluge` ability (the spell was already equipped by default) and glows in the fog
  like the other ability pickups.
- `reach.gd` treats `Z` as solid until the player has `deluge`. The full-kit reachability sets include `deluge`.
- Bible 4.1 (A4) and 4.4 (the Ripasheiku row) name the new rooms. Bible 4.5 (fire seals) gives the rules.
  `levels/README.md` has the `Z` and `O` legend rows.

## Tests

- `test_reachability.gd`: a new test, `test_fire_seal_holds_until_deluge`, checks that the scroll can be reached
  without Deluge, that the seal keeps the Scorched Hall shut, and that Deluge opens it. `PICKUPS` counts `O`. Both new
  rooms are in `MATTOCK_ROOMS`.
- `test_world.gd`: a new test, `test_deluge_douses_the_fire_seal_for_good`. It checks that:
  - three seal tiles stand across the road;
  - the scroll grants Deluge, and the save remembers it;
  - touching the flames burns;
  - one cast bolt douses every tile and sets the flag;
  - the seal stays out when you come back into the room.

## Screenshots

`/mnt/project-files/pass-44/`: the Marsh Road, with the scroll on its perch and the fire seal under the gatehouse,
and a close-up of the seal.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 89 | Unchanged. |
| Combat and enemies | 15 | 86 | Unchanged. |
| World and level design | 15 | 90 | The Mist opens on both sides of the chapel. It has 9 rooms. |
| Art cohesion | 15 | 84 | Unchanged (on hold by Sean's priority). |
| Bosses | 10 | 84 | Unchanged. |
| Systems | 10 | 86 | The second Mist ability is in the world, with its own gate. Spells now open the world, not just hurt enemies. |
| Audio | 5 | 84 | One new sound. |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | Unchanged. |

Weighted score: 86.40 (up from 86.15).

## Lowest categories and next pass

Leaving Art aside, which is on hold, the lowest categories are Stability (83) and Bosses (84). Next: the dry basin
(Deluge fills it and a floating platform rises, bible 4.5), which Zorugeriru's second phase uses, then Zorugeriru
himself.
