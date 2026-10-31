# Pass 311: a resting drop checks for spikes once

Category: Stability and performance (last pass 303).

## Audit

I checked stability (bible 15.3: soaks, frame budget, leaks, state leaks) against what passes 304 to 310 touched.
- **The spike check (pass 308).** **`Drop._step_off_spikes` ran every physics frame a drop lay still**, and each run scans every child of the room. Nine drops resting for 2 s made 764 scans, where nine would do. One scan costs about 2 µs in the Flooded Hall, so nine drops cost about 1 ms a second and no frame budget saw it. But the cost grew with every drop and with every child a room has, for the whole 10 s a drop lies there, and it was waste with no purpose.
- **The door clamp (pass 307).** `Drop.keep_in_room` asked two tiles at each side edge every frame for every drop and coin, about 1 µs a pair. A spray of 50 coins made about 100 µs a frame of tile lookups, all for coins nowhere near a door.
- **`poison_tick` (pass 310).** `Sfx.load_all` loads every file in `assets/sfx/` at start, so the new sound is loaded before play. The journey soaks' load check (pass 303) passed in this pass's full run.
- **The mix.** `Sfx` starts each sound at most once a physics frame from a pool of 12 voices, and the loudest file peaks at -1.4 dB. There's still no master limiter, and a runtime peak meter on the bus would need an `AudioEffectCapture` the game doesn't have. That's a larger change than this pass, so I've left it open, as passes 302 and 310 did.

## Fix

- `Drop`: a resting drop checks for spikes once, as it settles (`_settled`), and again only after it leaves the floor, as when a torn leaf drops it. `Drop.spike_checks` counts the checks for the test.
- `Drop.keep_in_room`: the door clamp asks the tiles only within `DOOR_CLEAR` (40 px) of a side edge.
- Test: `test_a_resting_drop_checks_for_spikes_once` (`test_economy.gd`) lets nine drops rest for 2 s in a room with spikes, one of them on the spikes. It must check nine times, and the one on the spikes must still step off. With the per-frame call put back, it counts 764.
- Bible 15.3: a paragraph after pass 303's.

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
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: a resting drop costs nothing per frame. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 312 takes Movement (last pass 304).
