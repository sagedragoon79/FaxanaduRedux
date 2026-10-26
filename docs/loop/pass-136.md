# Pass 136: cloak dyes and the Lord's Gold

Systems (97.5, weight 10) was tied for the lowest category apart from Art, and weighs the most of the tied ones. I audited bible 9, 10 and 11.

| System | Finding | Verdict |
| --- | --- | --- |
| Skill tree (9) | every Act III node in, and Mantra of Death since pass 134 | fine |
| Saves and settings | built; older settings files load cleanly (pass 129) | fine |
| Map, pins, charts, locks | built (passes 127, 128) | fine |
| Completion card (11) | built (pass 106) | fine |
| **Gold sinks (10)** | Respecs, Ointments, Elixirs, keys and tempers are built, but the cosmetic sink (cloak dyes, 6) was not. After the Daybreak shops, a run finishes with thousands of gold and nothing to spend it on. | **built** |
| **The 100% reward (11)** | The card promised a "Lord" glow on the cloak. Nothing gave it. | **built** |
| Boss rush (11) | not built | still to come |

## As built (bible 10, 11)

- **Ilse's Dyeworks:** Ilse the Dyer stands in the Market Row in Eolis (`eolis_dyer`, a new NPC sheet from `castgen.py`). She sells six dyes:

  | Dye | Price |
  | --- | --- |
  | Ember Red | 300 g |
  | Tide Blue | 500 g |
  | Dusk Violet | 800 g |
  | Ash Grey | 1,200 g |
  | Saffron | 1,800 g |
  | Night | 2,500 g |

  - A new dye goes straight on.
  - A dye you own, or the Warden Green you start in, can be worn again for free.
  - The save keeps `dyes` and `dye`.
- **The cloak dye shader** (`shaders/cloak_dye.gdshader`): the player sheet's cloak is its only green, so every green texel takes the dye and keeps its shading. The skin, leather and blade are untouched.
- **The Lord's Gold:** a clear at 100% sets the `lord` flag (`Completion.award`). That puts the Lord's Gold on Ilse's shelf for free: a pale gold cloak with a band of light running down it.
- `--dye=ID` wears a dye for screenshots.
- Deviation: the bible's "cosmetics" didn't say where they are sold. They went to a dyer in the home town, where a returning player passes anyway.

## Screenshots

In `/mnt/project-files/pass-136/`:
- `dyeworks.png`: Ilse's shelf.
- `cloak_dyes.png`: all eight cloaks running: Warden Green, Ember, Tide, Dusk on the top row; Ash, Saffron, Night and the Lord's Gold below.

## Tests

`test_the_dyer_dyes_the_cloak` (`test_economy.gd`), new:
- Ilse is in the Market Row, with a sheet;
- she sells six dyes;
- a new game wears Warden Green, with no shader;
- buying Ember Red costs 300 g and puts the shader on with the dye's color;
- with no gold, Tide Blue can't be bought;
- Warden Green and Ember are worn again for free;
- the Lord's Gold stays off the shelf at 99% and appears at 100%, and it glows.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Unchanged. |
| Combat and enemies | 15 | 97.75 | Unchanged. |
| World and level design | 15 | 97.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Late gold has a use, and 100% has its reward. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2531 of 2532 checks passed on the first run. The save round-trip test caught that the new `dyes` and `dye` fields were not in its list; it now sets them, and passes (64 checks). CI runs the whole suite on the PR.

Weighted score: 95.85 (up from 95.825). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio and Stability are tied at 97.5. Both weigh 5; pass 137 takes Audio.
