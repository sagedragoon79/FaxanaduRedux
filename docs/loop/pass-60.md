# Pass 60: Borabohra's roost

Daybreak's boss (bible 8.6), phase 1, code-drawn at 2x. The Spires now end in a fight that uses Thunder, the zone's
spell: the bird is mostly cloud in the air, and only lightning brings it down where a blade can reach it.

## What changed

- **The Roost** (`levels/daybreak/roost.room`, 58,-12, 60x23, header `boss: borabohra`):
  - It is reached by a new east door off the Spire Stair's top landing.
  - Three stone islands float over a cloud-stone floor, each topped by a dead conduit. Wooden landings step up to
    them.
  - Conduits in a boss room get no world flags (`room.gd`), so they wake afresh each fight. `Conduit.reset()` lets
    them go dead again.
  - The arena seals with iron portcullises, like the Tower's.
- **Borabohra** (`scripts/bosses/borabohra.gd`):
  - 320 HP. It circles a slow figure-eight over the islands.
  - In the air its cloud turns blows to 30%, and it touches for 14.
  - **Feather volley**: the wings go wide for 0.6 s, then a fan of five harpy feathers. A parried feather flies home
    and hits it.
  - **Dive bomb**: a 0.65 s fix, then a stoop through where you stood for 22, unparryable, and a climb back out.
  - **Grounding**: when all three conduits are awake, lightning arcs from each to the bird. It falls to the floor and
    lies open for 4.5 s, taking blows in full, then the conduits go dead and it rises.
  - It is drawn half again larger than its body box, with cloud-billow wings, flight feathers and trailing rain.
  - Its reward is the Sky Key and a skill point.
- **Music** `borabohra` (E minor at 150: a galloping bass, thunder-roll toms, stabbed fifths and the bell lead).
- **Screenshot option** `--conduits=N` wakes every conduit at frame N.
- **Bible 8.6** describes the fight as built. Phases 2 and 3, the wide camera and the Spring of Sky are deferred.
  Bible 3.2 has the roost note.

## Tests

- `test_boss.gd` adds six tests:
  - The roost wakes it, with its own theme.
  - The tells are fair.
  - The volley throws five feathers.
  - The dive hurts a player who stands still, then it climbs back.
  - The conduits ground it: two are not enough, and the third drops it to the floor with full damage. It then rises
    and the conduits go dead, with no world flag set.
  - Its defeat gives the Sky Key and a skill point, and it never returns.
- `test_reachability.gd`: the roost is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`. The existing fire and thunder flood
  checks it, so no new flood was added.
- The music test lists `borabohra`, and the Daybreak soak covers the new room.

## Screenshots

`/mnt/project-files/pass-60/`:
- `roost_intro.png`: the roc arrives with its banner.
- `roost_grounded.png`: grounded by the conduits, eye shut.
- `roost_60.png` and `roost_200.png`: the arena from the door.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 89 | Unchanged. |
| World and level design | 15 | 92.5 | Unchanged. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 89.25 | A sixth boss, built around the zone's spell. Phases 2 and 3 are still owed. |
| Systems | 10 | 89.25 | Unchanged. |
| Audio | 5 | 89 | A new boss theme. |
| Stability and performance | 5 | 86.75 | Unchanged. |
| Faithfulness | 5 | 89 | Borabohra guards the Sky Key, as in the original's tower top. |

Weighted score: 88.95 (up from 88.85).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (86.75). Next: chase the 8 ObjectDB leaks at suite exit and add a frame-time
soak of the roost fight. After that, Borabohra's phase 2 (the lightning storm that strikes the tallest point).
