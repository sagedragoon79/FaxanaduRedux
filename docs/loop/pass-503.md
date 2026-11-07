# Pass 503: shade and vary the grass fringe on floors and ledges

## Category

Art / World, from the independent-grade queue — not the rubric rotation. Art outranks the rotation
when the queue holds no fresh Sean note (none this pass; all three notes are answered), and the
headline art item (the PixelLab guardian bases) is **blocked**: three bases already wait for Sean's OK
(Haar Wyrm, Thane Vorrund, Drowned Warden), the limit of three, and no note frees a slot. The hero
sprite (the grade's top defect) would be a fourth base, also over the limit. So this pass takes the
next unblocked, code-first grade defect — one of the two pass-502's "Next" named for pass 503 — the
**flat grass fringe**, flagged at the pass-500 grade:

> The grass fringe on floors and ledges is one flat bright-green band with no shading or variation,
> cheapening otherwise-moody rooms (haar_lampwick, deep_roots, source_hall). Give it a shaded ramp,
> a darker root/under edge and a little per-tile variation; code-first.

No generations and no base-approval gate; it touches every moss-capped zone.

## What was built

The green (or, in water zones, cyan) fringe on the top of every ground tile is the code-drawn
`cap_moss` in `tools/art/tilegen.py`, shared by all eight moss-capped zones (gym, heartwood, haar,
boughs, vorrhallow, evercrown, sunken, spires). The old version painted its **top two rows in the
single brightest shade** of the light ramp and only dropped a shade near the base — so a run of ground
tiles rendered as one uniform bright stripe. That is the band the grade saw.

`cap_moss` now paints lit grass, not a stripe:

- **A value ramp down each blade.** Only the taller, lit blades carry the brightest shade on their very
  **tip**; the body steps down shade by shade (`top-1`, `top-2`, `top-3`) to a **dark root line**
  (`top-4`, clamped at the ramp floor) where the grass roots into the soil. The bright pixels are now
  sparse tips, not a solid top row, so the fringe has top-light and a shadowed base.
- **Per-tile variation.** Each tile takes a value shift from its seed — lush (0), normal (−1) or sparse
  (−2) at roughly 45 / 35 / 20 % — so a floor reads as patches of deeper and brighter grass instead of
  one continuous band. A per-blade jitter deepens the odd column within a tile.

This is **code-first**: no art is repainted, only `cap_moss` and the **eight** moss-capped
`assets/tiles/<zone>.png` it regenerates. The stone-cap (hearthroot, trials) and girder-cap (tower)
zones are untouched, and the parallax backdrops are untouched.

## A determinism gotcha, handled

On this PC a full `python tools/art/tilegen.py` run re-encodes **every** tileset and `<zone>_mid.png`
with byte-different PNG bytes but **pixel-identical** output (a Pillow encoding difference, not a real
change). Committing that churn would bury the real diff. So each regenerated PNG was compared to `HEAD`
pixel-by-pixel, and only the files with a non-zero pixel diff were kept — the eight moss tilesets,
2410–2856 changed pixels each. Every byte-only file (all ten `*_mid.png`, plus hearthroot / tower /
trials tilesets) was reverted with `git checkout`. The PR carries only real pixel changes.

## Checks

- **Verified by eye** at 1x (actual game zoom) and 4x, old vs new, in the three rooms the grade named —
  `heartwood/deep_roots` (green, `top`=4), `sunken/source_hall` (cyan, `top`=3) and `haar/lampwick`
  (green, `top`=3). The green floor now reads as shaded patches of lush and sparse grass with lit tips
  and a dark rooted base, not a uniform bright line; the cyan ledge rim varies along its length without
  muddying, and the separate waterline is untouched; haar (already a dim fog green) gains subtle
  variation with no regression.
- **`tools/art/test_tilegen.py`** (now 10 checks, 3 new) guards `cap_moss`: the cap ramps through ≥3
  shades, the lowest painted row is darker than the highest (tips lit, root dark), and the per-tile
  value shift spans ≥1 shade across a dozen seeds. The game suite is Godot-only and CI runs no Python
  unit tests, so this is a local art-tool guard — run it with `python tools/art/test_tilegen.py`.
  Mutation-checked: setting `tilt` to 0 drops the per-tile spread to 0.27 and fails the variation
  check; flattening the body ramp to one shade fails the ramp and root-line checks.
- Full local Godot suite green (below); CI test + mix green; no test loads the tileset PNGs, so the
  regenerated art does not touch the suite.

## Rubric (design bible 15.3)

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 92 | The grass fringe is shaded and varied instead of a flat bright band, so floors and ledges read as lit grass rather than a stickered strip. With pass 500's rim shading, pass 501's atmospheric perspective and pass 502's softened sky, the environment art keeps tightening; the hero and guardian HD bases remain the open gap (gated art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Pure asset change; no runtime cost. |
| Story and world | 5 | 99 | Unchanged. |

Weighted: 97.95.

## Next

Pass 504: the art loop stays gated on Sean — three guardian bases (Haar Wyrm, Thane Vorrund, Drowned
Warden) wait for his OK, the limit of three, so no new base can be made until he approves one. Until
then, the other code-first grade defect pass-502's "Next" named: **tile variants / grid banding** (brick
and wall fields still tile obviously — add atlas variants in `tilegen` so the repeat unit stops
reading). After that, the larger room-and-decor defects — **empty midgrounds** and **flat directionless
lighting** — and the **zone-to-zone incoherence** (unify outline weight and light direction across zone
tilesets, pull base hues toward the master palette). The hero sprite (the grade's top defect) needs
PixelLab and would be a fourth base — held until a slot frees.

For Sean (carried from pass 498, still open): the rain sheet won, so the **Haar marshes** could take a
thin, slow drizzle to suit the fog, and the High Boughs an even fainter mist-rain — say the word and a
pass wires it in.
