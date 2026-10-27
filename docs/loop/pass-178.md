# Pass 178: the towns know their mini-bosses

Every category apart from Art was tied at 99. World weighs 15, and its last pass (170) was the oldest at that weight, so pass 178 takes World. I audited the world against bible 3 and 4 and the newest content (passes 171 to 177).

| Check | Finding | Verdict |
| --- | --- | --- |
| Reachability | every room, the Thorn Yard and the Alpha's den included, passes `test_reachability.gd` | fine |
| Forepaw (pass 175) | the larder and the hospital stand on the town floor and clear of the lift | fine |
| Fire against bark (pass 177) | Mascon, which sells Fire, comes before Conflate on the critical path, so the answer is in hand before the knights | fine |
| **World-state for the mini-bosses** | Bible 4.4 lists a world change for every boss on the path. The two optional guardians built in passes 169 and 171 had none. No one in any town spoke of them before or after, so they were found only by walking every door. | **built** |

## As built

- **Conflate:**
  - Squire Ithil stands by the east door to the Thorn Yard. While the Captain stands, the squire warns of the first knight the Tree grew, whose bark turns a blade, and passes on a father's word that only fire was feared. That ties pass 177's fire into the world.
  - Once the Captain falls (`boss:bark_captain`), `conflate_squire_glad` takes the squire's place and speaks of the yard won back.
- **The Drowned Market:**
  - Once King Grieve's fall wakes the market, Houndkeeper Brand stands in it. He wound the king's hounds for forty years and tells of the Alpha still pacing its den under the kennels.
  - Once it is wound down, `dartmoor_houndkeeper_glad` sleeps easy and blesses the Life Fruit it kept.
- **Room conditions:**
  - A room's `npc:` condition may now list several flags, space-separated, and all of them must hold (`Room.flags_hold`). The houndkeeper uses `boss:king_grieve !boss:clockwork_alpha`.
  - An Alpha beaten before Grieve changes nothing until the market wakes.
  - `levels/README.md` documents the syntax.
- All four people have `lines_cleared` for the blooming Tree. Their sheets were drawn by `castgen.py` from their looks.

## Screenshots

- `/mnt/project-files/pass-178/conflate-squire.png`: Squire Ithil in green by Conflate's east sign.

## Tests

- `test_world.gd`, `test_the_towns_know_their_mini_bosses` (new). It checks:
  - the squire swaps on the Captain's flag;
  - the houndkeeper is absent while Grieve reigns, appears after, and swaps on the Alpha's flag;
  - each hint names the guardian's place;
  - `Room.flags_hold` requires every condition.

Full suite: 3326 of 3327 checks passed, with no script errors. The one failure was a single 51.2 ms frame (the limit is 50) in the post-game journey soak, in `zenis/heart_gate`, a room this pass does not touch. That test passed twice when run again on its own. It is the second such one-frame spike in a full run (pass 174 saw 58.6 ms in the other journey soak), so the journey soaks' 50 ms spike check is worth a Stability look.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged: both optional guardians now have a place in the world's talk, before and after. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 179 takes Bosses (weight 10, last pass 171).
