# Pass 441: the Ointment by the buttons

## Category

Faithfulness (last audited in pass 433).

## Audit

Pass 433 proved the Elixir against a real blow with the buttons held. The original's other lifesaver
is the Ointment: rubbed on from the menu, it turns every blow aside for a while. Ours was only ever put
on by a call (`use_ointment`) in `test_ointment_is_bought_used_and_wears_off`, which then checked one
direct `take_damage`. Nothing pressed the pause menu's "Use Ointment" row with the buttons, nothing
checked that the menu spends none of its time, and no real foe swung at it.

## Fix

`test_the_ointment_is_rubbed_on_with_the_buttons` (tests/test_systems.gd) runs the whole game: Pause,
Down to Use Ointment and Jump rub it on and close the menu with the full ten seconds left. A Rot Dwarf
beside the hero swings through it (seven blows) and nothing lands; once it wears off, his next blow
lands. All held: no bug. Bible 4.1's Ointment deviation note gains "The Ointment by the buttons
(pass 441)".

Mutation check: taking the Ointment out of `Player.invulnerable` fails the test (a blow lands while
it should be on).

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
| Faithfulness | 5 | 99 | Score unchanged. The Ointment is proved from the menu against a real foe. |

Weighted: 96.8625.

## Next

Pass 442: Combat.
