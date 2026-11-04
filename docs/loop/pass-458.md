# Pass 458: the Blade skills, by the buttons

## Category

Combat (last audited in pass 450).

## Audit

The leads in the schedule were already proved with the real controller: a shield's parry and guard
against the Rot Dwarf (passes 418 and 394), the Rune Dagger's throw (pass 410), and spells at a real
foe (pass 442). A scan of every test that drives `Input` found no Blade skill among them except
Deluge Pierce's cast. Fourth Strike, Rising Cut and Riposte change what Attack, Up with Attack, and
Block do, and each was tested only with scripted intents (`p.input.attack_pressed`, `p.input.up`,
`p.input.block_pressed`).

## Bug found

None. While writing the test, the fourth tap at first reset the combo. The test's wait was wrong, not
the game: with Fourth Strike the third swing cools for the light 0.20 s, and waiting the finisher's
0.38 s let the 0.40 s combo window lapse.

## Fix

`test_the_blade_skills_answer_the_real_controller` (tests/test_economy.gd) learns the first five Blade
skills and presses for real:
- Four taps of Attack run the ground combo to a fourth hit. Only the fourth is heavy, and every cut
  deals Keen Edge's damage on a training dummy.
- Up with Attack throws a Monodron more than 30 px into the air.
- Block, pressed as a Rot Dwarf's blade comes down, parries it. The Riposte answers once with a heavy
  cut and its sound.

Bible 9 gains "The Blade skills, by the buttons (pass 458)".

Mutation check: with no Riposte on a parry, 2 checks fail (none answered, the dwarf unhurt). With no
launch on Rising Cut, 1 check fails (the Monodron rose 6 px).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The Blade skills are proved with the buttons. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 459: World.
