# Pass 84: The Ending

This pass adds the ending and credits (bible 8.9, Reward). The game can now be finished.

## What changed

- **Trigger**: `BossArena` waits `ENDING_DELAY` (4 s) after the `evil_one` reward, so the banner shows first. The timer ignores slow motion. Then it calls `GameState.begin_ending()`, which:
  - sets the `cleared` flag;
  - counts `clears` (a new save key);
  - emits `ending_started`.
- **EndingScreen** (`scripts/ui/ending_screen.gd`): code-drawn, with PixelFont text. It has three parts:
  - **Epilogue**: four cards over the Tree at night. The meteor's light drains away, then the three springs light up.
  - **Credits**: a 2600 px climb from Eolis to the crown, past zone names, springs and branches. The sky goes from night to dawn, and it ends on the crown in leaf with the sun rising. The credits scroll over it.
  - **Thanks**: your rank and time played, then back to the title.
  - Controls: jump or attack turns a card early or holds the climb at 4x. Pause skips to the thanks card, which ignores presses for 1 s.
- **Game** (`scripts/game.gd`):
  - On `ending_started` it pauses the world, hides the HUD and plays `ending`.
  - When the ending finishes, it saves (the cleared flag rides along), tears the world down and opens the title.
  - Pause can't open the pause menu over the ending.
  - New `--ending=SECONDS[,PART]` option for screenshots.
- **Music**: `track_ending` in `musicgen.py`: the Eolis F lydian at 76 bpm, with pads, a rising arpeggio, a bell and a lead.
- **Docs**: bible 8.9 has an as-built note. The secret ending (no deaths plus the Battle Suit) stays deferred with the Sunken Spring.

## Tests

- `test_boss.gd`: `test_the_heart_of_the_meteor_dies_for_good` now also checks that the ending starts and the save is marked cleared.
- `test_systems.gd`:
  - `test_the_ending_tells_climbs_and_thanks`: cards turn on time and on a press, the climb speeds up while a button is held, and the thanks card has its grace period.
  - `test_pause_skips_the_ending_to_the_thanks_card`
  - `test_the_game_plays_the_ending_then_returns_to_the_title`: the real Game node, with no save written.

## Screenshots

`/mnt/project-files/pass-84/`:
- `ending_epilogue.png`
- `ending_springs.png`
- `ending_credits_low.png`
- `ending_credits_mid.png`
- `ending_crown.png`
- `ending_thanks.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (the ending is plain code art, like the rest for now). |
| Bosses | 10 | 95.5 | Unchanged. |
| Systems | 10 | 91.5 | The game can be finished, and the save remembers it. |
| Audio | 5 | 91.5 | An ending theme. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 93.5 | The climb up the Tree to the credits. |

Weighted score: 91.40 (up from 91.28; 91.400 unrounded).

## Next

The game is finishable from start to end. The lowest categories are Art (84.75, deferred by Sean until near completion) and Stability (89). Pass 85 should be a stability pass: a full-route soak or a playthrough-style regression across all zones. After that, return to the deferred list.
