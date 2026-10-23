# Pass 33: The lift to Eolis, and the Tower complete

Faithfulness was 74. Bible 3 promises "an elevator shortcut back to Eolis", but the lift only joined Forepaw and the
Tower Foot. This pass also builds the last three Tower rooms, which makes 26 of 26.

## What changed

- **The lift goes home.**
  - `LiftCage` now has three `STOPS`: Forepaw, the Tower Foot, and a new cage at the East Gate of Eolis (`prop: 4, 19,
    lift`), "down the outside of the trunk".
  - Pressing Up in a running cage opens a **Forepaw Lift** menu of the other stops (`Menus.open_lift`).
  - With no menu open, the cage rides to its usual stop (`USUAL`), so scripted rides still work.
  - The cage only runs once Zoradohna falls. Until then it hangs still, as before.
  - Bible 4.4 is updated.
- **Gear Pit** (`tower/gear_pit`, 16,-4): the great gears' pit between the Gear Shaft and Winch Hall.
  - It is reached through a new east door low in the Gear Shaft (door 3). A floor shaft drops into a new ceiling shaft
    in Winch Hall (door 5, with a beam under it).
  - Spikes lie under a beam. A Mana Dew sits on a ledge up the east wall, reached by a glove climb up a hanging wall.
  - Two Gear Bats guard it.
- **Cistern** (`tower/cistern`, 16,-2): the tower's dry water store, under a new floor shaft in Winch Hall (door 6).
  - It has three Grub Lumps, a chest, and a Potion Shard on a high shelf.
  - A beam climb leads back to the hall, and a door leads east to the Ore Bin.
- **Ore Bin** (`tower/ore_bin`, 17,-2): a half-full ore bin with a Minecart Rider on his rounds, a chest on the
  beams, and a fake-wall cubby holding a Potion Shard.
- All three are reachable with the glove alone, before the Mattock: a reason to explore the Winch Hall hub on the way
  up.

## Tests

- `test_the_lift_runs_down_the_trunk_to_eolis` (test_economy):
  - the Eolis cage is still before Zoradohna falls;
  - then it offers Forepaw and the Tower Foot;
  - it rides up to Forepaw, onto open floor;
  - and it rides all the way home to Eolis.
- `test_mantra_path_and_lift_travel_soak` now rides by picking each stop from the menu.
- The reach tests pass with the three new rooms: everything is reachable with the glove, with no soft-locks.

629 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-33/`:
- `eolis_lift.png`: the cage at the East Gate, beside the gatekeeper.
- `winch_shaft.png`: Winch Hall's new ceiling shaft and the beam under it.
- `gear_pit.png`: the spike beam, the hanging wall and the Mana Dew ledge.
- `cistern.png`, `ore_bin.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 86 | The Tower of Trunk is complete at 26 rooms, with hubs, loops, a skip route and secrets. |
| Art cohesion | 15 | 78 | Unchanged. The lift cage still draws at 1x. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 81 | Lift stops join the Mantra Path as fast travel. |
| Audio | 5 | 75 | Unchanged. |
| Stability and performance | 5 | 76 | Unchanged. |
| Faithfulness | 5 | 77 | The elevator back to Eolis, as in the original's route home. |

Weighted score: 82 (81.95, up from 81.40).

## Lowest categories and next pass

1. **Audio (75)** and **Stability (76)**: per-surface footsteps (bible 11), and soak the lift menu.
2. **Art (78)**: redraw the lift cage at 2x, add a pixel font, and add bell and window props.
3. **Bosses (78)**: with the Tower complete, M4 moves on to the Mist (bible 3, zone 3). The first boss there is
   Ripasheiku.
