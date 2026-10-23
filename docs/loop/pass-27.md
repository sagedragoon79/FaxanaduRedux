# Pass 27: The Minecart Rider

The Tower's last listed enemy (design bible 7), and a save test across the Act I state. Faithfulness was 70 and
Stability 70 going in.

## What changed

- **Minecart Rider** (`MinecartRider`, room tile `K`). A Forepaw dwarf hunched in an ore cart.
  - Trundles the floor at 30 px/s and turns at walls and floor ends.
  - With you level with him (within 170 px and 30 px of height) he turns to you and hauls the brake for 0.6 s: the sprite
    pulses white, the wheels throw sparks, and the brake shrieks every 0.2 s. That is the telegraph.
  - Then he charges at up to 230 px/s, throwing sparks off the wheels; contact costs 22 health instead of 10. Jump him.
  - At a wall or the floor's end the cart stops dead, shakes the screen and tips forward for 1.1 s: the rider is dazed and
    takes every blow. A charge that finds nothing stops after 2.2 s. He then turns and trundles on.
  - The iron tub lets through only 40% of a blow, except from above (a pogo on the rider) or while tipped.
  - 56 HP, 8 to 14 gold, 20 XP, and a Poison drop like the other Tower dwarves.
  - Sheet `minecart_rider` from `castgen.py`, drawn at 2x: a riveted rust-red tub with ore heaped at the back, spoked
    wheels, a lamp, and a goggled rider with a pick. Animations: roll, rev, charge, crash (tipped, dazed stars), stagger.
- Placed in **Mine Mouth** and the **Rail Gallery** (between the spike pits, so his charge ends at the pit's edge).
- **Bible:** the Tower enemy list in section 7 describes him.

## Tests

- `test_minecart_rider_revs_charges_and_crashes_into_the_wall`: a rev of at least `MIN_TELEGRAPH`, a charge above 150 px/s
  that runs down a player on the floor, and a crash at the far wall.
- `test_minecart_tub_turns_blows_until_it_crashes`: 40% from the side, full from above, full while tipped.
- `test_act_one_state_survives_a_save_round_trip`: spring and boss flags, Mantra Path stops and their positions, the blade's
  temper, the named title, Mantra Shards and the Mattock all survive a save, a new game, and a load.

591 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-27/`: `rider_sheet.png` (every frame, 3x), `mine_mouth.png` (the rider revving, white, at the
east end of Mine Mouth).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | A charger with a clear tell and a clear punish window; the Tower roster is complete. |
| World and level design | 15 | 80 | Unchanged. |
| Art cohesion | 15 | 74 | The rider matches the 2x code-drawn cast. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 77 | Unchanged. |
| Audio | 5 | 71 | Unchanged (reuses the guard and dash sounds). |
| Stability and performance | 5 | 72 | The Act I state round-trips through a save. |
| Faithfulness | 5 | 71 | The original's Tower cast is all here. |

Weighted score: 79 (79.35, up from 78.90).

## Lowest categories and next pass

1. **Faithfulness (71)** and **Audio (71)**: a cart rattle and a brake shriek of their own; Tower landmark rooms (the bible
   wants three per zone: the great winch, the forge, and one more) and the remaining Tower rooms (16 of 26).
2. **Stability (72)**: soak the Mantra Path and lift travel under random input.
