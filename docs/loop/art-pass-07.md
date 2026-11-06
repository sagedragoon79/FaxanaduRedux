# Art loop pass 7: foes that faced away

Sean (2026-11-05) noticed that many PixelLab foes look away from the player. Their bases are
8-direction characters whose rotation names are off: the image saved as `east` is often a
three-quarter view turned away from the camera, and the true profile sits under another name.
Clips asked for "east" from that view walk off into the screen.

## Audit

Every remade foe (21) was checked: each base's eight rotations side by side, the `west` view
mirrored, and the first frame of every shipped strip.

| Foe | Shipped facing | Fix |
|-----|----------------|-----|
| Grub Lump | back plates only, head turned away | remade |
| Marsh Hag | the back of her reed shawl, face hidden | remade |
| Mothling | three-quarter rear, face hidden | remade |
| Sap Spitter | the back of the stump, spout and eye hidden | remade |
| Silt Adder | the back of its hood | remade |
| Shade Knight, Drowned Dwarf, Clockwork Hound, Glass Slug, Spire Sentinel, Minecart Rider | three-quarter toward the camera, facing right | fine |
| Bark Knight, Bog Puffcap, Crystal Dwarf, Gear Bat, Lantern Ghost, Leaf Mantis, Seed Bomber, Spring Eel, Storm Harpy, Thunder Beetle | side profile, facing right (several were already started from another rotation) | fine |

## The fix

For each of the five, `base/guard.png` is now the base's `west` view mirrored: a clean right
profile with the face (or the spout, the eye) in view. Every clip was made again from it
(`custom_start_frame`, pixminimax, east) into `*_s` folders: 19 clips, 19 generations. The old
clips stay in their folders as sources.

- `pixellab_sheets.py` packs the `*_s` clips. The manifest's picks were redone for the new clips
  (the Grub Lump's windup is 4 frames now, the Sap Spitter's death skips the burst-spray frames).
- The Marsh Hag's staff is now on her far side, so the wisp's crook points (`CROOK`) were measured
  again: in her hex the crook is raised in front of her, no longer behind.
- The manifest named the Mothling's character as 231a7a98; its base is 05c30138.

## Rule

The style guide gains step 1a (check the facing before any clip) and a review line: every
animation's first frame is compared with the base's `west` view mirrored. A three-quarter view
toward the camera is fine; one turned away is not.

Images: `/mnt/project-files/art-loop/facing/` (before and after, the lineup).

## The Silt Adder, again

Sean regenerated the Silt Adder himself (character bf6df4fc, a cobra hood instead of a cloth one),
and its clips had been remade from the new base's `east` view in an open PR (#537). That view turns
the hood's back to the camera too, and this pass's first fix had used the old character. The adder's
`float_s`, `strike_s` and `death_s` are now made from Sean's base, its `west` view mirrored
(3 generations), and #537 is closed in favour of this.
