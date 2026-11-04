# Pass 446: a turned blade is heard as a guard

## Category

Audio.

## Audit

Passes 442 and 444 made a slash that a guard turns push the hero back like a clang, on ordinary foes and on four guardians. This pass listened to such a slash with the real Attack button.

## Bug found

The shield's `guard` thud played, and so did the cut's `hit`. `Player._process_attack_hits` played `hit` for any swing that touched a foe, whether or not the blow landed. A turned blade still sounded like one that landed.

## Fix

- The swing now notes whether anything gave way: a blow that no guard turned, or stone broken.
- A swing that met only guards is heard by the guard's thud alone.
- A swing that lands, or does both, still plays the cut.
- Bible 13.3: "A turned blade is heard as a guard (pass 446)".

## Tests

- `test_a_turned_blade_is_heard_as_a_guard` slashes a Rot Dwarf's shield for real, and hears `guard` alone. It then slashes his back, and hears `hit` alone.
- `test_a_guardians_guard_turns_the_blade_back` now also listens to each of the four guardians' turned slashes.
- Mutation: playing the cut on every swing fails the dwarf check and all four guardian checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. A turned blade is no longer heard as a cut. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 447: Stability.
