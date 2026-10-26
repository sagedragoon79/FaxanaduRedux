# Pass 125: ladders where the original had them

World (97) was tied for the lowest category apart from Art and weighs 15. Pass 124 added ladders, but only the Hollow Mouth and the gym had one. In the original, the Tower of Trunk is climbed by ladders.

## Audit

| Room | Finding | Verdict |
| --- | --- | --- |
| Tower Foot | the tower's main shaft is a zigzag of seven planks up to the Winch Hall ledge, with nothing that reads as the tower's own way up | **ladder** |
| Mine Shaft | the miners' shaft, descended by a plank zigzag, and the way back up was the same climb | **ladder** |
| Forepaw Stair | its plank stack is the pogo challenge over the spikes; a ladder would empty it | left as is |
| Fungus Shaft, Gnawed Stair | the Fungus Shaft is the Glove's gate (the wall-jump shaft to the boss), and the Gnawed Stair is past it | no ladders |
| Eolis halls | single-floor rooms | nothing to climb |
| Apolune, Rot Dwarf Hall | their planks hold a chest and a shard, a small jumping reward | left as is |

## As built

- **The Tower Foot:** a ladder up the right wall from the floor to the ledge at the Winch Hall door. Its top is the ledge's plank, beside the zigzag.
- **The Mine Shaft:** a ladder up the right side from the shaft's bottom, through the upper floor beside the miners' doors.
- **The gate guard:** `test_ladders_never_open_a_gated_room` builds the world with every ladder taken out (each top cell left as a plank, the rest open air). It then checks that, with no abilities and with the Glove, the real world reaches no room the bare one doesn't.
  - To check that it bites, I put a ladder up the Fungus Shaft as a trial. The test failed and listed the nine Trunk rooms behind the Glove gate, from the Rot Dwarf Hall to Rokusutahn's chamber. The trial ladder was then removed.
- **Bible 6.11:** "Where ladders go": between floors that already connect, never in an ability gate, with the test named and the three placements listed.

## Screenshots

In `/mnt/project-files/pass-125/`:
- `tower_foot_ladder.png`: the Tower Foot's ladder up the right wall to the Winch Hall ledge, beside the plank zigzag.
- `mine_shaft_ladder.png`: the Mine Shaft's ladder through the upper floor.

## Tests

- `test_ladders_never_open_a_gated_room` (`test_reachability.gd`), new.
- Every existing gate test (Glove, Mattock rooms, Stride, Thunder, winch and the Old Flue) passes with the new ladders.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | Unchanged. |
| Combat and enemies | 15 | 97 | Unchanged. |
| World and level design | 15 | 97.25 | The Tower climbs by ladder again, and a test guarantees no ladder ever opens a gate. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 97 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2443 checks, all passing.

Weighted score: 95.4125 (up from 95.375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat (97, weight 15) is the heaviest of the lowest. Pass 126 takes Combat: how the newer foes meet ladders (a hit knocks you off) and the combat feel of the late game.
