# Pass 229: what you wear, added up

Systems' last pass (221) was the oldest apart from Art, so pass 229 takes Systems. I audited the economy, shops, skill tree, the Equipment and Inventory pages, saves and settings against passes 222 to 228, and paid most attention to the shield's ward from pass 225.

| Check | Finding | Verdict |
| --- | --- | --- |
| Item descriptions against their data | Every number in a gear text (armor 15/30/45/60%, guard 50/70%, ward 20/30/40/20%, the helmet's 10%) matches `data/items.json`. | fine |
| The ward's cap and the two-hander | `refresh_stats` caps the ward at 60% and gives a slung shield none. Tested since 225. | fine |
| **What the totals are** | Armor and helmet stack by what each lets through, so the Battle Suit (60%) under the Battle Helmet (10%) stops 64%, not 70%. The ward sums and caps. Neither total appeared anywhere in the game, so a player could not tell what their kit added up to or that a two-hander drops the shield's ward. | **fixed** |
| A slung shield's row | It said "On your back while you hold a two-hander" and nothing about guard or ward. | **fixed** (now "Slung with a two-hander: no guard or ward.", still three lines) |

## As built

- The Equipment page has a footer, as the shops and the skill tree do: "Armor 64%   Ward 60%" (`Menus.worn_totals`, read from the player's own `defense` and `magic_ward`). It updates as you change gear.
- The subtitle: "What you wear and hold. Armor stops blows; a ward turns sorcery. Tempers stay with each blade."
- `--wear=A,B` (game.gd) owns and wears gear for screenshots.
- `test_the_equipment_page_adds_up_what_you_wear` (`test_economy.gd`, new): five kits from bare to a two-hander, each footer's text, that it fits beside the hint, and the slung shield's line. The existing three-line check caught my first, longer wording of that line.
- Screenshots: `/mnt/project-files/pass-229/equipment_totals.png` (a two-hander in hand: Armor 64%, Ward 20%) and `equipment_two_hander.png` (the slung Magic Shield's row in three lines).
- Bible 5.2 (Equipment): "What you wear, added up".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the gear page now shows what the kit adds up to. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 230 takes Audio (last pass 222, now the oldest).
