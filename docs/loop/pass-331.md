# Pass 331: the rooms and shrines the bible says were built

Category: World (last pass 323).

## Audit

- **Room counts.** Pass 323's `test_the_bible_counts_each_zones_rooms` holds 3.1 and 3.2. No room has been added since.
- **Room size (3.3).** The rule says rooms are "multiples of one screen", "1x1 up to 4x3 screens". Nothing held it, and the levels disagree. 14 map rooms are 60 tiles wide (a screen and a half): the Crown-Leaf, the Throne Hall, Zenis's last rooms and others. The Roost is 60x29 and the Heart Gate is 56x23. Two Guru Trials are 20 rows high, shorter than a screen.
- **Save points (3.3).** The bible says "2 to 3 Meditation Shrines per zone". Nothing held it, and the levels disagree. The Mist, Daybreak and the Sunken Spring have 1 each, and the Tower and Dartmoor have 5. What decides where a shrine goes is the distance rule that `test_no_room_is_far_from_a_rest` holds (pass 195), not the count.
- **Reachability, doors and pickups.** These are held by `test_reachability.gd`, `test_the_rooms_hold_the_finds_the_bible_counts` and the door tests. Passes 324 to 330 touched no room.

## Fix

- Bible 3.3: an "As built (pass 331)" note on each rule.
  - Room size: every map room is at least one screen (40x23) and at most 4x3 screens (160x68). 14 are a screen and a half wide and the Heart Gate is 56. The trials are off the map, and two of them are shorter than a screen.
  - Save points: each zone's shrine count, with the Gurus that stand in for missing shrines.
- Tests (test_rooms.gd), both reading the bible:
  - `test_every_room_keeps_the_bibles_size` holds the bounds, the count of screen-and-a-half rooms, and the count of short trials.
  - `test_every_zone_has_the_shrines_the_bible_counts` holds each zone's shrine count to `levels/`.
- Mutation checks: writing "Tower of Trunk 4" or "13 are a screen and a half" in the bible fails the tests.

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the room size and shrine rules now say what was built and are held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 332 takes Bosses (last pass 324).
