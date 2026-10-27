# Pass 170: the Proving Scar

World, Bosses, Systems, Audio, Stability and Faithfulness were tied at 98.75. World weighs the most (15), so pass 170 takes World. I audited the world against bible 3 and 4, `levels/README.md` and the newest content (passes 162 to 169).

| Check | Finding | Verdict |
| --- | --- | --- |
| Alpha's Den (pass 169) | the kennels' plank lid lets you climb back out; the den is reachable and has no soft-lock | fine |
| The trials (passes 162, 168) | they are off the map, entered through the Guru, and each has a checker proof | fine |
| Save spacing | every zone has a shrine or a Guru within reach; Zenis has two, one at the top of the Drift Well | fine |
| **Zenis, the gauntlet** | The zone table plans 14 rooms and a "gauntlet using every ability", and 4.2 puts the gauntlet between the Dragon Slayer and the Evil One. Zenis had 7 rooms. The Heart Gate opened straight onto the throne, and the climb asked for nothing past the Glove, the Hour Glass and the drift. Zenis's key mechanic was never built. | **built** |

## As built

**The Proving Scar** (`levels/zenis/proving_scar.room`, 67,-12, 80x45) now lies between the Heart Gate and the Throne of Zenis. It is a scar through the meteor that walks every earlier road once more, one gate after another:

1. A fire seal (Deluge).
2. A chimney 23 tiles tall with no ledge in it (the Climbing Glove).
3. Two thorn-faced steps six tiles high (the Wing Boots).
4. A nine-tile gap over a pit with a Storm Harpy in it (the Elven Stride).
5. A conduit gate guarded by a Shade Knight (Thunder).
6. A plug of cracked stone over a shaft down to a hound (the Mattock).
7. A shaft of time-locked water (the Hour Glass).
8. An illusory wall at the top (the Black Onyx).

A shrine waits in the last hall, before the throne. The throne and the arenas past it moved two screens east on the map. Zenis now has 8 rooms.

## Screenshots

- `/mnt/project-files/pass-170/scar-entry.png`: the fire seal and the foot of the chimney.
- `/mnt/project-files/pass-170/scar-steps.png`: the second boots step, the stride gap with the Harpy, and the far ledge's conduit.
- `/mnt/project-files/pass-170/scar-glass.png`: the hound's chamber, the time-locked water and the shrine in the last hall.

## Tests

- `test_reachability.gd`, `test_the_proving_scar_asks_for_every_ability` (new): with every ability, the checker crosses the Scar to its shrine. Without any one of the seven (Glove, Boots, Stride, Mattock, Thunder, Deluge, Hour Glass), it can't.
- `test_rooms.gd`, `test_the_proving_scar_lies_between_the_slayer_and_the_throne` (new) checks that:
  - the doors chain the Heart Gate, the Scar and the throne;
  - each gate is a live object of its kind;
  - the shrine stands in the last hall;
  - the three foes are corrupted.
- The Scar has been added to the Mattock and Thunder room lists. Three checker kits now include what the Scar asks for:
  - the Dragon Slayer test and the Fire and Thunder test now carry the Wing Boots;
  - the turned-wind test now carries the Dragon Slayer, since its "every pickup in the game" check now includes a shrine past the flesh.

Full suite: 3231 checks, all passing, with no script errors in the log. The first run caught the two kits that were missing the Boots and the Dragon Slayer; both were fixed, and their tests pass.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Zenis has its gauntlet: the last climb asks for every ability, and a checker proof shows that each one is needed. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.775 (up from 96.7375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.75. Bosses and Systems weigh the most (10), and Bosses' last pass (163) is the older, so pass 171 takes Bosses.
