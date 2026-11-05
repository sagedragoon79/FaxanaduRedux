# Pass 474: A guardian holds still in hitstop

## Category

Bosses.

## Audit

Lead: a guardian under a slower game. Passes 470 and 472 checked the hero's own timers at every game
speed. A guardian's timers all run on `delta` (state_time, tells), so they slow with the game. A search
for the wall clock (`Time.get_ticks_msec`) in the boss scripts found three uses outside `_draw`, and
each one places a hurtbox: the Snapcrown's head in its idle sway (`_think`), the Haar Wyrm's heads at
rest (`_move_heads`) and the Gloamweaver's lanterns (`_place_lanterns`, every physics step).

## Bug found

The wall clock does not stop. In hitstop the engine runs at time scale 0, so every blow freezes the
fight, but these sways kept moving. A probe froze each guardian for 0.4 s of real time: the
Snapcrown's head drifted 3.4 px and the Gloamweaver's lanterns 1.2 px under a frozen blade. Under a
slower Game speed they swayed at full speed while the rest of the fight slowed. (The Haar Wyrm's heads
ease toward their sway, so they held still in hitstop; at 70% they still swayed at full speed.)

## Fix

`Enemy.game_time` counts the foe's own game time in `_physics_process`. It stops in hitstop and slows
with the game. The three sways read it in place of the clock. The drawing's shimmer in `_draw` still
reads the clock; that belongs to the art loop and moves no hurtbox.

`test_a_guardian_stands_still_through_hitstop` (test_boss) freezes the Snapcrown, the Haar Wyrm and the
Gloamweaver at rest for 0.4 s of real time each and checks that nothing moved, and that the
Snapcrown's clock runs 0.7 s in a second at 70%. Bible 8 gains "A guardian holds still in hitstop
(pass 474)".

Mutation check: with the three boss scripts back on the wall clock, the test fails on the Snapcrown
(3.41 px) and the Gloamweaver (1.19 px).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Score unchanged. Three guardians' hurtboxes now freeze in hitstop and slow with the game. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 475: Systems.
