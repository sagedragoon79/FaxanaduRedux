# Art loop pass 8: the guardians begin — the Haar Wyrm head, and the rules for a base

The art loop turns from foes to the seven placeholder guardians (style guide, section 8). Sean set
the bar on 2026-11-06: Yldenfall should look **beautiful, on par with AAA pixel-art games** (Hollow
Knight, with Blasphemous, Dead Cells and Owlboy alongside), and gave full authority to spend the
PixelLab budget on it. This pass lays down the rules that batch work needs, and makes the first
guardian base — the Haar Wyrm — for Sean's approval before any animation.

## The rules, written down first

Four of Sean's 2026-11-06 decisions are now in the style guide and the bible, so every later pass
and any parallel thread follows them without being told again.

- **The art goal** is in the bible (`12.0 Art goal`): the AAA bar, that art outranks the rubric
  rotation, and that every art change is judged by eye at 1x and 2x against the style guide.
- **Facing** (style guide, section 3 and step 1a): anything that **moves** — walk, run, every
  attack, jumps — is a strict east/west profile (east the source, west its mirror). A **still**
  animation (idle, rest, talk, a guardian's intro or taunt) may use the **south-east three-quarter
  stance**, turned toward the camera, which shows the face.
- **Turn clips** (step 1b): a character with a still three-quarter pose and a moving profile gets a
  2-to-3-frame turn clip from the three-quarter base, played forward (still -> moving) and backward
  (moving -> still). PixelLab's drift in turn frames is **not** hand-fixed in the loop: the frames
  go to `art/cleanup/<character>/turn/` for Sean, listed on the workbench as ready for his cleanup.
  The importer now prefers `art/cleanup/<folder>` over the raw output, and never re-cleans a cleaned
  frame (`tools/art/pixellab_sheets.py`, `frames_of` / `is_cleaned`; `art/cleanup/README.md`).
- **Prompt craft for props** (step 1c): one prop per sentence, saying what holds it and where;
  scope a comparison to the part (`<creature>-style <part>`, never "like a `<creature>`", which
  turns the whole figure into that creature); keep a part's words physical; say what must stay
  clear; give a glow a colour, never *light*/*lamp*/*bulb*; and if a prop still wanders after one
  retake, generate the figure without it and inpaint, rather than reroll.
- **Base before animation** (step 1d): for each guardian, make only the base first (the east
  profile and the south-east three-quarter stance), save a review picture, deploy it, and wait for
  Sean's note before any animation. No more than three guardians wait at once.

## The Haar Wyrm head base

The Haar Wyrm (`haar_wyrm.gd`, bible 8.4) is a three-headed serpent of fog and bone, drawn
entirely in code: a rotating coil, bezier necks, and three identical heads whose solid one is
drawn pixel-by-pixel in `_draw_head`. The guardian's rig (the coil, the necks, the fog, the
dousing, the flood) is procedural and stays code; the part a sheet can carry is the **solid head**.

- **Base:** `create_character` **pro**, 8 directions, 112 px, side view (`character_id`
  `bdc95683-2f2c-4de5-843c-485b7e493e67`, group `feb421a7-...`). **15 generations** (balance
  168.1 -> 153.1; no credits spent). A horned serpent head: grey-green scaled hide, bone plates
  along the snout, a backswept bone crest and two horns, a fanged jaw, and one **lantern-yellow
  eye** as the hostile accent (the Haar zone's mood, style guide section 1). Prompt written to the
  step 1c rules; the base came back clean on the first take — no stray props, horns in place.
- The `east` rotation is a clean right profile with the face in view, so it is `base/guard.png`
  (the facing check, step 1a, passed on the first try — a change from the art pass 7 foes). Sources
  in `art/pixellab/bosses/haar_wyrm/base/` (the group's first boss folder).
- **Review picture:** `shots/haar-wyrm-base-for-approval.png` — the east profile and the south-east
  three-quarter at 1x and 4x, with the hero at rough scale. Deployed to the hosted Shots tab.

No animation, and no change to `haar_wyrm.gd`, until Sean approves the base. Open question for him
in the review and on the workbench: the head reads well as a sheet, but should the guardian keep
its code-drawn heads (and only gain this as a portrait/intro look), or move the solid head to the
sheet while the coil and necks stay code? That decision shapes the clips this base feeds.

## Budget

Start 168.1 generations + 50 USD credits; **15 generations** spent on the base; **153.1 + 50 USD**
left. Guardians are budgeted 60–100 generations each (style guide 8), so the credits are untouched
and the next guardian bases fit comfortably.

## Next

Hold for Sean's OK on the Haar Wyrm base. While it waits, make the next guardian bases in order —
Thane Vorrund, then the Drowned Warden (no more than three waiting at once) — and the non-art queue
items: the VFX-tool trial on one code effect, and the pass-497 grade's defects (the hero sprite,
flat lighting/AO, depth and tile repetition). A fresh note from Sean outranks all of it.
