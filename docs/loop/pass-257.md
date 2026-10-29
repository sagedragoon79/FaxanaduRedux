# Pass 257: the Bloom's brood

Category: Faithfulness (last pass 249).

## Audit

The faithfulness checklist (`test_the_faithfulness_checklist_is_all_here`) already holds the original's towns, Gurus, ranks, rings, keys, springs, spells, relics and bosses, and the King's 1,500 gold and the farewell ending are in place. This time I read StrategyWiki's list of the original's enemies against bible 7 and 8. Each of the original's bosses has an arena, but one of them had lost the thing it was known for: the original's Pakukame "releases Liliths" three at a time, until those are destroyed. The remake's Bloom bit, whipped and spat seeds, and nothing came out of its petals.

Bible 7 says the foes reuse the original's monster names where they exist (Monodron, Hornet, Myconid). I set aside renaming other foes after the original's (Necron Aide, Geributa, Lamprey): the remake's families do different things, so the old names would mislead.

## Fix

- `Lilith` (`scripts/enemies/lilith.gd`, code-drawn), a violet imp with pink petal wings and 10 HP.
  - It is harmless while it clears the petals, then hangs beside and above you, each of the three in its own place.
  - It screeches with its wings flared for 0.4 s, then dives at where you were for 8 and climbs back on the other side.
  - It never returns once struck down.
- Pakukame's brood (bible 8.5):
  - From phase 2, when it would whip or spit from afar and none of its brood flies, the petals flare and spin for 0.7 s (clamped like every tell), and three Liliths fly out.
  - The first far move below half broods; after that it broods no sooner than three moves after the last brood, and only once all three are down.
  - The brood dies with the Bloom.
- Test: `test_the_bloom_looses_its_liliths_three_at_a_time` (`test_boss.gd`). It checks five things:
  - no brood in phase 1;
  - a fair tell, then three Liliths;
  - none more while they fly;
  - a Lilith's screech before its dive;
  - three more once they are struck down, and the brood dying with the Bloom.
- The Bloom's tell test now covers `BROOD_TELL`, and the checklist test checks the brood of three.
- Mutation check: with the "none of its brood left" gate removed, the test fails.
- Screenshots, both looked at: `/mnt/project-files/pass-257/brood_260.png` shows three Liliths out over the leaf, and `brood_320.png` shows one diving at the hero.
- Bible 8.5 "The brood", bible 7 (Branches row), and the rubric's faithfulness line.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. Pakukame's third move from afar adds pressure in phase 2. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the original's Pakukame looses its Liliths again. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 258 takes Combat (last pass 250).
