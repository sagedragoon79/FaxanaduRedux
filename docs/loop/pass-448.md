# Pass 448: a door gives back the air moves

## Category

Movement feel.

## Audit

Pass 443 carried a ground dash through a side door. This pass followed the air moves through doors. Every door's arrival goes through `Player.teleport`, which calls `_refresh_air_moves`. So a hero who has spent the double jump and the air dash gets both back on arriving, the way landing gives them back. Neither the bible nor any test said so. Shafts that climb through several rooms depend on it.

The side-door lead turned out to change little. A side door's arrival puts the hero's feet on the door's sill (`_place_at_door`), so an air dash through one comes out level with the floor. A jump buffered into an arrival is already covered: a hold forgets buffered presses (pass 440) and keeps the press made as it ends (pass 432).

## Bug found

None. The behavior is a design fact that was never written down, and it is the genre's rule: each room of a shaft is climbed fresh. It is kept.

## Fix

- Bible 3.3 gains "A door gives back the air moves (pass 448)".
- `test_a_door_gives_back_the_air_moves` (test_rooms) checks it:
  - with the double jump and the air dash spent, the hero rises through a ceiling door and comes up into the room above still rising, with both back;
  - near the top of the rise, the real Jump double jumps;
  - the real Dash air dashes.
- Mutation: taking the refresh out of `teleport` fails all three checks. The double-jump check was first written so that it passed anyway. It now compares the speed before and after the press.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. A door's refresh of the air moves is written and proved by the buttons. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 449: Faithfulness.
