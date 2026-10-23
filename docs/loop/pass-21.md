# Pass 21: Mattock routes

Date: 2026-10-23. Scope: World (75), with Audio (64) and Art (72) touches. Pass 20 put the
Mattock in the world. This pass gives it places to go: the cracked stone in the Tower of
Trunk now leads somewhere.

## What was built

- **Behind the Winch Hall's cracked wall** (door 4) is the **Forepaw Stair** (17,-4), a
  two-screen climb.
  - It opens on a **pogo challenge**: a 26-tile floor of spikes with thorn bulbs hanging
    over it, too wide to jump. Strike down as you fall to bounce across.
  - An east-side climb leads to a ledge where a Gear Bat roosts.
  - High on the west side, a shelf leads to a **Life Fruit** sealed behind cracked stone.
- **Forepaw Gate** (18,-4): the dwarf city's gate, with a shrine and an Iron Dwarf. The gate
  opens from within, so Forepaw and Zoradohna come next.
- **Behind the Tower Foot's cracked wall** (door 4) is the **Ore Vault** (13,-2), reached
  by backtracking to the tower's first room.
  - An Iron Dwarf guards a floor of cut stone.
  - Dig through it with the Mattock into a cache with a chest (260 gold) and a Mana Dew.
  - A step lets you climb back out.
- **Iron portcullis:** in the Tower of Trunk, boss arenas seal with a portcullis that drops
  over the door (iron bars, riveted straps, spiked tips) instead of Trunk roots
  (`ArenaSeal.style`).
- **Mini-boss music:** `miniboss`, a work song turned into a fight. It is in D phrygian at
  128 bpm, with a hammer on every beat and an anvil on the off-beats. The Foreman's arena
  plays it, and `BossArena.BOSSES` can name a track for each boss.

- **Stability fix:** a root-gate opened on an earlier visit was rebuilt with its collision
  still on. The heart's flag said open and the roots weren't drawn, but an invisible wall
  remained, and the log showed a script error each time. `RootGate` now starts with its
  shape disabled when it is already open. The root-heart test checks that no solid shape
  is left.

### The reachability checker learns the pogo

With the Mattock, a fall onto spikes or a thorn bulb counts as a pogo: the checker treats it
as a landing just above the hazard, and the bounce works like a jump from there.

A related fix: jumps that land back at the height they started from (across a gap) are now
counted. The checker used to skip them, and pogo chains need them.

The tests now model the Act I progression:
- With only the glove, every room and pickup outside `MATTOCK_ROOMS` is reachable, and the
  Mattock rooms stay shut.
- With the glove, the Mattock, keys and amber, every room and pickup is reachable, with no
  soft-locks.

## Automated verification

New tests:
- the glove alone can't open the Mattock rooms;
- with the Mattock every room and pickup is reachable, with no soft-locks;
- a checker unit test: a spike floor can't be crossed without the Mattock, and can with it;
- the music list includes `miniboss`.

All earlier reachability tests still pass with the new pogo edges and the same-height jump
fix.

Screenshots reviewed:
- the Forepaw Stair's spike floor and thorn bulbs;
- the Ore Vault with the cut stone floor, the cache below it, and the dwarf;
- the portcullis closed behind the player in the Foreman's Hall.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 80 | Unchanged. |
| World and level design | 15 | 77 | Ability-gated backtracking now pays off: two cracked walls lead to three rooms, a pogo gauntlet and two secrets. 10 tower rooms. |
| Art cohesion | 15 | 73 | The tower's arena seal is now iron, not roots. |
| Bosses | 10 | 72 | Unchanged. |
| Systems | 10 | 74 | The checker models the pogo, so Mattock routes are verified. |
| Audio | 5 | 66 | A mini-boss track. |
| Stability and performance | 5 | 65 | An invisible-wall bug on revisits fixed; the suite's log is free of script errors. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 76 (76.25, up from 75.50).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Stability (65)**: lightly weighted, but the lowest. A
   stability pass, with a soak test across the tower rooms and a frame-time check on the
   Foreman fight, is cheap.
2. **Bosses (72)**: Zoradohna, the Hammer of Forepaw (bible 8.2), beyond the Forepaw Gate.
3. **Art (73)**: the older code sheets at 2x.
