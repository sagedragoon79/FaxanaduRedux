# Pass 310: a poison tick is heard

Category: Audio (last pass 302).

## Audit

I checked the sound (bible 13.3, `tools/audio/levels.py --check`) against what passes 303 to 309 touched.
- **Drops that move (passes 307, 308).** A drop moved out of a doorway or off spikes moves on the frame it settles, so you never see it slide. A drop makes no sound when it lands either, so a silent move fits; a settle sound on the moved ones only would be the odd one out.
- **Poison ticks (passes 306, 309).** **A poison tick was silent.** Since pass 306 a tick takes 2 to 4 health, and pass 309 gave it a green number for players who turn numbers on. Taking the flask plays `hurt`, but the eight ticks after it played nothing, so a player with numbers off only learned of it from the masks. Every other loss of health has a sound.
- **The rise out of a floor door (pass 304).** A floor or ceiling door inside a zone is a scroll, silent by design like a side door's scroll (3.3, pass 302's audit). Between zones it fades with `door` like a side door. So the rise is consistent with side doors.
- **Mix headroom.** `levels.py --check` passes. It checks each file's peak and loudness, not a worst-case stack. `Sfx.play` starts each sound at most once a physics frame, and the pool holds 12 voices. A summed worst case with no master limiter is still open, and it is noted for a Stability or Audio pass that can measure the bus at runtime.

## Fix

- New sound `poison_tick` (`sfxgen.py`): a small wet glug, a sine bubble sagging from 300 to 170 Hz, a smaller one 70 ms behind it, over a breath of low-passed noise. 0.22 s, peak -10.5 dB in the file (`hurt` is -7.5 dB), played at -4 dB.
- `Player._tick_poison` plays it on each tick that takes health. A tick at the last point or under an Ointment stays silent.
- Test: `test_every_poison_tick_is_heard` (`test_economy.gd`) poisons the hero in Zenis. A tick that bites must glug and not play `hurt`. The file's peak must sit under `hurt`'s. Ticks at the last point and under an Ointment must be silent. With the play call taken out, it fails.
- Bible 13.3: an entry after pass 302's.

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
| Audio | 5 | 99 | Unchanged score: every loss of health now has a sound. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 311 takes Stability (last pass 303).
