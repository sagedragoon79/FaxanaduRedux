# Pass 137: the wind and wrong gravity are heard

Audio (97.5, weight 5) was tied with Stability as the lowest category apart from Art. I checked every mechanic the player moves through or touches for a sound (bible 13.3: "Every action has SFX").

| Interaction | Sound | Verdict |
| --- | --- | --- |
| Map, pins (pass 128), Death (132), cracked stone (`break`), pickups, chests, doors | all heard | fine |
| Ladders, swimming, Feather Fall, Bounce-pods, Stride seeds | all heard | fine |
| **Wind currents (the Branches), Borabohra's updraft** | silent: you were blown sideways or lifted with no sound | **built** |
| **Wrong-gravity pockets (Zenis)** | silent: your weight left and came back with no cue, in the final zone | **built** |
| **Wearing a dye you own (pass 136)** | played the coin sound, though nothing is paid | **fixed** |
| Mix (`levels.py --check`) | passes | fine |

## As built (bible 13.3)

- **`wind_catch`:** a gust that swells and blows past, with a flap of cloth, when a wind current or updraft first catches you.
- **`drift_in`:** a hollow, glassy shimmer that rises as a wrong-gravity pocket lifts your weight.
- **`drift_out`:** a low hum that drops, then a soft thud, as the true pull returns.
- Each sounds once as you cross the edge. It then waits `Player.FIELD_CUE_GAP` (0.3 s) before it may sound again, so hovering on an edge doesn't chatter. `Player._field_cues` watches the fields each frame.
- **`cloth`:** a cloth swish as a dye goes on at Ilse's Dyeworks. A dye bought still rings the coin as well. A dye worn again plays only the cloth.
- All four are rendered by `sfxgen.py`, at -19 to -21 dB RMS. `levels.py --check` passes (115 effects, median -18.2 dB).

## Level report

`/mnt/project-files/pass-137/levels.txt`: the full `levels.py` table and the check result.

## Tests

`test_wind_and_wrong_gravity_are_heard` (`test_movement.gd`), new:
- dropped into a pocket, `drift_in` sounds once;
- walking out, `drift_out` sounds once;
- off a ledge into a current, `wind_catch` sounds once, and not on the ledge before;
- the cue gap is 0.3 s.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Unchanged. |
| Combat and enemies | 15 | 97.75 | Unchanged. |
| World and level design | 15 | 97.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Unchanged. |
| Audio | 5 | 97.75 | The last silent movement fields have a voice. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2538 checks, all passing, with no script errors in the log.

Weighted score: 95.8625 (up from 95.85). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability (97.5) is the lowest apart from Art. Pass 138 takes Stability.
