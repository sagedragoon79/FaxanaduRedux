# Pass 314: every guardian opens without a shield

Category: Combat (last pass 306).

## Audit

- **Zone threat (5.5).** Foes' and bosses' blows, their shots and (since pass 306) poison take the zone's threat; hazards stay at one mask by design. No gap.
- **Telegraphs.** `test_every_wind_up_in_the_game_is_fair` (pass 234) still holds every named wind-up to `Enemy.MIN_TELEGRAPH`. Nothing new since pass 306 added a tell.
- **Rune Dagger against the shield.** Sean's off-hand rule (PRs #347, #349) makes the dagger and a shield a choice. With the dagger in hand, a hero has no guard, no parry and no ward (pass 313). Bible 5.2 says no fight needs a parry, and that still holds for damage. **But bible 9 promises Executioner and Bloodletting "a window in every fight", and two guardians opened only on a parry: Shadow Eura and the Evil One's first phase.** A dagger build, or one with the two-handed Broad Sword, put skill points into those two skills and saw them do nothing in either of the last fights. The dagger is now a build choice open to every player, so this matters more than it did when only the two-hander lost the parry.

## Fix

- `ShadowEura.punishable()`: also open while spent after a blow of its own. That is the 0.6 s `recover` after the cut from behind (phase 1), and `f_recover` after any free cut, heavy, cast or dash (phases 2 and 3). A decoy has no opening.
- `EvilAvatar.open()`: also open in the 0.7 s `burst` that ends its pull, so the plate is bare then too, as when it reels.
- Bible 8: the two table rows and a paragraph after pass 276's.
- Test: `test_every_guardian_opens_without_a_shield` (test_boss.gd). It reads the openings table and fails any row whose only way in is a parry. Then it fights Shadow Eura and the Evil One, puts each into its spent state and checks it is open, shut again once it moves on, and (for the Evil One) bare-plated. With the old code and bible, 5 of its 7 checks fail.

No screenshot: the opening shows as it did (Executioner's bonus), with no new drawing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: a shieldless build keeps its skills in the last two fights. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 315 takes World (last pass 307).
