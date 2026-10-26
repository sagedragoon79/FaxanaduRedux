# Pass 151: the mashing hand holds Attack

Stability (98, weight 5) was tied for lowest apart from Art with Faithfulness, and had gone longer since its last pass (144). I audited stability against bible 15.3 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Frame budget | every zone soak averages under 1 ms a frame; boss fights hold their budget | fine |
| Victim and Mascon (passes 145, 148) | soaked with the Mist's rooms | fine |
| Rare drops (pass 147) | off in the runner like every drop, and covered by their own test | fine |
| Restored music (pass 150) | the journey after the end walks every spring's zone with its flag set | fine |
| **Thrust (pass 149)** | `PlayerInput.attack_held` is new, and the soaks' mashing player never held Attack. No soak had learned a Blade skill either, so Thrust, Riposte and Rising Cut had never been soaked: a lunge into walls, off ledges, through doors, onto spikes. | **soaked** |
| **Found by it: a drop's first safe spot** | The first run of the new soak caught an overlap in Mascon. The player climbed the ladder into the Scorched Hall, fell back down its floor shaft into Mascon, and met the spikes before it first landed. The hazard set it back at its safe footing, which was still the Scorched Hall's, so it appeared inside Mascon's ground (the physics pushed it out a frame later). Since M3, `World._place_at_door` set the safe footing only for side and inner doors. | **fixed** |

## As built

- **`_mash` holds Attack** (`test_soak.gd`). It is held for spans of 4 to 60 frames (30% of spans), so most holds charge a Thrust and letting go thrusts. The old 8% taps stay, plus a press on each new hold.
- **`_learn_the_blade(w)`** learns every Blade node, Thrust included. Every zone soak and both journeys (`_journey_buff`) call it.
- **Thrust count:** each zone soak prints its thrusts and checks there was at least one, all but the Sunken Spring's, which is all water (a charge is spent underwater).
- **Two soaks retuned for the new hand:**
  - The journeys mash on their own dice (`hand`), so the doors a walk picks no longer depend on how the mashing draws. With one shared generator, the extra draws sent the first lap round 14 Eolis rooms.
  - The Bloom fight soak steps the player into Pakukame's biting range every 5 s, so the bite is always soaked; the new mashing had kept its distance for the whole fight.
- **The after-the-end leak check retraces its lap:** its second lap now walks new ground, and the first sight of a zone's music, sheets and tiles is cached for good (66 objects). A probe walking the same lap three times showed a flat 2,937 objects each time, so this was caching, not a leak. The check now measures a third lap that retraces the second: 3,259 objects before and after.
- **`World._place_at_door`:** every door's arrival is now the player's first safe spot in the new room. A hazard before the first landing sets you back under the shaft you fell through, and the first landing takes over as usual. Bible 3.3 has a line on it, and 15.3 a paragraph on the pass.

## Report

`/mnt/project-files/pass-151/soak.txt`: the zone soaks with the new mashing before the fix (with the Mascon overlap), then every soak line of the final full run (no overlaps). The table is from the first run.

| Zone | Rooms | Thrusts | Average frame |
| --- | --- | --- | --- |
| Tower | 26 | 16 | 0.75 ms |
| Eolis | 6 | 2 | 0.54 ms |
| Trunk | 28 | 20 | 0.72 ms |
| Mist | 13 | 12 | 0.86 ms |
| Branches | 9 | 7 | 0.77 ms |
| Daybreak | 9 | 6 | 0.79 ms |
| Dartmoor | 13 | 16 | 0.69 ms |
| Zenis | 7 | 1 | 0.99 ms |
| Sunken Spring | 4 | 1 | 0.88 ms |
| Trials | 2 | 2 | 0.50 ms |

## Tests

- `test_world.gd`, `test_spikes_before_the_first_landing_set_you_back_in_the_new_room` (new). It drops from the Scorched Hall into Mascon and checks:
  - the arrival is the first safe spot, inside the room and in the open;
  - a hazard before landing sets you back in the open in Mascon;
  - the first landing takes over as the safe footing.

  Against the old code it fails: the safe spot was still the Scorched Hall's.
- `test_soak.gd`: every zone soak now holds Attack with the Blade branch learned and checks for thrusts.

Full suite: 2770 checks, all passing, with no script errors in the log. The first full run failed once: a single 61.6 ms frame in the Eolis plaza during the after-the-end journey. Two runs of that test alone retraced the same path with the worst frame at 5.9 and 8.4 ms, and a second full run passed with no frame over 33 ms. So it was a one-off hitch of the machine, not of the game; the check stays as strict as it was.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | Unchanged. |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | The soaks mash the whole Blade branch, and the first run found and fixed a real bug in how a drop sets your safe footing. |
| Faithfulness | 5 | 98 | Unchanged. |

Weighted score: 96.2375 (up from 96.225). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (98) is now the lowest apart from Art, so pass 152 takes Faithfulness.
