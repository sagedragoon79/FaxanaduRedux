# Art loop pass 5: the Carillon foes (batch 4)

Thunder Beetle, Storm Harpy and Spire Sentinel, remade to `docs/art/enemy-style-guide.md` with the
Shade Knight (pass 1) as the reference. Art and `_draw` hookups only: no AI, timing or numbers changed.

## Before

All three were flat code rectangles (`_px` and polygons in `_draw`): a violet dome on six stick legs,
a box-bodied harpy with polygon wings, and a stone knight of about twenty rectangles with a halberd line.

## After

Each is a PixelLab `create-character-v3` base (side view, 256 px, 9 generations) and pixminimax clips,
east, every clip started from one frame of its base (`custom_start_frame`) so every state shares one model.

- **Thunder Beetle** (24 px tall, standard-small): storm-violet chitin with gold bands and copper horns.
  The custom-body base's "south" rotation is its true side profile, so the clips start from it. idle 8,
  walk 8, charge 6 (the wing cases lift: the tell), discharge 4 (cases wide, gold wings fanned), spent 6
  (made from the charge's open frame: cases sag open, the opening), hurt 2, death 7 (rolls onto its back).
  The static sparks and the lightning ring stay code, the sparks now just over the shell (`SPARK_Y`).
  A violet rim (`"rim"`) keeps the dark shell off the Spires' dusk walls.
- **Storm Harpy** (40 px with wings, a flier, anchored on her centre): slate and violet wings, storm-white
  hair, gold eyes and talons. Her base's "east" view turned her back to the camera, so the clips start from
  her "south-east" view (the side profile with her face). hover 8 at 16 fps (the wingbeat), windup 4 (wings
  flung wide: the tell), throw 3 (the wingbeat that flings the feathers; the clip's baked sparkles are left
  out by `pick`), recover 7 (winded, wings drooping, also shown while reeling), hurt 2, death 8 (tumbles
  down; the first two frames baked in a red slash and are left out).
- **Spire Sentinel** (42 px with its halberd tip, the body on its 38 px hitbox): the base came out as
  steel plate twice (the retake dropped the cape and kept the halberd clear of the body), so its
  side-profile frame was recoloured to pale lilac shrine stone with the gold glyph kept
  (`tools/art/stone_tint.py`, `base/guard.png`) and every clip was made from that frame. idle 1 (a statue
  holds still), stalk 8, raise 4 (the halberd lifted over its shoulder: the tell), slam 3 (6 its smear),
  spent 4 (the blade buried in the floor), stagger 7, hurt 2, death 9 (crumbles to rubble). The waking
  eyes, the glyph's blaze in the tell, the cracks while it is open and the grit it kicks up are code,
  placed on the art (`EYE`, `GLYPH_AT`, `SEAMS`).

All three play their death under the dissolve (`die` keeps redrawing, as the Shade Knight does).
`test_<foe>_plays_an_animation_for_every_state` checks every state maps to an animation of its sheet,
that the tell is not the idle, and the hurt, reel and death.

## Notes for review

- The guide's scale table lists the Spire Sentinel as large (48 to 64). Its hitbox is 38 px tall and the
  guide's rule is that the art matches the body, so it is drawn at 42 with the halberd: about the hero's
  height. Raising it means a taller hitbox, which is a gameplay change for another pass.
- The slam's art reaches about 20 px in front of its feet; its hitbox (`slam_rect`) reaches 52. Unchanged
  here (numbers are out of scope); a later gameplay pass can shorten the rect or the art can be retaken
  with a longer lunge.

## Cost

58 generations: three bases and a Sentinel retake (36), 22 for 17 clips. Balance after: 346 (shared
with the other batch threads).

Images: `/mnt/project-files/art-loop/{thunder_beetle,storm_harpy,spire_sentinel}/`.
