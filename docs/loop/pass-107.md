# Pass 107: movement against bible 6.2 to 6.6

Movement (94.75) was the lowest category apart from Art. Pass 104 pinned the juice checklist (6.7). This pass checks every number in 6.2 to 6.6 that no test held to its exact value. Each one was checked in scripted runs, frame by frame, at the edges of its window. Three things were off and are fixed.

## Audit

| Item | Bible | Found | Result |
| --- | --- | --- | --- |
| Coyote time | 0.10 s | a jump counts up to the 6th frame off a ledge | OK. New edge test. |
| Jump buffer | 0.12 s, on ground, wall and double jump | a press 7 frames before landing jumps; 8 frames is dropped | OK. New edge test. A double jump pressed late in an air dash fires the frame the dash ends; that case is now tested and written into the bible. |
| Corner correction | up to 6 px | 5.9 px slid, but exactly 6 px bumped the head | **Fixed**: see below. |
| Ledge correction | 4 px | under 4 px only, and **never while wall-sliding**: with the Climbing Glove, falling past a ledge you clip by a pixel caught you in a slide down its face | **Fixed**: see below. |
| Wall slide | 90 px/s | yes | OK (existing test) |
| Wall stick | 0.08 s | pushing away holds the slide 4 to 5 frames | OK. New test. |
| Wall jump | 220 out, 380 up | yes | OK. Now pinned to the exact value. |
| Climb jump | 120 out, 380 up, 0.06 s lock | yes, for neutral input and for holding toward the wall | OK. New test. |
| Lock, then blend | 0.10 s lock, then control blends back over 0.10 s | the lock and blend timers ran together and ran out together, so control came back all at once | **Fixed**: see below. |
| Wall coyote | 0.08 s | a wall jump works 4 frames after the last contact; 5 is too late | OK. New test. |
| Double jump | 48 px, 326 px/s, refreshed by ground, wall, pogo and seeds | yes | OK. New test for the speed and the wall refresh (the others had tests). |
| Pogo | 380 px/s, 420 with Jump held, 45 ms hit-stop, 28x24 hitbox, active 0.14 s | yes | OK. New test bounces both ways and reads the hit-stop. |

## Fixes

**Ledge correction with the glove.** `_apply_ledge_correction` skipped any frame where you were wall-sliding. With the glove, touching a ledge's face while falling and holding toward it starts a slide on the first frame, before the correction runs. So a clip of even 1 px caught you on the wall instead of stepping you up, and you slid down. Most of the game is played with the glove. Now the correction also runs during a slide. It probes 2 px toward the wall, the same as the wall-contact check. If the lip is within 4 px it lifts you and steps you onto it. A scripted fall at clip depths of 1 to 5 px now lands on the ledge the same way with and without the glove.

**Inclusive limits.** Both corrections tried whole-pixel steps. A step of exactly 6 px (or 4 px) left the body flush against the tile, and the physics counts flush as touching, so the bible's limit was really "just under". Each step now reaches 0.1 px further (`Player.CORRECTION_SLOP`). A 6 px overhang slides past and 7 px bumps the head. A 4 px clip steps up and 5 px doesn't.

**The wall-jump blend.** `_control_lock_timer` and `_control_blend_timer` were both set at the jump and both counted down every frame. The 0.10 s blend had already run out by the time the 0.10 s lock ended, so steering came back at full strength in one frame. A climb jump got 0.04 s of blend. Now the blend counts down only once the lock is over, and the lock's overshoot carries into the blend. Pushing back toward the wall after a wall jump:
1. holds 220 px/s for 6 frames;
2. steers at a sixth of full air control on the first free frame;
3. reaches full control 0.10 s later.

The arc carries a little further out before you can turn it, which is what the bible asked for.

## Tests

`test_movement.gd`:
- `test_movement_numbers_match_bible_6_2_to_6_6`: every number in the tuning against the bible.
- `test_coyote_time_is_a_tenth_of_a_second`: the last frame a ledge jump counts is the 6th.
- `test_jump_buffer_holds_a_press_for_0_12_s`: a press 3 or 7 frames before landing jumps; 8 is dropped.
- `test_corner_correction_reaches_6_px_and_no_further`
- `test_ledge_correction_lifts_you_4_px_onto_a_ledge`: 2 and 4 px step up, 5 doesn't, with and without the glove.

`test_abilities.gd`:
- `test_pushing_off_a_wall_sticks_for_0_08_s`
- `test_the_wall_jump_locks_input_then_blends_it_back`
- `test_a_climb_jump_goes_up_and_slightly_out`
- `test_wall_coyote_lasts_0_08_s`
- `test_double_jump_numbers_and_refresh`
- `test_the_buffer_carries_a_double_jump_through_an_air_dash`
- `test_pogo_numbers_match_the_bible`

Full suite: 2060 checks, all passing.

No screenshot this pass: the changes are a few pixels and a few frames of motion, which a still image doesn't show.

## Bible

Section 6.2 (the buffer through a dash; ledge correction during a wall slide; inclusive limits) and 6.3 (the blend starts when the lock ends).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 95.5 | Every number in 6.2 to 6.6 is tested at the edges of its window. Ledge correction now works with the glove, and the wall-jump blend actually blends. |
| Combat and enemies | 15 | 95 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.375 (up from 94.225).

## Next

Combat (95) and Stability (95) are now tied for lowest apart from Art. Stability already has fuzzed-input soaks for every zone, so pass 108 takes Combat.

Bible 7 still lists enemies that were never built, and the bible asks for 4 to 5 families per zone:
- the Mist has 2 (Lantern Ghost, Bog Myconid); Marsh Hag, Drowned Dwarf and Mist Wisp are unbuilt;
- the Branches have the Leaf Mantis only; Sky Ray, Seed Bomber and Bark Knight are unbuilt;
- Daybreak has 2; Spire Sentinel and Wind Imp are unbuilt.

Pass 108 builds the Drowned Dwarf (rises from water) for the Mist, the thinnest zone that has water. It must have a telegraph of at least `Enemy.MIN_TELEGRAPH` with a pose, a flash and a sound, and it gets placed in Mist rooms. The bible will mark which of the rest stay cut.
