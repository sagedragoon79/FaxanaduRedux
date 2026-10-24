# Pass 68: stability

A stability pass. Stability (87.75) was the lowest category apart from Art.

## What changed

- **Hour Glass soak**:
  - The Dartmoor soak (`_soak_zone(..., glass = true)`) now runs 660 frames a room, about 11 s. It turns the Hour
    Glass whenever it is ready, so each room sees time stop, freeze its water and projectiles, and run again twice,
    under random input.
  - It checks the usual things: no escapes, no embedding, and no node growth.
  - Every zone soak now also reports and checks its average frame time against the 60 fps budget.
- **Waterfall drawing**:
  - The falling streaks were about 1,000 `draw_rect` calls a frame across the Waterfall Stair's two falls.
  - They are now two small repeating textures per fall (white streaks at 2x density, built once), scrolled at two
    speeds and tinted by state, which is a few draw calls a frame.
  - The new `test_waterfalls_stay_cheap` checks it: 0.62 ms a frame, with time stopping twice.
- **HUD Hour Glass mark**: it appears only once the glass is owned, at the right end of the potion and gold row.
  - Full and bright when it can be turned.
  - Sand pours while time is stopped.
  - The top bulb refills, dimmed, as it runs back.
  - The plate widens to fit it.
- The HUD soak now has the glass shown, turning every 200 frames.

## Tests

- `test_soak.gd`:
  - The Dartmoor soak covers the Hour Glass: 9 rooms, 0.67 ms a frame on average.
  - Every zone soak checks the frame budget.
  - `test_waterfalls_stay_cheap`.
  - The HUD soak draws the glass, at 0.77 ms a frame.
- Nothing new broke under the soak.

## Screenshots

`/mnt/project-files/pass-68/`: `stair_flow.png` and `stair_frozen.png`. They show the textured falls and the HUD
glass, full and then draining.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 89.5 | Unchanged. |
| World and level design | 15 | 93.75 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 90.5 | The Hour Glass now reads on the HUD. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 88.5 | Frame budgets checked in every zone soak, a time-stop soak, cheaper falls. |
| Faithfulness | 5 | 89.75 | Unchanged. |

Weighted score: 89.61 (up from 89.55; 89.6125 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is still Stability (88.5), then Audio (89.25). Next is back to Dartmoor:
- The lower city past the Waterfall Stair's gallery.
- A third Dartmoor enemy (Clockwork Hound or Meteor Slug).
- Then King Grieve's approach.
