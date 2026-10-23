# Pass 30: The Old Flue, and the HUD at 2x

Two things the last pass named: the Tower's wall-jump skip route (bible 4.3), and the HUD and pickups, the last 1x art
on screen. Art was 76 going in.

## What changed

- **Flue damper (`Q`).** `FlueDamper` (`scripts/world/flue_damper.gd`) is one tile of riveted iron louvers.
  - It is solid until `boss:zoradohna` is set, then stands open (louvers edge-on, no collision).
  - The Reach checker treats `Q` as solid unless the `winch` ability is given.
  - The Tower Foot's ceiling, top right, now has a three-tile damper over a shaft (door 5). A sign below explains it.
- **The Old Flue** (`tower/old_flue`, 14,-6, 40x68).
  - A three-screen chimney with no ledges: two wall-jump chimneys and a spike strip between chambers.
  - It has two Gear Bats, a chest, and a Potion Shard on a high beam.
  - Door 2 is the floor shaft down to the Foot. Door 1 leads east into the Rafters.
- **The Rafters** (`tower/rafters`, 15,-6, 120x23), under the tower's crown.
  - Beams over two spike runs, the wider one under a hanging pillar.
  - It has an Iron Dwarf, two Gear Bats, and a Mantra Shard on the middle beam.
  - A climb at the east end leads to a new west door at the top of the Mine Shaft (door 3, with a ledge).
- **The skip.** Bible 4.3 and 4.4 now spell the route out. Once Zoradohna falls and the winch turns, the Foot reaches
  the Rail Gallery without the lift, Forepaw, the Mine Mouth or the Mine Shaft climb.
- **HUD at 2x** (`game_hud.gd`). Every icon is drawn in half-pixels.
  - **Health masks** are carved ivory masks with eyes. They fill from the chin up and turn green when poisoned. The
    half mask is the left half of the shape.
  - **Magic bar:** a glass tube with a highlight and a shadow line, ticks every 10 MP, and a gem cap.
  - **Red Potions** are round flasks with corks. Gold is a struck coin.
  - A faint backing plate keeps the HUD readable over bright rooms.
- **Pickups at 2x.**
  - Item pickups each have a detailed icon: glove, Life Fruit, Mana Dew, Potion Shard, and a turning Mantra Shard.
    Two twinkles orbit each one.
  - Chests have plank grain, iron corners, a brass band, and a lock plate whose keyhole glows. An opened chest shows its
    thrown-back lid.
  - The gold purse and spinning coins are redrawn too.
- Screenshot option `--hp=N`.

## Tests

- `test_the_flue_damper_opens_once_zoradohna_falls` (test_economy): three shut tiles, then open after the flag.
- `test_the_old_flue_skips_the_tower_once_the_winch_turns` (test_reachability) works on the Tower without the lift
  rooms:
  - with no `winch`, the Foot can't reach the Rafters;
  - with it, the Foot reaches the Rafters and the Rail Gallery.
- `MATTOCK_ROOMS` gains the two new rooms, and the Act I reach test adds `winch`.

612 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-30/`:
- `hud.png`: two and a third masks full.
- `damper.png`: the damper shut, then open.
- `old_flue.png`, `rafters.png`.
- `life_fruit.png`: the new fruit icon.
- `chest.png`: the new chest, and the damper at the top right.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged; the Flue is the hardest glove climb yet. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 82 | The skip route is in place, and the Tower has 19 of 26 rooms. |
| Art cohesion | 15 | 78 | No 1x art is left in the HUD or pickups. The fallback font is still not a pixel font. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 80 | Unchanged. |
| Audio | 5 | 72 | Unchanged. |
| Stability and performance | 5 | 73 | Unchanged. |
| Faithfulness | 5 | 73 | The bible's planned sequence break is built. |

Weighted score: 81 (80.75, up from 80.25).

## Lowest categories and next pass

1. **Audio (72)**: the Rafters and the Flue would suit wind ambience. Check the music transitions between Tower rooms.
2. **Faithfulness (73)**: the remaining 7 Tower rooms.
3. **Art (78)**: a pixel font for the HUD and menus (a code-generated bitmap font, bible 12).
