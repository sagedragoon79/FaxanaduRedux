# Pass 358: tablets and wards sound like themselves (Audio)

Category: Audio (last pass 350).

## Audit

- **The mix:** `python3 tools/audio/levels.py --check` passes (162 effects at a median of -18.5 dB, 34 tracks, 14 beds). Every effect file is played by some script.
- **Passes 351 to 357** added no new sources of sound. The boss kill flash (356) lands under the guardian's own fall (`boss_won`, pass 222), and the flasks' marks (357) are drawn on flasks that already uncork and pour (pass 350). Neither needs a sound.
- **Borrowed cues** were the gap:
  - Reading a lore tablet (`LoreTablet.interact`, 142 of them in the world) played `door` at -4 dB. A sign sounded like a door opening, though nothing opens.
  - The bound fog (`MistCurtain`) and the elven veil (`StrideVeil`) played `fizzle`, the spell-fail sound, when they turned you away. Pass 122 took the locked doors off `fizzle` for this reason: a refusal is not a spell gone wrong.

## Fix

- Two new effects in `tools/audio/sfxgen.py`:
  - `tablet_read`: a hand brushing grit off the carving, then two soft stone-struck notes a fourth apart over a low hum (peak -6.0, RMS -19.0, by the median).
  - `ward_refuse`: a low thrum that swells and is pressed down a step, with a breath of air (peak -6.9, RMS -17.3).
- `LoreTablet`, `MistCurtain` and `StrideVeil` play them. A ward still sounds once per approach, like its message.
- Bible 13.3: the count is now 164, and a note "Tablets and wards (pass 358)".
- `test_tablets_and_wards_sound_like_themselves` reads a tablet and walks into the fog of Lantern Landing and the veil of the North Bough for real. Each sounds once, never `door` or `fizzle`, and each cue is played only by its own scripts.

Mutation: with the veil back on `fizzle` and the tablet back on `door`, 4 checks fail.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. Two more borrowed cues replaced. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 359 takes Stability (last pass 351).
