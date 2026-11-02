# Pass 396: a rest at every guardian's door (Bosses)

Category: Bosses (last pass 388).

## Audit

- Passes 389 to 395 changed no fight. Pass 395 measured the walk back to a Guru from every room, but not the walk the other way, from a rest to a fight. That walk is paid on every retry, since a lost fight sends you back to your last Guru or shrine (5.4).
- No line of 8 said how long that walk may be. Doors walked from the nearest shrine or Guru room to each of the 16 arenas: 12 are 0 or 1. Four are 3 or more:
  - Borabohra (the Roost): past Daybreak's Guru, the Spire Foot and the Spire Stair.
  - Zorugeriru (the Spring of Mist): past Mascon's Guru, the Scorched Hall and the Dry Cistern.
  - The Drowned Warden (the Wellspring): past the Spring Gate's shrine, the Drowned Aqueduct and the Source Hall.
  - The Evil One's heart, past the veins (2) and the throne, the end of the final climb.
- The boss arenas are reached with the bosses' own tests elsewhere (pass 388 for each ability).

## Fix

- A Meditation Shrine in the room before each of the three long arenas:
  - the Spire Stair's top ledge by the roost door (36, 8);
  - the Dry Cistern's east floor by the spring door (35, 19);
  - the Source Hall's dry shelf at the water's edge (24, 14), well back from its Shade Knight.
  Screenshots: /mnt/project-files/pass-396/spire_stair.png, dry_cistern.png, source_hall.png.
- Bible 8: "A rest at every guardian's door (pass 396)". Every arena is at most one door from a rest. The Evil One's veins and heart (2 and 3) are the written exceptions, the final climb past the throne's shrine.
- Bible 3.3's shrine counts: the Mist 2, Branches (Daybreak) 2, Sunken Spring 2.
- `test_every_guardian_is_a_door_from_a_rest` (`test_boss.gd`) reads every room file, walks the door graph from every shrine and Guru room, and holds each of the 16 arenas to the rule and its two exceptions.

Mutation check: with the Dry Cistern shrine removed, the test fails 1 check (Zorugeriru, 3 doors).

Reachability: 101 checks passed (every new shrine is reachable and no soft-lock).
Full suite: 7131 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. Every guardian's retry starts at most a door away. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 397: Systems.
