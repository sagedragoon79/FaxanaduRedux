# Pass 40: A pixel font

Faithfulness was lowest at 81. Every word in the game was drawn in Godot's fallback font: a smooth vector sans that
looks like a web page over pixel art. Faxanadu's lettering is chunky NES type.

## What changed

- **A custom 5x7 bitmap font** (`tools/art/fontgen.py`, giving `assets/fonts/pixel.png` and `pixel.json`).
  - Every glyph is drawn by hand in the script: 94 printable ASCII characters.
  - Capitals and digits are 7 rows tall, lowercase has a 5-row x-height, and descenders drop 2 rows.
  - Glyphs are proportional (mostly 5 wide, with narrow i, l, punctuation), on an 11-row line.
- **`PixelFont`** (`scripts/ui/pixel_font.gd`) builds a Godot `FontFile` from those files at runtime. That avoids the
  importer and keeps headless CI simple.
  - It uses fixed size 11, no antialiasing and `FIXED_SIZE_SCALE_INTEGER_ONLY`.
  - `scale_for` snaps every requested size to a whole scale: 8 to 16 draw at 1x, 18 and 22 at 2x, 44 at 4x. Under the
    window's integer stretch, text always lands on the pixel grid.
  - `draw` stamps a one-texel outline in eight directions, because bitmap fonts can't be outlined by the text server.
  - `wrap_lines` and `draw_wrapped` handle wrapped text.
- **Every UI screen uses it**: the title logo (4x with a 1-texel drop shadow), menus, shops, the skill tree, the pause
  menu, the map, banners and toasts, the boss bar and the HUD.
  - The dialog box wraps each page once up front, so words don't jump lines as they type out. It holds 5 lines, 13 px
    apart.
  - The map legend is now laid out right to left from measured widths. The wider font made "Pin: Jump (0/12)" run into
    "Shrine".
- A new shot option, `--say=NPC`, opens the dialog box on that NPC's lines, for screenshots.
- Bible 14 (UI art) now names the custom font in place of a licensed one, with the reason.

## Tests

`test_systems.gd` has two new tests:

- `test_pixel_font_covers_ascii_and_scales_by_whole_numbers`:
  - every printable character has a glyph;
  - 2x text is exactly twice as wide, and 3x is three times as tall;
  - sizes snap to whole scales;
  - wrapping keeps lines inside the box.
- `test_every_npc_line_fits_the_dialog_box`: every greeting and line in `data/npcs.json` wraps to at most 5 lines.

## Screenshots

`/mnt/project-files/pass-40/`: the title, pause menu, shop, skills, dialogue, map, the rank-up banner and the boss
banner.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | Unchanged. |
| World and level design | 15 | 87 | Unchanged. |
| Art cohesion | 15 | 84 | Text finally matches the pixel art: one grid, no smooth vector type. |
| Bosses | 10 | 84 | Unchanged. |
| Systems | 10 | 82 | Unchanged. |
| Audio | 5 | 84 | Unchanged. |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | NES-style lettering and a block-letter logo, as in the original. |

Weighted score: 85.05 (up from 84.55).

## Lowest categories and next pass

1. **Systems (82)**: the Lantern Key gate and the road on toward the Spring of Mist. Also the zone track "restored"
   variants.
2. **Stability and Bosses (83 and 84)**: Zorugeriru, the Mist Hydra.
3. **Combat (84)**: the Mist Wisp, Bog Myconid and Drowned Dwarf.
