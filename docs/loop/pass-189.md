# Pass 189: what a blade does, and the cloak anywhere

Systems' last pass (180) was the oldest apart from Art, so pass 189 takes Systems. I audited the systems (bible 9 and 10, and the gear in 5.2) against the newest content (passes 180 to 188).

| Check | Finding | Verdict |
| --- | --- | --- |
| **Choosing a blade** | Sean asked about swapping blades because the Broad Sword swings slower (pass 186). Neither the shop nor the Equipment page showed any number: a blade's row said "slow" or "hits harder". You had to buy a blade and try it to learn what that meant. | **built: blade numbers** |
| **Dyes and kept gear** | Gear swaps anywhere since pass 186, but a cloak dye you own could only be put on at Ilse's in Eolis. | **built: a Cloak section** |
| **The detail box** | The menu's detail box holds three lines. With the Broad Sword in hand, the Magic Shield's row ran to four (its text plus "on your back"), so its last line was drawn off the box. | **fixed** |
| Skills and the Rune Dagger (passes 184, 188) | Bloodletting, Executioner and Siphon read only blade hits, so the free dagger can't farm health or MP. Keen Edge scales it, as the bible says. | fine |
| The helmet and kept gear in saves (passes 185, 186) | They migrate and round-trip (tests from those passes). | fine |
| Prop finds as treasures (pass 187) | Counted, sensed and saved. | fine |
| Hero body sets and the cloak layer (PR #206) | The dye reaches the cloak layer, so a dye chosen on the new Cloak section shows at once. | fine |

## As built

- `Menus.blade_numbers(id)` gives a blade's cut and heavy damage (tempers in), its extra reach and how much slower it swings. For example, the Broad Sword shows "Cuts 17, heavy 32, reach +16, 30% slower."
  - It is added to each blade's detail on the Equipment page and on a shop's shelf.
- The Equipment page ends with a **Cloak** section:
  - `Menus.cloak_dyes` lists Warden Green, the dyes in your save, and the Lord's Gold once the flag `lord` is set.
  - `Menus.choose_equipment` puts gear on or off as before, and puts on a dye you have.
- `GameData.items_of_kind(kind)` lists item ids of one kind in table order.
- Shorter texts that fit the box:
  - the Broad Sword: "Dwarven storm-iron, as long as you are tall. Two-handed: no shield, and slow, but it sweeps a huge arc.";
  - the Magic Shield: "Guards 70%. A parry flings small shots back at your foes, even sap and molten rock.";
  - the shield note under a two-hander: "On your back while you hold a two-hander."
- `--cursor=N` (game.gd) puts an opened menu's cursor on a row, for screenshots.
- Two doc comments in `game_state.gd` had drifted onto the wrong functions (`dye`, `owns_gear`). They are now back on `begin_ending` and `owns_dye`.
- Bible 5.2 (the Equipment entry) and 10 (the dyes).

## Screenshots

- `/mnt/project-files/pass-189/equipment.png`: the Equipment page on the Dwarvish Broad Sword, with its numbers, and the Cloak section below.

## Tests

- `test_economy.gd`, `test_the_equipment_page_shows_blade_numbers_and_changes_the_cloak` (new) checks:
  - the numbers of the Short Sword and the Broad Sword, and of a tempered Long Sword;
  - that every dye is on Ilse's shelf;
  - the Cloak section's dyes for a new game, then with dyes bought and won and the Lord's Gold;
  - the worn mark, and a blade row's numbers;
  - that every detail fits three lines with all gear owned;
  - that choosing a dye wears it away from the Dyeworks, but not one you don't have.

Full suite: 3511 of 3511 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged: a blade is now chosen by its numbers, and the cloak is dressed where you stand. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 190 takes Audio (last pass 181, now the oldest).
