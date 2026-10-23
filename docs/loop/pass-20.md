# Pass 20: the Foreman, and the Mattock

Date: 2026-10-23. Scope: Bosses (68). The Tower of Trunk's mini-boss guards the Mattock,
the Act I ability that lets you pogo and break cracked stone (bible 5, A2). The player
already knew how to pogo and break stone. Until now nothing gave the Mattock.

## What was built

- **The Foreman** (`scripts/bosses/foreman.gd`, an `Enemy`, in the `boss` group so the HUD
  shows its bar). He is a rock golem the dwarves set to work the tower, still wearing a
  foreman's lamp-helm, with the Mattock wedged in his back. He has 220 HP, and his rock
  halves every blow except one from above or while he is stunned. Blows never interrupt
  him. He plods after you and picks an attack by distance, never repeating a close or
  middle attack:
  - **Pound** (close): fists overhead for 0.75 s, then a two-fisted slam. It crushes what
    is in front of him (22, can't be parried) and sends a Shockwave rolling each way.
  - **Throw** (middle distance): he heaves a boulder overhead for 0.6 s, then lobs it at you
    (`scripts/bosses/rubble.gd`).
  - **Charge** (far, or every fourth attack): he crouches and scrapes the floor for 0.85 s,
    then barrels across the hall. Jump him or take a ledge. If he meets a wall, he is
    **stunned** for 1.8 s and takes full damage. The impact shakes 3 rocks loose from the
    ceiling, one over you. Each rock marks its spot with a growing shadow and trickling
    grit for 0.7 s before it falls.
  - **Phase 2** (below half health): tells are 25% shorter (never under
    `Enemy.MIN_TELEGRAPH`), he charges faster, the wall shakes down 4 rocks, and the pound
    drops 2.
  - He gets a name card, a roar, and a crumbling death.
- **2x sheet** (`foreman`, cell 96x80, Canvas scale 2), with 10 animations. He is drawn in
  warm rock brown with gold ore veins, so he stands out from the lavender tower stone.
- **Foreman's Hall** (19,-5) is the arena, east of the Foreman's Gate, whose barred end
  now opens. The hall has two ledges for dodging the charge. It uses `boss: foreman`:
  `BossArena` seals the way in, spawns him at the far end and, on his defeat, grants the
  boss's `ability`. The Mattock goes to the player and `GameState`, with a banner
  explaining it.
- Bible 7 records the Foreman's numbers.

## Automated verification

Seven new tests in `test_boss.gd`:
- the hall wakes him at the far end and seals the way in;
- every tell in both phases, and the rockfall tell, is at least `MIN_TELEGRAPH`;
- the charge scrapes first, hits the far wall, stuns him and drops rocks, and he takes
  full damage while stunned;
- his rock halves a blow, a blow from above lands in full, and blows don't interrupt him;
- the pound sends a shockwave each way;
- the boulder is lobbed and lands on a player standing still;
- beating him gives the Mattock (in the player and in `GameState`), marks him beaten,
  reopens the door, and he never returns.

The animation test checks the sheet. Reachability passes; the hall is a dead end until
the Mattock opens cracked stone.

Screenshots reviewed: the sheet; the name card over the hall, with him in the pound tell; the
charge.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 80 | Unchanged. |
| World and level design | 15 | 75 | 7 tower rooms; the Mattock is now in the world. |
| Art cohesion | 15 | 72 | The golem reads well; the arena seal is still Trunk roots, not iron. |
| Bosses | 10 | 72 | A mini-boss with three readable attacks and a punish window. |
| Systems | 10 | 73 | The second ability is earned; a boss reward can be an ability. |
| Audio | 5 | 64 | Unchanged; he borrows the boss track. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 76 (75.50, up from 74.85).

## Lowest categories and next pass

1. **Faithfulness (60)**, **Stability (63)** and **Audio (64)**: lightly weighted. A mini-boss
   track and an iron arena seal for the tower would help both Audio and Art.
2. **World (75)**: Mattock routes. The cracked stone in the Winch Hall and the Tower Foot
   leads up toward Forepaw and Zoradohna.
3. **Bosses (72)**: Zoradohna, the Hammer of Forepaw (bible 8.2).
