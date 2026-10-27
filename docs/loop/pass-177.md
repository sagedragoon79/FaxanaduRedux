# Pass 177: fire catches living bark

Every category apart from Art was tied at 99. After Movement (pass 176), Combat weighs the most (15), and its last pass (169) is older than World's (170), so pass 177 takes Combat. I audited combat against bible 5 and 7 and the newest content (passes 170 to 176).

| Check | Finding | Verdict |
| --- | --- | --- |
| Openings (pass 163) | both mini-bosses name their opening (`punishable`), and the source scan holds for every boss | fine |
| Tells | the Captain's thrust and vault tells, and the Alpha's, are tested at or over `Enemy.MIN_TELEGRAPH` (passes 169, 171) | fine |
| The Hour Glass | it stops the clockwork Alpha (a deliberate exception) and no other foe, as bible A8 sets out | fine |
| Forepaw's physician (pass 175) | mends health, magic and poison, but leaves Second Wind's once-a-rest charge alone, so it can't be used to farm the skill | fine |
| **Fire against living bark** | The Bark Knights and their Captain wear bark that turns three-quarters of a blow until it is chipped off, plate by plate. A fireball met that bark like a sword: a quarter of its damage and one plate. The one spell you can buy before Conflate had nothing to say about the wooden knights on the roads past it. | **built** |

## As built

- **`burn_bark()`** on `BarkKnight` and `BarkCaptain`: fire burns the whole coat off at once (`bark = 0`), with embers and a high crack of bark. `Fireball.burst` calls it before the flame lands, so the fireball's damage lands in full on bare heartwood.
- The Captain ignores it while dormant, in his intro and while dying, as he ignores blows.
- The rule that a plate grows back each time a knight pulls his lance free is unchanged.
- In the Thorn Yard, the Fire spell (20 MP, sold in Mascon) is now the answer to the Captain's five-plate guard. A sword still chips it off plate by plate.

## Tests

- `test_enemies.gd`, `test_fire_burns_a_bark_knights_bark_off_at_once` (new): every plate goes, the flame lands in full, and the next blow lands in full too.
- `test_boss.gd`, `test_fire_burns_the_captains_bark_off_at_once` (new): all five plates go and the flame lands in full. Pulling free, he grows one back.

Full suite: 3315 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged: the Fire spell now has a purpose against the bark knights. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 178 takes World (weight 15, last pass 170).
