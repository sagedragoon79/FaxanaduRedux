# Pass 46: Zorugeriru, the Mist Hydra

Wing Boots, Deluge, fire seals and dry basins are in, so the Mist's second boss (bible 8.4) can be built in full:
all three phases, his arena and his reward. Art stays code-drawn at 2x, as Sean asked (gameplay first).

## What changed

- **The Spring of Mist** (`mist/spring_of_mist`, map 35,-7, 60x23) is reached through a new east door in the Dry
  Cistern. It is the boss arena (`boss: zorugeriru`).
  - The spring stands on a stone shelf in the middle, with the hydra's coil wrapped around it.
  - Three dry tanks cross the floor (`u` bed, `=` stain), with floating debris between them and steps up to the shelf.
  - Fog is thinner here (0.6) so the heads read.
- **Basins in a boss room** keep no flag. They are dry on every try, and full for good once the boss is beaten
  (`DryBasin.start_full`).
- **`Zorugeriru`** (`scripts/bosses/zorugeriru.gd`, extends `Enemy`). The body is never hit; only his four
  `HydraHead` hitboxes (`scripts/bosses/hydra_head.gd`, a `BossSegment`) are. Each head is a light in the fog.
  - **Phase 1:** the heads take turns being solid, 3.4 s each.
    - The solid head hangs low and follows you along its lane. It rears for 0.6 s (eyes flash, a ring marks the
      strike), bites, and lies where it bit for 1.1 s. A parry stuns it 0.8 s longer.
    - A mist head breathes. Mist wells at its jaws and pools below it for 0.7 s, then a `MistBreath` fog bank rolls
      along the floor: 12 damage, not parryable. Jump it, or get up on the tank walls.
    - A blow on a mist head passes through.
  - **Phase 2 (below 60%):** all three heads turn to mist and keep breathing, and eyes glint in the coil.
    - The fourth head comes out only once all three tanks are full (Deluge each one; their rafts float up).
    - It bites no lower than the rafts.
    - Phase 1 damage is clamped, so a big hit can't skip phase 2.
  - **Phase 3 (below 30%):** the coil bursts and the spring floods the arena to the tanks' rims (`HydraFlood`).
    - Feet under the water take 8 damage a second.
    - The three heads take turns again with tells a quarter shorter (never under `Enemy.MIN_TELEGRAPH`).
    - The breath rolls along the water's surface.
- **Reward:** the Dworf Ring and a skill point (the `BossArena` table). The **Spring of Mist** prop (`spring_mist`)
  can be cleared only once `boss:zorugeriru` is set.
  - This follows the Spring of Trunk: the boss, then press Up at the spring.
  - Clearing it sets `spring:mist`, which the fog already halves on.
  - `Spring` gained `text` and `needs_flag`.
- `--boss-hp` works for Zorugeriru, stepping him into phase 2 or 3 for screenshots.
- Bible 8.4 is filled in with the fight as built, and 4.4 has a Zorugeriru row. The `levels/README.md` prop list
  has `spring_mist`.

## Tests

- `test_boss.gd`:
  - `test_spring_of_mist_wakes_the_hydra`: three dry flagless tanks, a hidden fourth head, the spring locked.
  - `test_zorugeriru_telegraphs_are_fair`.
  - `test_only_the_solid_head_takes_damage`: mist heads take nothing, and the heads take turns.
  - `test_zorugeriru_bites_then_lies_open`: the rear lasts at least `MIN_TELEGRAPH`, the bite strikes low and lands.
  - `test_mist_breath_rolls_along_the_floor`: tell, ground level, motion.
  - `test_fourth_head_shows_only_when_the_tanks_are_full`: hidden at zero and at two tanks, out and hittable at
    three; the rafts stand.
  - `test_phase_three_floods_the_floor`: the water rises to the rims, the floor hurts, a raft doesn't.
  - `test_zorugeriru_defeat_gives_the_dworf_ring`: ring, heads gone, doors open, spring cleared sets `spring:mist`,
    tanks stay full on return.
- `test_soak.gd`: `test_hydra_fight_soak_stays_lean` runs 30 s through all three phases with a mashing player:
  0.72 ms a frame, nodes 15 to 20 at peak. The room is also in the Mist room soak and the fog check.
- `test_reachability.gd`: the arena is in `MATTOCK_ROOMS`.

## Screenshots

`/mnt/project-files/pass-46/`:

- `hydra_p1.png`: phase 1, with the solid head low and the mist heads high.
- `hydra_p2.png`: phase 2, all mist, with a breath pooling.
- `hydra_p3.png`: phase 3, the flood, with fog rolling on the water.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 89 | Unchanged. |
| Combat and enemies | 15 | 86 | Unchanged. |
| World and level design | 15 | 90 | The Mist has 11 rooms; the arena changes under you. |
| Art cohesion | 15 | 84 | Unchanged (on hold). The hydra is code-drawn and serviceable. |
| Bosses | 10 | 87 | Five bosses. This is the first built around terrain the player changes mid-fight. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 84 | Unchanged. The fight borrows the generic boss theme and existing sounds. |
| Stability and performance | 5 | 84 | A boss soak through all phases. |
| Faithfulness | 5 | 86 | Zorugeriru and the Dworf Ring are in. |

Weighted score: 86.90 (up from 86.50).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest are Audio and Stability (84). Next:

- a hydra theme and his own sounds (bite, breath, flood), with `track_zorugeriru` in the music tests;
- the Spring of Mist's world changes from bible 4.4: drowned boardwalks resurface (the Victim Causeway dip and the
  Fog Cut hollow). The fog halving and the fountain's 2/3 already follow `spring:mist`.
