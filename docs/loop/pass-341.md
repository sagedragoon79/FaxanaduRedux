# Pass 341: the gold sheet, kept to the rooms (Systems)

## Audit

The Systems category was last audited in pass 333, which priced the skill tree. This pass read bible 9 and 10 against the code. Shop prices are held: every staple's price has been checked since pass 277, the cartographers too, and the dyer's six dyes since pass 136. The skill tree has been held since pass 333.

The gold sheet (10.1) is not held. It counts each zone's chests, their range and their gold, and the gold one pass of its foes pays. The par test reads the same rooms, but only to show that the kit stays affordable. It never reads the table. The sheet was drawn in pass 197 and the rooms grew after it:

| Zone | The sheet said | The rooms hold |
| --- | --- | --- |
| Trunk Hollows | 9 chests, 90 to 150, 1,080 g | 12 chests, 90 to 200, 1,500 g |
| Tower of Trunk | 13 chests, 2,980 g | 20 chests, 4,510 g |
| The Mist | 8 chests, 2,780 g | 9 chests, 3,080 g |

That is 1,970 g the sheet didn't know about. The par purse left after Full Plate is 4,830 g, where the bible said about 3,700. The Tower's foes pay 429 g a pass, against the 420 the sheet said. The other six rows matched.

## Fix

- Bible 10.1: the Trunk, Tower and Mist rows now give what the rooms hold. The par purse now reads about 4,800 g. A new "sheet kept to the rooms (pass 341)" note says what had drifted.
- `test_the_gold_sheet_counts_the_rooms` (test_economy.gd) holds every row to the rooms: the foes' drop range after threat and corruption, the chests' count, range and gold, and one pass of foes to within 10 g. It also holds the purse left after Full Plate, rounded to the hundred. It reuses the par test's `_zone_gold` and `GOLD_PATH`.

Mutation check: with one Trunk chest raised from 200 to 2,600 g, the test fails three times (the range, the total and the purse).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the gold sheet had drifted by 1,970 g of chests. It is now corrected and held to the rooms. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 342, Audio: audit passes 335 to 341 for audio facts in bible 13.3 that no test holds or that the mix disagrees with.
