# Pass 363: the room legend, held both ways (World)

Category: World (last pass 355).

## Audit

Passes 356 to 362 built no room and moved no gate. The reachability, door, size, gate-number and README-jump tests still hold the world.

Pass 355 tested the README's safe jumps and room sizes. The README's other half had no test: its legend, the key to every character a room's grid can hold. A script read every room's grid and the loader's cases in `Room._place` and compared them with the legend, both ways:
- `x`, the Evil One's **light veins** in `zenis/veins` (pass 82, bible 8), is placed by the loader and used in a room, but had no legend row. A builder reading the README could not know the character was taken, and might reuse it or think the Veins room was wrong.
- Every other character matched both ways. The combined rows (`/` `\`, `>` `<`, `1`-`9`) and the ones placed outside `_place` (the basin's stain `=`, the doors, empty air) were accounted for.

## Fix

- `levels/README.md`: an `x` row for the light vein, and a line saying the legend is held.
- `test_the_readme_legend_matches_the_rooms` reads the legend, all of it, including the combined and range rows. It then checks that:
  - every character any room's grid uses has a row;
  - every row is a character the loader places (read from `Room._place`, plus the doors, the basin's stain and empty air).
- Bible 3.3: the builder's notes gain "The legend, held both ways (pass 363)".

Mutations:
- With the `x` row removed, the check names `x (zenis/veins.room)`.
- With a legend row for a character the loader doesn't know, it names that character.
- With the slope row cut to `/` alone, it names `\ (tower/ore_vault.room)`.

## The full run

The full run failed 1 check: `test_a_journey_after_the_end_stays_lean`. On its second lap, `tower/mine_shaft` had a burst of three frames over 50 ms (57.0, 101.3 and 86.4 ms, at frames 27, 29 and 34). This pass changed no game code and no soak, only the README, `test_rooms.gd` and the docs. Run alone, the test passed (worst 8.9 ms).

This is the second burst like this in five passes. Pass 359 saw one in `eolis/guru_temple` on the first lap. The rooms differ and each passes alone, which points to the host, not a room. One clue for pass 365 (Stability): the retraced lap holds 4,252 live objects in the full run against 3,335 alone. Nearly a thousand more objects are alive by the time this soak runs, so a garbage or allocation pause late in the suite is worth tracing frame by frame, as pass 182 did.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. The builder's legend is complete and held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 364 takes Bosses (last pass 356).
