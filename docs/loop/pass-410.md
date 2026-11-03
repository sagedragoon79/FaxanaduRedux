# Pass 410: the Rune Dagger, by the buttons

## Category

Combat (last pass 402).

## Audit

- Tests press every combat button through the real controller (`Input`):
  - each press, by pass 386: Block, Spell, Next Spell, Red Potion, Hour Glass, Throw and the Thrust's release;
  - Block held and let go, by pass 394;
  - the attack buffer and the combo window, by pass 402.
- Every number in `combat_tuning.gd` is named by a test.
- Every foe and guardian is held to `Enemy.MIN_TELEGRAPH`.
- The gap is the Rune Dagger beyond "it flies". Three behaviours were only ever scripted:
  - its aim: Up held throws it straight up;
  - its buffer: a press in the last 0.15 s of a swing goes as the swing ends (pass 192);
  - Sean's off-hand rule: with a shield on the arm, there is nothing to throw (pass 313).

## Fix

`test_the_rune_dagger_answers_the_real_controller` (test_combat.gd) plays each one through `Input`:

- Throw hurls it the way you face.
- With Up held, it goes straight up.
- Pressed in the last 0.15 s of a swing, it does not go while the swing is out, and goes as the swing ends.
- With a shield on the arm, Throw does nothing.

The test sets the shield slot it needs and puts it back. Sean's off-hand code is not changed.

Bible 5.3 gains "The Rune Dagger, by the buttons (pass 410)".

Mutation check: when Throw's buffer lasts a single frame instead of 0.15 s, the test fails ("the buffered press goes as the swing ends").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The Rune Dagger's aim, buffer and off-hand rule answer the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 411: World.
