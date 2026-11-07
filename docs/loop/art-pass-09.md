# Art loop pass 9: the Haar Wyrm steam base — the far horn curls forward now

Game version: v1.1.0 (Mono). Last updated: 2026-11-06.
Covers: the Haar Wyrm head base redrawn as a steam-and-bone wyrm with the three-quarter far horn
fixed (Sean's note e20c6ea1), and a new prompt-craft rule for multi-part creatures.

## Sean's note

On the pass-8 review picture (`shots/haar-wyrm-base-for-approval.png`) Sean left a **Fix this** on
the south-east three-quarter: *"The 3/4 view is off. The far horn is curled backward instead of
toward the muzzle."* In the old base the near horn hooked forward over the brow while the far horn
curled back the other way, so the pair read wrong. Pass 499 also re-cast the guardian as **steam and
bone**, not fog, so the base was due a redraw anyway (it was the superseded fog look).

## The redraw

Both go together: a fresh **pro** base (`create_character`, 8 directions, 112 px, side), its prompt
written so both horns hook forward in every view and the head reads bleached and steam-scoured.

- **A false start, and a new rule.** The first retake (`ce2606ee-…`, 15 generations) asked for "a
  three-headed bone-and-steam serpent's head" and PixelLab drew the whole beast — two and three heads
  fused on one neck. Discarded. The lesson is now in the style guide (step 1c): **name only the part
  the sprite is, not the multi-part creature** — the Haar Wyrm's heads, necks and coil are code, so
  the sprite is "a single dragon-serpent head, one head only", never "a three-headed serpent".
- **The kept base** (`23a1a8fb-e2b6-4454-b3b6-6cd706c693e1`, group `cf6b825e-…`, 15 generations;
  balance 106.0 → 76.0, no credits). One head: a long bone-pale snout and brow, grey-green scaled
  neck, a fanged jaw, bone spines down the nape, one lantern-yellow eye. **Two thick bony horns rise
  from the crown and both curve forward over the brow toward the muzzle** — a matched forward-hooking
  pair in the east profile and the south-east three-quarter alike, so the far-horn complaint is
  answered and the two views agree. Paler and more bleached than the fog base: steam-and-bone, not
  grey fog. The `east` rotation is a clean right profile with the face in view, so it is
  `base/guard.png` (facing check, step 1a, passed first try). Sources overwrite
  `art/pixellab/bosses/haar_wyrm/base/`; the fog base (`bdc95683-…`) is superseded.
- **Review picture** rebuilt at `shots/haar-wyrm-base-for-approval.png` (east profile and south-east
  three-quarter at 1x and 4x, the hero at rough scale) by the new committed tool
  `tools/art/base_review.py`, and deployed to the hosted Shots tab. **No animation, and no change to
  `haar_wyrm.gd`, until Sean approves this base.**

The open question from pass 8 still stands for Sean when he reviews: keep the guardian's three heads
code-drawn (this base becomes a portrait/intro look only), or move the solid head to the sheet while
the coil and necks stay code? That decision shapes the clips this base feeds.

## Budget

Balance at the top of this pass: **106.04** generations + 50 USD credits. This pass spent **30**
generations (15 on the discarded multi-head retake, 15 on the kept base), leaving **76.04 + 50 USD**.
Credits untouched; the next guardian bases (Thane Vorrund, then the Drowned Warden) fit comfortably
before the 2026-11-28 refill.

## Rubric

No in-game change ships this pass (the base gates on Sean's approval), so the scored categories are
unchanged from the pass-497 independent grade (5.3/10, recorded in `grades.json`). The art goal
(bible 12.0) is the live bar; this pass moves the first guardian a step closer and leaves it with
Sean.

| Category | Note |
| --- | --- |
| Art and cohesion | Base only, not yet in-game; held at the pass-497 grade. |
| Characters and foes | Haar Wyrm base redrawn, far-horn note answered, awaiting approval. |

## Next

Hold for Sean's OK on the Haar Wyrm steam base. While it waits, make the next guardian base in order
— **Thane Vorrund** — then the Drowned Warden (no more than three waiting at once), and otherwise the
non-art queue: the VFX-tool trial on one code effect, and the pass-497 grade's defects (the hero
sprite, flat lighting/AO, depth and tile repetition). A fresh note from Sean outranks all of it.
