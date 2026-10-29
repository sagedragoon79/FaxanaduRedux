# Pass 246: the spikes are heard

Category: Audio (last pass 238).

## Audit

I checked the sounds against the bible:
- `levels.py --check` is clean: 147 sound effects, 34 music tracks and 14 ambience beds.
- Every name the code plays has a file, and every file is played; the step and broad-blade sounds are built from a prefix.
- Every foe, boss and world script that plays no sound of its own was checked against what it does.

The gap found: the Crystal Dwarf's eruption. The bible says six crystal spikes erupt along the floor one after another, the danger you must jump or dash. Only the fist made a sound (`break`). Each spike rose in silence, so the attack that actually hits gave no warning by ear, and the cue that it runs toward you was missing. King Grieve, the Evil One's avatar and the Evil Heart all raise the same spikes, so all four fights had it.

## Fix

- `sfxgen.py` adds `crystal_stab`: a 0.03 s high crack of stone, a hard glassy ping (2093, 3311 and 4870 Hz, out of tune on purpose) and a short low grind, 0.24 s.
- `CrystalSpike` plays it at -6 dB as each spike rises out of its mark, so an eruption ticks along the floor. A static frame mark lets two spikes that rise on the same frame (the Evil Heart's wave runs both ways) sound once.
- Test: `test_a_crystal_spike_stabs_up_with_a_sound` (`test_enemies.gd`). It checks that:
  - the mark glows in silence;
  - the spike sounds as it rises, once;
  - two spikes rising together sound once;
  - the file is on disk.
- Mutation check: without the same-frame mark, the pair check fails (2 sounds).
- `levels.py --check` stays clean (148 sound effects).
- Bible 7 (the Crystal Dwarf's row).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the eruption that does the damage now sounds as it comes. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 247 takes Stability (last pass 239).
