# Pass 195: somewhere to rest at the top of the Tower

World's last pass (187) was the oldest apart from Art, so pass 195 takes World. I audited world and level design (bible 3 and 4, the layout rules in `levels/README.md`) against passes 186 to 194. Pass 194 made foes hit harder in the deep zones (zone threat, 5.5), so I also checked how far each room is from a rest and how thick the foes are.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Save spacing (bible 3: "no room is more than 4 rooms from a save")** | Nothing tested it. Walking the door graph from every Meditation Shrine and Guru found one room over: the Bell Loft, a dead end at the top of the Tower. It is five doors from the Mine Vault's shrine (by the Crown Lookout, the Rafters, the Mine Shaft and the Rail Gallery) and five from Forepaw's Guru, with Gear Bats roosting the whole way. Every other room is within 4. | **fixed: a shrine in the Crown Lookout, and a test** |
| Save spacing where foes hit at double | In Dartmoor, the Sunken Spring and Zenis the farthest room is 3 doors from a rest (the Wellspring, the Heart). Under 2x threat that is the line worth keeping, so the test holds those zones to 3. | **held by the test** |
| Foe density under threat | The busiest rooms per screen are the Mist's Victim Causeway and Fog Cut (5 foes in one screen, at 1.4x) and Zenis's Heart Stair (8 foes in two screens, at 2x, corrupted). The Mist's foes are slow and fog-bound. The Heart Stair is the final gauntlet, between the Drift Well's and the Proving Scar's shrines. Through par armor a blow there costs about a mask (5.5). | fine |
| Shrines per zone (bible 3: 2 to 3) | The Mist has 1 shrine and Daybreak has 1, but each has towns with Gurus (Victim, Mascon; Daybreak), and the distance rule holds. | fine |
| Reachability, secrets, signposting | Unchanged since pass 187. The full reachability suite passes with the new shrine. | fine |

## As built

- `levels/tower/crown_lookout.room`: a Meditation Shrine (`S`) on the floor at 12,19, by the lookout's sign. Screenshot: [crown_lookout_shrine.png](/mnt/project-files/pass-195/crown_lookout_shrine.png).
- `test_world.gd`, `test_no_room_is_far_from_a_rest` (new):
  - builds the door graph of every zone apart from the gym and the trials;
  - counts the doors from each room to the nearest shrine or Guru (an npc whose role in `data/npcs.json` is `guru`);
  - holds every room to `SAVE_REACH` (4), and rooms in a zone whose threat is 2 or more to `DEEP_SAVE_REACH` (3).
  - Without the new shrine it fails on the Bell Loft (checked).
- Bible 3, Save points: the rule notes its test, the deep-zone limit and the Crown Lookout's shrine.

Full suite: 3792 of 3792 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the bible's save-spacing rule now holds everywhere, and a test keeps it. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 196 takes Bosses (last pass 188, now the oldest). Pass 194 left boss arenas at threat 1, so a boss damage sheet is a natural audit.
