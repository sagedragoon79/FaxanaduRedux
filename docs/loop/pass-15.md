# Pass 15: decor and backgrounds at 2x density

Date: 2026-10-23. Scope: Art (69). After pass 14 the tiles were 2x, but the room decor and the
parallax backgrounds still drew every pixel as a 2x2 block.

## What was built

- **Decor atlases at 2x** (`tools/art/decorgen.py`, `D = 2`): a decor cell is still 16x32 world
  pixels but is painted as 32x64 atlas pixels, with one-atlas-pixel strokes. Each piece was
  redrawn rather than upscaled. Trunk: grass blades that taper and lean, seed heads, domed
  fungus caps with a dark rim, gill ticks, a glint and drifting spores, a spotted mushroom, a
  twig with a leaf, roots that taper and branch into rootlets, moss with drips, and a ringed
  bracket fungus. Eolis: weeds with small flowers, rounded pebbles, a planked crate with a
  brace and nails, ivy with alternating leaves, a chain of alternating links with a hook, a
  banner with a golden tree emblem, and a sconce with a teardrop flame.
- The decor JSON gains `"density"`; glow points are now stored in world pixels.
  `Decor` reads the density to cut the atlas and draws each piece at world size.
- **Parallax backgrounds at 2x** (`tools/art/tilegen.py`): the 640x480 layers are painted at
  1280x960 with finer detail: grain in the far heartwood fibres, haloed spores, shaded roots
  with rootlets and domed glowing caps, bark ridges on the columns, stone courses and
  mullioned windows in the Eolis houses, framed lanterns with two rings of light.
  `Backdrop` scales each sprite to `SIZE`, so the layers still repeat every 640 world pixels.
  The title screen draws them at world size the same way. No camera code changed.
- Bible 12.1 records the decor and background densities.

## Automated verification

New test: both decor atlases are 2x and hold four rows of cells, and both Trunk background
layers are 2x images that still cover 640x480 world pixels. Full suite: 412 checks pass.
Screenshots reviewed: the Eolis plaza, Lantern Grotto, Fungus Shaft, the Trunk entrance and
the title screen, plus the decor atlases and the far layer at 4x beside the old 1x version.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged. |
| World and level design | 15 | 68 | Unchanged. |
| Art cohesion | 15 | 71 | Tiles, decor and backgrounds all at the 2x density of the hero. Enemy and NPC sheets are next. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 73 (72.95, up from 72.65).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Audio (62)**: lightly weighted.
2. **World (68):** the last 5 Trunk rooms.
3. **Art (71):** enemy and NPC sheets to 2x (`castgen.py`).
