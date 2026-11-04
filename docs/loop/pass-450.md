# Pass 450: the Thrust at a shield, by the buttons

## Category

Combat (last audited in pass 442).

## Audit

Pass 434 let the Thrust go with the real Attack, and pass 442 had a slash turned by a real shield push
the hero back. But no Thrust let go with the buttons had met a guard: `test_thrust_charges_and_lunges`
scripted the intent at a Monodron with no shield, and the turned-blade tests used a cut. The Thrust is
its own move (its own damage, a lunge that has to stop at what it strikes), so it needed its own proof.

## Bug found

None.

## Fix

`test_the_thrust_answers_the_real_controller_at_a_shield` (tests/test_combat.gd) holds the real Attack
five tiles from a Rot Dwarf held on patrol (the first cut falls short), waits out the 0.4 s charge and
lets go. Facing the hero, his shield turns the Thrust: no harm, the guard's thud and no cut, the lunge
stopped and the hero pushed back at 200 px/s. Facing away, the Thrust bites for the heavy hit times
1.5, is heard as a cut with no thud, and the lunge stops at him. Bible 5.3 gains "The Thrust at a
shield, by the buttons (pass 450)".

Mutation check: leaving the Thrust out of the turned-blade push fails the test ("pushed back at
200 px/s (-160)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The Thrust is proved with the buttons at a shield. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 451: World.
