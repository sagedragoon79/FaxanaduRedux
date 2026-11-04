# Pass 444: a guardian's guard turns the blade back

## Category

Bosses.

## Audit

Pass 442 made a blade that a foe's guard turns push the hero back at `turned_blade_push` (200 px/s), through `Enemy._on_blocked`. That fixed the ordinary foes. The guardians override `_on_blocked`, so this pass read each override to see whether the new rule reached them.

## Bug found

Four guardians turn blows with guards of their own:
- King Grieve, warded on his throne;
- Zoradohna, whose open cockpit turns blows from the side;
- the Evil One's core;
- the Evil Heart, against any blade but the Dragon Slayer.

Each one played its guard thud but never pushed the blade back. A slash they turned got only the 120 px/s recoil of a cut that lands, so a guardian's guard read as a hit. The Evil Heart's case is the worst of the four: its guard is the game telling you that you need the Dragon Slayer. The other guardians' overrides are empty only in states where no fight is under way (dormant, intro, submerged, dying). They are unchanged.

## Fix

- `Enemy.turn_blade()` holds the push, `_on_blocked` calls it, and the four guardians' own guards call it too.
- Bible 5.3: "A guardian's guard, too (pass 444)".
- `test_a_guardians_guard_turns_the_blade_back` slashes each of the four for real with its guard up. In each case the blow does nothing and the hero is pushed back at 200 px/s.
- Mutation: taking the call out of the four guardians fails all four push checks (-120 px/s).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. Every guardian's guard now reads as a guard. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 445: Systems.
