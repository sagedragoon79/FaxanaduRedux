# Pass 111: the core moves on special terrain

Movement (95.5) was the lowest category apart from Art. Pass 107 tested every number in bible 6.2 to 6.6, but only on plain floors and walls. This pass ran the same moves on each kind of special terrain the game has, frame by frame at the edges of each window:
- one-way platforms;
- the Bark Knight's rooted lance (a one-way ledge that goes away);
- wind currents;
- drift pockets;
- sap;
- deep water.

## Audit

| Terrain | Move | Found | Result |
| --- | --- | --- | --- |
| One-way platform | coyote time off its end | the 6th frame is the last that counts, the same as a floor | OK. New test. |
| One-way platform | ledge correction | **a fall that clipped its lip by even 1 px went straight past**. The correction probes for a wall to bump, and a one-way has no side | **Fixed** |
| One-way platform | drop-through while running | drops | OK. Tested so the fix above can't lift you back up. |
| Bark Knight's lance | Down + Jump | **did nothing but jump**: drop-through only knew the room's one-way tiles | **Fixed** |
| Bark Knight's lance | coyote when it goes from under you | holds | OK. New test. |
| Wind current | coyote off a ledge into the current | the 6th frame is the last | OK. New test. |
| Drift pocket | jump buffer on a slow landing | 7 frames early jumps, 8 is dropped, the same as on plain ground | OK. New test. |
| Sap | jump, wall jump, double jump | the jump is weaker by design (bible 8); the rest act normally | OK. Existing test. |
| Deep water | jump out at the surface | **at rest the body bobs, and for about 5 frames in every 20 its middle is clear of the water. A jump pressed then waited up to 6 frames for the body to sink back in, or was lost** | **Fixed** |
| Updraft, water, wall | double jump and air dash refresh | refreshed | OK. Existing tests. |

## Fixes

**The water is footing for coyote time.** While swimming, the coyote timer is held full, as it is on a floor. On the frames the bob lifts the body clear, a jump press still finds coyote time and is a full jump out on that frame. Under water a press is still a stroke, because swimming takes the stroke path before the jump path. Swimming out of the side of a pool into the air now gets the same 0.10 s grace as walking off a ledge.

**Ledge correction on one-way lips** (`Player._apply_one_way_ledge_correction`). When the sideways probe finds nothing to bump, the lip is looked for from above instead. For each lift of 1 to 4 px (inclusive, with the pass-107 slop), it lifts you when all three hold:
1. lifted by that much and moved on, the feet would come down on something within that lift;
2. lifted but not moved, they would not, so a drop-through or a fall straight down past a platform is never lifted back up;
3. unmoved, nothing is under the feet, so a solid floor is left to the normal landing.

A clip of 1 to 4 px now steps onto a one-way the way it does onto solid ground, and 5 px doesn't.

**Drop-through on any one-way body.** Down + Jump also checks this frame's floor contacts for a one-way collision shape. That covers the Bark Knight's lance and any one-way body added later, not just the room's tiles.

## Tests

`test_movement.gd`:
- `test_coyote_time_off_a_one_way_platform`
- `test_ledge_correction_lifts_you_onto_a_one_way_lip`:
  - 1, 2 and 4 px clips step up;
  - a 5 px clip doesn't;
  - a drop-through on the run still drops.
- `test_a_jump_at_the_surface_jumps_out_at_any_point_of_the_bob`: 20 phases of the bob, each with the press on that frame.
- `test_coyote_time_holds_in_a_wind_current`
- `test_the_jump_buffer_holds_in_a_drift_pocket`

`test_enemies.gd`:
- `test_the_bark_knights_lance_drops_through_and_gives_coyote_time`

Without the fixes, the one-way lip test, the surface test and the lance drop-through test fail; with them, all pass.

No screenshot: the changes are a few pixels and frames of motion.

## Bible

- 6.2: coyote time names every kind of footing, and the ledge clip covers one-way lips.
- 6.8: the water counts as footing for coyote time.
- 7: the Bark Knight's lance can be dropped through.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96 | The core moves hold their windows on every special terrain. Three real misses are fixed: the surface jump, one-way lips and drop-through on the lance. |
| Combat and enemies | 15 | 96 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2150 checks, all passing.

Weighted score: 94.7 (up from 94.6).

## Next

Audio (95.5) is now the lowest category apart from Art. The newest foes borrow other foes' sounds: the Drowned Dwarf's heave uses `tell_heavy`, and the Bark Knight's brace uses `tell_charge`. Pass 112 gives the foes built since the last audio pass their own voices in `sfxgen.py`, then checks the mix with `levels.py --check`.
