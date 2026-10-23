# Pass 25: Forepaw freed

Zoradohna's world-state change (design bible 4.4), plus music. Faithfulness was 66 and Audio 67 going in.

## What changed

- **Forepaw** (`levels/tower/forepaw.room`, 20,-4, 80x23). It is the dwarves' city behind the Forepaw Lift. The lift's new
  east door seals while Zoradohna lives (it is a boss arena), so the town opens only once he falls. It holds:
  - the Guru;
  - **Hrothgar the Smith** (Forepaw Forge);
  - **Elder Basalt**, who explains Dunmar the champion, King Grieve's bargain with the meteor, and the Ruby Ring's place at
    the gate of Zenis;
  - two miners, one up on a walkway;
  - two houses;
  - the lift cage.
  - Its own theme, `forepaw` (G major, 96 bpm, anvils in time, a plucked tune).
- **The Forepaw lift** (`LiftCage`, room prop `lift`). It is an iron cage on a chain in Forepaw and in the Tower Foot.
  - Up rides between the two (`World.travel`, with a fade).
  - Until `boss:zoradohna` is set, the cage hangs still and says so.
  - This is the shortcut home: the Tower Foot sits one door from the Spring of Trunk.
- **Smith tempers** (bible 5.2):
  - Temper Blade I (700 g) and II (1,600 g) each add +15% damage to the blade in hand (`GameState.data.tempers`,
    `temper_level()`, `TEMPER_BONUS`).
  - II needs I (the shop shows "Needs I"). A new blade starts untempered.
  - The shop detail line shows "Your Hand Dagger: tempered 0 of 2".
  - The Meteor Shard cost waits for shards to exist in the world (noted in the bible).
- **Zoradohna's own boss theme**, `zoradohna`: E minor, 144 bpm. A churning sixteenth-note engine bass, kick on every
  beat, anvil off-beats, and a lead from bar 5. The arena now plays it instead of the generic boss track.
- **NPC sheets:** four new NPCs from `castgen.py` (dwarf build).
- **Bible:** sections 4.4 and 5.2 are updated.
- **Fix, Zoradohna's wall climb.** It ran for a fixed spot 30 px from the wall. The sealed doorway on the left (and now the
  right) holds the hull further out than that, so the drill could run in place at the seal forever. It now starts
  climbing wherever it meets a wall, and after 2 s at the latest. The test helper now seals the lift's doors as the real fight
  does. Without that, the drill drove out through the new east doorway in the test.

## Tests

- `test_the_forepaw_smith_tempers_a_blade_twice`: locked, then I, then II. The test checks the +15% and +30% damage, owned, and
  that a new blade starts fresh.
- `test_the_forepaw_lift_runs_once_zoradohna_falls`: still before the flag; then down to the Tower Foot, onto open floor,
  beside the cage; then back up.
- The reach checker: Forepaw is a Mattock room. The music test list covers the new tracks.

563 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-25/`:
- `forepaw_west.png`: the Guru, the smith by the forge house, and the elder.
- `forepaw_east.png`: a miner, the walkway dwarf, the sign, and the lift cage with its chain and lit lamp.
- `smith.png`: the Forepaw Forge menu with Temper I for 700 g, Temper II showing "Needs I", and the detail line.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 81 | Unchanged. |
| World and level design | 15 | 79 | A freed town and a shortcut that loops the tower back to the Trunk. |
| Art cohesion | 15 | 73 | Unchanged. The town reuses the tower set, and it needs a forge set piece. |
| Bosses | 10 | 78 | Zoradohna has his own theme. |
| Systems | 10 | 75 | Smith tempers, and lift travel. |
| Audio | 5 | 70 | Two new tracks: the boss theme and the town. |
| Stability and performance | 5 | 70 | Unchanged. |
| Faithfulness | 5 | 69 | Forepaw freed, the dwarf smith, the lift, and the Ruby Ring's story. |

Weighted score: 78 (77.95, up from 77.45).

## Lowest categories and next pass

1. **Faithfulness (69)**, **Stability (70)** and **Audio (70)**. Remaining M4 items are fast travel (the Mantra Path,
   bible 3.3) and the Tower's remaining rooms. A soak pass over the new rooms comes too.
2. **Art (73)**: a forge set piece for Forepaw; the HD Zoradohna sheet when the art thread delivers it.
