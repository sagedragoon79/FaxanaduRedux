# Pass 457: the hospital, by the buttons

## Category

Faithfulness (last audited in pass 449).

## Audit

The original's poison and its hospital cure are both in the remake (bible 7 and 10.2): Tower foes
leave poison flasks, and Physician Halvar in Forepaw mends health, magic and poison for free. Both
were tested only with scripted intents (`p.poison()`, `p.input.up_pressed`). The player's own route
was unproven: walking over a flask with the real controller, carrying the poison to the hospital, then
the real Up and Jump through his treatment. Two things could go wrong there: the poison ticking while
his words hold the hero, and the Jump that closes his last page leaping.

## Bug found

None.

## Fix

`test_the_hospital_cures_poison_through_the_buttons` (tests/test_economy.gd) holds the real Right. It
walks the hero over a poison flask (poisoned) and on to Halvar, and the poison bites on the way. One
real Up opens his treatment and pauses the world, makes health and magic whole, draws the poison out,
plays `heal`, and shows his `lines_treated`. Real Jumps turn the pages and close them, and the closing
Jump does not leap. No tick follows, and no gold is taken. Bible 10.2 gains "The hospital, by the
buttons (pass 457)".

Mutation check: a treatment that leaves the poison in fails the test (2 checks).

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
| Faithfulness | 5 | 99 | Score unchanged. The hospital's cure is proved with the buttons. |

Weighted: 96.8625.

## Next

Pass 458: Combat.
