# Art loop pass 2: batch 1, the Heartwood and Hollin Tower foes

Five foes remade to `docs/art/enemy-style-guide.md`, with the Shade Knight (art pass 1) as the
reference: Sap Spitter and Grub Lump (Heartwood), Gear Bat, Minecart Rider and Silt Adder
(Hollin Tower). Only art and `_draw` hookups changed; no AI, timing or numbers.

## Before

The Sap Spitter, Grub Lump, Gear Bat and Minecart Rider were castgen rig sheets (readable,
coarser than the hero, two to four frames a state). The Silt Adder was code-drawn: a line-segment
body with a polygon hood.

## Made

Each foe is one PixelLab character (`create-character-v3`, side view, `template_id` `custom`,
single color black outline, high detail) and pixminimax clips made from its own east view, so
every state shares one model. Canvas by size class: 128 px for the three small foes, 160 for the
cart, 192 for the serpent (each source at least twice its world height).

| Foe | Look | Height | Animations (frames) |
|-----|------|--------|---------------------|
| Sap Spitter | gnarled bark stump on twisted roots, a glossy amber sap sac, cyan fungus | 22 | idle 8, windup 4 (sac swollen bright), spit 3, hurt 1, death 5 |
| Grub Lump | fat grub with overlapping bark plates, pale belly, cyan spots, amber mandibles | 14 | crawl 8, windup 6 (reared, bunched), drop 1 (curled ball), land 2 (on its back, open), hurt 1, death 3 |
| Gear Bat | riveted dark-iron clockwork bat, leather wings, lamp-orange eyes, brass axle | 28 | fly 8, bare 8, windup 6 (hunched, wings high), roost 7 (hanging), stagger 2, hurt 1, death 4 |
| Minecart Rider | soot-bearded dwarf in a battered helmet, in a rusty riveted ore cart | 38 | roll 8, rev 6 (hauling the brake), charge 7 (ducked low), crash 8 (tipped, rider dazed), recover 1, stagger 2, hurt 1, death 5 |
| Silt Adder | verdigris hooded serpent with copper bands and a bone belly | 44 | float 8, coil 4 (hood flared), strike 3 (jaws wide), stagger 2, hurt 1, death 6 |

- **Effects left out.** The clips baked in a few effects (a sap glob, a burst spray, a slash
  arc, a smear behind a blow). Those frames are skipped with `pick`, so the glob, the gear and
  every flash stay code (guide 3).
- **The Gear Bat's gear is code.** The art draws the brass axle bare; `GearBlade.draw_gear` (the
  thrown gear's own drawing, now static) draws the gear on it at 0.85 size while the bat has it,
  whirring fast in the tell. So `bare` is the same wingbeat with no gear, one model throughout.
- **The roost is the folded-wing clip turned upside down** (`gear_bat/roost_hang`, no PixelLab
  call): it hangs from the ceiling by its feet.
- **Rim and gain** on the Gear Bat (lamp orange), the only dark foe of the five, so it stands off
  the Tower's dark walls.
- **The Grub Lump's drop** is the clip's curled ball; its face turns a little toward the camera in
  that one frame. It shows for the half second of the fall only.
- Each script gains `anim_now()` (death under the dissolve, stagger, hurt in hitstun, then the
  state's own pose) and keeps redrawing while it dissolves, as the Shade Knight does. Tells still
  flash with `draw_sheet(..., white)`.
- The Silt Adder gets a castgen placeholder sheet (`autosprite_only`), centred on its body.
- Test: `test_batch_one_foes_play_an_animation_for_every_state` (every state of all five plays an
  animation of its sheet; each tell its own pose; hurt, death).

## Cost

40 PixelLab generations: 20 for the five bases (3, 3, 3, 5 and 6 by canvas size) and 20 for
18 clips. No retakes were needed. Budget for this batch was about 130.

## Review

Images in `/mnt/project-files/art-loop/<foe>/` (before and after lineups, in-game shot, an
animated sheet of every animation) and `/mnt/project-files/art-loop/batch1-lineup.png`.

## Rubric

Art cohesion moves for five foes of about forty; the score stays as the gameplay loop last set it.
