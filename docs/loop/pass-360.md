# Pass 360: every squash written and felt (Movement)

Category: Movement (last pass 352).

## Audit

Since pass 352, every number in `MovementTuning`, `GameCamera` and `Feel` is held to its own line of section 6, and passes 353 to 359 changed no movement. One line of the juice list (6.7) was still held by nothing.

**Squash and stretch** said "jump 0.85x1.2 for 3 frames; land 1.25x0.8 scaled by fall speed; wall jump stretch toward direction." In the code:
- The shapes were fourteen bare `Vector2` literals in `player.gd`. Only the jump and the landing were written in the bible. The double jump's "small upward squash" (6.4) had no number. The dash, the pogo, the bounce-pod, the glide, the stroke, the heavy swing, the thrust, the throw, the cast and the parry were named nowhere.
- "For 3 frames" was never true. A squash eases back from the frame it is set, at 16 per second (a bare `16.0` in `PlayerVisual`), so it is a little over half gone after 3 frames.
- No test held any shape, the easing, or the landing's scaling by the fall.

## Fix

- `PlayerVisual.SQUASH` names every shape and `SQUASH_RECOVERY` the easing. `squash_for(move, strength)` sets one, and a landing passes its share of a full-speed fall. The numbers are unchanged, so the feel is too.
- Bible 6.7's line now writes every shape, the rate and what the rate means (over half of a squash eased back in 3 frames, nearly all of it in 0.2 s). It drops the untrue "for 3 frames" and adds a note "Written and held (pass 360)".
- `test_every_squash_is_written_and_felt` checks:
  - each shape and the rate are written on the line;
  - the player sets only named shapes;
  - a jump, a double jump, a dash and a wall jump each set their own shape for real, and over half of it eases back in 3 frames;
  - a fall at full speed lands 1.25x0.8, and a hop lands softer.

Mutations:
- Easing at 6 per second instead of 16: 2 checks fail.
- A landing that ignores the fall speed: 1 fails.
- A double jump with no squash: 1 fails.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. The last unheld line of the juice list is held. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 361 takes Faithfulness (last pass 353).
