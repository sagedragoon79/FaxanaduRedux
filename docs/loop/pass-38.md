# Pass 38: The fog's frame time

Stability was lowest at 78. Pass 36's fog is a full-screen shader over every Mist room, and pass 37 added a boss fight
under it. Neither had been measured.

## What changed

- **Fog at world-pixel resolution** (`scripts/world/fog.gd`, `shaders/fog.gdshader`).
  - The fog was a ColorRect drawn over the 2x scene, so every world pixel ran the shader four times. Its result was
    already snapped to world pixels, so three of those four runs were wasted.
  - It now renders into its own small SubViewport, at one texel per world pixel. A Sprite2D shows it at the view's
    whole-pixel origin, and nearest filtering keeps the texels on the world's pixel grid. The look is unchanged.
  - The viewport stops updating when a room has no fog.
- **Cheaper shader.**
  - The drifting murk samples a 64x64 tileable lattice texture (`Fog.drift_texture`, made once and seeded) instead of
    hashing with `sin` per fragment.
  - The light loop compares squared distances and skips the `sqrt` and `smoothstep` for lights out of reach.
- **Measured** with the software GL renderer (llvmpipe) under xvfb, for 900 frames:

  | Room | No fog | Fog before | Fog now |
  | --- | --- | --- | --- |
  | Sunken Chapel | 28 to 30 s | 39 to 45 s | 36 s |
  | Drowned Stair | 28 s | 32 to 35 s | 33 s |

  The chapel's fog overhead fell from about 11 to 17 ms a frame to about 8 ms, in a renderer far slower than any GPU.
  On real hardware it is a fraction of that.
- Bible 14 (performance) notes the rule for pixel-snapped full-screen effects.
- Merged with main, which brings Ripasheiku's HD Autosprite sheet (PR #54).

## Tests

These are new in `test_soak.gd`:

- `test_random_input_soak_in_every_mist_room`: the live-room soak (escapes, embedding, node growth) now covers the Mist.
- `test_fog_stays_cheap_in_every_mist_room`: it sweeps the player across each Mist room and times `Fog._update`
  (0.012 to 0.019 ms). It checks that the fog never reaches `MAX_LIGHTS`; the most is 13, in the chapel.
- `test_widow_fight_soak_stays_lean`: 30 seconds of Ripasheiku against a mashing player, forced into phase 2 halfway.
  - The run reaches every state from stalk to web, reel, drop and dropped.
  - Frames average 0.55 ms, with the slowest at 7.4 ms.
  - Nodes go from 11 to 15 and settle.

## Screenshots

`/mnt/project-files/pass-38/`:

- the chapel fight under the new fog path, with the HD Ripasheiku;
- the Fog Cut, which looks the same as before.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | Unchanged. |
| World and level design | 15 | 87 | Unchanged. |
| Art cohesion | 15 | 82 | Ripasheiku in HD (PR #54). |
| Bosses | 10 | 83 | The HD sheet gives the widow real presence. |
| Systems | 10 | 82 | Unchanged. |
| Audio | 5 | 80 | Unchanged. |
| Stability and performance | 5 | 82 | Mist soaks and a boss soak; the fog's cost is halved and measured. |
| Faithfulness | 5 | 81 | Unchanged. |

Weighted score: 84.20 (up from 83.75).

## Lowest categories and next pass

1. **Audio (80)**: a Ripasheiku boss theme, and web and drop sounds.
2. **Faithfulness and Art (81 and 82)**: a bitmap pixel font.
3. **Systems (82)**: the Lantern Key gate and the road to the Spring of Mist.
