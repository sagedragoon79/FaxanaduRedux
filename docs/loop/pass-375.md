# Pass 375: the minimap, kept rather than swept (Stability)

Category: Stability and performance (last pass 367).

## Audit

Passes 368 to 374 added three things that run every frame:
- the minimap, drawn by the HUD (pass 373);
- the aqueduct's spill and the drowned statue, which redraw;
- the spill's looping pour (passes 371 and 374).

The spill and the statue are a few rects a frame, in one room each, and the room-budget test enters both rooms. The HUD soak runs in Winch Hall on a new game. There only one room is walked, so the minimap was nearly free and its worst case was never measured.

A probe with every room walked and every zone charted put `Minimap.layout` at about 0.18 ms a frame. It swept all 120 rooms of the catalog to find the 15 in view. It ran every frame for a picture that changes only when you change rooms, walk a new one, or buy a chart. That is about 1% of a 60 fps frame spent on nothing, and it grows with the map.

## Fix

- `Minimap.layout` keeps the rooms in view on the world (`Minimap.CACHE`), keyed by your room and the number of rooms walked, charts held, and catalog rooms. Only the dot is worked out each frame. `layout` reports `cached`.
- Measured on a full map: 2.8 µs a frame kept, against 172 µs for a fresh look.
- Bible 12 (the minimap's note) gains "Kept, not swept (pass 375)".
- `test_the_minimap_stays_cheap_on_a_full_map` (test_soak) checks that:
  - a full map fills the window, and the next frame keeps it;
  - the kept view equals a fresh look;
  - the dot still moves every frame;
  - walking a new room, a chart, and going through a door each make it look again;
  - a kept frame costs under half a fresh look and under 0.1 ms.

Mutations:
- A key without the walked-room count failed "walking a new room looks again".
- Never keeping the view failed 4 checks: the keep, the dot, and both cost checks.

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
| Stability and performance | 5 | 99 | Unchanged score. The minimap's full-map cost is measured and cut from 0.17 ms to 3 µs a frame. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 376: Movement.
