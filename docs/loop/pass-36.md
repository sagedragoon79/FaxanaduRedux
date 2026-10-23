# Pass 36: The fog, and the Lantern Ghost

Bosses and Faithfulness were lowest at 78. Bible 3.2 names the Mist's key mechanic: "fog limits vision;
lanterns". Pass 35 built the zone, but nothing in it was hidden yet. This pass adds the fog, and the first Mist enemy,
which is built around it.

## What changed

- **Fog** (`scripts/world/fog.gd`, `shaders/fog.gdshader`). The World now has a fog layer. It sits over the room and
  under the motes and HUD, and it is on in Mist rooms.
  - It is a grey-green murk at a density of 0.88. It leaves clear pockets:
    - around the player (112 px, about 7 tiles);
    - around every decor lantern (64 px);
    - around anything in the group `light` with a `light_radius`. Shrines are lights (80 px).
  - The pockets fall off in four bands, and noise drifts through the murk, so it reads as pixel fog rather than a
    smooth vignette.
  - `Fog.clear_at` and `visibility_at` mirror the shader on the CPU, for enemies and tests.
  - Restoring the Spring of Mist (`spring:mist`) halves the density and widens sight by half, as the bible's
    progression table says.
  - A room's `fog:` header sets its own density, and 0 turns the fog off.
- **Lantern Ghost** (`scripts/enemies/lantern_ghost.gd`, legend `A`).
  - It is the hooded wisp of a drowned dwarf, code-drawn at 2x: a peaked shroud with a ragged hem that waves, a dark
    face with lantern-yellow eyes, and a trailing tail.
  - It drifts through wood and stone.
  - In the fog it fades to 7% and shows only as far as the light reaches it.
  - When it closes in, its eyes flare for 0.55 s with a new `wail` sound. The wind-up is always at least 75% visible,
    so the telegraph stays fair in the murk. Then it lunges (18 damage) and fades back.
  - Six ghosts haunt the three Mist rooms: two in the Fog Cut, three in the Drowned Stair, and one in Lantern Landing.
- Bible 3 (fog) and 7 (Lantern Ghost), and `levels/README.md` (`A` and `fog:`), are updated.

## Tests

- `test_the_mist_fog_hides_all_but_the_light` (test_world) checks:
  - the Mist is fogged;
  - the player carries the first light;
  - lanterns and the shrine add pockets;
  - beyond sight the fog is thick, and little shows through in the murk;
  - the spring thins the fog and widens sight;
  - the Tower has no fog.
- `test_lantern_ghost_shows_only_near_light_and_lunges_through_walls` (test_enemies) checks:
  - the ghost is under 15% visible in the murk;
  - it drifts through a wall to the player;
  - its wind-up lasts at least `MIN_TELEGRAPH` and stays bright;
  - its lunge lands.

## Screenshots

`/mnt/project-files/pass-36/`:

- the Fog Cut and Lantern Landing under fog;
- a Lantern Ghost in the player's pocket of light, with a zoomed crop;
- the Drowned Stair seen from mid-climb.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | The Lantern Ghost: a fair threat that uses the zone's light. |
| World and level design | 15 | 87 | The Mist now plays differently: read the lanterns, climb into the dark. |
| Art cohesion | 15 | 81 | Banded pixel fog with lantern pockets; the ghost at 2x. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 82 | Fog and lights as a system the spring will change. |
| Audio | 5 | 80 | The ghost's wail. |
| Stability and performance | 5 | 78 | Unchanged. The fog is one quad and one shader with at most 48 lights. |
| Faithfulness | 5 | 80 | The Mist's fog and lanterns, as bible 3.2 asks. |

Weighted score: 83.30 (up from 82.65).

## Lowest categories and next pass

1. **Bosses (78)**: Ripasheiku, the Lantern Widow (bible 8.3), in a sunken chapel. She is seen only where her lanterns
   glow, which the fog now makes possible.
2. **Stability (78)**: measure the fog shader's cost on a full Mist room.
3. **Combat (84)**: the Mist Wisp, Bog Myconid and Drowned Dwarf, and more Mist rooms toward Victim.
