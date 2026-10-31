# Pass 322: every skill page names the number it gives

Category: Combat (last pass 314).

## Audit

- **Passes 315 to 321.** The Rune Dagger and the shield share the off hand (Sean's #347, #349). Pass 316 holds the dagger's reach on every guardian, and pass 319's soaks guard in alternate rooms. Pass 318 made Bloodletting audible, and pass 321 set the flask's row straight. Each of these has its test.
- **Bible 5.3 against `combat_tuning.gd`.** Every row is held by `test_the_starting_combat_values_match_bible_5_3`, and every tuning value is read by some test.
- **The skill tree's numbers were not held.** About half the tree is combat, and its pages name figures: Bloodletting's 2 HP, Executioner's 35%, Keen Edge's 10%, Last Stand's 20% and 25%, Siphon's 50%. Tests read the constants (`Player.BLOODLETTING_HEAL` and others), but **nothing tied the page text in `data/skills.json` or the bible's list (9) to them**. Retuning a skill would have left the page that sells it promising the old figure. The bible's Executioner line also still said "staggered bosses", though it pays on any opening. Pass 314 gave every guardian an opening without a shield.

## Fix

- Test: `test_every_skill_page_names_the_number_it_gives` (test_economy.gd). Each numeric skill is learned alone, `GameState.refresh_stats` runs, and the effect is read off the hero (or from its constant). The skill's page must name that number, and so must its line in bible 9. That covers 18 pages and 16 bible lines. As a mutation check, setting Bloodletting to 3 HP and Quick Draught to 0.5 fails both pages by name.
- Bible 9: Executioner's line now reads "a boss in its opening", and a deviations bullet explains the new test.

No number changed, and nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the skill tree's figures are now held to the code. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 323 takes World (last pass 315).
