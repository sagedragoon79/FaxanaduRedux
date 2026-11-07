# Art loop pass 11: the Drowned Warden base — the stone colossus of the spring

Game version: v1.1.0 (Mono). Last updated: 2026-11-07.
Covers: the Drowned Warden base (`create_character` pro, 8 directions, for Sean's approval), the third
guardian base in order while the Haar Wyrm and Thane Vorrund bases wait.

## The pass

The Haar Wyrm (art pass 9) and Thane Vorrund (art pass 10) bases are both still under Sean's review —
two of the three bases allowed to wait at once (guide step 1d). So this pass makes the **next guardian
base in order — the Drowned Warden** (bible 8.10), bringing the waiting count to the limit of three. No
new look or behaviour ships in game, so nothing is graded.

## The base

- **One pro call** (`create_character`, `mode: pro`, 8 directions, 112 px, `view: side`,
  `body_type: humanoid`, `template_id: mannequin`), character
  `dd60fb96-8abd-4355-ae75-cce3ecb45328`, **15 generations**, no retake. Sources in
  `art/pixellab/bosses/drowned_warden/base/` (the eight named rotations, `guard.png`, `result.json`,
  `queued.json`).
- **The design** (bible 8.10, `drowned_warden.gd` header): the guardian the first dwarves built to keep
  the source of every spring — a colossus of **pale weathered limestone** and **green verdigris bronze**,
  a **horned dwarf-king's iron helm**, **cyan spring-light** for eyes and a **round cyan lamp set in its
  chest** (the one opens on the spring's light for the phase-3 Undertow), both great hands gripping a tall
  **three-pronged bronze trident** held upright. The hardest fight in the game and the only one fought in
  water. The stone legs and arms read cracked and water-stained; the verdigris plates armour the chest,
  shoulders and forearms; the cyan eyes and chest lamp are the only bright accents (bible 12.2, the Sunken
  Spring's pale stone and cyan light).
- **Prompt craft held (guide step 1c).** Every prop was named by what holds it and where — the helm on its
  head, the trident gripped in both hands and held upright with the prongs up, the lamp set into the centre
  of its chest — one prop per sentence, each glow given a colour (cyan), with "nothing else floats around
  it; one single figure only". The result came back clean: no stray or wandering props in any of the eight
  rotations, no duplicate figure, no reroll needed.
- **Facing check passed first try (guide step 1a).** PixelLab's `east` rotation is a true right-facing
  near-profile — the face with its cyan eyes, the horned helm and the trident all reading on the right,
  the figure turned to fight right — so it is `base/guard.png`. `west` mirrored is an equally clean
  profile (kept as the fallback). The `south-east` rotation is a warm front-facing three-quarter turned
  toward the camera, both horns and eyes and the centred chest lamp showing, for the still poses (idle,
  rest, the rise-from-the-deep intro). The `north-east`/`north-west` back views correctly show the cracked
  stone back, not a second face.
- **Review picture** at `shots/drowned-warden-base-for-approval.png` (east profile and south-east
  three-quarter, 1x and 4x, the hero for scale), deployed to the hosted Shots tab. **No animation, and no
  change to `drowned_warden.gd`, until Sean approves this base.**

## Budget

Balance at the top of this pass: **51.04** generations + 50 USD credits. This pass spent **15**
generations (one base, no retake), leaving **36.04 + 50 USD**. Credits untouched. The third of three
allowed bases now waits, so no further base is made until Sean approves one of the three. The next base in
order after the Drowned Warden is the **Marsh Hag Matriarch** (bible 8.10 mini-bosses); at ~15 generations
a pro base it fits the remaining balance with room for a retake, once a waiting slot frees.

## Rubric

No in-game change ships this pass (the base gates on Sean's approval), so the scored categories are held
at the pass-497 independent grade (5.3/10, in `grades.json`). The art goal (bible 12.0) is the live bar;
this pass moves the third guardian a step closer and leaves it with Sean. The base reads strong — a clear
colossal silhouette (horned helm, broad shoulders, upright trident), clean material separation (pale stone
against verdigris bronze) and a single bright accent (the cyan eyes and chest lamp).

| Category | Note |
| --- | --- |
| Art and cohesion | Base only, not yet in-game; held at the pass-497 grade. |
| Characters and foes | Drowned Warden base drawn, props clean, facing passed first try; awaiting approval. |

## Next

Hold for Sean's OK on the Haar Wyrm, Thane Vorrund and Drowned Warden bases (three now waiting, the
limit). No further guardian base until one is approved. While they wait, the non-art queue: the VFX-tool
trial on one code effect, and the pass-497 grade's defects (the hero sprite's fidelity gap, flat
lighting/AO, depth and tile repetition). A fresh note from Sean outranks all of it.
