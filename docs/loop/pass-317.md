# Pass 317: an old save is told of the off hand

Category: Systems (last pass 309).

## Audit

- **Equipment page.** The Off Hand section lists the Rune Dagger first, then each shield, and the footer's Ward figure follows `refresh_stats`. Pass 313 checked that the ward drops to the helmet's share when the dagger is chosen.
- **Skill tree.** Executioner and Bloodletting read `punishable()`, which now includes pass 314's shieldless openings. Their tests still pass.
- **Shops, settings, pause and inventory pages.** Nothing has changed since pass 309, and their tests hold.
- **Saves and the off hand.** `sanitize` carries older saves over: renamed items, moved pickups, the Battle Helmet's slot, the Dragon Slayer. **Sean's off-hand rule had no carry-over.** A save from before 2026-10-31 that had found the Rune Dagger and wore a shield loads with Throw silently doing nothing. Under the old rule, the pickup's banner said nothing about the hand. Sean's own save is likely just such a save.

## Fix

- `GameState.VERSION` goes to 2, with `OFFHAND_VERSION` set to 2. `sanitize` marks a save with an older version, the dagger found and a shield worn (`notice:offhand`).
- `GameState.take_load_notice()` returns the banner once and clears the mark. `Game._continue` shows it after the welcome toast: "The Off Hand: Your shield now holds the throwing hand. To throw, choose the Rune Dagger under Off Hand (Equipment)."
- The shield stays on. Which hand to keep is the player's choice, and Sean's off-hand code is unchanged.
- Bible 15 (Saves and settings): a bullet after pass 213's.
- Test: `test_an_old_save_with_shield_and_dagger_is_told_of_the_off_hand` (test_systems.gd). It covers four cases: an old save with a shield and the dagger is told once; one with the hand free is not; one written under the rule is not; and the shield stays worn.

Screenshot: `/mnt/project-files/pass-317/offhand-notice.png`, a version 1 save continued in the Hornet Gallery. The first wording ran nearly edge to edge, so I shortened it, and it now fits with room to spare.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: an old save is told why Throw is quiet. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 318 takes Audio (last pass 310).
