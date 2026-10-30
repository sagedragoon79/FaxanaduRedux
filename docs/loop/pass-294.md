# Pass 294: a mana orb sounds like magic, not the menu

Category: Audio (last pass 286).

## Audit

I checked the sound (bible 13.3) against what passes 287 to 293 touched.
- **A foe falling out of its room (pass 291).** It dies just below the room's edge, a moment after it leaves the screen, and plays the same `enemy_die` as any kill. Sounds are not placed in space, so it is no louder than a kill on screen. That is fair: you knocked it there, and the cry tells you it fell.
- **Torn-floor thorns (pass 292).** The set-back plays `hurt` like every spike. It is one sound for one rule, so it reads the same as any thorn.
- **A death's purse (pass 293).** The purse makes no sound until it is taken (`coin`). It glows and bobs on screen, and it now always lies on ground you stood on, so it is found by sight. A looping cue would need a sound placed in space, which `Sfx` doesn't have.
- **Drops (passes 289, 290).** Bread and the Myconid's loaf play `heal`; the Ointment plays `item`; the War Glove sounds as it goes on. **The mana orb played `blip`, the menu cursor's beep.** That is the sound pass 128 took off the map because a thing in the world sounded like a menu. The orb is the commonest drop (1 kill in 10), so this was heard most often.

## Fix

- New sound `mana_orb` (`tools/audio/sfxgen.py`): a soft breath of air under three glassy notes rising quickly up a major triad (A, C sharp, E), each with a faint shimmer a fifth above. It lasts 0.42 s and peaks at -8.0 dB, under `heal`'s -6.0. The mix check passes.
- `Drop._collect` plays it for a mana orb.
- Test: `test_kills_sometimes_drop_bread_or_mana` now requires the orb to play `mana_orb` and never `blip`. With the old line put back, it fails (`["blip", "coin", "coin"]`).
- Bible 13.3: an entry before "Rewards that sound".
- sfxgen rewrote other wavs; I restored all but `mana_orb.wav`.

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
| Audio | 5 | 99 | Unchanged score: the last pickup that borrowed a menu sound has its own. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 295 takes Stability (last pass 287).
