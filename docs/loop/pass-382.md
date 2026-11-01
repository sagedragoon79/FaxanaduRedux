# Pass 382: what every zone sounds like (Audio)

Category: Audio (last pass 374).

## Audit

Passes 375 to 381 added no sound. Pass 374's waterfall has its own test, and 13.3's counts (166 effects, 34 tracks, 14 beds) are held to `assets/`. So the audit read 13.3's Ambience and Footsteps lines against `Music.for_room` and `Room.ZONE_SURFACES`. Each line told part of the story, and no test read either:

- Ambience named the Tower's three beds and said "one bed per zone". It never said which bed each zone plays, or which rooms name their own.
- Footsteps named the ground of Eolis, the Trunk, the Tower and the Mist. It said nothing of the other six zones: the Branches (plank), Daybreak, Dartmoor, the Sunken Spring and the Trials (stone), or Zenis, which takes the moss step.
- Apolune has played Eolis's theme since pass 05 (`music: eolis`). It is the one town without a song of its own, and the bible never recorded that.

## Fix

- Bible 13.3 has a new bullet, "Every zone's sound, as built (pass 382)":
  - a table giving each zone's theme, bed and ground;
  - a list of the 22 rooms that name their own music, bed or ground, with what they name, Apolune's borrowed theme included.
- `test_every_zone_sounds_as_the_bible_says` (`test_rooms.gd`) checks:
  - every zone folder's row against the code, and its theme and bed against `assets/music/`;
  - every `music:`, `ambience:` and `surface:` line in `levels/` against the list;
  - the count.

Mutation checks:
- With Zenis's ground set to stone, the test fails 1 check.
- With a `music:` line added to the Hollow Knot, it fails 2 checks: the list and the count.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. Every zone's theme, bed and ground, and every room's own, are written and held. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 383: Stability.
