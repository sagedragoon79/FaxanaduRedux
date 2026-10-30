# Pass 301: a mana orb says what it gave

Category: Systems (last pass 293).

## Audit

I checked the systems (bible 5.3, 9, 10 and 15.3) against what passes 294 to 300 touched.
- **The saved purse (pass 300).** A tear moves the purse node and updates `GameState.data.purse` in place, so the next shrine rest saves the new spot. Continue and a return from the title reload the room with its floor whole, and the purse lies on the tile beside where the pit was. If you quit before saving, the old spot loads over floor that is whole again, and the next tear moves it as it did before. A second death in the same fight frees the first purse and leaves a new one (`Player._die`), and `World._on_player_died` saves that one. Dying with no gold clears it.
- **Fall kills (passes 296, 298).** The game keeps no kill tally, bestiary count or achievement that a kill feeds. A fall kill goes through `Enemy.die` like any other, so it pays gold, a drop, experience and `on_kill` exactly once. `perished` stays false and only `fell` is set, and the coins and drop come to rest at the gap's edge. A set-back touches no stat.
- **The mana orb (pass 294).** In the code it gives 12 MP and drops 1 kill in 10, and the drops row of bible 5.3 says the same. Bible 10 covers only gold, which is right. **But the orb was the only drop that said nothing when you took it.** Bread says "+15 health", a great loaf "+40", poison, the War Glove and an Ointment each have a line. The orb gave 12 MP without a word, and nothing else in the game names it or its amount.
- **The pause Equipment page with the PixelLab hero (#323, #325).** It lists blades, armor, shields, helmets and cloak by item, not by sprite, so the new sheets can't put it out of step. The starting Short Sword and Warden Green show as worn, with their numbers (`/mnt/project-files/pass-301/equipment.png`).

## Fix

- `Drop._collect`: taking a mana orb shows "A mana orb. +12 magic." (from `MANA_GAIN`).
- Test: `test_kills_sometimes_drop_bread_or_mana` now requires that toast. With the line taken out, it fails (`[]`).
- Bible 5.3, the drops row: every drop shows a toast saying what it gave.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the last silent pickup now shows what it gave. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 302 takes Audio (last pass 294).
