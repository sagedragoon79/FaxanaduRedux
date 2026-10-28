# Pass 193: the original's twelve pieces of gear, on record

Faithfulness's last pass (184) was the oldest apart from Art, so pass 193 takes Faithfulness. I audited faithfulness to the original (the bible's checklist: towns, Gurus, ranks, rings, keys, springs, bosses, gear) against the newest content (passes 184 to 192).

| Check | Finding | Verdict |
| --- | --- | --- |
| **The original's gear** | The original sold twelve pieces: the Hand Dagger, Long Sword, Giant Blade and Dragon Slayer; Leather Armor, Studded Mail, Full Plate and Battle Suit; and the Small Shield, Large Shield, Magic Shield and Battle Helmet. In passes 184 to 186, at Sean's asking, two were renamed and the helmet moved to a slot of its own. Each change was noted where it was made (the 5.2 row, the pass doc), but nothing listed them together. Nothing would catch a later rename that dropped an original name with no record. | **built: a table of what changed, held by a test** |
| Leftover names | No text a player sees still says Hand Dagger or Giant Blade. The old ids appear only in `RENAMED_ITEMS` and the bible's history. | fine |
| The pause menu's Equipment row (pass 189) | Its line said it swaps blades, armor, shields and helmets, but since pass 189 it dyes the cloak too. | **fixed** |
| Kept gear (pass 186) | The original replaced gear as you bought it. The bible records the deviation and why. | fine |
| The Rune Dagger, the sting rule, the throw buffer and the gear sounds | None of these replaces an original item or mechanic. The dagger is a tool beside the blade, recorded as an addition. | fine |
| Ranks, rings, keys, towns, springs, Gurus, bosses | Unchanged since passes 145 to 175 checked them all. | fine |

## As built

- Bible 5.2: **"The original's gear, and what changed"**:
  - a table with a row for each change (the Hand Dagger, the Giant Blade, the Battle Helmet) and for the addition (the Rune Dagger), each giving the pass and why;
  - a line naming the nine originals that keep their names and place.
- `test_economy.gd`, `test_the_originals_twelve_pieces_of_gear_are_all_here` (new):
  - each of the original's twelve names is an item, or has a row naming an item that took its place;
  - each id in `GameState.RENAMED_ITEMS` has a row;
  - the Battle Helmet keeps its name in the helmet slot.
- The pause menu's Equipment line: "Swap between the blades, armor, shields and helmets you have, and dye your cloak."

Full suite: 3553 of 3553 checks passed, with no script errors.

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
| Faithfulness | 5 | 99 | Unchanged: every change to the original's gear is now on record, and a test keeps it so. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 194 takes Combat (last pass 186, now the oldest).
