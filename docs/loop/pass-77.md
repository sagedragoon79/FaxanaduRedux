# Pass 77: Zenis begins

The gate of Zenis opens onto the meteor (bible 8.9, section 9 world table).

## What changed

- **The gate opens** (`scripts/world/zenis_gate.gd`):
  - The gate now stands flush against the east wall of `dartmoor/zenis_gate`, with the room's new door 2 behind it.
  - While shut, a StaticBody bar (`BAR`) closes the way from the floor to the vault.
  - `is_open()` once all four rings are held and `boss:shadow_eura` is set. The leaves then fold back over about a
    second on the meteor's cyan light, the bar comes away, and you walk through.
  - The ring sockets moved up into the arch so they stay visible on the open gate.
- **Zenis zone** (`levels/zenis/`):
  - Tiles: `paint_meteor` in `tools/art/tilegen.py` (Voronoi cells of black-violet scar tissue, blood-red seams, cyan
    pores; crystal-lit cap).
  - Backdrops: `zenis_far` (ribbed shell walls, veins of light, a red glow below) and `zenis_mid` (hanging and
    rising tendrils with cyan bulbs).
  - Decor: `decorgen.py` adds polyps, crystal splinters, floor veins, tendrils, vault eyes, a wall eye and a flesh
    shelf.
  - Audio: `track_zenis` (B locrian at 84 over a heartbeat, pads detuned against each other) and `amb_zenis`
    (breathing drone, heartbeat, glassy whines). `musicgen.py` gains a `locrian` scale.
  - Zone registration: in `World.ZONES`, cyan spore motes, footsteps `moss`, decor glow cyan, iron arena seals.
- **Rooms**:
  - `zenis/threshold` (62,-9, 60x23): a landing with a sign, a shrine, flesh pillars up from the floor and down
    from the vault, a spiked trench, a Shade Knight and a Crystal Dwarf.
  - `zenis/heart_stair` (63,-10, 40x45): seven switchback shelves with a Meteor Slug, a Crystal Dwarf, two Shade
    Knights and a Clockwork Hound. The heart above is not open yet.
- Both rooms are in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.
- **Docs**: bible 8.9 has an as-built note for the way in.

## Tests

- `test_rooms.gd`: `test_the_gate_of_zenis_opens_onto_the_meteor`. Three rings don't open it; shut, it stops you at
  its face; four rings and the shadow open it; you walk through into Zenis with its theme, ambience and motes; the
  Threshold leads on.
- `test_soak.gd`: `test_random_input_soak_in_every_zenis_room`.
- `test_boss.gd`: `zenis` and `amb_zenis` are added to the music list.

## Screenshots

`/mnt/project-files/pass-77/`:
- `threshold.png`
- `heart_stair.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90.5 | Unchanged. |
| World and level design | 15 | 95 | The last zone opens, with a real gate. |
| Art cohesion | 15 | 84.75 | Zenis has a look of its own (code-drawn, serviceable). |
| Bosses | 10 | 93.25 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 90.5 | Zenis theme and ambience. |
| Stability and performance | 5 | 89 | One more zone soak. |
| Faithfulness | 5 | 90.5 | The ring-gate opens onto Zenis, as in the original. |

Weighted score: 90.46 (up from 90.31; 90.4625 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (89). Next: Zenis's corrupted enemies ("remixes of every family") and its
"gravity wrong" mechanic, then the Dragon Slayer and the heart.
