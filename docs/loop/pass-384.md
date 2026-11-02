# Pass 384: every move answers on its frame (Movement)

Category: Movement feel (last pass 376).

## Audit

Passes 377 to 383 changed no movement number or controller code, and every number in section 6 is still held to its own subsection. The audit read 6.7's juice checklist line by line for a claim no test holds. One was left: **Input**, "every action responds on the same frame it is pressed. 60 fps physics, fixed timestep; rendering uncapped with interpolation."

Every move test scripts the player's intent (`PlayerInput.scripted`), setting `jump_pressed` and the rest by hand. So the real path, from a button through `Input` and `PlayerInput.poll` to the move, was never timed. A poll that read a press a step late, or a move that waited a frame for its buffer, would have passed every test. The line's "uncapped" was also loose: the game sets no frame cap of its own, but vsync is on, so drawing follows the display.

Timing the presses turned up how Godot counts them. A test resumes inside a physics step, and a press made there counts from the next step, as a button read between steps does. So "the same frame" means the first step that sees the press.

## Fix

- No game code changed: the probe found every move already answers on that first step.
- `test_every_move_answers_on_the_frame_it_is_pressed` (test_movement) swaps in the real controller and presses each move through `Input`. It checks that the next step is the one that sees the press, and that the move has happened once that step has run:
  - on the floor: a jump (vy is the jump's 400 px/s less one frame of gravity), a dash at 380 px/s, a slash, and an up-slash;
  - in the air: a double jump, a level air dash, and a down-strike;
  - on a wall: a wall jump away at 220 px/s;
  - in deep water: a stroke.
- It also reads the project's clock: 60 physics steps a second, physics interpolation on, no `max_fps` cap, and vsync on. Finally, it checks that 6.7 names the test.
- Bible 6.7's Input line now says what was timed and how, and what "uncapped" means.

The first full run failed one check that had nothing to do with this change: `test_every_boss_fight_holds_the_frame_budget` in `trunk/root_chamber`, 49.4 ms at the 99th percentile with 1.68 ms on average. The same fight alone ran 0.64 ms and 1.26 ms. That is the host taking the VM in a burst, which pass 367 found and taught the journey soaks to set aside, but the boss fights' budget never got the rule. It now does: a fight's frame over 16.6 ms is set aside when `_host_paused` says the main thread was mostly off the CPU while the host stole time, and the frames set aside are counted and printed. A fight that loses more than a tenth of its frames to the host fails, since too little of it was judged. Bible 15.3's note on the host's pause says so.

Mutation check: a `PlayerInput.poll` that hands each press over one step late fails all 9 moves.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score. The last untested juice line is held through the real controller. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score. The boss fights' frame budget sets the host's pauses aside, as the journeys' does. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 385: Faithfulness.
