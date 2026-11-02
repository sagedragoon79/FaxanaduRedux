# Pass 407: a save slot left behind

## Category

Stability (last pass 399).

## Audit

- The real-controller tests from passes 400 to 406 press buttons through `Input` and send `InputEventAction` events. The runner already names any button left held (`held_actions`) and releases it before the next test, so a half-sent action cannot leak.
- The last full run played 50.5 soak minutes and heard every sound.
- Its engine errors all come from tests that feed in damaged or old saves and settings on purpose.
- The gap is the save slot. Twenty-six tests choose a test slot (`GameState.slot = 9` and others) so that their rests and saves stay off the player's three flasks. Each puts the slot back by hand, and nothing checked that it did. A test that left slot 9 chosen would send every later test's saves there. A test that saved without choosing a slot would then write to slot 9 instead of slot 1, and pass 399's guard on the player's flasks would no longer catch it.

## Fix

`tests/test_runner.gd`:

- `_clean_slate` starts every test on the first flask (`CLEAN_SLOT`, the game's own default).
- `_leaks` names "save slot left on N" when a test leaves another slot chosen.

`test_every_test_starts_from_a_clean_slate` leaves slot 9 chosen and checks two things: the runner names it as a leak, and the clean slate puts the first flask back.

The guard's first full run found 18 tests that left a test slot chosen, in test_soak.gd, test_rooms.gd and test_systems.gd. Thirteen chose a slot and never put it back. Five loaded a test save, which chooses that slot too (`load_game` sets `GameState.slot`). Each of the 18 now remembers the slot it found and puts it back. Since the runner now starts every test on slot 1, the leak was harmless in this run, but the order of tests could have hidden a stray save.

Bible 15.3 gains "A save slot left behind (pass 407)".

Mutation check: with the slot check turned off, the test fails ("a save slot left changed counts as a leak").

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
| Stability and performance | 5 | 99 | Score unchanged. A test cannot leave another save slot chosen for the tests after it. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 408: Movement.
