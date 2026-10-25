# Pass 94: The wide camera

Bible 8.6 gives Borabohra's arena "three floating islands; the camera pulls out wide". That has been deferred since pass 60. This pass builds it as a general room option.

## What changed

- **`camera: wide`** (new room header, `Room.wide_camera()`):
  - `GameCamera.set_room_limits(rect, wide)` aims the framing at `WIDE` (0.8). The view is 800x450 world pixels, 25% more each way.
  - It eases there over about 0.6 s (`frame_scale` follows `frame_goal`), and the zoom follows.
  - The framing never goes past the room's edges. A room too small for the full pull-out gets as much as fits, and a room smaller than the screen is never zoomed in.
  - Going back to a normal room snaps to the normal framing at once, so the view never shows past the smaller room while it eases.
  - The camera still sits on whole render pixels at the current zoom, and the sub-pixel shift is given in screen pixels. The HUD and PixelFont are drawn outside the world viewport, so they are unscaled.
  - The weather motes tile their field across the wider view. The parallax backdrop already covers it.
- **The Roost** is now 60x29: six rows of open sky above the fight, and `camera: wide`. All three islands, the roc and the lightning are in frame at once.
  - The roc's arena is anchored to the floor (the 16 rows above it), so the fight plays as before.
  - The two Roost cell positions in `test_boss.gd` and `test_soak.gd` move down six rows.
- **Fix:** Borabohra had no `PHASES`, so since pass 60 its health bar threw a script error every frame and drew no phase marks. It now lists `[PHASE_2, PHASE_3]`, and a new test checks that every boss with a health bar has them.
- Bible 6.7 (the wide camera) and 8.6, and the `levels/README.md` header list.

## Tests

`test_combat.gd`:
- `test_a_wide_room_eases_the_camera_out`: the ease, the settle, the zoom, 25% more view, staying inside the room, the sub-pixel bound, and the snap back.
- `test_the_wide_camera_never_shows_past_a_small_room`: limits on height and on width, and never zooming in.
- `test_the_roost_frames_the_storm_wide`

`test_boss.gd`:
- `test_every_boss_marks_its_phases_on_the_health_bar`

Full suite: 1776 checks, all passing.

## Screenshots

`/mnt/project-files/pass-94/`:
- `roost_wide.png`: the Roost framed wide, with all three islands, the conduits, the roc circling and the phase marks on its bar.
- `roost_duel_wide.png`: phase 3 framed wide, with the roc over the updraft.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 92.5 | Camera framing that fits the space (6.7). |
| Combat and enemies | 15 | 92.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.5 | The roc fight reads whole at a glance, and its bar shows its phases. |
| Systems | 10 | 93 | Unchanged. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92.5 | A script error that fired every frame in a boss fight is fixed and guarded by a test. |
| Faithfulness | 5 | 95.5 | The bible's wide camera is in. |

Weighted score: 92.69 (up from 92.58; 92.6875 unrounded).

## Next

Audio (92) is now the lowest apart from Art. Tilte, the last deferred spell (10.2: 2,500 g at the Daybreak scriptorium), is the biggest remaining bible gap. Pass 95 builds Tilte.
