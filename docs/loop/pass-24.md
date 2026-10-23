# Pass 24: Zoradohna, the Hammer of Forepaw

The Tower of Trunk's main boss (design bible 8.2), the biggest remaining M4 gap. Bosses was 72.

## What changed

- **Zoradohna** (`scripts/bosses/zoradohna.gd`, extends `Enemy`, group `boss`). A walking siege drill with a dwarf
  champion in the cockpit. 360 HP, phases at 65% and 30%.
  - **The hull** lets a quarter of a side blow through. Down-strikes on the stacks and cockpit land in full
    and bounce the player (pogo with the Mattock).
  - **Stuck drill:** ramming a wall (1.5 s) or diving into the floor (1.1 s) leaves the drill stuck and open to any blow.
  - **Phase 1:**
    - Drill charge: 0.8 s spin-up tell, then a 270 px/s ram that hurts on contact.
    - Stomp: 0.7 s rear-up tell, then a slam with a shockwave each way.
  - **Phase 2:** the lift rises (`LiftShaft`, girders and cable marks streaming down the shaft wall).
    - Debris falls every 2.4 s, one rock over the player, each marked 0.7 s ahead.
    - Every third attack the drill runs to a wall, climbs it, marks the player's spot (0.7 s) and dives.
    - Tells are 20% shorter, never under `Enemy.MIN_TELEGRAPH`.
  - **Phase 3:** the cockpit bursts open (1.3 s, invulnerable) on the meteor-crystal harness. Side blows glance off.
    Strikes from above hit for 1.5x.
  - **Defeat:** the harness shatters, the dwarf is freed, and the player gets the **Ruby Ring** and a skill point (`BossArena`).
- **The Forepaw Lift** (`levels/tower/forepaw_lift.room`, 19,-4): a one-screen lift platform with two side ledges
  to escape the drill. It is reached through a new east door in the Forepaw Gate. The iron portcullis seals
  the arena, as in the Foreman's Hall. It is a Mattock room in the reach checker.
- **Sheet:** `zoradohna` from `castgen.py` at 2x (128x88 cell, origin 60,84). It has 15 animations: idle, walk,
  drill_tell, drill, stuck, slam_tell and slam, each with an `open_` variant for phase 3, plus freed.
  - The climb and dive turn the machine in code.
  - The hull is rust-red so it reads against the lavender tower walls (the Foreman's lesson).
- **Screenshots:** `--boss-hp=F` now also works for Zoradohna (it jumps to that phase).
- **Bible:** section 8.2 now records the built design and its two deviations.
  - The arena is one screen with the rise drawn behind, rather than a scrolling shaft.
  - Falling debris is dodged, not pogoed.

## Tests

There are 9 new tests in `test_boss.gd`:
- the arena wakes it, with the shaft drawn behind;
- the telegraphs are fair in all three phases;
- the hull armor and the full-damage pogo vents;
- the wall ram leaves it stuck and fully vulnerable;
- the charge hurts the player in its path;
- the slam sends shockwaves both ways;
- phase 2 raises the lift, drops debris, and climbs and dives at the player's spot;
- phase 3 opens the cockpit (side blows 0, strikes from above 1.5x);
- defeat gives the Ruby Ring and a skill point once, and opens the way out.

546 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-24/`:
- `lift_phase1.png`: the intro, with the title banner and the boss bar with its two phase marks.
- `lift_rising.png`: phase 2, with girders on the shaft wall, a rock falling, and the red siege drill against the tower stone.
- `lift_open.png`: phase 3, with the hatch thrown back and the pink crystal harness on the dwarf's chest.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 81 | A boss built around the pogo. |
| World and level design | 15 | 78 | The Forepaw Gate opens onto the lift. 12 tower rooms. |
| Art cohesion | 15 | 73 | The code-drawn boss sheet is readable but toy-like next to the HD Foreman. It is queued for the art thread. |
| Bosses | 10 | 77 | Three phases with a rising lift, a wall climb and dive, and a cockpit you crack open. |
| Systems | 10 | 74 | Unchanged. |
| Audio | 5 | 67 | Unchanged. Zoradohna uses the generic boss theme. |
| Stability and performance | 5 | 70 | Unchanged. |
| Faithfulness | 5 | 66 | Zoradohna and the Ruby Ring, as in the original. |

Weighted score: 77 (77.45, up from 76.80).

## Lowest categories and next pass

1. **Faithfulness (66)** and **Audio (67)**: freeing Forepaw (the dwarves return, the elevator to Eolis, the
   smith, bible 4.4), and a Tower boss theme.
2. **Stability (70)**: add the Forepaw Lift to the soak (it is a tower room, so the soak already plays it).
3. **Art (73)**: the HD Zoradohna sheet from the art thread.
