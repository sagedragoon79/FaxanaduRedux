# Pass 85: Stability

This pass targets Stability, the lowest rubric category after Art (which Sean has deferred).

## What changed

- **A door walk** (`test_every_door_in_the_game_lands_you_safely`, `test_soak.gd`):
  - It goes through all 240 doors in the game, one at a time, starting fresh in each room.
  - For each one it checks that the far room loads and the player isn't hurt. The player must arrive inside the room, out of the walls, and standing (for side doors).
  - It also checks that a lap of the whole game leaves no nodes behind. The count went from 46 to 46.
- **Bug found and fixed** (`World._enter`): the old room was only `queue_free`d, so its walls stayed in the physics world for one more step.
  - With instant transitions, the player could arrive in the new room overlapping the old room's walls and be shoved out of the room on the next physics step. They then fell out of the room.
  - This hit 14 doors in the walk (for example Market Row from the East Gate).
  - Normal play hid it behind the fade or scroll, which keeps the player frozen for a few frames. Any instant arrival would hit it.
  - The old room now leaves the tree at once, then is freed.
- **A shrine round trip** (`test_every_shrine_saves_and_continues_where_you_rested`): rest at every shrine, then load that save into a fresh world the way Continue does. You must wake in the shrine's room, standing and out of the walls.
- **Reachability checker speed** (`scripts/world/reach.gd`): results are identical; only the speed changed.
  - It now caches four things for its fixed ability set: a per-room solidity map, memos of `standable()` and `drop()`, where each climb leads, and where each jump leads.
  - When a room's root-gate opens, that room's caches are dropped, along with the edge, climb and jump caches.
  - One flood with the glove went from 55 s to 4.3 s. The late-game set (8 abilities) went from 289 s to 17 s.
  - Node sets and stuck lists matched the old checker exactly (hash of the sorted node keys, both sets).
  - The whole test suite now runs in about 5 minutes instead of about 30.

## Tests

- `test_soak.gd`:
  - `test_every_door_in_the_game_lands_you_safely`
  - `test_every_shrine_saves_and_continues_where_you_rested`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 95.5 | Unchanged. |
| Systems | 10 | 91.5 | Unchanged. |
| Audio | 5 | 91.5 | Unchanged. |
| Stability and performance | 5 | 92 | Every door and shrine is proven, a transition bug is fixed, and the suite is 6x faster. |
| Faithfulness | 5 | 93.5 | Unchanged. |

Weighted score: 91.55 (up from 91.40; 91.550 unrounded).

## Next

Back to the deferred list. The Sunken Spring with the Drowned Warden and the Battle Suit would also unlock the secret ending. Other options are Borabohra's and Pakukame's third phases.
