# Art loop pass 6: the foes of Vorrhallow and the Sunken Spring

Batch 5 of the art loop: the Clockwork Hound, the Crystal Dwarf, the Glass Slug (`meteor_slug`)
and the Spring Eel, remade to `docs/art/enemy-style-guide.md` with the Shade Knight (pass 1) as
the reference. Only art, sheets and `_draw` hookups changed: no AI, timing or numbers.

## Before

All four were flat code drawings: `_px` rectangles (Hound, Slug), `draw_rect` and polygons
(Crystal Dwarf) and a chain of circles (Eel), one pose per state, with no hurt, stagger or death
art.

## After

Each is a PixelLab character (`create-character-v3`, side view, 256 px) with pixminimax clips
(east) made from one start frame, so every state shares one model (guide 6, step 2a).

| Foe | Base | Height (world px) | Animations |
|-----|------|-------------------|------------|
| Clockwork Hound | 2742be26, `dog` template | 30 (small to standard; its body 18 under the ears and key) | idle 8, trot 8, wind 4 (the crouch), pounce 4 (the leap, jaws open), skid 5 (the landing), stagger 10 (on its back, legs kicking), hurt 2, death 9 (springs and gears burst, it falls on its side) |
| Crystal Dwarf | 36bb2e01, `mannequin` | 34 (standard) | idle 8, walk 8, windup 4 (the crystal fist raised), rooted 4 (driven into the floor), recover 2, hurt 2, stagger 4, death 7 (to his knees, then face down) |
| Glass Slug | a1e66369, no skeleton | 26 (small) | idle 8, crawl 8, swell 4 (reared, cracks blazing), recover 6 (the heave, then slack), hurt 2, stagger 4, death 8 (the shell cracks, the body melts flat) |
| Spring Eel | ca0abb11, no skeleton | 10 thick, about 38 long (a gain and a pale rim, so it reads in the teal water) | swim 8, coil 4 (drawn back into an S, jaw open), dart 3 (stretched straight, jaw gaping), slack 10, hurt 2, stagger 4, death 9 (limp, lamp dark) |

- **Retakes.** The first Crystal Dwarf's east view hid the crystal fist behind his body (the weapon
  must read in silhouette, guide 1), so the base was made again with the fist held in front. The
  first Eel reared upright like a sea serpent; the retake asked for a 256x96 canvas, so it lies
  level, and its clips start from its south view, which PixelLab drew as the clean side profile.
  The Hound's first crouch baked a spark onto its face; the retake (`wind_r1`) asked for none.
- **Effects cut by `pick`.** The Slug's heave spat fire in frames 2 and 3 and its hurt drew a
  slash in frame 1; the Eel's dart drew a speed streak in frame 2. Those frames are left out:
  the globs, the flashes and the motion are code (guide 3).
- **The Dwarf's stagger clip** let go of the crystal fist (it floated off his arm), so his
  stagger holds his flinch instead. The Hound's and the Slug's own stagger needs were met by
  their clips (the Hound's tumble onto its back is its parry stagger, which it always had).
- **Code glows kept on top**, placed at the art's point: the Hound's eyes in its crouch, the
  Dwarf's raised fist, the Eel's brow lamp in each animation (it turns with the Eel's aim when it
  coils and darts). The tell's white pulse is `draw_sheet`'s.
- **Stopped time.** The Hound's loops run on its own clock (`_clock`), which stops with it, so
  the Stillstone freezes its art mid-stride as it froze the old drawing.
- **Palette.** Each sheet cuts its own 48 colours. The Dwarf and the Slug get the Vorrhallow
  teal rim the Shade Knight has, so the dark iron and the black shell stand off dark walls.
- **Slab cleaner.** The Slug's grey-violet foot is the flat dull grey the cleaner removes, so
  `meteor_slug` is in `NO_SLAB_CLEANING` (opaque pixels checked before and after: the other
  three sheets lose none).
- **Clockwork Alpha** loads its pack's sheet when it arrives (`_ready`), so the first hound it
  calls no longer loads a sheet mid-fight (`test_every_boss_fight_holds_the_frame_budget`).
- Test: `test_vorrhallow_foes_play_an_animation_for_every_state` and
  `test_spring_eel_plays_an_animation_for_every_state` (every state, the tell, hurt, stagger
  and death each play an animation the sheet has).

## Budget

PixelLab: 86 generations (six bases at 9, of them two retakes; 26 clips at 1 or 2), under the
batch's share of about 130.

## Images

`/mnt/project-files/art-loop/<foe>/`: before and after in the foe's room, and the lineup.

## Rubric

Art cohesion moves for four more foes of about 40; the score stays as the gameplay loop last set it.
