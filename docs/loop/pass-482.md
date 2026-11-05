# Pass 482: A guardian's banner in real time

## Category

Bosses.

## Audit

Leads: what a boss fight shows on screen under a slower game, slow motion and hitstop.

- The guardians themselves, their hurtboxes and their attacks run on game time (pass 474 moved the last
  wall-clock sways), so a fight slows evenly with the hero.
- The boss bar's trail, the hurt flash and the gold roll-up run on the frame's `delta`. That is right:
  they are part of the hit, and the flash holds through hitstop on purpose.
- The reward banner and the toast are not part of the hit; they are words to read. `GameHud._process`
  counted both down on game time.

## Bug found

A guardian's reward banner (3.2 s) and the skill-point toast under it (2.2 s) ran on game time. At 70%
Game speed the banner stayed about 4.6 s; the slow motion after a boss's death blow (8), which plays
under the very banner the win shows, stretched it further, and any hitstop froze it. A toast went the
same way. The music and door fades were moved to real time in passes 476 and 477; the HUD's words had
been missed.

## Fix

`GameHud._process` counts the banner and the toast down with `Feel.unscaled(delta)`, so both last their
time in real seconds at every speed. The hurt flash, the boss bar's trail and the gold roll-up stay on
game time. `test_a_guardians_banner_reads_in_real_time_at_every_game_speed` (test_boss) times both at
full speed, at 70% and in a 0.3 slow motion: each is still up 12 frames before its time and gone 12
frames after. Bible 8 ("What a win says") gains "Read in real time (pass 482)".

Mutation check: with the countdown back on `delta`, the test fails 4 checks (both slower modes, both
timers gone late).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Score unchanged. A guardian's banner reads the same at every speed. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 483: Systems.
