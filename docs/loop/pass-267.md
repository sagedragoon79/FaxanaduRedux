# Pass 267: every guardian's hall answers its fall

Category: World (last pass 259).

## Audit

I scanned every sign and NPC line for place names that are not room names. Every name in them is a real room or a district such as the Deep Workings, including pass 265's tavern hints. Then I listed every guardian's arena with its own signs and the signs in the rooms next door, before and after its fall.

Most halls already change their sign once the guardian is beaten:
- the Trunk's chewing stops;
- the Forepaw lift's drilling stops;
- the Spires' nest is empty;
- the Mist's spring is clear;
- the Hound has run down;
- the Matriarch is gone;
- the Source's keeper is gone.

Seven did not, and still spoke of their guardians as alive after they fell:
- **Sunken Chapel:** "Lanterns still burn on the altar", though Ripasheiku's lanterns go dark when she falls (4.4). The Lantern Landing above it still said "Something sings in there".
- **Crown-leaf:** "Nothing grows up here but the Bloom."
- **Thorn Yard:** its knight "still keeps the watch".
- **Roost:** "Wake the conduits and the storm will come down to you."
- **Wellspring:** "Its Warden has never let anyone near it."
- **Gate of Zenis and Throne Hall:** no word for after Shadow Eura or King Grieve.
- **Foreman's Gate:** its golem still at work.

## Fix

- Nine `[boss:<id>]` sign lines, one for each of those signs. Each reads once its guardian is beaten, on the same tablet (pass 251).
- Old Cormac's chapel line is now in the past tense.
- Test: `test_every_guardians_hall_answers_its_fall` (`test_rooms.gd`). It checks two things:
  - every sign in every arena outside Zenis has a line for after its own guardian;
  - the Lantern Landing, the Foreman's Gate and the Sunken Chapel, loaded for real, read the old line before the guardian falls and the new one after.

  Zenis is left out, because its halls are followed by the ending.
- Mutation check: with the crown-leaf's new line removed, the test names `branches/crown_leaf (3,19)`.
- Bible 4.4, "Every guardian's hall answers its fall".

No screenshot, since only sign text changed and the tablets look the same.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: every hall knows its guardian has fallen. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 268 takes Bosses (last pass 260).
