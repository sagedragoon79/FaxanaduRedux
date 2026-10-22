# Pass 01: M1 movement prototype

Date: 2026-10-22. Scope: milestone M1 (movement prototype) only; other rubric categories
start scoring at M2 and M3.

## What was built

- Player controller with every section 6 mechanic: run, variable jump, apex hang, coyote time,
  jump buffer, corner and ledge correction, fast fall, wall slide and wall jump (plus a neutral
  climb jump), double jump, ground and air dash, slash, up-slash and the Mattock pogo.
- Ability toggles (F1 to F4) so each gate can be felt with and without its ability.
- Graybox gym (`levels/gym/gym.room`, 170x46 tiles) with stations for jump heights, dummies,
  a spike pogo corridor, cracked stone, a wall-jump shaft, double-jump and dash gaps, thorn
  bulbs and one-way stairs that loop back.
- Juice: squash and stretch, 9 dust and particle types, dash afterimages, a physics scarf,
  hit-stop, trauma-based screen shake, rumble, eased camera look-ahead and look-down, and
  12 synthesized sound effects.

## Automated verification

27 tests, 48 checks, all passing. They assert the bible's numbers within tight tolerances:
jump height 72 px (±3), apex time 0.36 s, tap jump under 26 px, max fall 520 px/s, run speed
165 px/s reached within 7 frames, coyote window (works at 5 frames, fails at 9), buffered
jump on landing, corner correction, one-way drop-through, wall-slide cap 90 px/s, wall jump
220/380 px/s, single-wall climbing, double jump 48 px (±4), dash 57 px (±7), air-dash
charges, pogo off spikes without damage, spikes hurting without the Mattock, slash hits,
cracked floor and wall breaking, and the gym loading safely.

## Rubric (movement category only)

| Check | Status |
| --- | --- |
| Section 6 values met in replays | Done (tests above) |
| Juice checklist | Mostly done. Missing: player red flash on damage (blinks only), shake and flash toggles in a settings menu (the values exist in `Feel`), sub-pixel smooth camera |
| Same-frame input response | Done (input read at the top of each physics frame) |
| No stuck states under fuzzed input | Not yet: needs the random-input soak bot (planned for M2) |
| Human playtest | Not yet |

**Movement feel score: 78 / 100.** The mechanics and numbers are in place and verified, but
the score is capped until a fuzz soak runs clean and someone has played it with real hands.

## Next pass

1. Random-input soak bot (catches stuck states and soft-locks in the gym).
2. Sub-pixel camera offset (design bible 12.1) to remove pan stepping at high scale.
3. Damage flash, options for shake and flash.
4. M2: combo chain, parry, spells framework, first real enemies.
