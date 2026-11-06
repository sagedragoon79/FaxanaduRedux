# Pass 498: Carillon rains from a sheet now, driven on the wind

## Category

The workbench queue's top item and a Sean note (2026-11-06): the **Carillon rain trial**. Try
PixelLab's free rain preset (the VFX tool, no generations spent) as Carillon's rain against today's
code-drawn streak field, and keep the better one. A free-VFX-plus-code pass; the first imported
effect sheet in the game.

## What was built

PixelLab's `slant_rain` preset, stripped of its baked floor mist and splash band and of the
per-layer floors so the three drop depths fall the full canvas, exported as a 32-frame sheet
(`assets/vfx/carillon_rain.png`, 960x720, a 6x6 grid of 160x120 frames). A new node draws it, and a
by-eye trial judged it against the old rain.

- **`SheetRain`** (`scripts/world/sheet_rain.gd`). Slices the sheet into its 32 frames once, then
  tiles them screen-wide in **two parallax layers** — a far layer at 2x scale, 20 fps, phase +16,
  alpha 0.42, and a near layer at 1x, 30 fps, alpha 0.85 — each drifting horizontally at its own
  speed. The two scales (160 px and 320 px repeat), speeds and phases keep the one-second loop and
  the tile from ever reading as a repeat, as Sean's note asked. It wraps with the camera like
  `Motes`, draws at the same depth (`z_index` 4), and `density()` thins it to 0.35 once the Sky
  Spring breaks the storm — the same `spring:sky` flag that thins the code rain (`Motes.SETTLES`).
- **The trial.** `World` draws either the sheet or the code streak field for Carillon, never both:
  `SheetRain.SHIPPED` holds the kept decision, and `--sheet-rain` forces the sheet on for a capture
  (`game.gd` -> `World.sheet_rain_trial`). The same two Carillon rooms were shot both ways
  (`shots/rain-trial/`): the code rain is a handful of faint streaks, while the sheet reads as a
  driven storm with real depth (bright near drops, faint far ones, wind-slanted). The sheet won, so
  `SHIPPED` is true; the streak field (`Motes` zone `spires`) stays as the fallback.
- **Drizzle.** Captured with `spring:sky` set, the sheet thins to a light rain that still reads —
  the storm breaking, as the bible's event table says.

The frame cost is cheap: the Carillon soak runs 1.57 ms a frame on average with the hero running
and dashing, well inside the 8 ms budget.

## Tests

In `tests/test_world.gd`: a new `test_rain_sheet_is_carillons_alone` (the sheet is active and cut
into its 32 frames in the spires, the code streak field stood down; in the High Boughs the sheet is
off and that zone keeps its own motes). `test_spring_of_sky_waits_for_the_roc_and_breaks_the_storm`
now checks `SheetRain.density` thins past half when the Sky Spring is cleared, instead of counting
motes. In `tests/test_soak.gd`, `test_spires_rain_stays_cheap` measures the sheet (active, 32
frames, density, 600-frame cost under budget) instead of the code rain.

Mutation check: flipping `SheetRain.SHIPPED` to false fails `test_rain_sheet_is_carillons_alone`
(the sheet never activates in the spires and the code field is not stood down).

Bible: Carillon's look (4.x) gains the rain-sheet paragraph, the Sky-Spring event row now points at
`SheetRain.density`, and 12.5 notes that most particle layers are code `Motes` but Carillon's rain
is the tiled sheet.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 86.5 | Carillon's rain now reads as a real storm with depth; one zone's atmosphere lifted, the rest deferred to the art loop. |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | The rain sheet, its two-layer draw and its drizzle are held by tests and the bible. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | The sheet rain runs 1.57 ms a frame in the Carillon soak. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 97.075.

## Next

Pass 499: art loop pass 8 — the seven placeholder guardians, the Haar Wyrm first, Sean approves each
base before animation (`PIXELLAB_API_KEY` is set; ~193 generations plus 50 USD of credits). Art
outranks the rubric rotation when the queue holds no fresh Sean note. Then the VFX pass (a code
effect vs the free VFX tool) and the pass-497 independent grade's defects (the hero sprite, flat
lighting/AO, depth and tile repetition).

For Sean: the sheet won, so other outdoor zones could take a light rain too — the **Haar marshes**
(`haar`) most of all, where a thin, slow drizzle would suit the fog; the High Boughs (`boughs`)
could take an even fainter mist-rain. Left for you to decide; say the word and the next pass wires
`SheetRain` (or a lighter code field) into them.
