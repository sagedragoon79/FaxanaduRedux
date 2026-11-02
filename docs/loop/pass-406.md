# Pass 406: rests and pins, heard through the buttons

## Category

Audio (last pass 398).

## Audit

- The mix is clean. `tools/audio/levels.py --check` reports 166 sound effects (median -18.5 dB), 34 music tracks and 14 ambience beds, with no clipping or stray levels.
- Every press in a menu is heard (pass 398). The map's open and close rustles are heard through its real buttons (pass 405).
- The boss fight driven by buttons (pass 404) does not listen for its sounds. But every boss sound is also heard by the boss tests that call the fight directly, and the "every sound heard" gate covers the rest.
- The gap is two sounds that only the "every sound heard" gate held:
  - The shrine's save chime. Pass 398 noted that no test listens for it on its own. The gate would still pass if the chime moved to the wrong moment or played twice, as long as some other test played it.
  - The map's pin sounds. `pin`, `pin_lift`, and `menu_refuse` when the map holds all twelve pins were never listened for. If pinning and lifting shared one sound, every test would pass.

## Fix

`test_rests_and_pins_are_heard_through_the_buttons` (test_systems.gd) presses the real controller and checks each sound:

- Up at a shrine rests and saves, with the save chime exactly once. It saves to test slot 9 and deletes that save afterwards.
- On the open map, Jump drops a pin with `pin` alone.
- Jump again lifts it with `pin_lift` alone.
- With twelve pins on the map, Jump adds none and plays `menu_refuse`.

Bible 13.3 gains "Rests and pins, heard through the buttons (pass 406)".

Mutation check: the test fails in both cases below.

- When lifting a pin plays `pin`: "and Jump again lifts it with its own sound".
- When the shrine is silent: "with the save chime, once".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The shrine's chime and the map's pin sounds are each heard through the real buttons. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 407: Stability.
