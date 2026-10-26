# Pass 147: rare drops, the War Glove and the Ointment

Combat (98, weight 15) was tied with World for the lowest weighted category apart from Art. I audited combat against bible 5 and 7 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 5.3 moves and `combat_tuning.gd` | pinned line by line (pass 105) and unchanged | fine |
| 7 telegraphs | every foe telegraphs at least `Enemy.MIN_TELEGRAPH`; checked by the roster tests | fine |
| Foes per zone | every planned foe is built (pass 123) | fine |
| Dash buffer (pass 146) in fights | a dash already cancels a swing, so a held press only changes timing at the cooldown and on landings; no new cancel | fine |
| Wanderer's Grace (pass 142) | a kill gives back air dashes, and with the buffer a dash pressed just before the kill now goes | fine |
| Victim (pass 145) | a town, no fights | fine |
| **7: "drops (gold, MP orbs, rare items)"** | Gold, bread, mana orbs and (from the Tower on) poison were built. Rare items never were, so no kill was ever more than routine. In the original, a slain monster sometimes left the Glove (stronger blows for a while) or an Ointment (no harm for a while), and those lucky drops changed how the next minute of a fight played. | **built** |

## As built (bible 7, 5.3)

- **The roll:** `Drop.roll` gains `rare_chance` (0.025, about 1 kill in 40), from any foe in any zone. It comes after bread, mana and poison, so it never changes their odds. The test runner sets it to 0 like the others.
- **War Glove** (60% of rare drops): the original's Glove, renamed so it isn't mistaken for the Climbing Glove. It is a red leather fighting glove with a gold-studded cuff.
  - **Effect:** walk over it and `Player.put_on_glove()` gives `war_glove_time` (15 s) of `war_glove_mult` (1.5x) on every blade hit, through the new `Player.blade_mult()`: slashes, the heavy finisher, the pogo and a Riposte. Spells are unchanged.
  - **Feel:** red sparks (`Dust` kind `might`) rise off the sword hand every 0.18 s. A toast says what it does, and another says when it fades.
  - **HUD:** a red fist and a draining bar beside the Ointment's row; the bar blinks in its last 3 s.
  - **Rules:** another glove starts the time over, and dying takes it off.
- **Ointment** (40%): into the pouch like a bought one (up to `Shop.OINTMENT_MAX`, 3). With the pouch full and none on, it goes straight on, as the original's did; with one already on, it's wasted.
- `game.gd`: `--drops` now lays out all five drops, and `--glove` starts with one on.

## Screenshot

`/mnt/project-files/pass-147/rare_drops.png`: the Eolis plaza with a glove on. The HUD shows the fist and its bar beside an Ointment, the toast reads "A War Glove! Your blows land half again as hard.", and bread, a mana orb, poison, a glove and an ointment jar lie in a row ahead.

## Tests

`test_economy.gd`, `test_rare_drops_a_war_glove_and_an_ointment` (new):
- the runner keeps rare drops off, and the tuning is 1.5x for 15 s;
- 4,000 rolls at the real odds give about 1 in 40 rare items, the glove the commoner;
- walking over a glove puts it on, and a real slash at a Monodron deals the dagger's damage times 1.5;
- it wears off after 15 s, and death takes a new one off;
- two ointments go in the pouch, and with the pouch full one goes straight on.

Full suite: 2698 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | The last unbuilt drop in bible 7: a rare kill now and then turns the next fight. |
| World and level design | 15 | 98 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | Unchanged. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Unchanged (the Glove is the original's, but one item doesn't move the category). |

Weighted score: 96.15 (up from 96.1125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Systems, Audio, Stability and Faithfulness are tied at 98. World weighs the most (15), so pass 148 takes World.
