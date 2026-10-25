# Pass 75: Shadow Eura, out of the glass

Phase 2 of the shadow before the gate of Zenis (bible 8.8), and its music.

## What changed

- **Phase 2** (`scripts/bosses/shadow_eura.gd`):
  - `MAX_HP` goes up to 240 and `PHASES` is now [0.5], so the mirror phase still takes half the fight.
  - Below half, the glass down the middle of the hall bursts (a line of debris and a toast). The shadow is untouchable
    for `SHATTER_TIME` (1 s), then turns on gravity and world collision and fights on its own.
  - It picks the skill tree branch you have learned the most nodes in (`ShadowEura.strongest_branch()`, Blade on a tie
    or an empty tree):
    - **Blade:** walks you down, cuts twice (`CUT_TELL` 0.4 s), then lunges with a heavy blow (`HEAVY_TELL` 0.5 s,
      20 damage).
    - **Arcana:** keeps about `KEEP` (150 px) away and casts a `ShadowBolt` (`scripts/bosses/shadow_bolt.gd`,
      `CAST_TELL` 0.5 s, 12 damage) every 1.4 s. Parry a bolt and it turns back into the shadow for 12. Come close
      and it cuts once.
    - **Wanderer:** air-dashes through you (`DASH_TELL` 0.45 s, 14 damage). Once, below a quarter health, it stops
      to drink (+12% over 0.8 s), and a blow spills the draught.
  - Every phase 2 blow can be parried, and a parry leaves it reeling for 1.2 s. Its poses come from your own sprite
    sheet (run, slash, cast, dash, drink, hurt).
- **Music**: `track_eura` in `tools/audio/musicgen.py` writes `assets/music/eura.ogg`. It is in E minor at 132 with
  reversed pads that swell into each bar. A `_Mirror` wrapper echoes every lead note three quarters of a beat late,
  softer and from the other side. BossArena now plays `eura`.
- **Options**: `--boss-hp=F` works for Shadow Eura (at 0.5 or below, the mirror breaks).
- **Docs**: bible 8.8 has a phase 2 as-built note.

## Tests

- `test_boss.gd`:
  - `test_shadow_eura_fights_with_your_strongest_branch`: branch choice and tells.
  - `test_shadow_eura_breaks_the_mirror_at_half`: the shatter, its theme, and the Blade combo landing after its tells
    and staggering on a parry.
  - `test_shadow_eura_casts_your_arcana_back_at_you`: the bolt, the parry, and the bolt hurting the shadow.
  - `test_shadow_eura_wanders_dashes_and_drinks`: the dash, the draught, and the spill.
  - `eura` added to the music list.
- `test_soak.gd`: the Eura soak now runs 2400 frames and breaks the mirror halfway (0.49 ms a frame, every state seen).

## Screenshots

`/mnt/project-files/pass-75/`:
- `shatter.png`
- `free.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90.5 | Three fighting styles built from the player's own build. |
| World and level design | 15 | 94.5 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 92.5 | The shadow's second phase answers how you built your hero. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 90 | Its own theme. |
| Stability and performance | 5 | 89 | Unchanged. |
| Faithfulness | 5 | 90.25 | Unchanged. |

Weighted score: 90.24 (up from 90.10; 90.2375 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (89). Next: Shadow Eura phase 3 (it splits in two; only the real one shows
in the floor's reflection). After that, the gate opens onto Zenis.
