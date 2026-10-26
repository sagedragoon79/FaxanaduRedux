# Pass 156: the boss rush

Systems (98.25, weight 10) was tied for lowest apart from Art with Audio, Stability and Faithfulness, and weighs the most of them. I audited systems against bible 9, 10 and 11 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Damage numbers (pass 154) | the option saves, and hits, heavy hits and hurts each show their own numbers | fine |
| Mantra of Thorns (pass 155) | listed with its needs; a pogo bot clears it | fine |
| Playtest build (PR #174) | the Windows export preset and workflow are on main; nothing in the game changed | fine |
| Shops, skills, saves, trials | covered by their tests; nothing new found | fine |
| **11 completion: "100% unlocks a boss rush"** | The `lord` flag was set at 100%, but it only gave the cloak. The rush the bible promised was never built. It was the one reward for a whole clear with nothing behind it. | **built** |

## As built

- **`BossRush`** (`scripts/data/boss_rush.gd`): a static run like `Trials`.
  - It holds the 13 guardians in critical-path order, with the Drowned Warden before Zenis.
  - It tracks the boss index, the clock, and the place you began.
- **The Guru of the Temple** offers a Boss Rush row under the Guru Trials. It shows "Sealed" until `lord` is set, then the best time.
- **The run:**
  - You begin whole, with full magic and potions.
  - `World.travel_to_door` carries you into each arena through door 1, as if you had walked in. The arena treats the boss as unbeaten while the rush is on it (`BossArena.defeated_before`), and the fight starts the usual way as you walk in.
  - When a boss falls, the arena gives nothing: no rings, keys, flags, gold, doors or ending. The rush mends a third of your health and all your magic, says "n of 13", and carries you on after 2.5 s.
  - The last fall shows "The Rush Is Won" with the time, keeps the best in `data.trials["boss_rush"]`, and carries you back to the Guru.
- **Falling:** a blow that would kill you, with no Elixir left, ends the rush instead ("The Rush Ends"). You go back to the Guru whole, with no death and no lost gold.
- **The HUD** shows "BOSS RUSH n/13", the clock, and the best time or FIRST RUSH.
- **Pause** gains "Leave the rush"; quitting abandons it.
- **`--rush=N[,SECONDS]`** screenshots a rush in progress.

## Screenshots

- `/mnt/project-files/pass-156/rush-hud.png`: rush 8 of 13, King Grieve, the clock at 8:34.2.
- `/mnt/project-files/pass-156/guru-rush-row.png`: the Guru's menu with the Boss Rush row open.

## Tests

- `test_systems.gd`, `test_the_boss_rush_runs_every_guardian_again` (new). It checks that:
  - the rush is sealed before `lord` and open after;
  - each of the 13 rush legs lands in its boss's arena, and walking in starts the fight;
  - the first fall mends a third of your health and all your magic;
  - after the last fall you are back at the Guru with flags, rings, gold and clears unchanged;
  - the best time is saved and shown on the row;
  - a killing blow ends a second rush, you live, you are back at the Guru, and no time is kept.

Full suite: 2897 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | The 100% reward the bible promised: a timed boss rush with a best time. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.4 (up from 96.375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio, Stability and Faithfulness are tied at 98.25, the lowest apart from Art, all weight 5. Audio was last taken longest ago among them, so pass 157 takes Audio. Unbuilt: Guru Trials Winds, Stillness and Falling.
