# Pass 281: a slain Naga leaves a great loaf

Category: Faithfulness (last pass 273).

## Audit

I read the faithfulness checklist (bible 15.3) and the bible's enemy section (7) against the original's enemy list, using [StrategyWiki's Faxanadu enemies page](https://strategywiki.org/wiki/Faxanadu/Enemies). I looked hardest at the Naga, which pass 273 added and passes 274 and 275 changed.

The page says the Naga "floats harmlessly over ladders but deals heavy damage on contact" and that "defeating it yields the game's largest bread". The remake keeps the float over the ladders and the heavy bite. A slain Naga, though, left only a few coins and the 1-in-12 chance of plain bread that every foe has. So the original's reward for winning the climb was missing. A fight beside a ladder costs health, and the original paid it back.

The rest of the checklist holds:
- the towns and their Gurus;
- the ranks, rings, keys and springs;
- the bosses, the spells and the relics;
- the Dragon Slayer;
- Pakukame's Liliths, three at a time;
- Fraternal Castle;
- Mascon's tavern;
- the Naga by the ladders.

## Fix

- **The great loaf:** a new drop kind, `loaf`, twice a bread's length with three scores across it. Eating it heals `Drop.LOAF_HEAL` (40), against a bread's 15, and settles poison as bread does.
- **A sure drop:** `Enemy.sure_drop` is a drop a foe always leaves instead of rolling for one. The Naga's is `loaf`. Foes without one roll as before.
- **The drop helper:** `Drop.make` creates a drop of a given kind. `Drop.roll` now uses it.
- **Debug drops:** `--drops` lays out the loaf too, sixth in the row.
- Tests:
  - `test_a_slain_naga_leaves_a_great_loaf` (`test_enemies.gd`). With every drop chance at zero, a slain Naga still leaves exactly one loaf. It falls to the floor, and eating it heals 40.
  - The faithfulness checklist test now checks the Naga's sure drop.
  - Mutation check: with the Naga's `sure_drop` empty, the test fails ("[]").
- Screenshot, looked at: `/mnt/project-files/pass-281/drops.png`. The six debug drops lie on the floor in Eolis's West Gate, and the long loaf shows clearly twice the size of the bread at the start of the row.
- Bible: section 7's Naga entry and the 15.3 checklist line.

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
| Faithfulness | 5 | 99 | Unchanged score: the Naga now pays back the climb as the original's did. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 282 takes Combat (last pass 274).
