# Pass 502: soften the halftone dither in the sky backdrops

## Category

Art / World, from the independent-grade queue — not the rubric rotation. Art outranks the rotation
when the queue holds no fresh Sean note (none this pass; all three notes are answered), and the
headline art item (the PixelLab guardian bases) is **blocked**: three bases already wait for Sean's OK
(Haar Wyrm, Thane Vorrund, Drowned Warden), the limit of three, and no note frees a slot. The hero
sprite (the grade's top defect) would be a fourth base, also over the limit. So this pass takes the
next unblocked, code-first grade defect — the one pass-501's "Next" named for pass 502, the recurring
**halftone dither moire**, flagged at the pass-497, pass-500 and pass-501 grades:

> A uniform dot/crosshatch dither grid over the midground reads as flat moire noise on several rooms
> (boughs, evercrown, spires, sky_spring, sunken, vorrhallow).

No generations and no base-approval gate; it touches every zone with a painted backdrop.

## What was built

The sky of every far layer (`<zone>_far.png`) is a palette-locked vertical gradient from
`tilegen.gradient(top, bottom)`. The old gradient blended between **two** colours — `top` and
`bottom` — with a fixed 4-pixel ordered dither squeezed into the transition band. Over the large
lower region that meant a 50/50 screen of two far-apart colours, on a rigid grid: a loud dot/
crosshatch screen-door with a hard banding seam where it kicked in. That is the moire the grade saw.

The gradient is now a **ramp**, not a two-colour screen:

- **`gradient_ramp(top, bottom)`** builds a ramp of several master-palette colours between the two
  endpoints — each step the nearest palette match to an even RGB interpolation — so the sky steps
  through intermediate colours instead of mixing only the two ends.
- **`gradient_pixel(ramp, x, y, h)`** dithers only across the thin seam between two **adjacent** ramp
  colours, and the dither threshold is **value noise (`hash2`)**, not a fixed ordered grid.

Because each dither now mixes two near-identical neighbours chosen by noise — not a rigid 50/50
screen of the two far-apart endpoints — a transition reads as a soft grain, and there is no repeating
period for the eye to lock onto as a grid. Most of the sky is solid palette bands; only the hairline
seams between them carry any grain at all.

This is **code-first**: no art is repainted, only `tools/art/tilegen.py` and the 11 committed
`*_far.png` it regenerates. The output is deterministic (`hash2` is pure), so the PNGs do not churn on
a re-run. The pass-501 atmosphere shader still desaturates and fades these layers on top, so the two
fixes compound: the backdrop recedes (501) and no longer carries a screen-door (502).

## Why not keep a dither at all

A pixel sky is palette-locked (bible 12.2/12.3): a gradient cannot blend to arbitrary RGB, so some
dither between the few available shades is unavoidable. The defect was never "dither exists" — it was
the **rigid grid** and the **two-colour contrast**. Ramping through intermediate palette colours drops
the per-seam contrast to near-nothing, and a noise threshold removes the period; together they turn a
screen-door into grain. Switching to a larger ordered (Bayer) matrix would only trade a small grid for
a bigger one, so noise is the right call for killing moire.

## Checks

- **Verified by eye** at 1x, old vs new, on the raw far layers (spires, boughs, evercrown, and the
  before/after pair) and **in-game** (spires/roost, evercrown/drift_well, with the atmosphere shader
  and the gameplay layer in frame): the dot-screen and the hard banding seam are gone; the backdrop
  recedes as a clean gradient and the lit tiles, rain and actors pop.
- **`tools/art/test_tilegen.py`** (7 checks) guards the helpers: the ramp is palette-locked, steps
  through ≥3 colours between far-apart ends, sits on its endpoints, has no repeated neighbours; a
  solid band is fully solid; a seam mixes only its two neighbours; and the dither has **no fixed
  x-period** (the moire signature). The game suite is Godot-only and CI runs no Python unit tests, so
  this is a local art-tool guard — run it with `python tools/art/test_tilegen.py`. Mutation-checked:
  collapsing the ramp to two colours fails the multi-step check, and restoring the ordered grid pushes
  the shift-4 repeat rate to 1.00 and fails the no-grid check.
- Full local Godot suite green (below); CI test + mix green; no test loads the backdrop PNGs, so the
  regenerated art does not touch the suite.

## Rubric (design bible 15.3)

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged; actors still read against a quieter backdrop. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 91 | The sky screen-door is gone across every zone, so the backdrops read as painted depth, not a moire mesh. With pass 500's rim shading and pass 501's atmospheric perspective, the environment art is close to cohesive; the hero and guardian HD bases remain the open gap (gated art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Pure asset change; no runtime cost. |
| Story and world | 5 | 99 | Unchanged. |

Weighted: 97.8.

## Next

Pass 503: the art loop stays gated on Sean — three guardian bases (Haar Wyrm, Thane Vorrund, Drowned
Warden) wait for his OK, the limit of three, so no new base can be made until he approves one. Until
then, the next unblocked grade defects, code-first: **tile variants / grid banding** (brick and wall
fields still tile obviously — add atlas variants so the repeat unit stops reading) and the **flat grass
fringe** (a single bright-green band on floors and ledges; give it a shaded ramp, a darker under-edge
and per-tile variation). Both are self-contained wins in `tilegen`. The **empty midgrounds** and **flat
directionless lighting** defects are larger room-and-decor work for a later pass. The hero sprite (the
grade's top defect) needs PixelLab and would be a fourth base — held until a slot frees.

For Sean (carried from pass 498, still open): the rain sheet won, so the **Haar marshes** could take a
thin, slow drizzle to suit the fog, and the High Boughs an even fainter mist-rain — say the word and a
pass wires it in.
