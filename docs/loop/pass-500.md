# Pass 500: ambient-occlusion rim shading on every solid edge

## Category

Art, from the workbench queue and the independent grade — not the rubric rotation. Art outranks the
rotation when the queue holds no fresh Sean note (none this pass; all three notes are answered), and
the headline art item (the PixelLab guardian bases) is **blocked**: three bases already wait for
Sean's OK (Haar Wyrm, Thane Vorrund, Drowned Warden), the limit of three, and no note frees a slot.
The player-sprite item would be a fourth base, also over the limit. So this pass takes the next
unblocked art item that most lifts the independent grade — the pass-497 grade's named "fastest win"
that starts in code:

> Flat lighting with no ambient occlusion: walls meet floors and platforms meet backgrounds with
> hard, unshaded seams; light sources rarely cast gradient pools or contact shadows.

and its sibling defect, "visible tile repetition... little tile variation... to break the grid", and
"over-reliance on halftone/dot-screen gradient fills... flattening large areas". No generations and
no base-approval gate, and it touches every room in the game.

## What was built

A new overlay node, **`EdgeShade`** (`scripts/world/edge_shade.gd`), that rim-darkens the air-facing
edge of every solid tile. Before this, a lit wall, floor or platform tile ran at full brightness
right up to its boundary with the dark background, so each read as a sticker laid on the backdrop —
the grade's "stickered tiles". Now the rim fades inward over part of the tile, so the surface curves
away into shadow at its edge and reads as a lit volume:

- **Undersides** of ledges and platforms darken most (reach 7 px, peak alpha 0.50) — they face away
  from the top-left key light (design bible 12.3).
- **Vertical wall faces** darken moderately (5 px, 0.34), so pillars and walls round off against the
  dark slots between them instead of ending at a hard bright line.
- **The walking surface** on top darkens only faintly (3 px, 0.14), so the lit top edge the player
  reads as footing is kept.
- **Concave corners deepen for free** where two rims overlap.

### Why rim the solid side, not the air side

The first cut cast soft shadows onto the open-air side of each seam (a drop shadow under ledges, a
band beside walls). On the game's near-black backdrops that was invisible — a dark shadow over a dark
background is no change. The seams that actually read as hard are where a *lit* tile meets the dark
air, so the fix darkens the lit tile's own rim, which shows. Verified by eye below.

Each rim is four thin rects fading from the boundary to nothing, in a near-black with a faint cool
bias (`Color(0, 0, 0.02)`). The room's outer frame is left alone (out-of-bounds counts as solid, so
boundary walls are not rimmed and the room does not gain a dark border). The lit centre of a solid
mass and the open middle of a room are untouched, so the gameplay layer keeps its contrast and combat
readability is unchanged (design bible 12.3, "Readability layers"). It draws over the tiles but under
the actors (tree order, `z_index` 0), once per room load, and costs nothing per frame.

## Design notes and trade-offs

- A secret wall the player later breaks open is a rare case the static shade does not redraw for; the
  reveal flash covers the stale pocket. Noted in the node's doc comment.
- Slopes are already in the room's solid set, so they rim like any wall.
- One-way platforms (legend `-`, ladder tops, risen boardwalks) are not solid ground; they are thin
  pass-through planks that mostly float, so they are not rimmed. Most "platforms" the player stands
  under are solid ledges, which do rim on their underside.

## Tests

`tests/test_edge_shade.gd` (new, registered in `test_runner.gd`): seven cases over the pure geometry —
out-of-bounds counts as solid not air, air cells and a fully buried cell draw nothing, the room's
outer frame is not rimmed outward (only its inner face), a floor's top gets the faint walking rim with
no underside, a floating ledge is rimmed on every exposed face including its underside, and a block's
outer corner gets two overlapping rims and none on the buried faces. Mutation-checked: keying the
underside rim on the cell above instead of below fails the floor case.

## By eye

Three rooms shot off-screen at 1x (`workbench/capture/shot.tscn`), and a 1.7x side-by-side of a
Kettleforge brick pillar with the shade off and on. With it on, the grey brick pillars round off
against the black slots between them and read as columns rather than flat panels; the bark ledges and
walls of `heartwood/deep_roots` gain shaded undersides; the stone frame of `hearthroot/king_hall`
reads as a lit border, not a stamp. The player, the king and the floor enemy stay fully bright — the
rim darkens only the tile edges, never the actors or the lit room centres. The strength is deliberately
restrained so it reads as shading, not as a dark outline.

## Rubric (design bible 15.3)

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged; the rim leaves the lit play centre and the actors bright. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 88 | Tiles read as lit volumes instead of stickers on the backdrop; the hero and guardian HD bases are still the open gap (gated art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | A static one-draw overlay; nothing per frame. |
| Story and world | 5 | 99 | Unchanged. |

Weighted: 97.2.

## Next

Pass 501: the art loop is still gated on Sean — three guardian bases (Haar Wyrm, Thane Vorrund,
Drowned Warden) wait for his OK, the limit of three, so no new base can be made until he approves
one. Until then, the next unblocked grade defects, code-first: **tile variants and grid banding**
(brick/wall fields tile obviously — add atlas variants so the repeat unit stops reading) and
**depth collapse** (desaturate/darken the parallax back layers so the play layer pops). The hero
sprite (the grade's top defect) needs PixelLab and would be a fourth base — held until a slot frees.

For Sean (carried from pass 498, still open): the rain sheet won, so the **Haar marshes** could take a
thin, slow drizzle to suit the fog, and the High Boughs an even fainter mist-rain — say the word and a
pass wires it in.
