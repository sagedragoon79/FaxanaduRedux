# Pass 485: The soak at 70%

## Category

Stability.

## Audit

Leads: clocks of a node's own that should follow a shared one, the minimap's blink, screens closed in
hitstop or slow motion, and a soak at 70% Game speed.

- After pass 484, the HUD's own `_pulse_t` drives only the minimap's blinking dot, which has no other
  clock to keep step with. No other node keeps a clock that a shared one should drive: foes keep
  `Enemy.game_time` (pass 474), the heartbeat and its pulse share the player's timer (pass 484).
- Pausing leaves `Engine.time_scale` alone and `Feel` runs while paused (`PROCESS_MODE_ALWAYS`), so a
  hitstop or slow motion begun just before a menu opens still ends on its real-time clock, and the
  screens read real time since pass 483. Slow motion ending inside a hitstop sets the base scale, which
  the hitstop's end then restores.
- Every soak ran at 100% Game speed. At 70% each physics step is shorter, and the slow motion and hitstop
  the last passes moved timers onto were never mashed through.

## Bug found

None. A proof.

## Fix

`test_random_input_soak_at_the_slowest_game_speed` (test_soak) mashes the gym for the three soak seeds,
900 frames each, at 70%, with a 0.3 slow motion and a hitstop dropped in every 150 frames (36 bursts).
No invalid position, no escape, no embedding, and once the last burst ends the game runs at 70% again.
Bible 15.3's stability notes gain "The soak at the slowest Game speed (pass 485)". The soak count in "How long the soaks play" goes from 44 to 45, and the soaks now play about an hour
of the game (59.4 minutes, 213,908 physics frames), up from 50.5.

Mutation check: with slow motion ending at full speed instead of the Game speed (`Feel._process`), the
test fails ("after the bursts the game runs at 70% again (1.00)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Score unchanged. The soak now covers the slowest Game speed with slow motion and hitstop. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 486: Movement.
