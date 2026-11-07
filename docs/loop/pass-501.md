# Pass 501: atmospheric perspective on the parallax back layers

## Category

Art / World, from the independent-grade queue — not the rubric rotation. Art outranks the rotation
when the queue holds no fresh Sean note (none this pass; all three notes are answered), and the
headline art item (the PixelLab guardian bases) is **blocked**: three bases already wait for Sean's OK
(Haar Wyrm, Thane Vorrund, Drowned Warden), the limit of three, and no note frees a slot. The
player-sprite item would be a fourth base, also over the limit. So this pass takes the next unblocked,
code-first grade defect — the one pass-500's "Next" named as pass 501's work, the recurring
**depth collapse** called out at both the pass-497 and pass-500 grades:

> Trunks, mid platforms and the play layer share value and saturation, so the player gets lost against
> busy backdrops.

No generations and no base-approval gate; it touches every zone with a painted backdrop.

## What was built

The two painted parallax layers (`<zone>_far.png`, `<zone>_mid.png`) are now pushed back by
**atmospheric perspective** — distance read as lower saturation and lower contrast — instead of
competing with the gameplay layer at the same depth. A small canvas shader,
**`shaders/atmosphere.gdshader`**, applied per layer in `Backdrop`:

- pulls the layer's colour toward grey (`desat`), dropping its saturation, and
- fades it toward the dark zone haze (`fade`, toward the palette's `night-1`), compressing its
  contrast and darkening its bright parts.

The further-back layer recedes harder: **`far` (desat 0.55, fade 0.5)** sits deeper than
**`mid` (desat 0.3, fade 0.24)**. The lit gameplay tiles — bright, and rim-shaded by `EdgeShade`
since pass 500 — are untouched, so they now stand clear of the muted backdrop. The effect is a
GPU fragment shader: no per-frame CPU cost, nothing baked, no backgrounds regenerated.

The colour maths live in a pure static `Backdrop.haze_color()` that mirrors the shader exactly, so
the tests drive the same formula the GPU runs (the same split the pass-500 `EdgeShade` uses: tested
logic, shader-drawn result).

## Why a shader, not a repaint

The ten zones' far/mid layers are ten pairs of hand-authored painter functions in
`tools/art/tilegen.py`. Repainting atmospheric haze into each would be a large, per-zone, error-prone
diff and would re-bake every PNG. One shader applies the same, tunable recession to every zone at
once, costs nothing at runtime, and keeps the source art unchanged — if the haze wants tuning later,
it is two constants in `Backdrop.ATMOS`, not ten repaints.

## Tests

`tests/test_backdrop.gd` (new, registered in the runner), eight cases over the pure transform and the
per-layer ordering:

- desat 0 / fade 0 leaves a pixel untouched; fade 1 lands on the haze.
- desaturation lowers HSV saturation while preserving perceptual luminance.
- fade moves a bright pixel toward the haze and darkens it (the haze is darker than a lit backdrop).
- `far` is desaturated and faded more than `mid`, both in range and both non-zero, and a bright pixel
  ends up less saturated and closer to the haze on `far` than on `mid`.
- the haze is a dark tone (atmosphere means receding into shadow, which suits these moody zones).
- `atmos_material` carries the configured desat/fade/haze uniforms and returns null for an unknown
  layer suffix.

Mutation-checked: flattening the `far`/`mid` ordering fails the recede test (4 checks); neutralising
the fade on all three channels fails both the fade and recede tests.

## By eye

Three busy-backdrop rooms shot off-screen with the effect off and on (`workbench/capture/shot.tscn`):

- **`spires/spires`** — the saturated magenta storm clouds, floating islands and web recede into a
  muted purple-grey; the NPCs, the hut, the green platforms and the stone floor pop where before they
  swam in the backdrop. Lightning still reads.
- **`heartwood/deep_roots`** — the background trunks darken and desaturate; the hero, wooden
  platforms, mushrooms and the slug read clearly, and the already-dark room is not crushed.
- **`boughs/sunlit_bough`** — the far branches and sky settle to a blue-grey haze behind the warm bark
  tiles and green leaves, so the depth order reads at a glance.

The gameplay floor and wall tiles (not parallax) stay bright throughout — only the back layers recede.

## Rubric (design bible 15.3)

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged; the backdrop recedes, the actors stay bright. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 90 | Depth collapse addressed: the back layers read as distance, so the lit play layer pops. With pass 500's rim shading, tiles are lit volumes against a receding backdrop. The hero and guardian HD bases are still the open gap (gated art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | A GPU fragment shader on two layers; no per-frame CPU work. |
| Story and world | 5 | 99 | Unchanged. |

Weighted: 97.6.

## Next

Pass 502: the art loop stays gated on Sean — three guardian bases (Haar Wyrm, Thane Vorrund, Drowned
Warden) wait for his OK, the limit of three, so no new base can be made until he approves one. Until
then, the next unblocked grade defects, code-first: **tile variants / grid banding** (brick and wall
fields tile obviously — add atlas variants so the repeat unit stops reading) and the **halftone dither
moire** (the dot-screen fill over the midground reads as a screen-door on several rooms — soften or
vary it; this pass's desaturation already dims it, but the grid still shows). The **grass fringe**
(flat bright-green band, pass-500 grade) is a small, self-contained code-first win too. The hero
sprite (the grade's top defect) needs PixelLab and would be a fourth base — held until a slot frees.

For Sean (carried from pass 498, still open): the rain sheet won, so the **Haar marshes** could take a
thin, slow drizzle to suit the fog, and the High Boughs an even fainter mist-rain — say the word and a
pass wires it in.
