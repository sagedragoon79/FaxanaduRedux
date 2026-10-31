# Pass 329: the spells' power, as the original ranked it

Category: Faithfulness (last pass 321).

## Audit

- **Passes 322 to 328.** None touched the original's rules. The skill pages, room counts, guardian health, the mercy assist, the dagger's ping, the settings check and bible 6's text are all the remake's own. The mercy assist is noted in bible 14 as an assist beside "one tuned difficulty".
- **The manual's items, read again** (archive.org NESManuals, the Faxanadu text): the Glove (timed attack up, the War Glove), the Ointment (pass 305), the Battle Helmet's ward (pass 225), the keys, the Mantra and the Red Potion (pass 321) each have a note or match.
- **The gap: the five spells.** The manual ranks them by power against Deluge: Fire "has 1.5 times the power of Deluge", Thunder "has four times the power of Deluge", Death "has six times the power of fire" (nine Deluges), and Tilte "is superior to all other forms of magic". The remake's `Spells.DATA` is Deluge 12, Fire 18, Thunder 16, Tilte 14 and Death 36. Only Fire keeps its ratio. **The bible had no note** that the others stray, or why.

## Fix

- Bible 4.1: "The spells' power (deviation, pass 329)" quotes the manual and says why the remake keeps only Fire's ratio. Each spell is a tool with its own job (gates, chaining, arcing, homing), paid for in MP and held by the 0.35 s cast cooldown. At the original's ratios, a 108-damage Death would end any foe in the game in one cast and most guardians in three or four. Death still hits hardest, and Tilte's homing is its superiority.
- Test: `test_the_faithfulness_checklist_is_all_here` requires the three quotes, that Fire is exactly 1.5 times Deluge, and that Death out-hits Fire and Thunder. Against the old bible it fails.

No number changed, so there is no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the spells' departure from the original's ranking is written down and the ratio kept is held. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 330 takes Combat (last pass 322).
