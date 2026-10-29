# Pass 250: the purse comes back

Category: Combat (last pass 242).

## Audit

I checked bible 5 and 7 against the player's code, looking at the moves where they meet:
- **Drinking:** a blow, a dash or leaving the floor ends the drink, and the charge is kept.
- **Guarding and parrying:** a parry wins over invulnerability, the ward over sorcery, a guard breaks at no MP.
- **Water:** a thrust's charge is spent in it, and throws and casts are held back while you can't use them.
- **Death:** the purse you drop (5.4).

The gap found is in 5.4. On death you drop 60% of your gold as a purse, and the bible promises it waits where you fell. `World._on_player_died` writes it to the save as `{room, x, y, value}`. But `GameState.sanitize`, which every load runs, had asked since pass 109 for the gold under `gold`, found none, and threw the purse away. So dying, saving at the shrine you woke at, and loading later lost the 60% for good, with nothing to say so. The save round-trip test had used the wrong key too, which is why it never failed.

## Fix

- `sanitize` keeps a purse with a number `value` above 0, normalized to `{room, x, y, value}`. It reads a purse named `gold` as well, and drops an empty or broken one.
- `test_every_save_field_survives_a_round_trip` in `test_systems.gd` now writes the purse as World does.
- Test: `test_a_dropped_purse_survives_a_save_and_load` (`test_rooms.gd`). It checks that:
  - dying drops 60 of 100 gold and the purse is in the game state;
  - after a save, a new game and a load, it is still there;
  - the loaded world lays it in the room;
  - a purse saved as `gold` is read, and an empty one is dropped.
- Mutation check: the old sanitize fails three of its checks.
- Bible 5.4.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: death's recovery now keeps its promise through a load. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 251 takes World (last pass 243).
