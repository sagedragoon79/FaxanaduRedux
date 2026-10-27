# Pass 181: mud underfoot in the Mist

Every category apart from Art was tied at 99, and Audio's last pass (173) was the oldest, so pass 181 takes Audio. I audited the sound against bible 13 (Audio) and the newest content (passes 172 to 180).

| Check | Finding | Verdict |
| --- | --- | --- |
| Mix | `levels.py --check` passes: 130 effects, 34 tracks, 14 beds, none clipping or out of range | fine |
| The Matriarch (pass 179) | her three own sounds, plus her daughters' hex sounds as kin; the voices test holds her to them; her fight plays the `miniboss` theme | fine |
| The Journey page and the reedcutter (pass 180, 179) | menu rows and talk use the shared menu and dialog sounds, like every other row and person | fine |
| **Footsteps in the Mist** | Bible 13 says each step sounds like the ground underfoot. The Mist is a fog-drowned marsh, and its new mire has a bog for a floor. But its zone surface was `moss`, so every step there sounded like the Trunk's living wood. | **built** |

## As built

- `step_mud` (sfxgen): a wet slap as the boot sinks in, then a small suction pop as it pulls free. It is shorter and brighter than the sap's slow drag. It was added at the end of the generator, so no other sound changed.
- `Room.ZONE_SURFACES.mist` is now `mud`.
- Rooms that override it:
  - The Mist's towns already set `surface: plank` and keep it.
  - The four rooms the dwarves built now set `surface: stone`: the Scorched Hall, the Dry Cistern, the Sunken Chapel and the Spring of Mist.
- The Matriarch's Mire, the Fog Cut, the Marsh Road, the causeway and the rest of the open marsh are mud. One-way boardwalks are planks, as everywhere.
- `levels/README.md` lists `mud` among the surfaces, and bible 13's Footsteps entry has been updated.

## Tests

- `test_rooms.gd`, `test_footsteps_follow_the_surface_underfoot` (extended):
  - `step_mud` exists;
  - a Mist room is mud;
  - the four dwarf rooms are stone;
  - the mire keeps the zone's mud.

Full suite: 3393 of 3393 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged: the marsh now sounds like a marsh underfoot. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 182 takes Stability (last pass 174, now the oldest): make the journey soaks' 50 ms spike check robust to a lone spike on room entry (it failed in full runs in passes 174, 178 and 179).
