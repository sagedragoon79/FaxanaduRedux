# Pass 158: the rush holds at its edges

Stability and Faithfulness were tied at 98.25, the lowest apart from Art, both weight 5. Stability's last pass (151) was the older, so pass 158 takes Stability. I audited the newest systems (the boss rush, damage numbers, the NES filter, the Mantra of Thorns) for broken states and frame cost.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Rush moves pause and quit** | The timers between arenas were made with `process_always`, so they ran under the pause menu: the rush could carry you on while paused. Quitting mid-rush left a timer holding a freed world, which errored when it fired. | **fixed** |
| **A fall mid-fade** | `World.travel` does nothing while the world is busy. A fall during a fade abandoned the rush and left you in a sealed arena. A second lethal blow could also end the rush twice. | **fixed** |
| **The clock after a win or fall** | It ran on during the 2.5 s carry back. | **fixed** |
| **The Zenis gate's shrine** | It stands by the arena's way in. In a rush it refilled you and saved mid-run, a free full heal. | **fixed** |
| **King Grieve's steward** | He appears in the throne hall once the king is dead, so in a rush he stood in the arena during the fight. | **fixed** |
| **A new or loaded game** | `Trials.run` and `BossRush.run` are static, so a run could carry over a return to the title. | **fixed** |
| Rush arena loads | 19 to 174 ms, behind the fade; the first room of a zone pays for its tileset | fine |
| Damage numbers | a flurry of 10 a frame frees itself as it goes; the frame stays in budget | fine |
| NES filter, Mantra of Thorns | covered by passes 155 and 156; soaks clean | fine |

## As built

- **Timing:** `BossRush._later` runs moves on a timer that stops with the pause menu, and only while the world (held by a weak reference) still exists.
- **Busy world:** `go` and `back` retry every 0.1 s while the world is busy.
- **`run.over`:** set once a rush is won or lost. The clock stops, and a second fall does nothing.
- **Shrines:** `SaveShrine.interact` in a rush only says "The mantra allows no rest in the rush."
- **Arenas:** in a rush, `Room` spawns no NPCs.
- **New games:** `World.start` abandons any trial or rush.

## Report

- `/mnt/project-files/pass-158/rush-load-times.txt`: the load time of each of the 13 arenas, measured headless.

## Tests

- `test_systems.gd`, `test_the_boss_rush_holds_at_its_edges` (new). It checks that:
  - the steward is there without a rush and gone during one;
  - the Zenis shrine neither heals nor saves in a rush;
  - a fall while the world is busy waits, you live, and the clock stops;
  - once the world settles you go back to the Guru whole, with one banner;
  - a world freed with a move pending leaves no error;
  - a new world starts with no trial or rush.
- `test_soak.gd`, `test_the_boss_rush_and_damage_numbers_stay_lean` (new): every rush arena loads in under 500 ms (CI is slower than this machine), and 1,200 damage numbers over two seconds free themselves inside the frame budget.

Full suite: 2931 checks. One frame-budget check failed once: `test_a_long_journey_through_the_whole_game_stays_lean` saw a 56.8 ms frame (the limit is 50 ms) in `tower/foreman_gate`, a room this pass does not touch. The test passed twice when run alone, and CI ran it again. There were no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Six ways the boss rush could break or be exploited are closed: pause, quit, a fall mid-fade, the clock, a shrine, a stray NPC. A new game always starts clean. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.425 (up from 96.4125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (98.25) is now the lowest apart from Art, so pass 159 takes Faithfulness. Unbuilt: Guru Trials Winds, Stillness and Falling.
