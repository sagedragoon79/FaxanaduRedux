# Pass 192: a throw pressed a moment early still goes

Movement's last pass (183) was the oldest apart from Art, so pass 192 takes Movement. I audited movement and game feel (bible 6, and the input feel in 5.3) against the newest content (passes 183 to 191).

| Check | Finding | Verdict |
| --- | --- | --- |
| **The Throw button (pass 184)** | Jump (0.12 s), Attack (0.15 s) and Dash (0.10 s) are buffered, so a press a moment early still counts. Throw read only the frame of the press. A Throw pressed in the last frames of a swing, a dash, a drink or the dagger's 0.4 s return was simply lost, and in a slash-throw rhythm that is most presses. | **fixed: a 0.15 s throw buffer** |
| Throwing while moving | You can throw while running, jumping, gliding, swimming and wall sliding. A wall slide faces you away from the wall, so the dagger flies off it, not into it. On a ladder your hands are full: the ladder's step runs before the throw, so none goes. | fine (the bible now names the ladder) |
| The Broad Sword's slower swing (pass 186) | Its 30% longer cooldown is only between swings. Movement, air control and the air combo are untouched, so its weight never touches how you move. | fine |
| The helmet and gear (passes 185, 186) | Nothing in them changes a movement number. | fine |
| The cloak layer and the walk pose (PR #206) | The cloak is drawn, not a body: it has no collision and no effect on movement. The walk plays the run slowed until a `walk` clip comes. | fine |

## As built

- `CombatTuning.throw_buffer` (0.15 s, Attack's value).
- `Player._throw_buffer_timer`:
  - It is set by a Throw press and runs down in `_tick_timers` with the other buffers, so a press made on a ladder expires there rather than waiting for you to step off.
  - `_try_throw` throws on the first frame the timer is live and nothing blocks the throw. Those blocks are a dash, a drink, a guard, a swing, a hit, or the dagger not yet whole.
- Bible 5.3 (a Throw buffer row) and 5.2 (the Rune Dagger's "Not while", now naming the ladder and the buffer).

## Tests

- `test_combat.gd`, `test_a_throw_pressed_a_moment_early_still_goes` (new):
  - the buffer is 0.15 s, as Attack's is;
  - a Throw pressed mid-swing goes as the swing ends;
  - one pressed 0.1 s before the dagger is whole goes the frame it is;
  - one pressed long before is dropped.

Full suite: 3549 of 3549 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged: every action button is now buffered the same way. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 193 takes Faithfulness (last pass 184, now the oldest).
