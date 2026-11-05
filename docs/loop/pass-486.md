# Pass 486: A press in hitstop

## Category

Movement.

## Audit

Leads: a jump or dash pressed during hitstop or a boss's slow motion, wall jump and pogo at 70%, and the
hurt knockback at every speed.

- Hitstop sets `Engine.time_scale` to 0. Godot still runs the physics steps, with a delta of 0, so
  `PlayerInput.poll` reads the buttons through the freeze, and a jump or dash begun there moves nothing
  until the game moves again.
- The wall jump, pogo and knockback set velocities, not distances per step, and pass 478 proved the
  timing windows only widen as the game slows; pass 481 proved the bounce at every speed.
- No test had pressed a button for real inside a freeze: the test runner turns hitstop off
  (`Feel.hitstop_enabled = false`), so every real-controller test so far ran with no freeze at all.

## Bug found

None. A proof. (A first try at "fixing" a low hop from a tap in hitstop was dropped: it is exactly the
one-frame flick's hop in play, 13 px, and the change would have raised the game's shortest hop.)

## Fix

`test_a_press_in_hitstop_is_kept_once` (test_movement) turns hitstop on for itself, freezes the game and
presses the real buttons inside it. Jump held is the full 69 px jump and Dash the full 64 px dash, once
each, as in play; Jump tapped and let go inside the freeze is the shortest hop in play (13 px, the
one-frame flick), never lost. In a 0.3 slow motion a held jump and a dash go as far within a step, and a
tap is a lower hop (17 px) but always a hop. Bible 6.7's Input line gains "A press in hitstop (pass 486)".

Mutation check: with presses dropped while the game is frozen (`PlayerInput.poll`), the test fails (the
held jump and the tap go nowhere).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Score unchanged. Presses inside a freeze are proved with the real buttons. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 487: Story and world.
