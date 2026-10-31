# Pass 313: the dagger in hand gives up the shield's ward

Category: Faithfulness (last pass 305).

## Audit

I checked passes 306 to 312 and Sean's off-hand change (PRs #347, #349) against the NES manual.
- **Poison scaled by zone (pass 306).** The deviation note in 7 quotes the manual's "fixed amount", and pass 306's paragraph follows it and says why the remake scales the tick. Covered.
- **Drops kept off doorways and spikes (passes 307, 308, 311).** The original's drops fall where the foe dies and fade. Keeping them where the hero can stand changes nothing the original promised. No note needed.
- **Poison cues (passes 309, 310).** The number and the glug are the remake's feedback on a rule already noted. No note needed.
- **The off hand and the original's shield.** The manual gives a shield one job: it resists enemy magic, always, once bought. Pass 225 carried that over as a passive ward and noted that a shield on the back of a two-hander wards nothing. **Sean's off-hand rule (a shield or the Rune Dagger) means taking the dagger also drops the shield's ward, and the bible never said so against the original.** The off-hand bullet mentions "no ward from a shield", but not that the original had no such choice, or that the helmet's ward stays.

## Fix

- Bible 5.2 (pass 225's paragraph): the deviation note. The original had no thrown dagger and its shield always resisted magic; in the remake taking the dagger gives up the shield's ward with its guard and parry, and only the helmet's ward stays. Sean's off-hand bullet is unchanged.
- Test: `test_a_shield_wards_a_foes_sorcery` now chooses the Rune Dagger through the Equipment page (`Menus.choose_equipment(Menus.OFFHAND_DAGGER, p)`) with a Magic Shield and Battle Helmet worn, and checks that the hand is free and the ward is the helmet's 20% only. It also requires the note in the bible; with the old bible it fails.

No screenshot: no visuals changed.

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
| Faithfulness | 5 | 99 | Unchanged score: the off hand now says how it departs from the original's shield. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 314 takes Combat (last pass 306).
