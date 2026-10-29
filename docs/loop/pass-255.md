# Pass 255: a rest that can't save says so

Stability's last pass (247) was the oldest apart from Art, so pass 255 takes Stability.

| Check | Finding | Verdict |
| --- | --- | --- |
| Signals on the autoloads | A probe built and freed the HUD three times. `GameState.flash` (a lambda), `banner` and `toast` keep no connections, so nothing stacks or fires into a freed node. | holds |
| Timers and tweens past their node | Three `create_timer` calls. A probe freed a room with a sap puddle drying and got no error. The boss rush's timer holds a weak ref (pass 158), and the ending's belongs to its arena (pass 247). Every tween is the node's own. | holds |
| A real run | The game under xvfb with OpenGL, 200 frames each in the plaza, the Root Chamber and the Spring of Mist. The only messages were the container's: no sound device and no V-Sync. | holds |
| Load times, frame budget, damaged files | Held by the soak and frame-budget tests (passes 99, 182), and by passes 109, 129 and 215. | holds |
| **A failed save** | `write_safely` returns false when the write fails (pass 109), but `World.save_at` dropped the result. The shrine said "Rested. Progress saved." and the Guru named your mantra either way. On a full or read-only disk a player could quit trusting a save that never happened. | **fixed** |

## As built

- `World.save_at` returns whether the file was written (true when the world plays without saves, as in tests and the gym).
- `SaveShrine.interact`: on a failed write it says `SaveShrine.NOT_SAVED`, "Rested, but the journey could not be saved." It still restores you and sets your respawn point. `Npc.rest`, the Guru's rest, says the same and names no mantra.
- `test_a_rest_that_cannot_save_says_so` (`test_systems.gd`, new). A shrine that writes says it saved. With the temp file's path blocked by a directory, the shrine and the Guru both say the save failed. Once the path is clear, the Guru names your mantra again.
- Mutation check: with the shrine ignoring the result, the test fails ("Rested. Progress saved.").
- Bible 15.3 (Saves and settings, Writing).
- No screenshot. The toast is the HUD's usual one, and the new line is about as long as the Guru's mantra line.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: a failed save is now told, not hidden. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 256 takes Movement (last pass 248, now the oldest).
