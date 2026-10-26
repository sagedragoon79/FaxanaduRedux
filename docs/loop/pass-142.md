# Pass 142: Wanderer's Grace

Systems (97.75, weight 10) was tied for lowest apart from Art with Audio, Stability and Faithfulness, and weighs the most of them. I audited systems against bible 9 and 10 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 10 shops and economy | Every shop in 10.2 is built, gold sinks include dyes (pass 136), and the smith now takes Meteor Shards (pass 140) | fine |
| Saves | Stale ids, round trips and post-game state are covered (passes 109, 138 and 141) | fine |
| 9 points | 29 points given against a tree that cost 41 | fine |
| **9 Wanderer branch** | The Arcana branch got its capstone in pass 134 (Mantra of Death). The Wanderer branch stopped at Second Wind, so its listed capstone, Wanderer's Grace, was missing. The other unbuilt nodes (Thrust, Whirlwind, Wildfire, Overflow and others) are mid-branch mechanics; Wanderer's Grace is the end of a branch players already climb, so it gives them somewhere to go. | **built** |

## As built

- **The node:** `wanderers_grace` in `data/skills.json`, Wanderer, 3 points, after Second Wind: "A dash lets harm pass through you 0.1 s longer, and every kill gives back your air dashes."
- **Longer grace:** `Player.dash_invuln()` returns `MovementTuning.dash_invuln` (0.1 s) plus `Player.GRACE_INVULN` (0.1 s) with the skill. `_try_dash` uses it. The movement numbers in bible 6 are unchanged; the skill adds on top, like Second Stride's extra dash.
- **A kill gives the dashes back:** `Enemy.die` calls `Player.on_kill()`. With the skill and the Elven Stride, it refills the air dashes you have spent (two with Second Stride), with a puff of feathers at your shoulders and the `wind_catch` sound from pass 137. It doesn't give the double jump back (the bible says "dash refreshes on kill"), and with nothing spent it does nothing.
- `GameState.refresh_stats` sets `p.wanderers_grace`, so a respec takes it away.
- The tree now costs 44 points against the 29 the game gives (Wanderer: 10 nodes, 19 points).

No screenshot this pass: the change is an extra 0.1 s of invulnerability and dashes coming back mid-fight, and a still image shows neither. The report `/mnt/project-files/pass-142/report.txt` gives each branch's nodes and points.

## Tests

`test_economy.gd`, `test_wanderers_grace_lengthens_the_dash_and_a_kill_gives_it_back`:
- without the skill, a dash gives the usual 0.1 s and a kill gives nothing back;
- the node opens after Second Wind and switches on;
- a real dash leaves more than 0.1 s of invulnerability;
- a Rot Dwarf's death refills both air dashes, and a kill with nothing spent does nothing;
- a respec takes it all back.

Full suite: 2607 checks, all passing, with no script errors in the log.

## Bible

Section 9: a "Wanderer's Grace (pass 142)" entry after the Act III tier's Wanderer nodes, with the new tree total.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98 | Unchanged. |
| Combat and enemies | 15 | 98 | Unchanged. |
| World and level design | 15 | 98 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | The Wanderer branch has its capstone, and it feeds back into movement and combat: kill in the air, dash on. |
| Audio | 5 | 97.75 | Unchanged. |
| Stability and performance | 5 | 97.75 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Weighted score: 96.025 (up from 96.0). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio, Stability and Faithfulness are tied at 97.75, all weighing 5. Pass 143 takes Audio.
