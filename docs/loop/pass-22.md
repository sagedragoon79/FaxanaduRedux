# Pass 22: Poison and a Tower soak

Lowest categories going in were Faithfulness (60) and Stability (65), so this pass works on both.

## What changed

- **Poison, a drop from Faxanadu.** From the Tower on, Iron Dwarves and Gear Bats sometimes
  (7% of kills) leave a violet flask marked with a skull.
  - It is a hazard to step around while picking up the gold.
  - Walking over it poisons you for 8 s: you lose 2 health a second, but never the last point.
  - While poisoned, your health masks and your sprite turn green.
  - Bread, a shrine or the Guru, or dying cures it. An Ointment keeps it off.
  - Enemies opt in with `Enemy.poison_drops`. The test runner zeroes `Drop.poison_chance`.
  - The design bible (section 7, drops) is updated.
- **Soak tests for the whole Tower** (`tests/test_soak.gd`).
  - Every Tower room is loaded live: enemies, doors and gates, with every ability.
  - A mashing player plays 420 frames in each.
  - The test checks for escapes from the room, being stuck in tiles, invalid positions, and runaway node counts.
  - Set `SOAK_ONLY=tower/a,tower/b` to soak only some rooms.
- **A Foreman fight soak.** A mashing player who can't die fights a Foreman who can't die for 30 s (1,800 frames).
  - It runs at 0.49 ms a frame on average, and the slowest frame is 2.2 ms.
  - At most 15 shockwaves, rocks and dust bursts are live at once.
  - The test asserts fewer than 60 live effects and an average under the 16.6 ms budget.
- **Bug found by the soak: stuck in the floor at an arrival door.** Coming back through Forepaw Stair door 1, or Ore Vault
  door 1, put the player inside the cracked wall behind that door. Physics then pushed them into the floor
  tiles.
  - In normal play you break that wall first. But a shortcut, a test or a later save could reach the far side first.
  - `World` now clears any cracked stone that overlaps the player when they arrive through a door. The block breaks quietly and stays broken.
  - Test: `test_arriving_through_a_door_clears_cracked_stone_in_the_way`.
- `--drops` now also drops a poison flask, and `--poisoned` starts the player poisoned (for screenshots).

## Tests

503 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-22/`:
- `poison.png`: the poisoned player (green cast), green health masks, and bread, a mana orb and the poison flask on the Foreman's Gate floor.
- `poison_zoom.png`: the three drops close up. The flask reads as a violet bottle with a cork and a skull, distinct from bread and the mana orb.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 80 | Poison adds a little risk to collecting drops in the Tower. |
| World and level design | 15 | 77 | Unchanged. |
| Art cohesion | 15 | 73 | Unchanged. |
| Bosses | 10 | 72 | Unchanged. |
| Systems | 10 | 74 | Unchanged. |
| Audio | 5 | 66 | Unchanged. |
| Stability and performance | 5 | 70 | Every Tower room and the Foreman fight are soaked in CI. One stuck-in-floor bug found and fixed. The frame time is measured. |
| Faithfulness | 5 | 62 | Faxanadu's Poison drop. |

Weighted score: 77 (76.60, up from 76.25).

## Lowest categories and next pass

1. **Faithfulness (62)** and **Audio (66)**: Faxanadu's rank-up at the Guru (the title fanfare and the
   original's lines) would help both.
2. **Bosses (72)**: Zoradohna, the Hammer of Forepaw (bible 8.2), beyond the Forepaw Gate.
3. **Art (73)**: the older code sheets at 2x.
