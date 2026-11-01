# Pass 379: secrets, counted (World)

Category: World (last pass 371).

## Audit

Passes 372 to 378 added no rooms. Pass 373's minimap draws shrines and shut key doors from the catalog that the full map uses, and its test covers that. Pass 377's ledger marks which zones are the original's. So the audit read sections 3, 4 and 11 for claims about the world that no test reads:

- 3.2's rooms, 3.3's shrines, landmarks and charts, and 11's secrets table are all held to `levels/`.
- 4.4's world-state rows are each tested where they are built.
- 11 opens: "Target: **at least 3 secrets per zone room-cluster**, about 70 total." The rubric's World row scores "secrets per zone", but nothing counted them. A probe that counts as the completion card does (hidden rooms, and treasures from the map's catalog) found that the line no longer described the game:
  - the world holds 12 hidden rooms and 128 treasures, 140 in all, twice "about 70";
  - Zenis holds only two, its hidden pocket in the Threshold with the Battle Helmet in it;
  - the Sunken Spring hides no room.

## Fix

- Bible 11 has a new note, "Secrets per zone, as built (pass 379)". It does three things:
  - It says how secrets are counted (as the completion card counts them, with treasures in plain sight included).
  - It gives the world's total.
  - Its table gives each zone's rooms, hidden rooms, treasures and sum.
- The note records two exceptions:
  - Zenis falls short of three by design: it is the last climb and keeps no side treasure (pass 135).
  - The Sunken Spring makes up its count with finds, not a hidden room.
- `test_every_zone_holds_the_secrets_the_bible_counts` (`test_rooms.gd`) builds the real catalog and checks:
  - every zone's row against the rooms;
  - three or more secrets in every zone but Zenis;
  - the total.

Mutation checks:
- With the Battle Helmet taken out of the Threshold, the test fails 2 checks (Zenis's row and the total).
- With the Sunken Spring's row set to 6 treasures, it fails 1 check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. Secrets per zone, a rubric item, are counted and held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 380: Bosses.
