# Pass 56: Daybreak holds up

A stability pass on the new zone. Stability was the lowest category outside Art (86).

## What changed

- No game code changed. The soak and the new checks found nothing to fix.
  - The Daybreak soak (pass 54) and the beetle placements (pass 55) ran clean across the whole suite.
  - The only exit warning is 8 leaked ObjectDB instances when the full suite ends, which predates this zone.

## Tests

- `test_rooms.gd`: `test_daybreak_state_survives_a_save_round_trip`.
  - Opens the Sky Steps chest, takes the Broken Shrine's Life Fruit and rests at its shrine through `World.save_at`.
    A new game forgets it all.
  - After loading:
    - The save room is `daybreak/broken_shrine`.
    - The Stride and the Life Fruit's health are back.
    - The fruit doesn't grow back.
    - The chest stays open.
  - It also checks that the shrine, the fruit and the yard's beetle are there.
- `test_soak.gd`: `test_daybreak_rain_stays_cheap`.
  - 600 frames in the Sky Steps with the player running, jumping and air-dashing under the rain and the lightning
    backdrop. It averaged 0.97 ms a frame, 4.24 ms at worst; the check is under 8 ms.
  - All 52 drops stay on screen and none are lost.
  - Leaving for the Crown-Leaf stops the rain.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 88 | Unchanged. |
| World and level design | 15 | 92 | Unchanged. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 88.5 | Unchanged. |
| Audio | 5 | 88.25 | Unchanged. |
| Stability and performance | 5 | 86.75 | A Daybreak save round trip and a storm frame-time budget. |
| Faithfulness | 5 | 88.25 | Unchanged. |

Weighted score: 88.51 (up from 88.47).

## Lowest categories and next pass

Leaving Art aside, Stability (86.75) is still the lowest. The next stability item is tracing the 8 ObjectDB leaks at
the end of the suite. Next for the world is Daybreak town past the fallen bridge (bible 3.2 and 10: a town with a
Guru, an armorer and the spell-scroll shop), with the Thunder spell and its conduits after it.
