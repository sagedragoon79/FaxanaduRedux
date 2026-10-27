# Pass 160: the Mantra of Winds

Every category apart from Art was tied at 98.5. Movement weighs the most (20), so pass 160 takes Movement. I audited movement against bible 6 and the newest rooms.

| Check | Finding | Verdict |
| --- | --- | --- |
| Coyote time, buffers, wall/pogo/double-jump/dash chains | covered by `test_movement.gd`, and the numbers match bible 6 | fine |
| Ladders, swimming, wind, Feather Fall | unchanged since their passes; the soaks are clean | fine |
| Mantra of Thorns (pass 155) | a pogo bot clears it in the real game | fine |
| The woken Drowned Market, rush arena entries | flat floors; entering through door 1 lands on the floor in all 13 arenas (pass 156 test) | fine |
| **Wind in the trials** | Bible 3.1 plans six Guru Trials, which are the game's movement courses. Wind currents (6.9) were the one traversal mechanic with no course of their own, and the Mantra of Winds was still listed as unbuilt. | **built** |
| **A trial wanting what you lack** | The springs can flow before the Wing Boots are found. The Guru would then open a course you can't finish. | **fixed** |

## As built

- **`levels/trials/winds.room`** (100 x 24): the Mantra of Winds. It is opened with Thorns by the second spring and built for the Glove and the Wing Boots. The course:
  1. Jump into a current that carries you over a 25-tile spike pit to a pillar.
  2. Climb the wall beside the pillar.
  3. Leap off the wall into a high current that drops you on a second pillar.
  4. Make a five-row jump up to a hanging plank; only the Boots reach it.
  5. Step into the last current, and hold Down to let go over the bell's slab. Ride it on and it throws you onto spikes.
- **Steady wind:** the mantra-space has no weather, so a trial's currents never turn with the Spring of Sky. This applies to `WindCurrent.dir` and to the checker's `Reach.wind_dir`. Pale flecks ride them instead of leaves.
- **`Trials.missing` and `Trials.ready`:** the Guru keeps a trial sealed until you hold every ability it is built for, and says what it wants: "Its footholds want the Wing Boots."

## Screenshots

- `/mnt/project-files/pass-160/winds-first-current.png`: riding the first current over the pit, with the climbing wall ahead.
- `/mnt/project-files/pass-160/winds-bell.png`: the last current over the bell's slab.

## Tests

- `test_systems.gd`, `test_the_mantra_of_winds_is_ridden_climbed_and_let_go` (new). It checks that:
  - the trial is built, with its needs and a description;
  - the checker reaches the bell with the Glove and Boots, both before and after the Spring of Sky;
  - the checker can't reach it without the Boots, or with the winds removed even with the Stride;
  - two springs open the trial, but it is not ready until the Boots are held;
  - in the real game, all three currents blow east with the Spring of Sky restored, and a jump from the ledge rides the first one to the pillar.
- The Guru Trials tests (64 checks) still pass.

Full suite: 2950 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Wind currents get their mastery course: ride, climb, double-jump and let go, over spikes. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.4875 (up from 96.4375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.5. Combat and World weigh 15; Combat's last pass (154) is older than World's (155), so pass 161 takes Combat. Unbuilt: Guru Trials Stillness and Falling.
