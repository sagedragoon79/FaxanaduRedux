# Pass 48: Into the Branches

The Mist is complete, so Act II goes on up the Tree (bible 4.2, step 5: the Branches, Conflate). This pass opens the
zone: its look, its sound, the zone's mechanic (bounce-pods), and the first three rooms. The Leaf Mantis and the rest
of Conflate come next. The pass also adds a stability item: a save round trip through every Act II world change.

## What changed

- **The Branches zone** (`levels/branches/`, `zone: branches`).
  - Tiles: `paint_bough` in `tilegen.py`, the Trunk's grain two shades lighter in the sun, with sprigs of leaves.
  - Parallax backgrounds (`branches_far`, `branches_mid`): sky, clouds, far boughs in the haze, and near boughs hung
    with enormous leaves.
  - Decor (`decorgen.py`): leaf litter, sky-blue flowers and sprouts; hanging leaves and vines; sun-yellow bracket
    fungus and leaf sprigs on walls.
  - Motes are drifting pollen. Footsteps are plank. The zone has a map color and name.
  - Every older tile, background and decor image is byte-identical (checked).
- **Music:** `branches`, a lilting D lydian theme with rippling plucks and a bell lead, the game's first open sky.
  `amb_branches` is wind in gusts, rustling leaves, bird trills and a creaking bough.
- **Bounce-pods** (`scripts/world/bounce_pod.gd`, legend `@`), the zone's mechanic (bible 3.2).
  - A fat seed-pod stands on the floor of its cell. Land on it from above and it squashes and throws you up at
    `MovementTuning.pod_bounce` (600 px/s, about nine tiles in play) through `Player.pod_launch()`.
  - Releasing jump doesn't cut the launch short, and it refreshes the double jump and dash.
  - The pod isn't solid: walk into it and nothing happens, and a hop on the spot launches you.
  - It has its own sound (`pod`). Bible 6.6 has the row.
  - `reach.gd` uses `POD_JUMP` (rise 7, across 3 at the top) from a pod's cell.
- **Rooms.**
  - The Spring of Mist gains an east door (door 2) above its last tank. It is sealed during the fight like any arena
    door.
  - **Windward Climb** (37,-8, 40x45): a pod-to-bough climb out of the Mist into the sun, with a side bough and a
    chest, a Mantra Shard, and hornets.
  - **Sunlit Bough** (38,-8, 60x23): a long bough in open sky. A bark wall that a pod vaults (or the glove climbs), a
    thorny dip to pogo, and a Mantra Shard only a pod on a low plank reaches.
  - **Leaf Landing** (40,-8): a shrine on the elves' leaf road, and a Life Fruit two pods up (or the boots). The road
    east is overgrown for now.
- Bible 3.2 (bounce-pods), 4.4 (where the Zorugeriru row leads) and 6.6 (the pod launch) are updated.
  `levels/README.md` has the `@` legend row.

## Tests

- `test_abilities.gd`:
  - `test_bounce_pod_throws_you_nine_tiles_up`: the launch speed, the air moves refreshed, and at least 8.5 tiles of
    rise with jump released.
  - `test_walking_into_a_bounce_pod_does_nothing_but_a_hop_launches`.
- `test_reachability.gd`:
  - `test_checker_rides_bounce_pods`: a ledge the Wing Boots can't reach, which a pod beside it can.
  - The three rooms are in `MATTOCK_ROOMS`. Every pickup is reachable, and there are no soft-locks.
- `test_rooms.gd`: `test_act_two_state_survives_a_save_round_trip`. The boss, spring, curtain, seal and basin flags,
  the three rings, the Lantern Key, the Wing Boots and Deluge all survive a save and load. The rooms rebuild in their
  changed state: fog parted, the seal out, the cistern and the hydra's tanks full, no hydra, and the boardwalks risen.
- `test_soak.gd`: `test_random_input_soak_in_every_branches_room`.
- `test_boss.gd`: the music test lists `branches` and `amb_branches`, and the Sunlit Bough plays them.

## Screenshots

`/mnt/project-files/pass-48/`: `windward_climb.png`, `sunlit_bough.png` and `leaf_landing.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Bounce-pods add a new verticality: big, readable launches. |
| Combat and enemies | 15 | 86 | Unchanged. The Branches has no enemy of its own yet (hornets stand in). |
| World and level design | 15 | 91 | Act II's second zone begins; three rooms. |
| Art cohesion | 15 | 84 | Unchanged (on hold). A new zone set, code-made like the rest. |
| Bosses | 10 | 87 | Unchanged. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 86 | A zone theme and ambience. |
| Stability and performance | 5 | 85 | Act II save round trip; Branches soak. |
| Faithfulness | 5 | 86 | Unchanged. |

Weighted score: 87.40 (up from 87.10).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest are Combat (86) and Faithfulness (86). Next: the **Leaf Mantis** (bible 7,
Conflate), the zone's first own enemy, code-drawn at 2x, in these rooms in place of some hornets; then more Conflate
rooms toward the town.
