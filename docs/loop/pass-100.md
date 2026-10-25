# Pass 100: Systems audit and the Act III skill tier

Systems (93.25) was tied with Movement as the lowest category apart from Art. This pass proves the save carries everything, audits each system against the bible, and builds the biggest gap: a skill tree too shallow for the points the game gives.

## Audit

| System | Bible | Status and evidence |
| --- | --- | --- |
| Save and load | 15.3 | **New proof.** `test_every_save_field_survives_a_round_trip` sets all 32 fields (every one but `version`) of `GameState.data` away from their new-game values, checks none was missed, saves, loads and compares by value. It then starts a fresh world from the save and checks the player's gold, gear, skills, stats and abilities. Everything survives. |
| Older saves gain new keys | 14 | `load_game` merges the save over `fresh()`, so a missing key takes its new-game value. New test: `test_an_old_save_gains_the_new_keys` loads a five-key save from an old build. |
| Ranks, titles and named rank | 9 | Built (16 ranks, Guru naming ceremony); tested. |
| Skill points | 9 | 15 ranks + 9 bosses + 5 from Mantra Shards = 29. |
| Skill tree depth | 9 | **Gap.** Built nodes cost 15 points in all, so the last 14 points the game gives had nothing to buy. Built ten more (below). |
| Respec | 9 | 200 g, rising 200 g each time, capped at 2,000 g; tested. |
| Shops, the final tier, `requires` flags | 10.2 | Built through pass 93; tested. |
| Map: auto-map, charts, pins | 3.3 | Built; tested. |
| Mantra Path and the Forepaw Lift | 3.3 | Built; covered by `test_mantra_path_and_lift_travel_soak`. |
| Settings | 14 | Saved to `user://settings.cfg`, applied at start; tested. |
| Completion screen, boss rush, Guru Trials, cloak dyes | 10.2, 11 | **Not built.** Optional, post-game layers; candidates for a later Systems pass. |

## What changed: ten more skill nodes

The tree now costs 36 points against the game's 29, so a full build means choosing. Each node needs the one before it in its branch.

- **Blade**, after Mattock Mastery:
  - **Riposte** [2]: a parry answers with a free heavy cut at the foe that swung, with the heavy slash smear and an impact spark.
  - **Keener Edge** [2]: another +10% melee damage.
  - **Bloodletting** [2]: each hit on a staggered foe heals 2 HP.
- **Arcana**, after Tilte Swarm:
  - **Thrift** [2]: spells cost 15% less.
  - **Chain Thunder** [2]: a Thunder bolt that strikes a foe leaps to the 2 nearest others within 110 px, one after another, for 75% damage each. The arcs fall from above, so a raised shield doesn't stop them.
  - **Time Thief** [2]: the Hour Glass holds 3.5 s. Its HUD bar now measures against the stop's own length.
- **Wanderer**, after Second Stride:
  - **Treasure Sense** [2]: the map puts an orange star on any room it shows that still holds an item or chest, and the legend adds "Treasure". The World's catalog now lists each room's treasures.
  - **Resilience** [2]: +1 mask.
  - **Last Stand** [2]: below 20% health, 25% less damage.
  - **Second Wind** [3]: once between rests, a killing blow leaves you at 1 HP. A shrine, a Guru or a respawn gives it back.

Deviations, recorded in bible 9:
- Thrust, Wildfire, Feather Fall and the other bigger mechanics still come later in their branches.
- Light Step was dropped: a dash's own invulnerability already carries you over spikes, so the node would do nothing. A test showed it.
- Pathfinder was dropped: shrines already refill potions.

## Tests

- `test_systems.gd`: `test_every_save_field_survives_a_round_trip`, `test_an_old_save_gains_the_new_keys`.
- `test_economy.gd`:
  - `test_act_three_skills_chain_and_apply`: order, effects, respec, and a tree that costs more than 29.
  - `test_riposte_answers_a_parry_with_a_heavy_cut`
  - `test_bloodletting_heals_on_a_staggered_foe`
  - `test_thrift_and_time_thief`
  - `test_chain_thunder_leaps_to_two_more_foes`: three struck, the far one spared.
  - `test_treasure_sense_marks_rooms_with_something_left`
  - `test_last_stand_and_second_wind`

Full suite: 1910 checks, all passing.

Screenshots:
- `/mnt/project-files/pass-100/skills.png`: the longer list scrolls.
- `/mnt/project-files/pass-100/treasure_map.png`: the star on Amber Falls, and the legend.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 93.25 | Unchanged. |
| Combat and enemies | 15 | 94 | Riposte, Bloodletting and Chain Thunder add new ways to fight. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.25 | Unchanged. |
| Systems | 10 | 94.5 | Every save field proven to round-trip; the tree is deep enough that points stay scarce to the end. |
| Audio | 5 | 93.75 | Unchanged. |
| Stability and performance | 5 | 94 | Unchanged. |
| Faithfulness | 5 | 96 | Unchanged. |

Weighted score: 93.48 (up from 93.31; 93.475 unrounded).

## Next

Movement (93.25) is now the lowest apart from Art. Pass 101 takes Movement: build Feather Fall (glide after the double jump, bible 9 Wanderer) and review air control and the dash against the bible 6 numbers in scripted runs.
