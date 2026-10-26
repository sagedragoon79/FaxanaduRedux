# Pass 150: the springs restore their music

Audio (98, weight 5) was tied for lowest apart from Art with Stability and Faithfulness, and the longest of the three since its last pass (143). I audited audio against bible 13.3 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Victim and Mascon (passes 145, 148) | each has its own theme over `amb_mist` | fine |
| Rare drops (pass 147) | the glove and an ointment are picked up with the `item` chime | fine |
| Thrust (pass 149) | `thrust_ready` rings as the charge fills and `thrust` sounds the lunge | fine |
| Mix | `levels.py --check` passes | fine |
| **13.3: "Each zone track gets a 'restored' variant (filter/arrangement change) when its spring returns."** | Never built. Restoring a spring hardens the sap, lifts the fog by half or breaks the storm (4.4), and the world shows it, but the music went on as if nothing had changed. Worst was Daybreak: after the Spring of Sky the rain thins to a drizzle on screen, while the bed went on roaring with wind, rain and thunder. | **built** |

## As built (bible 13.3)

- **`Music.RESTORED`**, keyed by each spring's flag, and `Music.restored(track)`, which `for_room` applies before `after_the_end`.
- **`trunk_restored`** (`spring:trunk`): the Trunk's A dorian theme with the plucks opened up bright, a shaker over the hand drum, and the bell melody doubled by a warm lead an octave down.
- **`mist_restored`** (`spring:mist`): the drowned waltz a touch quicker (72 from 66) and no longer muffled. The pads and music box are no longer filtered down, a lantern-bell rings where the heartbeat thumped, and the reverb is drier as the fog lifts by half.
- **`daybreak_restored`** (`spring:sky`): the storm broken. It runs at 100 bpm (from 116) with held chords and a walking bass, and the pulsing bass and thunder rolls are gone. The gusting plucks fall soft like the last drops off the leaves.
- **`amb_daybreak_restored`**: Daybreak's bed after the storm. A soft wind comes and goes over a fine drizzle, with water dripping off the leaves and no thunder.
- **The same tune:** each variant draws the same random notes in the same order as its zone track, so the melody is the one you already know, re-arranged.
- **In the moment:** restoring a spring turns its room's music to the restored track over 3 s (`Spring.RESTORE_FADE`, through `Music.for_room(room, fade)`).
- **Towns keep their themes:** Victim and Mascon, and Daybreak's town, name their own tracks.
- **Levels** (`/mnt/project-files/pass-150/levels.txt`):

  | Track | Peak | RMS | Its zone track |
  | --- | --- | --- | --- |
  | `trunk_restored` | -0.6 dB | -15.4 dB | -14.7 dB |
  | `mist_restored` | -1.9 dB | -13.8 dB | -14.1 dB |
  | `daybreak_restored` | -0.5 dB | -13.3 dB | -16.7 dB |
  | `amb_daybreak_restored` | -5.5 dB | -24.8 dB | -21.7 dB |

  `levels.py --check` passes. The storm's drizzle sits 3 dB under the storm.

## Tests

`test_boss.gd`, `test_restored_springs_change_their_zones_music` (new):
- the four new tracks load as loops;
- the Trunk plays its theme until the Spring of Trunk is restored, and restoring it turns the music at once;
- the Mist waits on its own spring, then plays `mist_restored` over `amb_mist`;
- Daybreak's storm music and bed hold until `spring:sky`, then both change;
- Victim keeps its own theme, and only the springs' zones change.

Full suite: 2757 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | Unchanged. |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | A line of the bible's audio plan that was never built: the springs change what you hear as well as what you see. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Unchanged. |

Weighted score: 96.225 (up from 96.2125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability and Faithfulness are tied at 98, the lowest apart from Art, and both weigh 5. Stability's last pass (144) came before Faithfulness's (145), so pass 151 takes Stability.
