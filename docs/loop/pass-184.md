# Pass 184: the Short Sword and the Rune Dagger

Sean asked for two weapon changes (2026-10-27): call the Hand Dagger a short sword, since every swing of it is a slash, and add a special dagger that is thrown as a projectile and then rematerializes back to the hero. Faithfulness was the scheduled category (last pass 175); this pass takes it, since the work is a naming and kit question first.

| Check | Finding | Verdict |
| --- | --- | --- |
| **The starting blade's name** | "Hand Dagger" named a stabbing weapon, but the blade only ever slashes (three-hit combo, up-slash, down-strike) | **renamed** |
| **A ranged answer before the spells** | Until Deluge (the Mist), nothing reaches a hornet, a Sap Spitter or a Seed Bomber except a jump and a swing. Every ranged tool costs MP. | **built: the Rune Dagger** |
| Old saves | a save naming `hand_dagger` would have fallen back to the starting blade untempered (pass 138's guard), losing its tempers | **migrated** |

## As built

- **Short Sword:** `data/items.json` id `short_sword` (8 light / 14 heavy, as before). `GameState.RENAMED_ITEMS` maps `hand_dagger` to `short_sword`; `sanitize` carries over the equipped blade and its tempers. A new game starts with it.
- **Rune Dagger** (`scripts/combat/rune_dagger.gd`, `Player._try_throw`):
  - Found on the floor of the Trunk's Hornet Gallery by the entrance sign (legend `}`), where three hornets and a Sap Spitter teach it.
  - The Throw button: B or ; on the keyboard, RB on a pad. Dash gave up its third binding (RB) and keeps the B button and RT. Up throws it straight up.
  - 420 px/s for 160 px; 6 damage scaled by Keen Edge; walls and gates stop it, one-way planks don't.
  - When its flight ends it breaks into rune light and reforms at the hero's hip 0.4 s later (`dagger_throw`, `dagger_return` in sfxgen). One at a time, no MP, never lost.
  - It gates nothing, so reachability is unchanged. It is not a blade, so it takes no temper and the five Meteor Shards still cover the four blades.
  - Drawn in code, as a layer apart from the hero, matching the paper-doll plan (Sean is drawing the hero empty-handed).
- The pause menu's Controls list has a "Throw dagger" row, and Throw can be rebound.
- `--shot-throw=N` (game.gd) throws it on frame N for screenshots.
- Bible 5.2 (the blade table, the values table, new Short Sword and Rune Dagger entries), 5.3 (the shoulders) and the pass 138 note; `levels/README.md` legend `}`.

## Screenshots

- `/mnt/project-files/pass-184/rune_dagger_pickup.png`: the dagger point-down by the Hornet Gallery's sign.
- `/mnt/project-files/pass-184/rune_dagger_flight.png`: thrown, with its rune-light trail.

## Tests

- `test_combat.gd`, `test_the_rune_dagger_flies_strikes_and_reforms_at_your_hip` (new): no throw without it; thrown the way you face; one at a time; it hits the dummy for 6 and breaks; no MP; it reforms after 0.4 s; Up throws it up.
- `test_combat.gd`, `test_the_rune_dagger_breaks_on_walls_and_at_the_end_of_its_reach` (new).
- `test_systems.gd`, `test_the_hand_dagger_is_the_short_sword_and_the_rune_dagger_is_found` (new): an old save's Hand Dagger and its tempers carry over; Throw is on B and RB; the dagger lies in the Hornet Gallery and the pickup grants it.
- `test_systems.gd`, `test_rebinding_swaps_and_resets`: uses N now that B is Throw's.
- The rename in `test_economy.gd`, `test_rooms.gd` and `test_systems.gd`.

Full suite: 3437 of 3437 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged: a free ranged tool for fliers and turrets, kept weak (6) so the blade stays the main weapon. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged: the starting blade's name now fits what it does. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 185 takes Combat (last pass 177, now the oldest).
