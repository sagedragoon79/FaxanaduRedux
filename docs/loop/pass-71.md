# Pass 71: King Grieve

Dartmoor's boss (bible 8.7), phases 1 and 2, in his Throne Hall.

## What changed

- **King Grieve** (`scripts/bosses/king_grieve.gd`, group `boss`). He is code-drawn at 2x and drawn larger than his
  body box: a broad dwarf king in a flood-rotted robe and a gold-edged mantle, the back of him grown over with magenta
  crystal, crystal grown up through his crown, and a half-crystal great-axe. 320 HP.
  - **Phase 1, the duel:**
    - Close in, he chops (0.6 s tell, the axe's edge glinting overhead, 20 damage), then sweeps low (0.4 s, 16).
    - Both blows can be parried, and a parry leaves him reeling for 1.2 s, open to every blow.
    - His crystal half turns half of every other blow.
    - Keep away and he leaps after you (0.6 s crouch) and slams for 22, with a shockwave each way.
  - **Phase 2, the throne (below half):**
    - He leaps onto his six-tile dais and wards himself in crystal. Blows from the side do nothing, and thorns along the
      dais burn anyone who climbs up beside him.
    - Every 3.2 s his crown blazes (0.5 s) and four **crystal shards** (`scripts/bosses/crystal_shard.gd`) glow in the
      floor (0.4 s), nearest the dais first, then shoot up to the vault.
    - The Hour Glass holds them as flat-topped footholds, a stair up to his crown. When time runs again, a held shard
      cracks and falls.
    - A blow down on his crown throws him from the dais, open for 1.8 s. He then duels on the floor (tells at 0.8x) for
      7 s before he climbs back.
  - **Reward:** the Demon Ring and a skill point, through `BossArena` (`king_grieve`). His seal is iron.
- **Throne Hall** (`levels/dartmoor/throne_hall.room`, 58,-7, 60x23), through a new east door in the King's Kennels.
- `--boss-hp` works on him: a fraction under half puts him in phase 2.
- **Docs**: bible 8.7 has him as built, and the Dartmoor note covers the hall.
- **Deferred**: phase 3 (the meteor takes him), the draining water clock, his theme (the fight plays the shared boss
  track), and Dartmoor draining.

## Tests

- `test_boss.gd`:
  - `test_the_throne_hall_wakes_king_grieve`
  - `test_king_grieve_telegraphs_are_fair`
  - `test_king_grieve_chops_then_sweeps_and_a_parry_opens_him`
  - `test_king_grieve_takes_the_throne_below_half_and_falls_to_a_crown_blow`
  - `test_king_grieves_shards_are_a_stair_while_time_stands_still`: the rising shards make a stair, the Hour Glass holds
    them and a player stands on one, and they crack when time runs.
  - `test_king_grieve_defeat_gives_the_demon_ring`
- `test_soak.gd`: `test_king_grieve_fight_soak_stays_lean`, a 30 s mashing fight with the throne phase and the glass.
  It averaged 0.57 ms a frame.
- `test_reachability.gd`: `dartmoor/throne_hall` is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.

## Screenshots

`/mnt/project-files/pass-71/`:
- `duel_150.png`: the duel.
- `throne_shards.png`: phase 2, warded on the throne, shards held in stopped time.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90 | Unchanged. |
| World and level design | 15 | 94.25 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 90.5 | A boss built on both of the zone's tools: the parry and the Hour Glass. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 88.75 | A boss-fight soak. |
| Faithfulness | 5 | 90 | Faxanadu's King Grieve and the Demon Ring. |

Weighted score: 89.86 (up from 89.76; 89.8625 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (88.75). Next: King Grieve's phase 3 (the meteor takes him), his theme and
the water clock, then Dartmoor draining.
