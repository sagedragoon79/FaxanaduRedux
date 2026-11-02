# Pass 390: every sound is heard (Audio)

Category: Audio (last pass 382).

## Audit

Passes 383 to 389 added no sound file: the Windloft veil (388) reuses `veil` and `ward_refuse`, and the combat buttons (386) changed timing, not cues. `tools/audio/levels.py --check` passes (166 effects, median -18.5 dB; 34 tracks; 14 beds). So the audit turned to coverage. 56 of the 166 sound files are named in no test, which by itself proves little, since many are played through tables and helpers. A full run with every name asked of `Sfx.play` recorded showed which files no moment of the suite ever plays. There were four:

- `door`: the creak of a door that fades. Tests build the world with `instant`, which skips the fade and the sound with it.
- `anvil`: the Forepaw forge's ring. The forge test counted strikes, but no hero stood within `Forge.HEAR` of the anvil.
- `broad_heavy`: the Broad Sword's heavy cut. Pass 190's test asked `swing_sound()` for the name and never swung it.
- `falls_pour`: the Aqueduct spill loops it on its own player, not through `Sfx` (pass 374 has its test).

## Fix

- `Sfx.heard` keeps every name played since start. The runner's `unheard_sounds()` lists every file in `assets/sfx/` that no test played, and an unfiltered run fails on any. `falls_pour` is listed in `OWN_VOICE` with the test that hears it.
- `test_a_door_that_fades_is_heard` (new, `test_world.gd`) gives the world a fader, walks the East Gate's door into the Trunk, and hears one creak as the fade begins and a clear screen after.
- `test_the_forepaw_forge_rings_and_throws_sparks` now hears the anvil 40 px inside `Forge.HEAR` and not 40 px past it.
- `test_the_dagger_the_broad_sword_and_the_equipment_page_have_voices` swings the Broad Sword's combo through to its heavy cut and hears `broad_heavy`.
- Bible 13.3 gains "Every sound is heard (pass 390)".

Mutation checks:
- With the anvil's `Sfx.play` removed, the forge test fails 1 check.
- With the Broad Sword's heavy cut playing `broad_slash`, the voices test fails 1 check.
- With the door's creak removed, the door test fails 1 check.
- Before the three tests, the full run failed "every sound heard" with the four names above.

Full suite: 7068 checks passed, soaks 50.5 minutes.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. Every sound file is now played by some test, and a run fails if one goes unheard. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 391: Stability.
