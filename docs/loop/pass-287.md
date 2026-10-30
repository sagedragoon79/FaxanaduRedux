# Pass 287: every foe's spoils stay in its room

Category: Stability (last pass 279).

## Audit

I read bible 15.3 and the soaks in `tests/test_soak.gd` against what passes 280 to 286 touched.
- **Already sound:**
  - The ladder rules and the cast cooldown add no nodes.
  - The new `flask_empty` sound is held to once per press by its own test. `Sfx` lets a sound start only once per physics frame and takes the voice nearest its end, so a mashed Heal can't pile up voices.
  - The tell test's driven tells run only in tests.
- **The new code:**
  - `Drop.keep_in_room` (pass 283) is now static and runs for every coin each frame (pass 285). Its cost is two comparisons for a body in the room's bounds. It frees a body only with `queue_free`, and every caller reads the body only on that same frame, so nothing is left holding a freed coin or drop.
  - It was only ever tested in the two Naga rooms. No test said a foe's spoils stay in any other room, or that a room full of falling coins keeps its frame budget.

## Fix

- New soak `test_every_foes_spoils_rest_in_its_room` (`test_soak.gd`):
  - In every room, every foe dies at once, each leaving a loaf and three coins. That is 82 rooms and 1,012 pickups.
  - Every pickup must rest on a floor inside its room within 5 s, before any could expire. None may be freed.
  - Each room must average under 8 ms a frame while it all falls.
  - The hero is frozen and counted out, so nothing is taken before it is judged.
- All hold, so no game code changed.
- Mutation check: with the coins' guard removed, 14 coins are lost across twelve rooms, not just the Naga rooms:
  - six in five Trunk rooms;
  - five in four Tower rooms;
  - two in the Mist;
  - one in the Sunken Spring's Source Hall.

  So pass 285 kept more gold than it measured.
- Bible 15.3: a new entry after pass 279's.
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: every room's spoils are held in the room and to the frame budget. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 288 takes Movement (last pass 280).
