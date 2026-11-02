# Pass 388: every fight meets the ability it tests (Bosses)

Category: Bosses (last pass 380).

## Audit

Passes 381 to 387 changed no guardian. Bible 8 opens by saying each boss has "an ability it tests", and each of the original's guardians names one on its **Tests:** line. Nothing checked that the map makes you hold that ability by the time you reach the fight. Six guardians name one. Each arena was run through the reach checker with what the critical path (4.2) gives before that fight, once without the ability it tests and once with it:

| Guardian | Arena | Tests | Without it | With it |
| --- | --- | --- | --- | --- |
| Rokusutahn | `trunk/root_chamber` | Climbing Glove (wall jumps) | shut | open |
| Zoradohna | `tower/forepaw_lift` | Mattock (pogo) | shut | open |
| Zorugeriru | `mist/spring_of_mist` | Deluge | shut | open |
| Pakukame | `branches/crown_leaf` | Elven Stride (air dash) | **open** | open |
| Borabohra | `daybreak/roost` | Thunder | shut | open |
| King Grieve | `dartmoor/throne_hall` | Hour Glass | shut | open |

Pakukame's lesson was not kept. The Stride hangs in the Windloft's open air, reached only with a second jump, and the Windloft's east door to the Crown-Leaf was on the open floor below it. A player could walk under the Stride and fight the Bloom without the dash its fight is built around: striding through the vine lash on the dash's invulnerability, and over the gaps its bites tear in the leaf. The Stride was still needed later, past the Sky Steps.

## Fix

- `levels/branches/windloft.room`: an elven veil (legend `|`, pass 216) now stands floor to ceiling before the east door, so only a dash passes. The Windloft's sign says the Bloom waits "past the wardens' veil". Screenshot: `/mnt/project-files/pass-388/windloft_veil.png`.
- The Crown-Leaf, the Storm Ledge and the Sky Steps join `STRIDE_ROOMS` in test_reachability, the rooms that open only with the Stride.
- `test_every_guardian_is_met_with_the_ability_it_tests` (test_reachability) holds all six rows of the table above to the reach checker, and checks each guardian's **Tests:** wording in the bible.
- `test_the_windloft_veil_keeps_the_bloom_for_the_stride` (test_abilities) uses the real controller from the Windloft's floor. Walking east without the Stride stops at the veil; with it, a dash passes and the door leads to the Crown-Leaf.
- Bible 8 gains "Every fight meets the ability it tests (pass 388)". 8.5's arena line and 4.1's Elven Stride row name the veil.

Mutation check: with the veil taken out, the reach test fails for Pakukame, and the real-controller test fails because the hero walks through to the Crown-Leaf without the Stride.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. Every fight that names an ability is now met with it, Pakukame's included. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 389: Systems.
