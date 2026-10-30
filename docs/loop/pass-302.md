# Pass 302: poison kept off is heard

Category: Audio (last pass 294).

## Audit

I checked the sound (bible 13.3, `tools/audio/levels.py --check`) against what passes 295 to 301 touched.
- **Drop toasts (pass 301).** A toast plays no sound of its own (`GameHud.show_toast`). Each drop's sound comes from `Drop._collect`, so the orb's new line sits over `mana_orb` and nothing else. Every drop has a sound: bread and the great loaf play `heal`, the orb `mana_orb`, poison `hurt`, and the War Glove and an Ointment play `item`. **The one gap: poison taken while an Ointment is on.** It showed "The Ointment keeps the poison off." and made no sound. It was the only pickup you couldn't hear.
- **A set-back in a fight (pass 296).** The set-back plays `hurt` (peak -7.5 dB). A torn floor's `crumble` (Rokusutahn, +4 dB, peak -3.1 dB file) or `break` (the Bloom, +2 dB) plays when the floor tears. The player falls onto the thorns several frames later, so the two cues don't start together. `hurt_heavy` plays only for a blow of a whole mask, and a spike costs less. `Sfx.play` starts each sound at most once a physics frame, and the mix check passes.
- **A fall kill (pass 298).** `enemy_die` plays at its usual level for a foe that dies just below the room. Pass 294 judged that fair: the cry tells you the foe you knocked off is dead. Foes that fall together die on the same frame only if they cross the edge together, and then `enemy_die` starts once, not stacked.
- **Doors and the purse (passes 299, 300).** A floor or ceiling door inside a zone is a scroll, which is silent by design (3.3). Between zones it fades with `door`. Rising out of a floor door has no cue of its own, as walking through a side door has none. A purse moved off torn floor moves under the tear's `crumble` or `break`, and taking it back plays `coin` as before.

## Fix

- `Drop._collect`: poison an Ointment keeps off plays `ward` (-6 dB), the glassy ring the shield's ward makes against sorcery.
- Test: `test_every_drop_is_heard_as_it_is_taken` (`test_economy.gd`) takes every kind of drop: bread, loaf, mana orb, poison, War Glove, Ointment, and poison under an Ointment. Each must make a sound and show a line, and the warded poison must ring `ward`. With the new line taken out, it fails on the warded poison (`[]`).
- Bible 13.3: an entry after the mana orb's.

No screenshot: nothing on screen changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: every pickup now has a sound. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 303 takes Stability (last pass 295).
