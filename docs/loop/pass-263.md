# Pass 263: the Bloom soak tears and broods

Category: Stability (last pass 255).

## Audit

I went through the recent additions looking for leaks, engine errors, frame spikes, and state lost across a room change or a save.

| Check | Finding | Verdict |
| --- | --- | --- |
| Liliths (pass 257) | They are children of the room, so they are freed with it on a death or a room change. `brood_alive` checks `is_instance_valid`. The Bloom's `die` strikes down any still flying. | holds |
| The Tide (pass 259) | It is rebuilt from the header and the `boss:king_grieve` flag on every entry. It holds nothing in a save. It redraws only while flooded, a few dozen rects a frame. The Dartmoor room soak covers it. | holds |
| The charts (pass 261) | They are plain items, saved with the inventory like the other charts. | holds |
| The new sounds (pass 262) | They load at start with the rest, and `Sfx.missing` guards the runtime `step_wade` name. | holds |
| **The Bloom soak** | It printed "gaps 0". Its comment says phase 2 is pushed "so the leaf gets torn too", but the player was put half a bite's reach from the root, and `_tear_leaf` refuses a tear that close. The leaf had never been torn in a soak, so the "never past 3 gaps" check passed on nothing. The brood was soaked only by luck, with no check on it. | **fixed** |

## Fix

`test_bloom_fight_soak_stays_lean` (`test_soak.gd`):
- In phase 2, while the jaws choose and aim (idle and the bite tell), the player stands 0.9 of a bite's reach out over the wider side of the leaf. My first try put the player there every two seconds, as phase 1 does, and let the mashing go on. The mashing walked back under the root before the jaws came down, so the full suite tore nothing: the fight lands only a few bites in its 15 s of phase 2, and only every other one chomps. Every phase-2 bite now comes down at the same spot, and the first chomp tears.
- If the leaf is somehow still whole after the usual 30 s, the fight runs up to 20 s longer until it tears. The soak prints each phase-2 bite.
- The leaf must be torn, with 1 to 3 gaps. The run now tears one.
- The brood must be loosed, with never more than 3 Liliths flying at once.
- At the end it fells the Bloom with a brood in the air, and no Lilith may be left in the room.

Mutation check: with the Bloom's `die` not striking its brood down, the test fails ("2 left").

Bible 15.3, the stability notes.

No screenshot, since nothing visible changed.

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
| Stability and performance | 5 | 99 | Unchanged score: the Bloom's tearing and brood are soaked for real. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 264 takes Movement (last pass 256).
