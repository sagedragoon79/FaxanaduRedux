# Pass 152: Eolis of Old

Faithfulness (98, weight 5) was the lowest category apart from Art. I audited the remake against the original Faxanadu and bible 1, 2, 11 and 16.

| Check | Finding | Verdict |
| --- | --- | --- |
| Bible 1 and 2 pillars | the World Tree, its springs, the towns, the Gurus and the mantra joke, Eolis's King and the dwarf bosses are all in | fine |
| The secret ending (bible 11) | built: no deaths and the Battle Suit add the epilogue's extra pages | fine |
| Pendant and Magical Rod | still left out on purpose (not in the bible) | fine |
| **Bible 11 easter egg: "a hidden room in Eolis rendered in authentic 8-bit NES palette and resolution, with the original's music style"** | Never built. Of the three easter eggs it was the only one missing, and the one that most directly tips its hat to the original. | **built** |

## As built (bible 11)

- **The way in:** the east end of the Temple of Mantras is a fake wall (`%`) over a small chamber with a door, under a `secret:` cover, so it counts as a hidden room on the completion card. The Black Onyx shows its seam like any other.
- **Eolis of Old** (`levels/eolis/old_eolis.room`, on the map above the temple): the town's fountain, a stair of square blocks, two planks, two tablets of new text and a chest of 1987 gold, the original's year.
- **`RetroFilter`** (`scripts/world/retro_filter.gd`, `shaders/retro.gdshader`): a room header `retro: true` turns it on. It is a canvas layer under the HUD (layer 4; the UI is 5) that reads back the screen and:
  - cuts it into blocks of 2 world pixels, 240 x 180 in the frame, close to the NES's 256 x 240;
  - frames it 4:3 with black bars, like a television of the day;
  - matches each block to the nearest of the NES palette's 55 distinct colours (redmean weighting).

  The HUD stays sharp so its numbers still read.
- **`old_eolis`** (`musicgen.py`): a new tune, not the original's (bible 16), on the 2A03's four voices only:
  - a 12.5% pulse lead;
  - a 25% pulse playing the chords as sixteenth-note arpeggios;
  - the 4-bit stepped triangle walking the bass;
  - the noise channel for drums.

  It is in F major at 132, with stepped volume envelopes and no reverb. Pulse waves sound louder than the filtered mixes at the same peak, so it sits at -14.6 dB RMS (peak -4.5 dB), the median of the music. `levels.py --check` passes. The room has no ambience bed.

## Screenshots

- `/mnt/project-files/pass-152/old_eolis.png`: Eolis of Old through the filter, with the fountain, the block stair and the chest.
- `/mnt/project-files/pass-152/temple.png`: the Temple of Mantras as you find it, with the chamber hidden behind the east stone.

## Tests

`test_world.gd`, `test_eolis_of_old_hides_behind_the_temple` (new):
- the temple is drawn and scored as usual, and its chamber starts hidden;
- walking east goes through the stone and finds the chamber;
- Up at its door goes to Eolis of Old, drawn through the filter (under the UI layer) and playing `old_eolis`, which loads as a loop;
- the chest holds 1987 gold;
- going back, the filter is off and the town theme returns.

The reachability, room and completion tests cover the new room and chest unchanged.

Full suite: 2781 checks, all passing, with no script or shader errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | Unchanged. |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | The last of the bible's easter eggs: the original's look and sound, hidden in its first town. |

Weighted score: 96.25 (up from 96.2375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, World, Systems, Audio, Stability and Faithfulness are tied at 98.25. Movement weighs the most (20), so pass 153 takes Movement.
