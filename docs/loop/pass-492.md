# Pass 492: A guardian's death blow, heard at every speed

## Category

Audio.

## Audit

Leads: sounds tied to game time or real time at 70% Game speed: the Stillstone's ticks (pass 491 heard them
at 70% through the real button), footstep and swing cadence, and a guardian's death-blow sound and music
through the freeze and the slow motion.

- Footsteps are spaced on game time (`_step_timer`), like the legs that make them, so at 70% they slow with
  the run: right.
- `Sfx` keeps each voice's end on the wall clock, as the mixer plays it, and its one-voice-per-frame guard
  counts physics frames, which run through hit-stop: right.
- The music's fades, duck and phase lift run on real time (pass 476). The last fight's ending timer
  ignores the time scale.
- No test had listened to a guardian's death with hit-stop on, or at 70%.

## Bug found

None. A proof.

## Fix

`test_a_guardians_death_blow_is_heard_at_every_game_speed` (test_boss) fells the Haar Wyrm at 100% and at
70% with hit-stop on. The roar goes off once, on the blow, inside the freeze; the win's chime sounds once,
as the dying ends, after the same game time at both speeds (1.59 s); and his theme is let go as it sounds.
Bible 13.3 gains "A guardian's death blow, heard at every game speed (pass 492)".

Mutation check: with the arena keeping the guardian's theme playing at the win (`BossArena._on_defeated`),
the test fails (2 checks).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. A guardian's death is heard right at 70% with hit-stop on. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 493: Stability.
