# Pass 120: hardening the last seven passes

Stability and performance (96.5) tied for lowest apart from Art. I audited what passes 113 to 119 added (Guru Trials, slopes, Seed Bomber, card vaults, Joker Key, Battle Helmet, Marsh Hag) for frame cost, save round-trips, re-entry and respawn, and errors in a headless run.

| Check | Finding | Verdict |
| --- | --- | --- |
| Zone soaks (random input in every room, all zones) | no errors or warnings in the log; Mist 0.87 ms a frame, card-vault and helmet rooms inside their zones' soaks | fine |
| **Trials zone** | `levels/trials/` had no soak at all | **added** (0.55 ms a frame) |
| Fog cost in the hag rooms | Fog Cut 0.018 ms, Victim Causeway 0.013 ms for the light list | fine |
| **Fog light order** | The decor's lanterns took slots first and play lights (boss lanterns, the hag's wisp and mark, spells) came after, up to 48. No room reaches the cap today, but a room crowded with lanterns would have left a foe in the dark. | **fixed** |
| **Hour Glass and the hag's hex** | Every enemy shot checks `TimeStop.active()` except `MireGrasp` (pass 119). A hand could rise and strike while time stood still. | **fixed** |
| **Hag respawn** | `_backed` wasn't reset on respawn, so a hag that came back could skip backing away | **fixed** |
| **Damaged saves: keys** | `sanitize` didn't check `keys`. A key entry that wasn't a number or a bool (from a hand-edited or damaged file) would reach `int()` in `key_count`. | **fixed** |
| Save round-trip of the new state | card keys, the Joker Key, Lantern Key, Battle Helmet (mask and full health on load), trial bests, opened card doors | fine, now tested |
| Card doors on re-entry | an opened door stays open (pass 117 test) | fine |

## As built

- **Fog** (`fog.gd`): the group `light` goes into the light list before the decor's lantern glows. Play lights are few, so lanterns only fill what is left.
- **MireGrasp:** holds still while time is stopped, whether it is the mark or the risen hand. The hand strikes when time runs on, like the other enemy shots that wait. Bible 4 (Hour Glass) lists it.
- **MarshHag:** `_respawn` resets `_backed` as well as the cooldown and the mark.
- **GameState.sanitize:** keeps a key entry only if its kind is a string and its value is a bool (the Lantern and Sky Keys) or a count of 0 or more.

## Tests

- `test_every_enemy_shot_honours_the_hour_glass` (`test_enemies.gd`):
  - every script in the `enemy_projectile` group checks `TimeStop.active()`;
  - a mire hand raised during a time stop doesn't strike until time runs on.
- `test_a_respawned_marsh_hag_starts_fresh` (`test_enemies.gd`): her hex dies with her, and she comes back whole with nothing left over.
- `test_play_lights_come_before_the_lanterns` (`test_world.gd`): with more lantern glows than the fog can light, a hag's wisp is still lit and clears the fog.
- `test_late_additions_survive_a_save_round_trip` (`test_rooms.gd`):
  - all of the new state above survives a save;
  - loading fills health to the helmet's new top;
  - damaged key entries are dropped.
- `test_random_input_soak_in_every_trial_room` (`test_soak.gd`).

## Bible

- 4, Hour Glass as built: the Marsh Hag's hand is among the things the glass holds.
- 3.2, Fog: play lights come before the decor's lanterns.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | Unchanged. |
| Combat and enemies | 15 | 97 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 96.5 | Unchanged. |
| Stability and performance | 5 | 97 | This pass fixed four issues and added five tests. Every zone, the Trials included, is soaked now, and the newest state survives a save. |
| Faithfulness | 5 | 96.75 | Unchanged. |

Full suite: 2364 checks, all passing.

Weighted score: 95.175 (up from 95.15). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement and Audio are tied at 96.5, and Movement carries more weight. Pass 121 takes Movement.
