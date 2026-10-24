# Pass 59: the Storm Harpy

Daybreak's flier (bible 7), code-drawn at 2x. The zone's enemies so far were a ground beetle and borrowed Trunk
hornets. The harpy makes the air above the bridge and the spire a threat, and it gives the parry a ranged use.

## What changed

- **Storm Harpy** (`scripts/enemies/storm_harpy.gd`, legend `y`):
  - Storm-grey and violet, with white hair, gold eyes and gold talons. Her wings are swept, scalloped polygons that
    flap.
  - Within 260 px she hangs about 72 px to one side of you and 84 px above, keeping her side unless you pass under
    her. That puts her out of reach of a plain slash.
  - **Tell**: she rears and throws her wings up for 0.55 s, flashing, with a screech (`screech.wav`).
  - **Volley**: a fan of three feathers aimed at you (`feather.wav`).
  - **Winded**: after a volley she sags about two tiles for 0.8 s, within a jump's reach. She then waits 1.4 s.
  - HP 30, 12 to touch, 16 XP, 6 to 12 gold.
- **Harpy feathers** (`scripts/enemies/harpy_feather.gd`):
  - 8 damage each, 200 px/s, 15° apart, burst on walls.
  - Parryable: a parried feather turns and homes back on its harpy for 12.
- **Placed** on the Fallen Bridge (replacing the far hornet) and twice up the Spire Stair (one of them replacing the
  hornet).
- **Bible 7** describes the harpy as built, and the README legend gains `y`.
- **Sounds** are appended to `sfxgen.py`, so every existing wav is byte-identical.

## Tests

- `test_enemies.gd`:
  - `test_storm_harpy_rears_then_flings_a_fan`:
    - She rears for at least `MIN_TELEGRAPH`, then flings exactly three feathers from above you.
    - A feather hits.
    - She sags, winded.
  - `test_a_parried_harpy_feather_flies_back`: a parry turns the feather without hurting you, and it strikes her for
    12.
- The room, soak and sound-file tests cover the placements and the new sounds. No reachability checks were added,
  as enemies don't affect them.

## Screenshots

`/mnt/project-files/pass-59/`: `harpy_40.png` and `harpy_70.png` (the harpy over the Fallen Bridge, perched above
the player).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89 | A flier that rewards the parry and the jump, not just the slash. |
| World and level design | 15 | 92.5 | Unchanged. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 89.25 | Unchanged. |
| Audio | 5 | 88.75 | Two new effects. |
| Stability and performance | 5 | 86.75 | Unchanged. |
| Faithfulness | 5 | 88.75 | Unchanged. |

Weighted score: 88.85 (up from 88.76).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (86.75), then Bosses (88.5). Next is Borabohra's roost (bible 8.6): three
floating islands, conduits on each that ground the bird when Thunder wakes them, dive bombs and feather volleys. It
is reached from the top of the Spire Stair.
