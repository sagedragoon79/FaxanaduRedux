# Pass 297: say what the original did on a death, and with its drops

Category: Faithfulness (last pass 289).

## Audit

I checked passes 290 to 296 against the NES manual: https://archive.org/download/NESManuals/Faxanadu%20%28USA%29_text.pdf.
- **Death (5.4, pass 293).** The manual: "You will start from the last Guru's House you visited." The hero keeps his items. "His experience will be the lowest point for that rank and the amount of money he has when he recovers will also be determined by his rank." The bible only said the purse keeps "tension without the original's harsh losses", and never said what those losses were. A reader couldn't tell what the remake changed, or why.
- **Drops (passes 290, 294).** The manual says "Some enemies have food and money", and food "will partially restore the hero's energy". It names no magic drop. Bread, gold, poison and the rare items are the original's, and the bible says so. The mana orb is the remake's own, and the bible had no deviation note for it.
- **A foe falling out of its room (pass 291).** The remake's rooms have floor gaps the knockback can reach. The original's foes kept to their screens. Dying as it falls keeps the original's rule that a felled foe pays. No note is needed beyond pass 291's paragraph.
- **The set-back (6.13, passes 292 to 296).** It is already marked as a genre deviation, with the Mattock's pogo as the reason. Passes 292 to 296 only made it hold.

## Fix

- Bible 5.4: a deviation note quoting the manual's death rule, and why the remake keeps the restart and the items but never takes experience. It turns the gold loss into a purse you can walk back to.
- Bible 7: a deviation note on the mana orb. The manual names only food and money from foes. The orb keeps a fight's magic coming between Gurus, as bread does for health.
- Test: `test_the_faithfulness_checklist_is_all_here` now requires both notes. 5.4 must carry a Deviation that quotes the rank's floor, and 7 must say the mana orb is the remake's. With the old bible it fails on both.

No screenshot: only the documentation changed.

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
| Faithfulness | 5 | 99 | Unchanged score: the death rule and the mana orb now say what the original did. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 298 takes Combat (last pass 290).
