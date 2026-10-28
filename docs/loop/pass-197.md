# Pass 197: risk pays, and the gold sheet

Systems' last pass (189) was the oldest apart from Art, so pass 197 takes Systems. Passes 194 and 196 made foes and bosses hit harder the deeper you go, so I audited the economy against that (bible 10), along with items, ranks and saves against passes 188 to 196.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Can a par player afford the par kit?** | Yes, easily. Start with the King's 1,500 g, open half the chests and fell each foe once. That buys the Long Sword and Leather, Studded Mail after the Trunk, Temper I after the Tower, and Temper II and Full Plate after Daybreak, with about 3,700 g to spare. Nothing tested it. | **held by a new test** |
| **Bible 10.1's gold table** | It promised foe drops scaled by zone, 35 to 70 g a foe in Dartmoor and Zenis. In the code every foe paid 2 to 16 g wherever it stood (Zenis's corruption doubles it). The chests carried the whole economy: one pass of Dartmoor's foes was about 270 g against 8,640 g in its chests. Since passes 194 and 196, the deep foes also hit twice as hard for the same few coins. | **fixed: foes pay their zone's threat; the table now comes from the rooms** |
| Potions against the new damage | The Red Potion is a flask refilled at every rest, so deeper damage costs no gold. Ointments (300 g) and the Elixir (1,500 g) are already affordable many times over by Daybreak. | fine |
| Gear, dyes, the Rune Dagger, saves (passes 186 to 193) | Unchanged since pass 189. Sanitize, the renames and the Equipment page all pass. | fine |

## As built

- `Enemy.die`: a foe's gold is multiplied by its room's threat (`Room.threat`, 5.5). A Dartmoor foe's 10 comes out as 20. A boss's purse (60 to 500 g, through `Enemy.die`) takes its arena's threat too, as its blows have since pass 196. Rokusutahn's goes through his own `Coin.spray` and is unchanged. The purse test leaves boss gold out, to stay on the safe side.
- Bible 10.1: the gold sheet replaces the old wishful table. For each zone it gives the foe drop after threat, its chests, their gold and one pass of foes. It is followed by the par-without-grinding rule.
- `test_economy.gd`:
  - `test_the_par_kit_is_affordable_without_grinding` (new) walks the critical path from the King's purse. At each zone it adds half its chests (read from the rooms, with `chest_gold` and `chest:` overrides) and one pass of its foes (the scripts' mean gold, with corruption and threat). It then buys the par kit from `data/shops.json` at the shop where it stands, and the purse must never go below zero.
  - `test_a_deep_zones_foes_pay_as_they_hit` (new): a Dartmoor foe's 10 gold drops as 20.

Full suite: 3829 of 3829 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the bible's economy table now matches the game, drops scale with risk, and a test holds the par purse. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged: in the original, deeper foes paid more too. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 198 takes Audio (last pass 190, now the oldest).
