# Pass 47: The hydra's voice, and the boardwalks rise

Audio was among the lowest categories, and Zorugeriru borrowed the generic boss theme and other enemies' sounds. The
Spring of Mist also had one bible 4.4 change still missing: the drowned boardwalks.

## What changed

- **Zorugeriru's theme** (`track_zorugeriru` in `tools/audio/musicgen.py`, `assets/music/zorugeriru.ogg`). It is a
  heavy surge in C# minor at 132 bpm:
  - a swelling bass that pushes on beat four;
  - war drums rolling a triplet into each downbeat;
  - three lead voices (the heads) trading one motif bar by bar, panned left, centre and right;
  - a fourth voice that answers low from bar 9.

  `BossArena.BOSSES` plays it for the fight.
- **His sounds**, appended at the end of `sfxgen.py` so every older wav stays byte-identical (checked):
  - `hydra_roar`: three throats a fifth apart, falling. It plays at the intro, each phase change, the fourth head's
    emergence and his death.
  - `hydra_bite`: a growl that snaps shut on a bone clack.
  - `mist_breath`: a long, throaty exhale.
  - `flood`: a rushing roar of water.
- **Drowned boardwalks** (legend `b`, `Room._place`).
  - While the spring is dry they are nothing. Once `spring:mist` is set they are one-way planks.
  - The Victim Causeway's dip is now two rows deep, like the Fog Cut's hollow: spikes at the bottom, and the boardwalk
    level with the floor across both.
  - `reach.gd` stands on `b` only with the `spring_mist` ability, so the critical path never counts on them.
- Bible 4.4 (the Spring of Mist row), 8.4 (his sound) and 13 (music list) are updated. `levels/README.md` has the `b`
  legend row.

## Tests

- `test_world.gd`: `test_drowned_boardwalks_rise_with_the_spring_of_mist` covers both rooms. Before the spring there is
  nothing at the plank. After it there is a one-way plank, and the player stands on it over the spikes.
- `test_reachability.gd`: `test_checker_stands_on_drowned_boardwalks_only_after_the_spring` uses a synthetic dip.
- `test_boss.gd`:
  - The Spring of Mist test checks that the fight plays `zorugeriru`.
  - The music-file test lists the new track.
- `test_every_sound_the_code_plays_exists` covers the four new sounds.

## Screenshots

`/mnt/project-files/pass-47/`: the Victim Causeway drowned, and risen after the spring.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 89 | Unchanged. |
| Combat and enemies | 15 | 86 | Unchanged. |
| World and level design | 15 | 91 | The Mist's spring now changes its rooms as the bible says. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 87 | Unchanged. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 85 | Every zone boss so far has its own theme and sounds. |
| Stability and performance | 5 | 84 | Unchanged. |
| Faithfulness | 5 | 86 | Unchanged. |

Weighted score: 87.10 (up from 86.90).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest are Stability (84) and Audio (85). The Mist is complete through its spring.
Next, from the bible's zone order (4.1, step 5): open the next zone past the Spring of Mist. That means a door out of
the arena once Zorugeriru is beaten, and its first rooms and enemies. A stability sweep belongs alongside it: a save
round-trip through the Mist's new flags (`spring:mist`, the basins, the seal, the curtain).
