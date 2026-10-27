# Pass 188: the Rune Dagger is a sting, not a blow

Bosses' last pass (179) was the oldest apart from Art, so pass 188 takes Bosses. I audited the bosses (bible 8) against the newest content (passes 179 to 187).

| Check | Finding | Verdict |
| --- | --- | --- |
| **The Rune Dagger against bark (pass 184)** | Every hit on bark knocked off a plate, and the dagger is free, so five throws from across the Thorn Yard stripped the Bark Knight Captain bare. A plate grows back each time he pulls free, so you could keep him bare from range. That undercut the fight's lesson, that fire (20 MP) or a blade up close is the answer to his guard. Bark Knights had the same problem. | **fixed** |
| **The Rune Dagger against a hex** | Any hit mid-hex broke the spell. A dagger from ten tiles off cancelled the Matriarch's staple attack and every Marsh Hag's hex, against bible 7's "the answer is to close in, through the fog, toward her light". | **fixed** |
| **The Rune Dagger against the Heart** | The bound Heart takes damage only from the Dragon Slayer, judged by the blade you hold while swinging. Throw, then swing while the dagger flies, and the dagger cut the Heart for 6. | **fixed** |
| The Rune Dagger elsewhere | It bursts Shadow Eura's false double from range, breaks a Lantern Widow's lantern in the fog (its light helps you find one), and is halved by armor on the front like any hit. These are fair uses of a ranged tool, and none skips a fight's lesson. | fine |
| The Dwarvish Broad Sword (pass 186) | It cannot parry. Shadow Eura's and the Evil One's phase 1 openings come only from a parry, but an opening only feeds Executioner and Bloodletting; neither fight's damage is gated on it. | fine |
| The Matriarch (pass 179), the helmet slot (185), kept gear (186) | Her tells are fair and tested. The helmet only scales damage taken. Kept gear lets you swap blades at a pause, and no fight checks a slot apart from the Heart (the Dragon Slayer). | fine |

## As built

- `Enemy.take_throw(damage, dir)` sets `Enemy.thrown` while the hit lands. `RuneDagger` calls it on anything that has it, and `take_hit` on anything else.
- Bark (`BarkKnight`, `BarkCaptain`): a thrown hit lands the bark's quarter and splits no plate. A blow, fire, or a hit while he is open works as before.
- A hex (`MarshHag`, `HagMatriarch`): a thrown hit stings her (the Matriarch's shawl still halves it) and the spell holds.
- The Heart (`EvilHeart`): a thrown hit always glances off.
- Bible 5.2 (the Rune Dagger's "A sting, not a blow" line) and 8 (the dagger, the two-hander and the gear against bosses).

## Tests

- `test_boss.gd`:
  - `test_a_thrown_dagger_stings_the_captain_but_splits_no_bark` (new). It checks the quarter, no plate split, the flag clearing, a blow still chipping, and a real throw through the dagger's flight.
  - `test_a_thrown_dagger_does_not_break_the_matriarchs_hex` (new).
  - `test_a_thrown_dagger_glances_off_the_bound_heart` (new).
- `test_enemies.gd`, `test_a_thrown_dagger_splits_no_bark_and_breaks_no_hex` (new): the Bark Knight and the Marsh Hag.

Full suite: see the PR.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged: the free ranged tool no longer skips the Captain's, the Matriarch's or the Heart's lesson. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 189 takes Systems (last pass 180, now the oldest).
