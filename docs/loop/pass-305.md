# Pass 305: say what the original's Poison did

Category: Faithfulness (last pass 297).

## Audit

I checked passes 298 to 304 against the NES manual (https://archive.org/download/NESManuals/Faxanadu%20%28USA%29_text.pdf).
- **Poison and the Ointment (pass 302).** The manual: Poison: "The hero's power will decrease by a fixed amount. It is poison." Ointment: "For a fixed period of time the Hero will be protected from any enemy attack." **The bible described the remake's poison (8 s, 2 health a second, cured by bread, a shrine or a Guru, kept off by an Ointment) with no word on what the original did.** The original's poison is one fixed loss when you touch it, not a sickness. Its Ointment wards off enemy attacks, and poison is no attack, so an Ointment keeping poison off is the remake's own rule. Both are fair choices, but a reader couldn't tell they were choices.
- **Pickup messages (pass 301).** The manual says only that items "are effective as soon as they are picked up". It shows no text for them. The remake's toasts use the original's names: Bread, Poison, Ointment, and the War Glove (the original's Glove, renamed in pass 147 with a note in 7). Bread, the orb, poison and the Glove all take effect at once. An Ointment found as a drop goes into the pouch, and goes straight on when the pouch is full, "as the original's did" (7, pass 147).
- **Floor and ceiling doors (passes 299, 304).** The manual: "Press to climb ladders and enter doors." It says nothing on moving between screens. The original's tall areas flip screen by screen as you climb or fall. The remake's floor and ceiling doors join rooms the same way, and 3.3 describes the rise out of a floor door. It is the original's screen flip carried into scrolling rooms, so no deviation note is needed.
- **The gold purse (passes 293, 300).** Pass 297's deviation note in 5.4 quotes the original's death rule and calls the purse the remake's answer to it. The purse moving off torn floor is a rule inside that purse, not a change against the original.

## Fix

- Bible 7: a deviation note after the Poison paragraph. It quotes the manual's Poison and Ointment, says the remake spreads poison over 8 s (16 health at most, never the last point) so bread can still settle it, and says the Ointment's ward over poison is the remake's.
- Test: `test_the_faithfulness_checklist_is_all_here` now requires both quotes in the bible, and that the remake's poison lingers over ticks (`Player.POISON_TIME` > `POISON_TICK`). With the old bible, it fails.

No screenshot: only the documentation changed.

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
| Faithfulness | 5 | 99 | Unchanged score: poison and the Ointment now say what the original did. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 306 takes Combat (last pass 298).
