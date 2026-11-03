# Pass 415: a fresh journey for every test

## Category

Stability and performance (last pass 407).

## Audit

Passes 408 to 414 added real-controller tests for drops and ladders, the King and the Guru, the Rune Dagger, doors, King Grieve's parry, a shop and the ready chimes. Each releases its buttons and puts its save slot back, and the runner checks both. What the runner never reset was the journey itself, `GameState.data`. A test built on `make_world` starts a new game, but a bare hero made with `make_player` reads his gear, gold and keys from whatever the last test left. Pass 412 equips a small shield to parry King Grieve, so the next bare hero could start with one. The gym's no-record switch (`GameState.active`) was not checked either: left off, it would stop every later kill from counting.

## Fix

- `_clean_slate` now calls `GameState.new_game()` and turns recording back on (`GameState.active = true`).
- `_leaks` names the no-record switch left off.
- The run's summary counts the tests that left the journey changed ("Journeys wiped").
- `test_every_test_starts_from_a_clean_slate` obtains a shield, sets gold to 777 and turns recording off, then checks the leak is named and the slate puts back a fresh journey.
- Bible 15.3 gains "A journey left behind (pass 415)".

Full run: 7283 checks pass; 408 tests left the journey changed and the next began fresh; soaks played 50.5 minutes.

Mutation: removing `new_game()` from `_clean_slate` fails the test (gold 777, gear still holding the small shield).

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
| Stability and performance | 5 | 99 | Score unchanged. Every test now begins a fresh journey. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 416: Movement.
