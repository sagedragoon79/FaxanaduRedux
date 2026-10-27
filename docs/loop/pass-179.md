# Pass 179: the Marsh Hag Matriarch

Every category apart from Art was tied at 99. Of the ties, Bosses had gone longest at its weight (last pass 171), so pass 179 takes Bosses. I audited the bosses against bible 8 and the newest content (passes 172 to 178).

| Check | Finding | Verdict |
| --- | --- | --- |
| Main bosses | all nine and the Evil One's three phases are built, telegraph fairly and stay beaten through a save (pass 174) | fine |
| Mini-boss voices and hints | the Alpha and the Captain have their own sounds (pass 173) and their towns know them (pass 178) | fine |
| **The mini-boss roster** | Bible 8 plans four mini-bosses, about one per zone: the Foreman, the Bark Knight Captain, the Clockwork Alpha and the Marsh Hag Matriarch. Only the Matriarch had not been built, which left the Mist, a two-town zone, without an optional guardian. | **built** |

## As built

- **The Marsh Hag Matriarch** (`scripts/bosses/hag_matriarch.gd`, code-drawn at 3x): the mother of every hag in the Mist, huge and bent under a bell of reeds, with a great wisp in her staff. 230 HP. She fights as her daughters do, from a distance through the fog, and her light shows where she is.
  - **Hex** (0.8 s tell): bog-light marks ring the floor under you and to either side, 40 px apart (three; five below half), and a mud hand bursts from each (12, unparryable). Strike her mid-hex and the whole spell breaks: every mark fizzles, that blow lands in full, and she gropes for her staff for 1.4 s, open.
  - **Sink** (0.5 s tell): crowd her for half a second and she sinks into the bog, untouchable, and rises at the far end of the mire. She also drifts away from you as she walks.
  - **Call** (below half, every third move): a Marsh Hag daughter climbs out of the bog at the far side, never more than one. The daughter sinks with her.
  - Her shawl halves blows unless she is open (fumbling, or reeling from a parry). Below half her tells are 20% shorter, never under `Enemy.MIN_TELEGRAPH`.
  - Her own voice: `matriarch_cackle`, `bog_sink`, `bog_rise` (sfxgen), over her daughters' hex sounds.
  - Reward: a Mana Dew, no skill point. Not in the Boss Rush, like the other mini-bosses.
- **The Matriarch's Mire** (`levels/mist/hag_mire.room`, 35,-6, 40x23, fog 0.5): through a new door 2 at the east end of Mascon's boardwalk. Two plank shelves at the ends and one high in the middle.
- **Mascon:** Reedcutter Siobhe stands by the east door and warns of the Matriarch, hinting at breaking the hex; once she falls, `mascon_reedcutter_glad` takes her place. Sheets drawn by `castgen.py`.
- `MireGrasp.hag` is now any `Enemy`, so the Matriarch's marks fade if she does.
- `Completion.GUARDIANS` counts her. Bible 4.4, 7, 8 (her entry and the openings table) and the Mascon notes updated.

## Screenshots

- `/mnt/project-files/pass-179/hag_mire.png`: her name card in the mire.
- `/mnt/project-files/pass-179/mascon_reedcutter.png`: the reedcutter by Mascon's east door.

## Tests

- `test_boss.gd` (new): the mire lies east of Mascon and wakes her at the far end; her tells are fair; her hex marks three (five) and the mud bites; a blow mid-hex breaks every mark and opens her, and the shawl halves blows otherwise; crowd her and she sinks, untouchable, and rises far off; she calls one daughter at a time, who dies with her; she gives a Mana Dew and no skill point.
- `test_world.gd`, `test_the_towns_know_their_mini_bosses`: the reedcutter swaps on her flag.
- `test_enemies.gd`: her three sounds are hers alone (the hags are her kin). `test_reachability.gd`: the mire is reachable.

Full suite: 3376 of 3377 checks passed, with no script errors. The one failure was a single 51.5 ms frame (the limit is 50) on the fourth frame in `sunken/source_hall` during the post-game journey soak, a room this pass does not touch; the test passed when run again on its own. This is the third such one-frame spike in a full run (passes 174 and 178 saw the others), so the next Stability pass should make that check robust to a lone spike on room entry.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged: every planned mini-boss is now built. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 180 takes Systems (weight 10, last pass 172).
