# Pass 14: tiles at 2x density

Date: 2026-10-23. Scope: Art (65). Since PR #20 the world renders at two pixels per world pixel,
but the zone tiles were still 1x, so every tile pixel became a 2x2 block beside 2x characters.

## What was built

- **Tile atlases at 2x** (`tools/art/tilegen.py`, `D = 2`): every zone tile is now a 32 px atlas
  tile for the same 16 px world tile. The painters were redrawn for the finer grid rather than
  upscaled: Eolis bricks get a one-render-pixel mortar line, a lit top and left edge, a shaded
  bottom and right, and a grain of pits; Trunk wood gets fine strands, sparser knots with a lit
  ring, and moss caps with blades of uneven height, a dark under-edge and fungus glow drips.
  Outlines stay one world pixel thick with a soft inner shade; outer corners are rounded with a
  stepped edge; platforms gain grain, nail heads and outlined brackets; amber gets highlighted
  bubbles.
- **Engine:** `TilesetFactory.DENSITY = 2`. Tile layers come from `TilesetFactory.layer()`, run
  at 32 px cells and are scaled by one half, so cell coordinates, collision and every
  `set_cell` call are unchanged. Collision polygons (including the one-way lip) scale with the
  layer. Bible 12.1's tile line says so.
- Parallax backgrounds stay 1x for now (they sit behind the play layer and scroll slower).

## Automated verification

403 checks pass. New: every zone atlas holds 32 px tiles, a cell still covers 16 world pixels,
and the player stands exactly on a floor's top edge. Screenshots reviewed: the Rootbound Hall
and the Eolis plaza at full size and at 4x.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged. |
| World and level design | 15 | 68 | Unchanged. |
| Art cohesion | 15 | 69 | Tiles match the 2x density of new art; decor and backgrounds still 1x. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 73 (72.65, up from 72.05).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Audio (62)**: lightly weighted.
2. **Art (69):** decor atlases (`decorgen.py`) and the parallax backgrounds to 2x.
3. **World (68):** the last 5 Trunk rooms.
