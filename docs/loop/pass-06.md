# Pass 06: cast art

Date: 2026-10-23. Scope: art cohesion (53). After pass 04 the player outclassed every other
character on screen; this pass brings the enemies and the townsfolk up to the same style.
Autosprite is still not connected here, so this is code-generated too; no credits spent.

## What was built

- **Shared rig module** (`tools/art/pixelrig.py`): the canvas, shading, outlining, IK and sheet
  writer from `spritegen.py`, now shared. The player sheet regenerates pixel-identical.
- **Enemy sheets** (`tools/art/castgen.py`):
  - Monodron: a horned one-eyed hopper, with idle, crouch and hop frames. Its frames mark the
    eye, and the game draws a pupil that tracks you.
  - Hornet: striped abdomen, beating wings, a curled sting in the windup, swept wings in the swoop.
  - Rot Dwarf: helm, beard, armor, a round shield and an axe on a rig. Walk, axe raised
    (windup), swing, recover with the shield back up, and stagger.
- **NPC sheets:** one per person in `data/npcs.json`, built from their `look` (robe, trim,
  skin, hair, hat, plus new `beard` and `build: dwarf`). Colors snap to the master palette.
  Each has a 4-frame breathing idle.
- **Sheet** (`scripts/fx/sheet.gd`) loads and draws any sheet. `PlayerVisual`, enemies
  (`Enemy.draw_sheet()`: white wash while flashing or telegraphing) and `Npc` use it.

## Automated verification

313 checks pass (from 311). New: every enemy state and every person has a sheet; the
Monodron marks its eye. The palette check now covers every character sheet, not just the
player's. Screenshots reviewed: King's Hall, the Dwarf Hall's Rot Dwarf, the Sap Tunnel's
hornet, and a cast lineup.

## Review against the bible

- 12.3: full outlines, 3 tones per material, master palette, no dithering on characters: met
  for the whole cast.
- 7 telegraphs still read: the white wash flashes over the new windup frames (raised axe,
  crouch, curled sting).
- 13.3 now notes the interim code-generated cast and that Autosprite output will use the same
  sheet format.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 70 | Enemies read clearly; windups show the attack coming (axe up, crouch, sting). Still 3 families. |
| World and level design | 15 | 52 | Unchanged. |
| Art cohesion | 15 | 62 | One consistent cast style across player, enemies and people. Bosses and props remain simpler. |
| Bosses | 10 | 55 | Unchanged. |
| Systems | 10 | 63 | Unchanged. |
| Audio | 5 | 60 | Unchanged. |
| Stability and performance | 5 | 60 | Unchanged. |
| Faithfulness | 5 | 52 | Monodron and the Rot Dwarf look like their Faxanadu roots. |

Weighted score: 66 (up from 64).

## Lowest categories and next pass

1. **World (52):** more Trunk rooms toward 28, a landmark, a second shrine.
2. **Bosses (55):** Rokusutahn's arena reveal and a stagger window; his look in the new style.
3. **Systems (63):** options menu (shake, flash, volume, rebinding).
