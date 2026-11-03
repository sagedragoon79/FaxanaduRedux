# Pass 434: a Thrust let go by a pause

## Category

Combat (last audited in pass 426).

## Audit

Passes 430 to 432 made sure a press made while the game is paused or the hero is held is not read
as the hero's. The Thrust is the one move made by a release, not a press, and that work never looked
at it. A player often opens the pause menu, takes a door or reads a sign with the charge full.

## Bug found

An Attack let go during a pause, a door's scroll or a dialog was seen as a release as soon as play went
on, and the hero lunged out of the menu, out of the door into the next room, or out of the dialog. A
probe confirmed it both ways: frozen (as by a door or a dialog) and with the tree paused (as by a menu).

## Fix

`Player` spends the charge while frozen, and on the first step after a pause it spends it when Attack
is no longer held. Held through the pause, the charge is kept and the player's own release in play
lunges. `test_a_thrust_is_not_let_go_by_a_pause_or_a_hold` (tests/test_combat.gd) presses the real
controller for all three. Bible 5.3 gains "A Thrust is not let go by a pause or a hold (pass 434)".

Mutation check: removing either half of the fix (the spend while frozen, or the spend after a pause)
fails the new test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. A real bug fixed: a charged Thrust no longer lunges out of a menu, a door or a dialog. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 435: World.
