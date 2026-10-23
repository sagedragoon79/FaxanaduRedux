# Pass 28: Tower landmarks

The bible wants three landmark rooms per zone (3.3). The Tower had one (the Forepaw forge). Art was 74, Audio 71 and
Stability 72 going in.

## What changed

- **The great winch** (`Winch`, room prop `winch`), standing on the stone block in the middle of Winch Hall. It is a
  toothed iron wheel and a rope drum in a timber A-frame. A crank and a pawl sit on the wheel, and its rope runs up out of
  sight toward Forepaw.
  - It stands still until `boss:zoradohna`, which matches the hall's sign ("It has not turned since the dwarves went
    quiet").
  - After that it turns slowly, and the marks on the rope crawl. This is a small world-state change you see on the way back
    through.
- **The Smelter** (`levels/tower/smelter.room`, 25,-6, 80x23), off the Rail Gallery's new east door. It is the end of the
  ore road (17 of 26 Tower rooms).
  - **The great crucible** (`Crucible`, prop `crucible`) hangs on chains above the walkway. It is an iron pot tipped to
    pour a wavering stream of molten ore into a stone trough. The metal's surface rolls, and the trough glows hottest where
    the stream lands and crusts toward its ends.
  - Sparks jump off the landing point, and an additive glow lights the hall.
  - The room holds an Iron Dwarf, a Minecart Rider, a Gear Bat, a slag-spike pit with a platform over it, a chest on a
    ledge, and a Mana Dew at the top of a platform climb.
  - The "wall of fog" sign moved here: the Mist cut is the room's east end.
- **Minecart Rider sounds**:
  - `cart`: two quick clacks and a rumble, heard every 0.5 s while he rolls and every 0.12 s while he charges.
  - `brake`: a wavering iron shriek for the rev.
  - Both are heard only near the player and get quieter with distance.
- **Bible:** 3.3 names the Tower's three landmarks; 4.4 adds the winch and the Smelter.

## Tests

- `test_the_great_winch_turns_once_forepaw_is_free`: still before the flag, turning after.
- `test_the_smelter_crucible_pours`: the crucible is there, hung high, and throws sparks.
- `test_mantra_path_and_lift_travel_soak` (Stability):
  - Nine Mantra Path hops between the Eolis, Apolune and Forepaw Gurus through the real menu, with button-mashing between
    hops, then six lift rides.
  - Every arrival lands in the right room, inside it, and not embedded.
- The reach checker covers the Smelter (a Mattock room), and the tower soak mashes in it.

598 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-28/`: `winch.png` (the winch on its block, turning, rope up through the walkway) and `smelter.png`
(the crucible pouring into the trough, the glow, an Iron Dwarf on the walkway).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 81 | The Tower has its three landmarks; the ore road ends somewhere memorable. |
| Art cohesion | 15 | 76 | Two large animated set pieces at 2x, in the zone's iron, rust and lamp-orange. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 77 | Unchanged. |
| Audio | 5 | 72 | Cart and brake sounds. |
| Stability and performance | 5 | 73 | The travel soak. |
| Faithfulness | 5 | 71 | Unchanged. |

Weighted score: 80 (79.90, up from 79.35).

## Lowest categories and next pass

1. **Faithfulness (71)** and **Audio (72)**: the Tower's remaining rooms (17 of 26), including the wall-jump skip route
   the bible promises after Zoradohna (4.3), and a Tower ambience bed.
2. **Systems (77)**: the Cartographer's map outline (bible 3.3) and map pins.
