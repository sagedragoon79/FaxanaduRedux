# Pass 460: the Boss Rush, entered and left by the buttons

## Category

Bosses (last audited in pass 452).

## Audit

Two of the scheduled leads were already covered. A guardian had been fought to its fall with the real
controller (pass 404), and the Thrust had been driven at a shield with the real buttons (pass 450).
The Boss Rush had not. All three rush tests began it with `BossRush.start` and ended it with a call
(`BossRush.back`, a fall, or a win). The Guru's Boss Rush row and the pause menu's "Leave the rush"
were never pressed. Leaving mid-fight is the path most likely to leave something behind: sealed doors,
an arena still fighting, or the guardian's music.

Also corrected: pass 459's notes said the King had been played only with a scripted Up. Pass 409 had
already taken his purse with the real Up, on its own.

## Bug found

None.

## Fix

`test_the_boss_rush_is_entered_and_left_with_the_buttons` (tests/test_systems.gd) runs the whole game in
the Temple of Mantras with every guardian down and the `lord` flag set, using only real input:
- Up at the Guru, Down to Boss Rush and Jump begin the rush. The hero is whole, `trial_begin` plays,
  and he is carried into the Root Chamber.
- Right walks him in, and the doors seal under the guardian's music.
- Pause, Down to "Leave the rush" and Jump bring him back within a step of the Guru. The rush is over,
  the game runs, no arena is still fighting, the guardian's music is gone and no flag has changed.

Bible 11 (the boss rush, under the completion screen) gains "Entered and left by the buttons
(pass 460)".

Mutation check: a "Leave the rush" that stops the clock without carrying the hero back fails 3 checks
(he stays in the Root Chamber, the arena still fighting, the boss music still playing).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. The Boss Rush is proved with the buttons. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 461: Systems.
