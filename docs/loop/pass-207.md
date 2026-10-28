# Pass 207: no silent sounds

Stability's last pass (199) was the oldest apart from Art, so pass 207 takes Stability. I audited passes 200 to 206 for what could fail without any test noticing.

| Check | Finding | Verdict |
| --- | --- | --- |
| Relics in saves (201) | `pendant` and `magical_rod` sit in `fresh()` abilities, and `normalize` keeps an old save's abilities. The save round-trip tests pass. | fine |
| The Inventory page (205) | It reads only `GameState.data` and the player, and every list is filtered against fixed tables (`ZenisGate.RINGS`, `KEY_ORDER`). So a save with an unknown ring or key shows nothing for it, and nothing fails. | fine |
| `--open` after `--give` (205) | It only applies to screenshot runs. Menus open on frame 2 as before, just after the gear and finds. | fine |
| `coin_big` loading (206) | `Sfx.load_all` reads the folder, so the new file loads with the game. The boss soak's "nothing loads mid-fight" check holds. | fine |
| **Sounds named at runtime** | `test_every_sound_the_code_plays_exists` reads only literal names in `Sfx.play("...")`. Pass 206 added `Coin.sound`, a helper that picks the name, and the same is true of `equipment_sound`, `swing_sound` and the footsteps' `"step_" + surface`. A typo in any of them plays silence and fails nothing. | **built: `Sfx.missing`, checked after every test** |

## As built

- `Sfx.play` adds any name with no file to `Sfx.missing`, each name once.
- `tests/test_runner.gd` clears the list before each test and fails the test if anything was added. So every test, the soak journeys and boss fights included, now also checks every sound that actually plays.
- New test `test_a_sound_with_no_file_is_caught_at_runtime`. It checks that a missing name is noticed. It also checks that every sound the helpers can pick exists: each coin value, each blade, armor, shield, helmet and dye, and the footsteps of every zone, every room's `surface:` line, and sap and planks.
- Mutation: misspelling `coin_big` fails `test_a_big_purse_sprays_few_coins` through the runner, with "played sounds that do not exist: [coin_bigg]".
- The first full run found no test playing a missing sound.
- Bible 15.3, stability measures: "No silent sounds".

Full suite: 4006 of 4006 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: a class of silent failure is now caught. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 208 takes Movement (last pass 200, now the oldest).
