# Pass 73: past the throne, to the gate of Zenis

The way on after King Grieve (bible 8.7 and 9).

## What changed

- **A door behind the throne**: the Throne Hall's door 2, on top of the dais. The boss arena seals every door but the
  way in, so the iron bars it until he is beaten, and from then on it is open.
- **Meteor Rise** (`levels/dartmoor/meteor_rise.room`, 60,-9, 40x68):
  - Eleven switchback shelves up a crystal-choked shaft, four rows apart and alternating sides.
  - His guard is still on them: two Crystal Dwarves, two Shade Knights and two Clockwork Hounds.
  - The way down to the Sunken Spring is signed and sealed at its foot (optional area, M7).
- **Zenis Gate** (`levels/dartmoor/zenis_gate.room`, 61,-9, 60x23): a shrine and the gate of Zenis.
  - The gate is a new prop, `zenis_gate` (`scripts/world/zenis_gate.gd`): black meteor-iron veined with crystal, with
    four ring sockets (Elf, Ruby, Dworf, Demon) that glow for the rings you hold.
  - Walking up to it tells you how many glow. With all four it still waits on the shadow before it (Shadow Eura,
    bible 8.8, not built yet).
- **Dartmoor drains, a first step**: once `boss:king_grieve` is set the drowned dwarves wake.
  - Steward Hrafna stands by the empty throne and Mason Brokk in the Drowned Market (new NPCs; sheets from
    `castgen.py`).
  - They say the water is going down, and point you up the Rise and at the Sunken Spring.
  - The time-locked water stays ("the water-clocks still hold their hour"), so no Hour Glass route changes.
- **Docs**: bible 8.7 covers the way on and the draining as built.

## Tests

- `test_rooms.gd`:
  - `test_the_way_past_the_throne_opens_once_the_king_is_at_rest`: the door is barred while he lives, the dwarves
    wake after, and nothing bars the way on.
  - `test_the_gate_of_zenis_waits_for_four_rings`.
- `test_reachability.gd`: both new rooms are in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.

## Screenshots

`/mnt/project-files/pass-73/`:
- `rise.png`
- `gate.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90 | Unchanged. |
| World and level design | 15 | 94.5 | The world answers the king's defeat, and the road to the last gate is open. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 91 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.5 | Unchanged. |
| Stability and performance | 5 | 88.75 | Unchanged. |
| Faithfulness | 5 | 90.25 | The ring-gate of Zenis. |

Weighted score: 89.98 (up from 89.93; 89.975 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (88.75). Next: Shadow Eura (bible 8.8) before the gate, starting with phase
1 (a shadow that mirrors your inputs with a delay).
