# Pass 31: Tower ambience, the Sorting Floor and the Slag Heap

Audio was the lowest category (72). This pass gives the Tower's parts their own sound and adds two Deep Workings
rooms. That makes 21 of 26 Tower rooms.

## What changed

- **Room ambience.** A room header can now name its own ambience bed: `ambience: heights` plays `amb_heights`.
  `Music.for_room` falls back to the zone's bed when there is none. This is documented in the levels README and in
  bible 11.
- **Two new beds** in `tools/audio/musicgen.py`:
  - **amb_heights** for the Old Flue and the Rafters: gusting band-limited wind and a breathy howl that bends with the
    gusts, plus a loose shutter knocking in bursts and roof beams creaking.
  - **amb_mine** for the Deep Workings rooms: a low stone hush, drips with a short echo off the shaft walls, two carts
    rumbling through the rock (with wheel clacks panning across), and far-off picks.
  - Both loop with the same tail fold as the other beds.
  - Levels were checked against amb_tower: RMS 0.07 against 0.11, the same 0.54 peak. Ambience plays under the zone
    theme at the fixed ambience level.
- **Sorting Floor** (`tower/sorting_floor`, 23,-4, 80x23).
  - Reached through a new east door in the Mine Mouth (door 3).
  - A beam climb leads to a ceiling shaft that comes up through a new floor shaft in the Mine Vault (door 2). This
    makes a loop: Mine Mouth, Sorting Floor, Mine Vault, Rail Gallery, Mine Shaft, Mine Mouth.
  - It has an Iron Dwarf, a Minecart Rider, two Gear Bats, a chest, and a Potion Shard behind cracked stone.
- **Slag Heap** (`tower/slag_heap`, 25,-5, 80x23).
  - It is under a new floor shaft in the Smelter's walkway (door 2).
  - Cooled slag lies in spike drifts, with a beam bridge over the first one.
  - Two Iron Dwarfs and two Gear Bats guard it. There is a chest on a high ledge and a Mantra Shard behind cracked
    stone.
  - A beam climb leads back to the shaft.
- **Bible:** 4.4 lists the two side rooms, and 11 describes the Tower's three beds.

## Tests

- `test_tower_rooms_pick_their_ambience_and_theme` (test_boss) walks Winch Hall, the Flue, the Rafters, Forepaw, the
  Mine Mouth and the Smelter. It checks each room's music and ambience.
- `test_music_follows_rooms_and_bosses` now also checks that the two new beds load as loops.
- `MATTOCK_ROOMS` gains the two new rooms. The reach tests pass: every pickup is reachable with the Mattock, with no
  soft-locks.

620 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-31/`:
- `sorting_floor.png`: the beam climb to the vault shaft, the rider and the chest.
- `slag_heap.png`: the slag drift, the shaft's beam climb, and the cracked pocket with its Mantra Shard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 83 | The Deep Workings now loop, and there are two more optional rooms with rewards. 21 of 26 Tower rooms. |
| Art cohesion | 15 | 78 | Unchanged. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 80 | Unchanged. |
| Audio | 5 | 75 | The Tower's three areas now sound distinct. The music is still placeholder synth. |
| Stability and performance | 5 | 73 | Unchanged. |
| Faithfulness | 5 | 74 | The mining tower reads as a working mine. |

Weighted score: 81 (81.10, up from 80.75).

## Lowest categories and next pass

1. **Stability (73)**: soak the new rooms (`test_soak` covers every tower room automatically). Profile the HUD's
   per-frame polygon clipping.
2. **Faithfulness (74)** and **World**: the last 5 Tower rooms.
3. **Art (78)**: a code-generated pixel font for the HUD and menus.
