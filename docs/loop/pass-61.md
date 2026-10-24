# Pass 61: clean exits, a roc soak, and the storm

Stability was the lowest category outside Art. This pass clears the long-standing leak report at suite exit, soaks
the new boss fight, and adds Borabohra's phase 2 (bible 8.6).

## What changed

- **No more leaks at exit.**
  - The "ObjectDB instances leaked" and "resources still in use" lines at every test exit were all audio playbacks.
  - Headless runs use Godot's Dummy audio driver, which never mixes. Each started playback stayed in the audio server
    until exit, so the last sound and track on each player were reported as leaks.
  - Stopping the players before quitting doesn't help, because removal also waits for a mix.
  - `Sfx` and `Music` now set `silent` when the driver is Dummy and start nothing. Their state still updates as
    before: `Music.track`, the streams set on the players, and fades.
  - A filtered run now exits with no leak lines.
- **Borabohra, phase 2** (below half):
  - **Storm bolts** (`scripts/bosses/storm_strike.gd`): every 3.2 s a bolt marks the tallest point for 0.6 s, then
    strikes the column for 18, unparryable.
  - The tallest point is the player if they stand at least three tiles above the floor. Otherwise it is a dead
    conduit, which the bolt wakes.
  - **Drain**: in phase 2 a woken conduit goes dead after 6 s unless all three are awake. That makes the storm too slow
    to ground the bird alone, so the player still has to Thunder one in time.
  - The volley throws seven feathers.
  - `--boss-hp` now crosses the phase line for screenshots.
- **Bible 8.6** describes phase 2 as built. Phase 3 is still deferred.

## Tests

- `test_soak.gd`, `test_roc_fight_soak_stays_lean`: a 30-second mashing fight. Conduits are woken every 10 s and the
  storm breaks halfway. Result: 0.84 ms a frame, nodes 10 -> 22. It sees dives, volleys, groundings, rises and storm
  bolts.
- `test_boss.gd`:
  - The storm breaks below half, and the volley grows to seven.
  - A bolt strikes a player standing on an island, and nothing lands during its tell.
  - On the floor, the bolt goes for a conduit and wakes it.
  - A lone conduit holds its charge in phase 1 and drains in phase 2.
- `test_systems.gd`, `test_no_sound_starts_without_a_sound_device`.

## Screenshots

`/mnt/project-files/pass-61/`:
- `storm_230.png`: a bolt's tell over the east conduit.
- `storm_260.png`: the conduit woken, and the seven-feather volley.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89 | Unchanged. |
| World and level design | 15 | 92.5 | Unchanged. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 89.75 | Borabohra gets its storm phase, which turns its gimmick into a risk-and-reward choice. |
| Systems | 10 | 89.25 | Unchanged. |
| Audio | 5 | 89 | Unchanged. |
| Stability and performance | 5 | 87.75 | Clean exits (the leak report is gone) and a soak of the roc fight. |
| Faithfulness | 5 | 89 | Unchanged. |

Weighted score: 89.05 (up from 88.95).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75), then Combat and Faithfulness (89). Next is Daybreak's remaining
world work. The Spring of Sky (bible 4.4) is restored after Borabohra and opens the way toward Dartmoor, the next
zone. Borabohra's phase 3 (the updraft duel) can follow once the Spring is in.
