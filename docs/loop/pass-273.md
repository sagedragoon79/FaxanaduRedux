# Pass 273: the Naga over the ladders

Category: Faithfulness (last pass 265).

## Audit

The faithfulness checklist (bible 15.3) already holds the towns, Gurus, ranks, rings, keys, springs, gear, bosses, spells and relics. Forepaw's hospital and Mascon's tavern are in, each with its deviation noted in bible 10. So this pass looked at the original's regular foes (StrategyWiki, "Faxanadu/Enemies") against bible 7, which says "Names reuse the original's monster names where they exist".

The remake has the Monodron, Myconid, Hornet and Lilith. None of the original's other foes is in: Zombie, Naga, Yuinaru, Snowman and the rest. Of those, the **Naga** is the one a returning player is most likely to notice: "a serpent-like creature that floats up and down, often over ladders". The remake has ladders all through the Tower of Trunk, and nothing in the game behaves that way.

## Fix

**Naga** (`scripts/enemies/naga.gd`, room legend `)`) is a sea-green hooded serpent the length of a man, code-drawn at 2x.
- **Float:** it rises and sinks 40 px either way of its home along its own column, one swing every 3.2 s. The swing follows game time, not the wall clock.
- **Tell:** when you are level with it (your chest within 24 px of its head) and in front within seven tiles, it draws back and flares its hood with a hiss (`naga_hiss`) for 0.5 s, washed white.
- **Strike:** it then strikes straight out along that level at 260 px/s for 0.4 s (`naga_strike`), 16 on touch, and glides back to its column. It waits 1.2 s before it hoods again.
- **Stats:** 22 HP, 3 to 5 gold.

A climb past one is timed to its swing.

Placed by the ladders of the Mine Shaft (30,24) and the Tower Foot (33,32).

Two new sounds come from `sfxgen.py`, appended at the end of the file. With them the effects' median holds at -18.4 dB and `levels.py --check` passes. A first cut moved the median to -18.6, and the pass 270 headroom absorbed that. I raised the two gains anyway.

Tests:
- New `test_the_naga_floats_its_column_and_strikes_level` (test_enemies). Out of sight, it swings at least 60 px and keeps its column. Held level and in front, it hoods for at least the telegraph, hisses, strikes along a flat line and bites. Above its swing it never strikes, and it glides back home.
- The voices test holds `naga_hiss` and `naga_strike` to the Naga alone.
- The faithfulness checklist test now checks that Nagas float over the Tower's ladders: at least two rooms, all in the Tower, each Naga within six tiles of a ladder.
- The Naga joins the gold-economy and combat-sheet legend tables.

The first test run caught a wall-clock swing: the Naga barely moved in a headless run, the same trap pass 271 met in `Feel`. The swing now accumulates `delta`.

Screenshots, looked at: `/mnt/project-files/pass-273/mine_shaft.png` (floating by the Mine Shaft ladder) and `/mnt/project-files/pass-273/coil_20.png` (hood flared, washed white in the tell). The first cut drew it at 1x, a thin worm beside the hero, so it is now drawn at 2x like the rest of the cast.

Bible: the section 7 Tower of Trunk row, and the 15.3 Faithfulness checklist.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: one more family, telegraphed and voiced. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the original's Naga is in. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 274 takes Combat (last pass 266).
