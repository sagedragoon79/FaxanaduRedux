# Pass 262: the brood and the tide find their voices

Category: Audio (last pass 254).

## Audit

I read bible 13.3 against the sounds the last few passes added. Passes 112, 173 and 190 set the rule: a foe or a piece of the world built later gets sounds of its own, so it can be told apart by ear. Three recent additions had broken that rule by borrowing sounds:
- Pass 257's Liliths screeched with the generic `buzz` and dove with `whoosh`, the same sounds as a dozen older foes.
- The Bloom's petal flare before the brood used that same buzz, so the tell for the brood sounded like a Lilith.
- Pass 259's standing water in Dartmoor gave the steps `mud`, the Mist's marsh slap and suction pop. Water a tile deep should slosh, not suck at the boot.

## Fix

Five new recipes in `tools/audio/sfxgen.py`:
- `lilith_screech`: a thin shriek rising through the beat of its wings, for the Lilith's tell.
- `lilith_dive`: a falling whistle and the rush of air, for the Lilith's dive.
- `bloom_brood`: a dry rustle under a low, rising, many-winged hum, for the Bloom's 0.7 s brood tell.
- `brood_loose`: a soft petal pop and a flurry of wings, as the three fly out.
- `step_wade`: a slosh with two drips, for a step in standing water.

`Room.surface_at` now gives `wade` in a tide, so the player's footstep plays `step_wade`.

Tests:
- The voices test holds the Lilith and Pakukame to their new sounds.
- The footstep test expects a step file for `wade`.
- The tide test checks that a step in the water plays `step_wade` and not `step_mud`.

Mix: `levels.py --check` passes, with the median at -18.4 dB. The first cut of the new sounds was quieter and pulled the median down to -18.6, which put `hurt` 9.1 dB over it, past the 9 dB spread. I raised their gains to fix that. `hurt` sits close to the edge, so future quiet sounds can tip it again.

Bible: the 13.3 entry "The Bloom's brood and the tide", plus the 4.4 King Grieve row and the 8.5 brood paragraph.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: no recent addition borrows another's voice. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 263 takes Stability (last pass 255).
