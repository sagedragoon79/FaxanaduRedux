# Pass 389: the architecture, as built (Systems)

Category: Systems (last pass 381).

## Audit

Passes 382 to 388 changed no system. The shops (10.2), the saves and options (14, passes 343 and 381) and the skill tree (9) are each held by tests. The audit read the rest of section 14, the technical architecture, which no test read. Most of it was still the plan's, and only the line about saving said where the build had gone another way:

- It named five autoloads that were never built: SaveSystem, EventBus, AudioDirector, InputRouter and RoomManager. The project has five others: `Feel`, `Controls`, `Sfx`, `GameState` and `Music`.
- It laid out a `scenes/` folder for the player, each foe family, boss, room and screen. There is one scene, `scenes/main.tscn`; the nodes are built in code by `class_name` scripts in `scripts/`.
- It promised `.tres` resources, a `scripts/world/room_loader.gd`, YAML room headers and a `levels/world.yaml` graph. The data is JSON, the room script is `scripts/world/room.gd`, the headers are `key: value` lines (`levels/README.md`), and the graph is the rooms' own `door:` and `map:` lines.
- It said the tests were GUT. They run on the project's own `tests/test_runner.gd`.
- It promised "Forward+ (2D lights, glow)". The renderer is Forward+, but no 2D light or glow node is used, and the screenshots run on the Compatibility renderer.

`docs/architecture.md` and CLAUDE.md were right. The bible, which CLAUDE.md calls the source of truth, was the one that had drifted.

## Fix

- Bible 14's Renderer line, Structure list, Level authoring line and Testing line now say what was built. A note records the plan's names, which were never built.
- `test_the_bibles_architecture_is_as_built` (test_systems) checks that:
  - every repository path section 14 names (30 of them) exists;
  - the autoload line counts and names exactly the project's autoloads, and names none of the plan's five;
  - the renderer is Forward+ and the screenshot tool draws on `opengl3`;
  - the tests run on the project's own runner, with no GUT add-on.

Mutation check: with section 14 as it stood on main, 17 checks fail. Ten are paths that don't exist (`scenes/player/` and the rest, `room_loader.gd`, `levels/world.yaml`), and the others are the autoload count and names and the renderer and runner lines.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The architecture section is as built and held to the project. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 390: Audio.
