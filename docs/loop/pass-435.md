# Pass 435: a sign read safely beside a foe

## Category

World (last audited in pass 427).

## Audit

Pass 431 found that the dialog box freezes the hero but does not pause the world. It looked only at
the presses that put the box away. The other half went unchecked: whatever the world does while a
tablet is read. Foes and hazards keep running, and the frozen hero cannot move, guard or close in.

## Bug found

A probe froze the hero beside a Rot Dwarf for four seconds, as a long tablet does: the dwarf's blows
took 20 HP from a reader who could do nothing about them. A door's scroll and a lift's fade freeze the
hero the same way.

## Fix

`Player.invulnerable` is now true while the hero is frozen, so no blow and no hazard lands during a
dialog, a door or a fade. `test_a_sign_is_read_safely_beside_a_foe` (tests/test_rooms.gd) reads a
tablet with a real Up beside a Rot Dwarf: he swings at the reader at least twice and nothing lands.
Once Attack puts the box away, his next blow lands. Bible 14 gains "A sign read safely beside a foe
(pass 435)".

Mutation check: taking `frozen` back out of `invulnerable` fails the new test (HP 60 to 40 while
the box is open).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. A real bug fixed: a foe no longer strikes a hero reading a sign. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 436: Bosses.
