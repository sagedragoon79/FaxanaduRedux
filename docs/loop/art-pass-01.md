# Art loop pass 1: the style guide and the Shade Knight

The second improvement loop (Sean, 2026-11-05) is for foes, guardians and their animations.
Its passes are numbered on their own (`art-pass-NN.md`) so they never collide with the
gameplay loop's `pass-NN.md`.

## Audit

`tools/art/lineup.tscn` (new) draws every foe and guardian in every state its script sets or
matches, at 2x, one row each (`/mnt/project-files/art-loop/roster-audit-lineup.png`). Three tiers:

- **HD, at the hero's level:** Hornet, Rot Dwarf, Iron Dwarf, the Foreman, Durgan, Gloamweaver,
  Gnarlmaw's parts (Autosprite) and now the Shade Knight (PixelLab).
- **Rig sheets** (castgen, readable, coarser than the hero): Blinkhop, Bog Puffcap, Bark Knight,
  Drowned Dwarf, Gear Bat, Grub Lump, Marsh Hag, Minecart Rider, Sap Spitter, Seed Bomber.
- **Flat code rectangles** (`draw_rect` shapes, no sheet): Clockwork Hound, Crystal Dwarf, Lantern
  Ghost, Leaf Mantis, Glass Slug, Mothling, Silt Adder, Spire Sentinel, Spring Eel, Storm Harpy,
  Thunder Beetle; guardians Bark Captain, Clockwork Alpha, Drowned Warden, the Everbloom's three
  forms, the Haar Wyrm, the Hag Matriarch, the Likeness, Skyrend, Snapcrown, Thane Vorrund.

## Style guide

`docs/art/enemy-style-guide.md`: design rules (original, one idea per silhouette, zone colours),
scale classes, rendering done by the importer (outline, palette, rim), the animation set with frame
counts and rates, telegraph rules (the art draws the pose, the code the flash), the PixelLab recipe,
the review checklist and the generation budget. Threads that remake foes in parallel work to it.

## The Shade Knight

Before: about 30 rectangles drawn in `_draw`, a blade line and a code shield.
After: a PixelLab knight, the drowned ghost of a dwarf royal guard in teal plate with a glowing
eye slit, a tower shield and a shortsword, 40 px, the hero's density and outline.

- Base: `create-character-v3`, side view, 256 px (9 generations). Clips: pixminimax, east. The first
  takes made from the base drifted between two models (shield behind the body in the idle, in front
  in the walk's second half), so idle, walk, thrust, cut and winded were made again from one frame of
  the walk where the shield is up in front (`base/guard.png`, `custom_start_frame`). The stagger and the
  death keep the base's view; the hurt is the stagger's first recoil. 27 generations in all (clips cost 1 for 8 frames, 2 for 12).
- Ten animations: idle 8, walk 8, thrust_tell 4 (drawn back), thrust 4 (smear, lunge), cut_tell 4
  (raised), cut 4 (smear, cut), winded 10 (shield and point sagging), stagger 6, hurt 2, death 8.
- `ShadeKnight._draw` plays them by state (`anim_now`): hurt while in hitstun, stagger while
  reeling, and the collapse under the dissolve after death (it keeps redrawing while it dissolves).
  The cold light at the blade's point in a tell stays code, placed at the art's point per tell.
- `pixellab_sheets.py` gains `ENEMY_SHEETS`; its grey-slab cleaner removed the flat grey patches the
  thrust's lunge left beside the helm and touched no other frame.
- Images: `/mnt/project-files/art-loop/shade_knight/` (before and after in the Drowned Nave, the
  lineup, an animated sheet of every animation).

## Rubric

Art cohesion moves only for one foe of about 40; the score stays as the gameplay loop last set it.
Next: split the roster into batches by zone for parallel threads, each reviewed against the guide.
