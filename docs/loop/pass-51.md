# Pass 51: The Elven Stride

Conflate's elder points up the north bough to the Windloft, where the wardens learned to stride. This pass opens that
way and places the zone's ability, the **Elven Stride** (bible 4.1 A5, 6.5). Pakukame's arena (8.5) tests it next.

## What changed

- **Elven Stride pickup** (`ItemPickup` kind `stride`, legend `d`): a leaf-green warden's feather trailing wind lines,
  drawn in code at 2x. Taking it sets `abilities.stride`, which the dash already checks.
  - The dash itself was built in the movement prototype and already matches bible 6.5: 380 px/s for 0.15 s,
    invulnerable for the first 0.10 s, one air charge, a 0.25 s ground cooldown and afterimages. Its existing tests
    cover the distance and the air charge.
  - `ItemPickup.ABILITIES` lists the kinds that grant an ability.
- **Rooms:**
  - Conflate's north bough is no longer roped off. Planks climb to a ceiling shaft (door 2).
  - **North Bough** (45,-10, 40x45): pods and planks zigzag up to a high bough with a mantis on it. A warden's cache
    (a Life Fruit on a plank) hangs out over the gap, a stride beyond any jump. That is the first stride gate.
  - **Windloft** (46,-10): the wardens' shrine, a rest shrine, and the Stride on a plinth.
- **Reach:** with `stride`, every jump envelope reaches `STRIDE_REACH` (3) tiles further across, an air dash at the
  top of the jump.
- Bible 4.1 (A5, where it is found) is updated. `levels/README.md` has the `d` row.

## Tests

- `test_world.gd`: `test_elven_stride_grants_the_dash`. Dash does nothing before the Stride. Taking it grants the dash
  and saves it, Dash then strides, and the feather doesn't come back.
- `test_reachability.gd`:
  - `test_elven_stride_crosses_the_gap_to_the_warden_cache`: the Stride can be reached without it, the cache can't,
    and with it every pickup is reachable with no soft-locks.
  - `STRIDE_SECRETS` are left out of the Mattock and Wing Boots checks.
  - Both new rooms are in `MATTOCK_ROOMS`.
- `test_soak.gd`: the Branches soak covers both rooms. It already mashes Dash with every ability on.

## Screenshots

`/mnt/project-files/pass-51/`: `windloft.png` (shrine and the feather on its plinth), `north_bough_top.png` (the high
bough, a mantis, and the cache across the gap) and `conflate_shaft.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | The dash is now part of play, not a debug toggle. |
| Combat and enemies | 15 | 87 | Unchanged. |
| World and level design | 15 | 91.5 | The zone's ability, its shrine and a first gate. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 87 | Unchanged. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 87 | Unchanged. |
| Stability and performance | 5 | 85 | Unchanged. |
| Faithfulness | 5 | 88 | Unchanged. |

Weighted score: 87.78 (up from 87.70).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest is Stability (85). Next: **Pakukame**, the Devouring Bloom (bible 8.5), on
the crown-leaf above the Windloft, code-drawn at 2x. Phase 1 is vine whips and seed spit with a mouth that opens
after each bite. Phase 2 bites gaps in the leaf to stride across. Phase 3 can come in a later pass. Add a boss soak
for stability.
