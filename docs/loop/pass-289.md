# Pass 289: a slain Myconid leaves bread

Category: Faithfulness (last pass 281).

## Audit

I read the faithfulness checklist (bible 15.3) and the bible's enemy section (7) against the original's enemy list, using [StrategyWiki's Faxanadu enemies page](https://strategywiki.org/wiki/Faxanadu/Enemies). I also checked what passes 282 to 288 touched.

- **The original's food comes from fixed foes.** Every enemy there has a fixed drop, either gold or bread. Five drop bread:
  - the sightless crawler and the Yuinaru: small bread;
  - the Yareeka and the Lamprey: medium bread;
  - the Myconid: "health-restoring bread";
  - the Naga: large bread.

  The remake builds two of these foes. Pass 281 gave the Naga its great loaf. **The Bog Myconid, the original's Myconid by name, still only rolled the 1-in-12 bread chance that every foe has.** In the Mist the Myconid's spores are the hazard you back away from, and in the original the reward for clearing one was always bread.
- **Kept as they are:** the gold drops. The remake scales gold by zone threat (10.1) and does not copy the original's fixed purses. The other three bread droppers have no counterpart in the remake.
- **What passes 282 to 288 touched:**
  - The spike damage and cast cooldown rows (5.3), the drops and coins kept in their rooms, the empty-flask sound and the spoils soak follow no rule of the original, and none breaks one.
  - The new set-back rule (bible 6.13) did not say it is the genre's and not the original's.

## Fix

- `BogMyconid` now sets `sure_drop = "bread"`. A slain one always leaves a loaf of bread (+15), as the Naga always leaves its great loaf.
- Tests:
  - `test_a_slain_myconid_leaves_bread` (`test_enemies.gd`). With every drop chance at zero, it leaves exactly one bread. The bread falls to the floor, and eating it heals 15.
  - The faithfulness checklist test now checks the Myconid's sure drop too.
  - Mutation check: with `sure_drop` empty, the test fails ("[]").
- Bible:
  - 7, the Myconid's entry.
  - The 15.3 checklist line.
  - 6.13 now states the deviation: spikes and their set-back come from the genre, and the Mattock's pogo is built around them.
- No screenshot: the bread is the existing drop, already looked at in pass 281.

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
| Faithfulness | 5 | 99 | Unchanged score: both of the original's bread-dropping foes that the remake builds now always drop it. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 290 takes Combat (last pass 282).
