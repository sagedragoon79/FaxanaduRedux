# Pass 491: The Stillstone at the slowest speed

## Category

Systems.

## Audit

Leads: systems that keep time at 70% Game speed and had not been covered: the shop and skill-tree screens
(their `_process` runs in real time since pass 483, and they are held by
`test_the_screens_run_in_real_time_at_every_game_speed`), a rest at a shrine (it reads one Up and saves
at once, with no timer of its own), and the Stillstone, whose stop and run-back had been timed only at
full speed, with a scripted press.

- The Stillstone (`TimeStop`) is ticked by the player on game time, so it never runs in hitstop and slows
  with the Game speed. That is right: what it stops (falling water, shots in flight) slows too, so a stop
  measured on the wall clock would end early against a slowed world.

## Bug found

None. A proof.

## Fix

`test_the_stillstone_answers_its_button_at_the_slowest_game_speed` (test_abilities) presses the real
Stillstone button at 70%: time stays stopped 214 frames (2.5 s of game time), its three ticks fall a
quarter-second of game time apart, a press while it runs back fizzles, and after 8 s of game time the
button turns it again. Bible A8 gains "At the slowest Game speed (pass 491)".

Mutation check: with the glass ticked on real time (`Feel.unscaled`) instead of game time, the test fails
(2 checks: 151 frames still, 481 to run back).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The Stillstone is proved by its button at 70%. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 492: Audio.
