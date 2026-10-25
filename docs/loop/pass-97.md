# Pass 97: Stride seeds and the movement audit

Movement (92.5) was the lowest category apart from Art. This pass audits the movement item by item against bible sections 6.1 to 6.7, then builds the two gaps that most affect feel.

## Audit

| Item | Bible | Status and evidence |
| --- | --- | --- |
| Run speed, acceleration, turn and friction | 6.1 | Matches `movement_tuning.gd`; asserted in `test_movement`. |
| Jump height, variable jump cut | 6.2 | Matches; jump-cut test. |
| Coyote time | 6.2 | Implemented and tested. |
| Jump buffer | 6.2 | Implemented, including into a wall jump (new test `test_the_jump_buffer_catches_a_wall_jump`). |
| Apex hang | 6.2 | Implemented; new test `test_apex_hang_halves_gravity_near_the_top`. |
| Corner correction and ledge nudge | 6.2 | Implemented and tested. |
| Wall slide, wall jump | 6.3 | Matches; tested. |
| Double jump, dash, dash charges | 6.4 | Matches; tested. |
| Air-move refresh ("dash-reset orbs") | 6.4 | **Gap.** Bible 6.4 promised refresh pickups for chained air routes; none existed. Built as stride seeds (below). |
| Pogo, thorn bulbs | 6.5 | Implemented and tested. |
| One-way platforms, drop-through | 6.6 | Implemented and tested. |
| Dust: run start, turnaround, land, wall slide, wall jump | 6.7 | All present. |
| Squash and stretch, dash afterimages | 6.7 | Present. |
| Hit-stop, boss-kill slow motion | 6.7 | Present at the bible's values. |
| Screen shake (trauma) and the shake setting | 6.7 | Present. **Gap:** every full jump's landing (about 506 px/s) passed the old `impact > 450` gate, so ordinary jumps shook the screen. |
| Rumble | 6.7 | Hits and dashes rumbled; big landings did not. Added with the fix below. |
| Footsteps per surface, coin magnet, blink | 6.7 | Present. |

## What changed

- **Stride seeds** (`StrideSeed`, legend `r`):
  - A green seed floating in the air. Touched while airborne, it bursts and gives back the double jump and every dash charge (`Player.refresh_air_moves`).
  - It only bursts when something is spent (`Player.needs_air_refresh`), so a seed is never wasted on a full player. It regrows after 2.5 s, shown as a faint husk.
  - A burst throws feathers, plays the new `seed` sound and gives a short rumble.
  - Placed three in Daybreak's sky steps, and one over the gym's dash gap with a label.
- **Only a big drop thuds**: the landing shake and a new landing rumble now need a drop of at least 7 tiles (112 px) from the highest point of the jump, as well as a fast impact. Ordinary jumps land clean.
- `Feel.last_rumble` records the last rumble so tests can see it.
- Bible 6.4 and 6.7 are updated; `levels/README.md` documents legend `r`.

## Tests

`test_abilities.gd`:
- `test_a_stride_seed_gives_back_the_double_jump_and_dash`
- `test_a_stride_seed_is_never_wasted`
- `test_the_jump_buffer_catches_a_wall_jump`
- `test_apex_hang_halves_gravity_near_the_top`
- `test_only_a_big_drop_thuds`

Screenshot: `/mnt/project-files/pass-97/stride_seeds.png`.

Full suite: 1813 checks, all passing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 93.25 | Every bible movement item checked; air routes can chain, and landings shake only when they should. |
| Combat and enemies | 15 | 92.75 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.75 | Unchanged. |
| Systems | 10 | 93.25 | Unchanged. |
| Audio | 5 | 93.5 | Unchanged. |
| Stability and performance | 5 | 93 | The movement promises are now pinned by tests. |
| Faithfulness | 5 | 96 | The bible's movement section and the game agree item by item. |

Weighted score: 93.05 (up from 92.88).

## Next

Combat (92.75) is now the lowest apart from Art. Pass 98 reviews combat feel against bible 5 (hit reactions, enemy telegraphs, knockback, damage numbers) and fixes what falls short.
