# Pass 34: Footsteps per surface, and the lift cage at 2x

Audio was the lowest category at 75. Bible 6.7 asks for "layered footsteps per surface", but every step played the
same muffled thud. Art was 78, and the lift cage was the last world prop still drawn at 1x.

## What changed

- **Footsteps follow the ground.**
  - `Room.surface_at(pos)` names the ground under a point. Platforms (`-`) are planks, sap pools are sap, and
    solid ground uses the zone's material from `Room.ZONE_SURFACES`: stone in Eolis and the gym, moss in the Trunk,
    and iron in the Tower. A room's `surface:` header overrides it.
  - The player plays `step_<surface>` on each step, or the old `step` outside a room, and emits `footstep(surface)`.
  - A landing layers the surface step under the land thud, louder the harder the fall.
  - `sfxgen.py` makes five new sounds:
    - stone: a gritty tap;
    - moss: a soft, muffled pad;
    - plank: a hollow knock;
    - iron: a short ring;
    - sap: a squelch.
  - They are added at the end of the generator, so the existing sounds come out byte-identical.
  - Bible 13 (Audio) and `levels/README.md` are updated.
- **The lift cage is redrawn at 2x.** It now has:
  - chain links that alternate face-on and edge-on;
  - a shackle block with a brass ring;
  - a riveted roof plate with a shadow under it;
  - bevelled posts and bars against a dark back wall;
  - a riveted brass band;
  - a plank floor on an iron lip;
  - a lantern that glows only while the lift runs.

## Tests

- `test_footsteps_follow_the_surface_underfoot` (test_rooms) checks:
  - Tower floors are iron, platforms are planks, sap is sap, and mid-air is nothing.
  - A step sound exists for every surface.
  - A running player emits iron footsteps.
  - The Trunk is moss, and a `surface:` header overrides the zone.

## Screenshots

`/mnt/project-files/pass-34/`: the running lift in Forepaw (with a zoomed crop) and the idle lift at the East Gate.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Footsteps now match the ground underfoot. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 86 | Unchanged. |
| Art cohesion | 15 | 79 | The lift cage is at 2x; the pixel font is still missing. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 81 | Unchanged. |
| Audio | 5 | 79 | Footsteps per surface, layered under landings. |
| Stability and performance | 5 | 76 | Unchanged. |
| Faithfulness | 5 | 77 | Unchanged. |

Weighted score: 82.3 (up from 81.95).

## Lowest categories and next pass

1. **Stability (76)**: soak the lift menu and the footsteps across every room.
2. **Faithfulness (77)** and **Bosses (78)**: M4 moves on to the Mist (bible 3, zone 3), whose first boss is
   Ripasheiku.
3. **Art (79)**: a bitmap pixel font, and bell and window props.
