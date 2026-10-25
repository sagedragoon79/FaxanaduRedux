# Pass 81: The Avatar on the Throne

This pass builds phase 1 of the Evil One, The Throne (bible 8.9).

## What changed

- **EvilAvatar** (`scripts/bosses/evil_avatar.gd`, boss id `evil_avatar`): a knight of black meteor crystal with a crystal greatsword, code-drawn at 1.3x.
  - It has 360 HP and `PHASES [0.5]`.
  - It stalks you and picks from four attacks:
    - **Cleave**: close, tell 0.55 s, 20 damage, parryable.
    - **Lunge**: middle range, tell 0.5 s, 18 damage, parryable.
    - **Pull**: tell 0.6 s. It drags the player through `Player.pull` for 1.2 s, then bursts in a 52 px ring for 14 damage, unparryable.
    - **Rain**: far, tell 0.6 s. A line of `CrystalSpike`s erupts toward you.
  - It uses pull at least every fourth attack.
  - Front armor halves blows. Its back, a blow from above, and a parried guard (1.2 s stagger) take full damage.
  - Phase 2: tells are x0.75 (never under 0.35 s), a cleave swings twice, and the pull is stronger.
- **BossArena**: the `evil_avatar` entry, titled "The Avatar Shatters", with 1 skill point and the `evil_one` music. The avatar spawns before the dais.
- **Room**: `zenis/throne` (67,-11, 60x23): a hall with two hanging planks, the throne dais at the east end, and signs. The Heart Gate gains door 2 behind the flesh.
- **Music**: `track_evil_one` in `musicgen.py` (B locrian at 120, a double-kick heartbeat, a tritone-dropping bass, detuned pads, and a lead with a low bell).
- **Reachability**: the throne is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`. The Fire-and-Thunder set includes `dragon_slayer`, and a new test proves the throne is shut without it.
- **Fix**: the Dragon Slayer pickup's gold guard was a jagged polygon whose grown outline failed to triangulate (logged errors since pass 80). It is now a plain trapezoid.
- **Docs**: bible 8.9 has an as-built note.

## Tests

- `test_boss.gd`:
  - `test_the_throne_wakes_the_evil_ones_avatar`
  - `test_evil_avatar_telegraphs_are_fair`
  - `test_evil_avatar_cleaves_and_a_parry_opens_its_plate`
  - `test_evil_avatar_pulls_you_in_then_bursts`
  - `test_evil_avatar_rains_crystal_in_a_line`
  - `test_evil_avatar_swings_twice_below_half`
  - `test_evil_avatar_defeat_shatters_it_for_good`
  - The music list adds `evil_one`.
- `test_soak.gd`: `test_evil_avatar_fight_soak_stays_lean` (2400 frames, phase 2 halfway; 0.49 ms a frame).
- `test_reachability.gd`: `test_the_throne_lies_behind_the_flesh_only_the_dragon_slayer_cuts`.

## Screenshots

`/mnt/project-files/pass-81/`:
- `throne_lunge.png`
- `throne_duel.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (the avatar is serviceable code art). |
| Bosses | 10 | 94 | The final boss's first phase, with its own pull mechanic. |
| Systems | 10 | 91 | Unchanged. |
| Audio | 5 | 91 | The Evil One's theme. |
| Stability and performance | 5 | 89 | One more boss soak. |
| Faithfulness | 5 | 92 | The Evil One waits on the throne of Zenis. |

Weighted score: 91.06 (up from 90.94; 91.0625 unrounded).

## Next

Phase 2, The Veins: a vertical chamber climbing past light-veins while the core fires beams.
