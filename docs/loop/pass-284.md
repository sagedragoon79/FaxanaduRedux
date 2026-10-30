# Pass 284: every tell a guardian's script names is heard

Category: Bosses (last pass 276).

## Audit

I read bible 8 against what passes 277 to 283 touched. The biggest was pass 278: every guardian's tells now sound as they start, held by `test_every_guardian_tell_is_heard_as_it_starts`. That test only hears the tells a guardian happens to use in 25 s of fighting. I listed every `_tell` state each guardian's script names and compared them to what the fight reached:
- **Five tells were never reached, so never checked:** the Foreman's throw, the Drowned Warden's undertow, King Grieve's burst, and Shadow Eura's cast and dash. Each needs a set-up the fight rarely gives (a far hero, the third phase, a late count).
- **Nine more were never reached either** (the Bark Captain's vault, Shadow Eura's burst, the Matriarch's sink, Zorugeriru's breath, Ripasheiku's web and drop, the Warden's slam, Rokusutahn's dangle and plunge). Each is entered by a literal state change with its sound beside it, so they are safe, but nothing said so.

## Fix

- `test_every_guardian_tell_is_heard_as_it_starts` (`test_boss.gd`) now:
  - drives the five unreached tells after each fight (`DRIVEN_TELLS`): it sets the state that picks the move, calls the guardian's own chooser, and fails if the tell starts in silence;
  - reads every tell each guardian's script names, and fails on any that is not heard in the fight, driven, or entered only by a literal state change with `Sfx.play` on that line or the next three.
- All five driven tells were already voiced, so no game code changed.
- Mutation check: with King Grieve's burst cue removed, the test fails ("king_grieve:burst_tell (driven, [])").
- Bible 13.3: a sub-entry under pass 278's.
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: every tell a guardian's script names is now held to its cue. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 285 takes Systems (last pass 277).
