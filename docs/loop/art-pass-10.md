# Art loop pass 10: the Thane Vorrund base — the grieving king, half crystal

Game version: v1.1.0 (Mono). Last updated: 2026-11-06.
Covers: the Thane Vorrund base (`create-character-pro`, 8 directions, for Sean's approval), the next
guardian in order while the Haar Wyrm base waits, and a small generalisation of `base_review.py`.

## The pass

The Haar Wyrm base (art pass 9) is still under Sean's review, so this pass makes the **next guardian
base in order — Thane Vorrund, the Unweeping** (bible 8.7) — per the base-before-animation rule (guide
step 1d; no more than three bases waiting at once, and only one waits now). No new look or behaviour
ships in game, so nothing is graded.

## The base

- **One pro call** (`POST /create-character-pro`, 8 directions, 128 px, `view: side`,
  `template_id: mannequin`), character `5c81af92-84c9-4414-8fbd-92c16a4da9c2`, **25 generations**, no
  retake. Sources in `art/pixellab/bosses/thane_vorrund/base/` (the eight named rotations, `guard.png`,
  `result.json`, `queued.json`).
- **The design** (bible 8.7, `thane_vorrund.gd` header): a broad dwarf king, a long braided grey beard
  to his belt, a flood-rotted deep-teal royal robe under a tattered gold-edged mantle, a dented iron
  crown. Jagged **magenta stillglass crystal** has grown across his back and shoulder and up through the
  crown — the one hostile accent, brighter than anything else on him (bible 12.2, Vorrhallow teal and
  stillglass magenta). Both hands grip a great two-handed battle-axe whose iron blade is crystal-touched
  along its lower edge. Tragic and regal, a weary bone-pale face.
- **Prompt craft held (guide step 1c).** Every prop was named by what holds it and where — the crown on
  his head, the axe in both hands, the crystal grown across his back — one per sentence, the glow given a
  colour (magenta), with "nothing floats around him". The result came back clean: no stray or wandering
  props in any of the eight rotations, no reroll needed.
- **Facing check passed first try (guide step 1a).** PixelLab's `east` rotation is a true right profile
  with the face, crown, beard and axe all reading on the right and the crystal on the far shoulder, so it
  is `base/guard.png`. `west` mirrored is an equally clean profile (kept as the fallback). The
  `south-east` rotation is a warm three-quarter turned toward the camera, for the still poses (idle, rest,
  the throne-room intro).
- **Review picture** at `shots/thane-vorrund-base-for-approval.png` (east profile and south-east
  three-quarter, 1x and 4x, the hero for scale), deployed to the hosted Shots tab. **No animation, and no
  change to `thane_vorrund.gd`, until Sean approves this base.**

## Tooling

`tools/art/base_review.py` was generalised off the Haar Wyrm: the subtitle and the rough-scale caption
are now optional arguments (the old build hardcoded "replace the drawn head in haar_wyrm.gd" and "a
guardian head sits a little taller than the hero"), and the swatch label reads "base" rather than "head".
Defaults keep the previous behaviour for any future base.

## Budget

Balance at the top of this pass: **76.04** generations + 50 USD credits. This pass spent **25**
generations (one base, no retake), leaving **51.04 + 50 USD**. Credits untouched. The next base in order
is the **Drowned Warden**; at ~25 generations a pro base it fits before the 2026-11-28 refill, with a
margin for a retake, and the credits stay in reserve for the guardians' animation batches.

## Rubric

No in-game change ships this pass (the base gates on Sean's approval), so the scored categories are held
at the pass-497 independent grade (5.3/10, in `grades.json`). The art goal (bible 12.0) is the live bar;
this pass moves the second guardian a step closer and leaves it with Sean.

| Category | Note |
| --- | --- |
| Art and cohesion | Base only, not yet in-game; held at the pass-497 grade. |
| Characters and foes | Thane Vorrund base drawn, props clean, facing passed; awaiting approval. |

## Next

Hold for Sean's OK on the Haar Wyrm and Thane Vorrund bases. While they wait, make the next guardian base
in order — the **Drowned Warden** — then the Marsh Hag Matriarch (no more than three waiting at once), and
otherwise the non-art queue: the VFX-tool trial on one code effect, and the pass-497 grade's defects (the
hero sprite, flat lighting/AO, depth and tile repetition). A fresh note from Sean outranks all of it.
