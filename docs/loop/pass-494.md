# Pass 494: The Evercrown's stillglass lifts off its foes

## Category

Art cohesion, from the workbench queue (Sean's standing note: "Evercrown: the cyan stillglass spikes read
as stamped over foes; separate them from foe silhouettes"). The headline queue item, the PixelLab art pass
for the seven placeholder guardians, is still blocked — `PIXELLAB_API_KEY` is set in no scope on this PC — so
this pass takes the next non-art item, a code-drawn readability fix that needs no generations.

## Audit

Every foe in an Evercrown room is `corrupted` (bible 8.9): the `CorruptionGrowth` node draws cyan stillglass
shards up through the foe's back, red veins and a beating eye, over whatever the foe itself draws. The shards
were flat solid-cyan triangles with a hard highlight and a near-black outline (`OUTLINE` 13101f, the same the
foes use). Captured on a corrupted Clockwork Hound and Storm Harpy in `evercrown/proving_scar`, they read
exactly as the note says: flat decals stamped over the body, with no light cast on the foe and no depth where
the glass meets the skin, so the shard shared the foe's silhouette instead of standing out from it.

## Bug found

No crash — a readability defect. The glass carried no separation cue: no cast light to lift it off the body,
no socket to root it, and an outline the same colour as the foe, so against a dark or busy foe the cyan sat on
the surface like a sticker rather than growing through it.

## Fix

`scripts/enemies/corruption_growth.gd` now gives each shard two separation cues and shares its geometry with
the test:

- **Cast light.** A soft three-ring cyan glow falls off outward from each shard onto the body, reaching
  `GLOW_MARGIN` (5 px) past the shard's own width and brightening a touch on the Everbloom's beat. The glass
  now reads against any foe silhouette, the same light language the sibling `CrystalSpike` and `LightVein`
  already use.
- **A socket.** A dark translucent disc where the shard breaks the skin, plus a `SHARD_DARK` wash over the base
  third of the shard, so the lit tip stands clear and the glass reads as grown out of the flesh, not onto it.
- The eye on the flank gets the same faint cast light for consistency.

The per-shard layout (base, tip, width, glow centre and radius) moved into a pure `shards()` method that
`_draw` and the test both call, so the on-screen separation is the one under test.

Proof: before/after captures of the corrupted Clockwork Hound and Storm Harpy in `evercrown/proving_scar`
(`--shot-at`, off-screen window, this PC, no xvfb). Before, the shards are flat cyan triangles; after, they
glow off the body and sink into a socket, reading as glass through the foe.

## Test

`test_corrupted_shards_lift_off_the_foe_silhouette` (in `tests/test_enemies.gd`): a corrupted foe grows three
back-shards; each shard's cast light reaches past its own width (the separation margin), the light falls along
the shard between base and tip, the light is translucent rather than an opaque patch, and a dark socket marks
the skin. Mutation-checked: zeroing `GLOW_MARGIN` fails 4 checks, zeroing `GLOW_ALPHA` fails 1. The design
bible's Evercrown corruption bullet (8.9) gains the pass-494 note.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 85.25 | The Evercrown's corrupted foes read as glass-through, not stamped-on. |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8875.

## Next

Pass 495: Stability (the next rubric category in the rotation). The art loop's guardian pass stays blocked
until `PIXELLAB_API_KEY` is set on this PC and the app is restarted.
