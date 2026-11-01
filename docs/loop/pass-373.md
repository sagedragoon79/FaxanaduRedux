# Pass 373: the minimap (Systems)

Category: Systems (last pass 365).

## Audit

Passes 366 to 372 changed only the menus' refusal sound among the systems. The Equipment page, the shops' Owned marks, the accessibility options and the in-game hints (all by action name, so a rebind never leaves a stale key on screen) are held.

Bible 12's UI list names what the interface has: HP masks, the MP bar, the boss bar with phase ticks, the full map and the minimap, among others. No minimap was ever built, so the only way to see where a door led was to stop and open the full map. Three other items on the list were also built differently, and the bible never said so:
- the inventory is a list, not a grid;
- the dialogue box has no portrait frame;
- the pad's buttons are named only by the Xbox layout.

## Fix

- `Minimap` (scripts/ui/minimap.gd), drawn by `GameHud._draw_minimap`:
  - A window 96 by 54 px in the HUD's top right corner shows the map around you at half the full map's scale.
  - Your room sits in the middle, pulsing in its zone's color. Rooms you have walked show, and rooms a chart gives you show dimmed.
  - Shrines and still-shut key doors are marked as on the full map, and a blinking dot shows where you stand.
  - It reads the full map's rules (`MapScreen.shown`), so the two always agree.
  - It hides while the full map, a menu or a dialog is open, and in the Trials and the Boss Rush, whose clocks hold the top of the screen.
  - Screenshotted in Forepaw with the Tower charted. Its backdrop is translucent so the room shows through.
- Bible 12: a note "The minimap (pass 373)", and the three items built differently, said plainly.
- `test_the_minimap_shows_the_map_around_you` (test_systems) checks that:
  - your room is centered and at half scale;
  - a walked room shows, an unknown room does not, and a charted room shows dimmed;
  - nothing beyond the window shows;
  - the dot stands in your room and moves with you;
  - the window sits in the corner;
  - the map, a menu, a dialog and a Trial each hide it, and it comes back after.

Mutation check: showing every room fails "a room you never walked or charted is not", and ignoring the dialog fails "nor under a dialog".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The minimap the UI list promised is built. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 374: Audio.
