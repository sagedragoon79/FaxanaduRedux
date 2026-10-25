# Pass 86: The Sunken Spring begins

Back to the deferred list with the optional zone (bible 3.1, M7). This pass is its first slice: swimming, the way in, three rooms and a swimming foe. The Drowned Warden and the Battle Suit come next.

## What changed

- **Swimming** (bible 6.8, new): deep water is legend `a`, gathered into one `SwimWater` per room.
  - While the middle of the body is in it, `Player.in_water` is set for the frame (like the drift pocket's `gravity_scale`).
  - The swimming player floats up to the surface (50 px/s) and sinks while holding Down (120 px/s), eased by 520 px/s² of drag.
  - A jump press is a stroke up (-230 px/s). With the head above the surface it is a full jump out, and swimming refreshes the double jump and air dash.
  - Across is 0.7x run speed. There is no breath timer.
  - The numbers are in `movement_tuning.gd` (Swimming group), and `test_swim_numbers_match_the_bible` asserts them.
  - The water is drawn over the bodies in it: translucent, with a rippling waterline (none under rock), drifting caustics, bubbles, and spray when you cross the surface fast.
  - New sounds: `swim`, `dive` and `eel_lunge` (sfxgen appends them, so every older sound stays byte-identical).
- **Reachability** (`reach.gd`): a spot with the feet in water is a standing spot.
  - From it the checker swims to the water cells beside, above and below.
  - With the head out (no water two rows up) it can jump out with `WATER_JUMP`, a little under a floor jump.
  - A fall stops at the first water cell.
- **The way in**: three cracked stones in the Meteor Rise's floor at its foot, under the sign that has promised the Spring since pass 73.
  - The Mattock breaks them. The shaft below is still flooded, so it is the zone's first swim.
  - A new floor door (door 3) leads down into the Spring Gate.
  - Down through a floor door you now arrive falling (`World.TOP_ARRIVE_FALL`, 120 px/s), so water doesn't float you straight back out.
  - Let go in the Spring Gate's shaft and you float back up into the Rise, then jump out onto its floor.
- **Three rooms** in `levels/sunken/`:
  - The **Spring Gate** (60,-6): a drowned cistern with a dome of trapped air whose shelf holds a shrine. It has two eels, plus a chest and a potion shard on the bottom.
  - The **Drowned Aqueduct** (61,-5, 80 wide): broken arch tops to climb out onto and two walls hanging into the water to swim under. It has three eels, a Mantra Shard on an arch, and a dry gallery with a chest.
  - The **Source Hall** (63,-5): a black pool beside a dry shore, with a Shade Knight and a Life Fruit on a shelf. A sign says the Source lies deeper, which is where the Drowned Warden will wait.
- **The Spring Eel** (`l`, a water cell with the eel in it): it weaves near home and never leaves the water.
  - Its tell: within about seven tiles it coils for 0.5 s, lamp blazing.
  - Then it darts at 300 px/s and bites for 14.
  - The dart stops dead at the water's edge, so the bank is safe.
  - Afterwards it hangs slack for 0.8 s and takes 1.5x damage. It has 30 HP.
- **Zone dressing**:
  - Tiles: `paint_spring`, pale limestone strata with pores and a blue-green stain.
  - Backdrops: a flooded cavern of terraced pools under slanting light, and nearer, the aqueduct's arches with swaying weed.
  - Decor: rimstone dams, spring pearls, weed, limestone straws, light seeps and flowstone.
  - Rising specks of light.
  - Music `sunken` (E dorian at 64) and ambience `amb_sunken`.
  - The zone is registered in the map, motes, decor glow and footstep tables.

## Tests

- `test_movement.gd`: `test_swimming_floats_sinks_strokes_and_jumps_out`, `test_swim_numbers_match_the_bible`.
- `test_reachability.gd`:
  - `test_checker_swims_through_deep_water`
  - `test_the_sunken_spring_lies_under_the_last_stone_of_the_rise`
  - The three rooms are added to the Mattock and Thunder lists.
- `test_enemies.gd`: `test_spring_eel_coils_then_darts_and_never_leaves_the_water`, `test_spring_eel_cannot_reach_the_bank`.
- `test_rooms.gd`: `test_the_sunken_spring_opens_under_the_last_stone_of_the_rise` breaks the stones, sinks into the zone (checking its theme, ambience and motes), floats back up into the Rise and jumps out onto its floor.
- `test_soak.gd`:
  - New: `test_random_input_soak_in_every_sunken_spring_room`.
  - The door walk now accepts arriving through a side door swimming instead of standing.

## Screenshots

`/mnt/project-files/pass-86/`: `spring_gate.png`, `aqueduct.png`, `source_hall.png`, `rise_foot.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.5 | Swimming is a new verb with its own feel (float, stroke, jump out). |
| Combat and enemies | 15 | 91.25 | The Spring Eel, a foe that hunts in three dimensions of water. |
| World and level design | 15 | 96.5 | The optional zone begins: three rooms, a real secret way in. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred; the new tiles are code-drawn and busy). |
| Bosses | 10 | 95.5 | Unchanged. |
| Systems | 10 | 91.5 | Unchanged. |
| Audio | 5 | 91.75 | A zone theme, an ambience and three effects. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 93.5 | Unchanged. |

Weighted score: 91.74 (up from 91.55; 91.7375 unrounded).

## Next

Pass 87: the Drowned Warden, the Spring's guardian and the hardest fight in the game (bible 8.10). It needs a way down from the Source Hall into an arena, and it drops the Battle Suit (armor tier 4). After that, the secret ending (no deaths and the Battle Suit).
