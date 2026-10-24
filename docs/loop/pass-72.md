# Pass 72: King Grieve's last phase, his theme and the water-clock

Finishes King Grieve (bible 8.7).

## What changed

- **Phase 3** (below a fifth, `KingGrieve.PHASES` is now `[0.5, 0.2]`): the meteor takes him.
  - He roars and cracks open for 1.4 s, untouchable. If he is on the throne he leaps down in front of it, and he
    never goes back.
  - Frantic now:
    - He walks at 1.8x.
    - His tells run at 0.65x, never under `MIN_TELEGRAPH`.
    - Every chop and sweep ends in a third blow: the axe raised again (0.45 s at full speed), then driven into the
      floor. Six Crystal Dwarf spikes burst out in a line toward you, 22 px and 0.08 s apart.
  - Cracked, he turns no blow, and a parry still opens him.
  - He is drawn with crystal cracks pulsing across his robe and face, and a glow while the meteor takes him.
- **His theme**, `grieve` (`tools/audio/musicgen.py`): the Dartmoor dirge risen into a march, D phrygian at 112, with
  war drums, a tolling bell and crystal stabs on the offbeats. `BossArena` plays it for the fight.
- **The water-clock** (`scripts/world/water_clock.gd`, room prop `water_clock`): a tall bronze-framed glass column of
  flood-water in the Throne Hall. It is full before the fight, drains as his health falls, and stands empty once he is
  beaten.
- `--boss-hp` under a fifth puts him in phase 3.
- **Docs**: bible 8.7 has phase 3, the water-clock and the theme as built.
- **Deferred**: Dartmoor draining and the Sunken Spring entrance. These are world changes that would rework the
  time-locked water routes, so they need their own pass.

## Tests

- `test_boss.gd`:
  - `test_the_meteor_takes_king_grieve_below_a_fifth`:
    - frantic tells stay fair;
    - he is untouchable while it happens and then comes down off the throne;
    - full damage from then on;
    - his combo ends in a burst of spikes.
  - `test_the_water_clock_drains_with_the_king`.
  - The wake test checks his theme plays, and `grieve` is in the music list.

## Screenshots

`/mnt/project-files/pass-72/`:
- `cracked_130.png` and `cracked_175.png`: phase 3.
- `clock.png`: the water-clock half drained.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90 | Unchanged. |
| World and level design | 15 | 94.25 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 91 | A full three-phase fight, with its own theme and an arena that tells the time. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.5 | A new boss theme. |
| Stability and performance | 5 | 88.75 | Unchanged. |
| Faithfulness | 5 | 90 | Unchanged. |

Weighted score: 89.93 (up from 89.86; 89.925 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (88.75). Next: Dartmoor draining after King Grieve, and the Sunken Spring.
