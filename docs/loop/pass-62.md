# Pass 62: the Spring of Sky

The third spring (bible 4.4), behind Borabohra. This closes Daybreak's arc: the boss falls, the spring runs, the storm
breaks, Eolis celebrates, and the gate down toward Dartmoor waits for the Sky Key.

## What changed

- **Spring of Sky** (`levels/daybreak/sky_spring.room`, 60,-12, 40x23):
  - The Roost gets an east door (door 2), sealed with the arena until the roc falls.
  - The spring (prop `spring_sky`, `needs_flag boss:borabohra`) stands on a dais, with a sign.
  - Clearing it sets `spring:sky`, which fills the Eolis fountain.
- **The storm breaks**: `Motes.SETTLES` thins a zone's motes once its spring runs. Daybreak's rain drops to 30%.
  `Spring.interact` refreshes the motes so the change shows at once.
- **Dartmoor's upper gate** (legend `g`): a `KeyDoor` of kind `sky`, drawn as shrine stone with a gold lightning glyph.
  Borabohra's Sky Key opens it for good and stays in the lock. In `reach.gd` it counts as the ability `sky_key`.
  Nothing lies past it yet but a sign; the way down comes with Dartmoor.
- **Eolis festival**: with `spring:sky`, a Festival Piper plays in the plaza, and Old Wena (`townsfolk_well_glad`)
  rejoices by the full fountain. The castgen sheets are new; every other sheet is unchanged.
- **Bible 4.4** describes what is built. The Branches wind reversal and the final shop tier are still to come. Bible
  3.2 has the room note, and the README legend gains `g`.

## Tests

- `test_world.gd`:
  - `test_spring_of_sky_waits_for_the_roc_and_breaks_the_storm`: the spring is locked until `boss:borabohra`.
    Clearing it sets the flag, the fountain shows 3, and the rain falls below half.
  - `test_eolis_holds_a_festival_for_the_last_spring`: the plaza's people before and after.
  - `test_the_sky_key_opens_dartmoors_upper_gate`: the gate holds without the key, opens with it, uses it up, and
    stays open.
- `test_reachability.gd`: `daybreak/sky_spring` is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`. The fire and thunder flood
  reaches it.

## Screenshots

`/mnt/project-files/pass-62/`:
- `sky_spring.png`: the spring on its dais, and the upper gate.
- `festival.png`: the full fountain, the piper and Wena.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89 | Unchanged. |
| World and level design | 15 | 92.75 | The third spring and its world changes. Daybreak's arc is complete up to the Dartmoor gate. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 89.5 | Weather that responds to the springs, and a keyed gate type. |
| Audio | 5 | 89 | Unchanged. |
| Stability and performance | 5 | 87.75 | Unchanged. |
| Faithfulness | 5 | 89.25 | Three springs and a full fountain, as in the original's arc. |

Weighted score: 89.13 (up from 89.05). The full suite ran 1151 checks; its one failure, the festival test reading flags left by an earlier test, was fixed with `GameState.new_game()` and re-run green in order with the other spring tests.

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (87.75). Next is M5 setup: Dartmoor (bible 6, zone 6). That means the zone
folder, the tilegen spec, music and ambience, the stair down from the upper gate, and the first rooms of the flooded
capital.
