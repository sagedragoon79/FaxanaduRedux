# Pass 186: kept gear and the Dwarvish Broad Sword

Sean (2026-10-27) asked:
- whether the hero can swap weapons, since a player might not like the Giant Blade's slower swing;
- to rename it the Dwarvish Broad Sword;
- to make it two-handed, with no shield.

World was the scheduled category (last pass 178), but this is gear and combat, so pass 186 counts as Combat. World moves to pass 187.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Swapping gear** | Buying or finding gear replaced the slot. A player who bought the Giant Blade and disliked its pace could not go back to the Long Sword without buying it again, and the shops called the Long Sword "owned". | **built: kept gear and an Equipment page** |
| **The Giant Blade's name** | Sean renamed it the Dwarvish Broad Sword. | **renamed, saves migrate** |
| **Two-handed** | A two-hander with no shield loses guard, parry, Riposte and reflect. At 15/28 it would be worse than it was. | **made two-handed, damage raised to 17/32** |
| Does anything require a parry? | No room, boss or reachability route needs one. Every parryable attack can be dodged or outranged, and you can swap to a one-handed blade at any time. | fine |

## As built

- **Kept gear:**
  - `GameState.data.gear` lists every blade, armor, shield and helmet you have, starting with `["short_sword"]`.
  - `GameState.obtain_gear` adds an item to it and puts it on. Shops, the Dragon Slayer, the Battle Helmet and the Drowned Warden's Battle Suit all use it.
  - `GameState.wear` puts on gear you have, or takes off worn armor, a shield or a helmet. You always hold a blade.
- **The Equipment page:**
  - A new pause-menu row between the Ointment and Options.
  - It lists your gear under Blades, Armor, Shields and Helmets, lowest tier first, and marks what is worn.
  - Each item's detail gives its temper level, a note that a shield goes on your back while you hold a two-hander, and how to take an item off.
- **Shops:** an item is "Owned" only if it is in your gear (`Shop.status`). Lower tiers you never bought stay for sale.
- **The Dwarvish Broad Sword:**
  - Id `dwarvish_broad_sword`, "two_handed": true, slash 17, heavy 32, reach 16, arc 20, swing 1.3.
  - `refresh_stats` clears `has_shield` and `reflects` while it is held, so Block does nothing and the shield layer never draws.
- **Saves:**
  - `RENAMED_ITEMS` maps `giant_blade` to `dwarvish_broad_sword`, including tempers and the gear list.
  - A save from before pass 186 keeps what it wore, plus the Short Sword.
- `--open=equipment` for screenshots, and the `--equip` debug option uses `obtain_gear`.
- Updated bible 5.2 (the table, the Broad Sword, the new Equipment entry) and 10.2 (the final tier).

## Screenshots

- `/mnt/project-files/pass-186/equipment.png`: the Equipment page holding three blades, armor, two shields and the helmet.

## Tests

- `test_economy.gd`, `test_gear_is_kept_and_swapped_and_the_broad_sword_takes_both_hands` (new) checks that:
  - bought blades are kept;
  - the Broad Sword is two-handed, so the shield is off and Block does nothing;
  - swapping back brings the shield to hand and keeps each blade's own tempers;
  - a blade can't be taken off, a shield can, and gear you don't have can't be worn;
  - the page lists blades by tier and marks what is worn;
  - an old save is renamed and keeps its gear.
- `test_economy.gd`, `test_the_final_tier_comes_with_the_spring_of_sky`: the Long Sword stays for sale, and a Broad Sword you put down is still owned.
- `test_combat.gd`, `test_the_dwarvish_broad_sword_sweeps_wide_but_swings_slow`: 17 and 32.
- `test_systems.gd`: the pause menu's Equipment row, and the save round trip with the gear list.

Full suite: 3461 of 3464 checks passed, with no script errors. The three failures were older shop and boss checks that expected a lower tier to count as owned once you had a better one, which kept gear changes on purpose. They now check what you have (the Large Shield, the Magic Shield, the Battle Suit kept with your gear) and pass.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged: each blade is now a play-style choice you can change back. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged: the original replaced gear, and the bible records why this differs. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 187 takes World (last pass 178, now the oldest).
