# Pass 70: the King's Stair and the Clockwork Hound

Dartmoor's fourth enemy (bible 7), and the stair down from the Drowned Market to the door of King Grieve's throne hall.

## What changed

- **Clockwork Hound** (`scripts/enemies/clockwork_hound.gd`, legend `j`). It is code-drawn at 2x.
  - One of King Grieve's brass hunting dogs: a riveted barrel body, steel legs, a hinged jaw, red eyes, and a winding
    key on its back.
  - **Pounce**: it trots after you. Within 120 px it crouches and its key spins up, ratcheting, eyes blazing, for
    0.45 s (the tell; new sfx `ratchet.wav`, appended at the end of sfxgen so every other wav stays byte-identical).
    Then it pounces in an arc aimed to land on you and bites for 14, parryable. It skids for 0.5 s on landing and waits
    1.1 s before it pounces again.
  - **Plating**: it takes half of every blow.
  - **Parry**: a parried bite throws it on its back for 1.3 s, belly bare, and every blow lands in full.
  - **Hour Glass**: it is clockwork, so stopped time stops it dead, mid-leap or not. It is the one enemy the glass
    stops (bible A8 updated).
  - 44 HP, 10 to touch, 22 XP, 8 to 14 gold.
- **The King's Stair** (`levels/dartmoor/kings_stair.room`, 55,-8, 40x45). It is reached through a doorway (an inner
  door) where the Drowned Market's sealed stair used to be.
  - The upper flight's only way down is through the king's fall.
  - The way back up is a frozen climb, with a dry niche halfway to wait out the glass.
  - At the foot are two hounds and a shrine.
- **The King's Kennels** (`levels/dartmoor/kings_kennels.room`, 56,-7, 80x23):
  - Three hounds among low stalls, and a spiked drain.
  - The kennel-master's loft is up hidden planks, with a 900-gold chest.
  - A shrine, and the shut door of the throne hall.
- **Docs**:
  - Bible 7 has the hound as built.
  - Bible A8 notes the hounds stop in stopped time.
  - The Dartmoor note covers the stair and the kennels.
  - The README legend gains `j`.

## Tests

- `test_enemies.gd`:
  - `test_clockwork_hound_winds_up_then_pounces`: the tell lasts at least `MIN_TELEGRAPH`, and the pounce bites a player
    standing still.
  - `test_clockwork_hound_plating_and_a_parry_flips_it`.
  - `test_clockwork_hound_stops_dead_in_stopped_time`.
- `test_rooms.gd`: `test_the_kings_stair_runs_down_from_the_market_to_the_kennels`.
- `test_reachability.gd`: both rooms are in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.
- The Dartmoor soak covers both rooms.

## Screenshots

`/mnt/project-files/pass-70/`:
- `stair_top.png`
- `stair_foot.png` (the fall frozen)
- `hound_30.png` and `hound_60.png` (the kennels)

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90 | An enemy that both the parry and the Hour Glass answer. |
| World and level design | 15 | 94.25 | A stair whose only way down is the water, and back up only frozen. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.25 | A new ratchet. |
| Stability and performance | 5 | 88.5 | Unchanged. |
| Faithfulness | 5 | 89.75 | Unchanged. |

Weighted score: 89.76 (up from 89.69; 89.7625 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (88.5). Next: King Grieve (bible 8), in the throne hall past the kennels.
