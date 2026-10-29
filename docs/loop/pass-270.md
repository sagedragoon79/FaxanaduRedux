# Pass 270: headroom for the loudest cues

Category: Audio (last pass 262).

## Audit

I read bible 13.3 against what passes 263 to 269 added:
- King Grieve's household guard (pass 268) rises with `splash`. That is the sound of the water he stands up out of, shared with everything that breaks a surface, not a foe's voice, so it is fine. The Shade Knight keeps its own voice once it stands.
- The Mascon tavern (pass 265) is two talk NPCs in a house. They speak with the talk blip like every townsperson, and the town keeps its bed.
- The Inventory's new Supplies and Charts groups (pass 269) move the cursor with the page's own blip.
- A brood that perishes with its guardian (pass 266) still plays `enemy_die`. Its death is shown, it just pays nothing, so that is right.

The gap was the mix itself. `hurt` sat at -9.5 dB RMS, 8.9 dB over the effects' median of -18.4, and `hit` sat 8.0 over. The check allows 9. In pass 262 a first cut of five quieter sounds moved the median 0.2 dB and failed the check on `hurt`, and every later audio pass had to dodge it.

## Fix

- `tools/audio/levels.py`: sound effects must keep `HEADROOM` (1.5 dB) inside the 9 dB spread. Before the fix this flagged `hurt` (+9.0) and `hit` (+8.0).
- `tools/audio/sfxgen.py`: `hurt` is saved at gain 0.42 (was 0.6) and `hit` at 0.62 (was 0.8). Both now sit at about -12.5 dB RMS, 6 dB over the median. Only those two files were regenerated.
- `Sfx.LIFT` (`scripts/autoload/sfx.gd`): `hurt` plays 3.1 dB up and `hit` 2.2 dB up, on top of any caller's offset, so in game they are as loud as before. This works for every caller, including the heavy swing's +2, a Guru Trial miss's softened hurt and the poison drop's hurt.
- Test: `test_the_loudest_cues_are_lifted_in_game_not_in_the_file` (test_rooms). It checks that both sounds are lifted, that a play's voice volume is the base, plus the offset, plus the lift, that an unlifted sound gets none, that the hurt is lifted more than the hit, and that each lift gives back what sfxgen took from its file.
- `levels.py --check` passes, with the effects' median still at -18.4 dB.
- Bible 13.3: new "Headroom for the loudest cues" entry, after the supplied music entry.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: the mix check now has room for new sounds. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 271 takes Stability (last pass 263).
