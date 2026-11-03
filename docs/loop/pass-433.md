# Pass 433: the Elixir in a real fight

## Category

Faithfulness (last audited in pass 425).

## Audit

The original's Elixir is the one item that answers death: carried, it brings the hero back at full
strength the moment he falls. Ours was held only by `test_elixir_revives_once_and_is_limited_to_one`,
which calls `take_damage` directly. Nothing proved that a real blow, landed in a real fight while the
player holds the buttons, is the one the Elixir answers, or that the hero can then walk away from it.

## Fix

`test_the_elixir_saves_a_real_fight` (tests/test_combat.gd) puts the hero at 5 HP with no MP and one
Elixir in front of a dwarf, with the real controller holding Right. The dwarf's swing fells him and the
Elixir answers it: he is not dead, HP and MP are full, the Elixir is spent, he is lifted, and the toast
"The Elixir burns. You rise again." shows. For 90 frames after he is never hurt while the held Right
carries him past the dwarf. The same fight without the Elixir fells him. Bible 5.2 gains "In a real
fight (pass 433)".

Mutation check: dropping the MP refill from `_drink_elixir` fails the new test (and the old one).
Halving the grace after the drink was caught by no test; the new test's 90 frames are inside even the
halved grace, so the grace length stays held only by its number.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Score unchanged. The Elixir is proved against a real blow with the buttons held. |

Weighted: 96.8625.

## Next

Pass 434: Combat.
