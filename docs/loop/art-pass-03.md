# Art loop pass 3: the Haar's foes

Batch 2 of the enemy art loop (Sean, 2026-11-05): the four foes of the Haar remade in PixelLab
to `docs/art/enemy-style-guide.md`, with the Shade Knight (pass 1) as the reference. Art files and
`_draw` hookups only: no AI, timing or numbers changed.

## Before

- **Lantern Ghost**: flat code rectangles (a shroud built row by row in `_draw`).
- **Bog Puffcap, Drowned Dwarf, Marsh Hag**: castgen rig sheets, coarser than the hero.

## After

Each foe is a PixelLab `create-character-v3` base (side view) with pixminimax clips made from its
east view, so every state shares one model. The zone's mood (bible 12.2): grey-green, bone and
lantern yellow, with one hostile accent each.

| Foe | Height | Base canvas | Animations |
|-----|--------|-------------|------------|
| Lantern Ghost | 26 (small, flier, anchored on its middle) | 128 | idle 8, lunge_tell 6 (claws drawn back by the hood), lunge 4, fade 6, hurt 1, death 5 |
| Bog Puffcap | 26 | 128 | idle 6 (gills dark), windup 4 (cap swollen, gills lit: the tell), burst 2, spent 8 (cap sagging open), hurt 1, death 5 |
| Drowned Dwarf | 32 | 256 | idle 8, walk 8, sunk 2, rise 8, sink 8, heave 6 (anchor hoisted: the tell), slam 2, mired 4, stagger 5, hurt 1, death 7 |
| Marsh Hag | 36 to the crook | 128 | idle 8, walk 7, hex 4 (staff raised: the tell), cast 3, fumble 8 (staff dropped, groping), stagger 2, hurt 1, death 6 |

- **Ghost**: drawn with `Sheet.draw` at the fog's alpha (`seen`), as the old drawing was, so it still
  shows only near light. Its eyes are in the art; the wind-up's flare is code, drawn at the eyes.
- **Puffcap**: the spore cloud stays code (`SporeCloud`). The cap point the cloud bursts from is
  the code rig's metadata, carried over by the importer; it sits in the new cap.
- **Dwarf**: PixelLab draws a crouch, not mud, so the new `tools/art/mire_frames.py` cuts the mire
  frames from the sink clip: each kneel frame pushed below the ground line and clipped there
  (sunk shows the helm's crown; rise and sink play it up and down). The bubbles stay code.
  He was too dark against the fog in the grayscale check, so he gets a `gain` and a bone rim.
- **Hag**: the green marsh-wisp stays code, now drawn at the art's crook per animation
  (`CROOK`); the wisp's light node is where it was. She also gets a `gain` and a bone rim.
  The stagger and hurt are the reel-back at the start of her death clip; the stagger clip
  drifted into a front view and is not used.
- Every script plays its collapse under the dissolve (`anim_now`, `_died_at`), as the knight does.

## Retakes

- The first Bog Puffcap base drew a toad under a toadstool (`base_toad/`). The retake says "only
  a mushroom, no animal".
- The first Marsh Hag base held two staffs, one through her body (`take1/`, with its clips).
  The retake says "one single staff in her front hand".

## Cost

51 PixelLab generations (budget about 120): ghost 7, puffcap 10, dwarf 17, hag 17, both retakes
included. Job slots were shared with the other batch threads, so clips queued behind 429s.

## Review

- `test_the_haars_foes_play_an_animation_for_every_state` (tests/test_enemies.gd): every state of
  the four plays an animation the sheet has, each tell is its own pose, a blow makes each flinch,
  and each collapses under the dissolve.
- Images: `/mnt/project-files/art-loop/haar/` (lineup before and after, Lampwick Causeway and the
  Marsh Road before and after, an animated sheet), and per foe in `art-loop/<foe>/`.

## Rubric

Art cohesion moves for four foes of about 40; the score stays as the gameplay loop last set it.
