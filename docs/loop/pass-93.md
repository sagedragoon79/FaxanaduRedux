# Pass 93: The final shop tier

The Spring of Sky's world-state row listed "the final shop tier" as the last change still to come. The bible's tier-3 blade, the Giant Blade (5.2: "2,800 g, slow, huge arc"), was never built and had no shop. Systems is tied lowest apart from Art, so this pass builds both together.

## What changed

- **Gated stock:** a shop entry can name a GameState flag (`"requires"` in `data/shops.json`).
  - `Shop.shelf(shop_id)` lists what is on the shelf now. An entry whose flag isn't set has the new status `"hidden"` and can't be bought.
  - The shop menu shows only the shelf and maps rows back to stock indices.
- **The tier:** with the Spring of Sky restored (`spring:sky`), trade returns on the sky road.
  - Eolis Arms stocks the **Giant Blade** for 2,800 g.
  - Daybreak's grocer keeps one **Life Fruit** for 2,000 g, the top of the bible's range. Daybreak was the only town without one.
- **The Giant Blade** (`giant_blade`): slash 15, heavy 28, reach 16.
  - Two new optional blade fields:
    - `arc` (20): the side slash is 20 px taller, covering the player from head to heel.
    - `swing` (1.3): every swing's recovery is 30% longer.
  - `Player.arc_bonus` and `Player.swing_mult` are set by `GameState.refresh_stats`.
  - Its damage per second is about the Long Sword's. You trade pace for reach and coverage, so it is a play-style change, as 5.2 asks of every blade.
  - It is drawn two pixels broader, and `SlashFx` scales the smear with the arc.
  - With the Dragon Slayer in hand it shows as owned (tier 4 beats tier 3).
- New screenshot options: `--equip=ID[,ID]` and `--swing=FRAME`.
- Bible 5.2 and 10.2 and the world-state table are updated. The 10.2 shop table had been split by a paragraph, and is whole again.

## Tests

- `test_combat.gd`: `test_the_giant_blade_sweeps_wide_but_swings_slow` covers damage, the hitbox's reach and height, the slower recovery, a hit two tiles out, and other blades keeping the plain arc.
- `test_economy.gd`: `test_the_final_tier_comes_with_the_spring_of_sky` covers:
  - Both entries hidden and unbuyable before the flag.
  - On the shelf after it, at the right prices.
  - Stats applied on purchase, the Long Sword counting as owned, and the fruit selling once.
  - The Giant Blade showing as owned with the Dragon Slayer.

Full suite: 1761 checks, all passing.

## Screenshots

`/mnt/project-files/pass-93/`:
- `giant_blade_shop.png`: Eolis Arms after the Spring of Sky, with the Giant Blade at 2,800 g.
- `giant_blade_swing.png`: a Giant Blade swing in Market Row, with its wide smear.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 92.25 | Unchanged. |
| Combat and enemies | 15 | 92.5 | A heavy blade with its own pace and coverage. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.25 | Unchanged. |
| Systems | 10 | 93 | Shops change with the world, and the last blade tier is in. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 95.25 | The bible's Giant Blade and the Spring of Sky's last world-state change are in. |

Weighted score: 92.58 (up from 92.45; 92.575 unrounded).

## Next

Stability (92) and Audio (92) are now the lowest apart from Art, then Movement (92.25). Pass 94 takes the wide camera that bible 8.6 defers for the Spires and Borabohra, a movement-feel and readability change.
