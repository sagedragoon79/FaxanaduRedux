# Pass 350: the flasks sound like flasks

Category: Audio (last pass 342).

## Audit

- **Passes 343 to 349** changed no sound. The audio numbers in 13.3 (pass 342), the cue count (pass 334) and every cue's file still pass on main.
- **The new title shelf (PR #388, Sean's three flasks).** It plays four cues, and three of them were borrowed from moments that mean something else. This is the same slip passes 128 and 294 fixed for the map and the mana orb:
  - taking a journey up played `save`, the rest's chime, though nothing is saved at that moment;
  - beginning a journey played `title`, the two-second fanfare a Guru plays when he names your rank;
  - pouring a journey out played `splash`, a body going into water.
  - Only `blip`, the menu cursor's beep, belongs there: moving between flasks is moving a cursor.

## Fix

- Two new code-synthesized cues in `tools/audio/sfxgen.py`:
  - `flask_uncork` (0.55 s): a round cork pop with a suck of air, then a soft swell up a fifth (C5 to G5 with an octave shimmer). It plays when you take a flask down, full or empty.
  - `flask_pour` (0.75 s): glugs slowing as the liquid runs out of the neck, a thin stream under them, and the empty glass ringing once.
- `SlotPicker` plays them in place of `save`, `title` and `splash`. `blip` stays.
- Mix: the first draft of the two cues was quiet. It lowered the median loudness by 0.1 dB and pushed `jump` and `broad_heavy` just past the spread limit (+7.5 dB), so the mix check failed. Raised to sit near the median (RMS -17.8 and -17.9 dB against -18.5), and the mix check passes.
- Bible 13.3: the count is 162 sound effects, and a new **The title's flasks (pass 350)** line names each cue and the test.
- Test: `test_the_flasks_sound_like_flasks` (test_systems.gd). Every cue the shelf plays except `blip` must have a file and be played by no other script, and the shelf must uncork and pour.
- Mutation check: putting `splash` back for the pour fails the test.

The shelf looks the same as before, so there is no new screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. The title's new shelf has sounds of its own. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 351 takes Stability (last pass 335).
