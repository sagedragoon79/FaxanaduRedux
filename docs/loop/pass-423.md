# Pass 423: every test begins in silence

## Category

Stability and performance (last pass 415).

## Audit

The tests added in passes 416 to 422 release their buttons, free their worlds and the whole Game node (421), and put back their save slots; the runner checks each. What it never reset was the music player, an autoload. The track, the ambience bed and a boss phase's lift a test left playing carried into the next test. `Music.play` does nothing when asked for the track already playing, so the 41 checks that a fight, a zone or the ending plays its music (`Music.track == ...`) could pass with no play at all whenever an earlier test had left that track on. A full run shows how common it was: 402 tests left music playing.

## Fix

- `_clean_slate` hushes the music: `Music.play("", 0.0)`, `Music.ambience("", 0.0)` and no phase lift.
- The run's summary counts the tests that left music playing ("Music hushed").
- `test_every_test_starts_from_a_clean_slate` leaves a boss theme, an ambience and a two-step lift playing, checks the slate silences all three, and that the next play of the boss theme is a real change.
- Bible 15.3 gains "Music left playing (pass 423)".

Full run: 7341 checks pass; 402 tests left music playing and 411 left the journey changed, and the next began clean; soaks played 50.5 minutes.

Mutation: removing `Music.play("")` from `_clean_slate` fails the test (the boss theme is still on).

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
| Stability and performance | 5 | 99 | Score unchanged. Every test now begins in silence. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 424: Movement.
