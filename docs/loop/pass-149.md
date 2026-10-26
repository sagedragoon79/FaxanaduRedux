# Pass 149: Thrust

Systems (98, weight 10) was the lowest weighted category apart from Art. I audited the systems against bible 9 and 10 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 10.2 shops | every town's shops are built, Mascon's scroll shop too (pass 148) | fine |
| 10 gold sinks | respecs, ointments, elixirs, keys, tempers and cloak dyes (pass 136) | fine |
| Rare drops (pass 147) | they fit the economy: an ointment found saves 300 g, and a glove never touches the shops | fine |
| Dash buffer (pass 146) | no system reads the dash press directly; nothing to change | fine |
| Saves | Victim's and Mascon's Gurus save and join the Mantra Path (passes 145, 148) | fine |
| **9 skill tree** | The Arcana branch has its capstone (pass 134) and the Wanderer its capstone (pass 142). The Blade branch stopped at its seventh node, Bloodletting. So a player who spent points there had nowhere left to go, and the bible's own headline melee skill, "Thrust: hold attack 0.4 s for a charged lunge (Faxanadu's thrust)", was never built. It is also the node Dragon Heart builds on. | **built** |

## As built (bible 9, 5.3)

- **The node:** `thrust` in `data/skills.json`, after Bloodletting, 2 points. The built tree now costs 46 points (Blade 13 over 8 nodes) against the 29 the game gives.
- **Input:** `PlayerInput.attack_held` (the button's state, as `jump_held` and `block_held` already were). The press still swings at once, so the charge builds through the first cut and a tap is only ever a cut.
- **Charge:** held past `thrust_charge` (0.4 s), a new `thrust_ready` sound rings and a spark of light runs off the point every 0.12 s. A blow, a dash, a guard, a drink, a ladder or the water spends the charge.
- **The thrust:**
  - It deals the heavy hit times `thrust_mult` (1.5) through `blade_mult()`, so Keen Edge and the War Glove count. With the Hand Dagger that is 21 against the heavy hit's 14.
  - Its point is a long, low box reaching 52 px past the body (a cut reaches about 34). It strikes every foe in it once and drives them back like a heavy hit.
  - It has a new `SlashFx` kind (a straight streak to a bright point) and a new `thrust` sound (a tearing rush ending on a bite).
- **The lunge:** on the floor it drives you at 320 px/s for 0.16 s, about 50 px, and stops at the first foe it strikes, recoiling like a cut, so it never carries you into a body. Off a ledge it ends. In the air the thrust strikes where you are, so it never crosses a gap the Elven Stride gates and the reachability checker needs no change.
- **Shadow Eura** echoes a thrust as a cut (her echo reads any unknown swing as a side cut).
- All numbers live in `combat_tuning.gd` (group Thrust), and bible 5.3 has a row for them.
- `game.gd`: `--shot-thrust=N` thrusts on frame N, for screenshots.

## Screenshot

`/mnt/project-files/pass-149/thrust.png`: the Eolis plaza a few frames into a thrust, with the dash dust thrown back and the point's streak running out ahead.

## Tests

`test_economy.gd`, `test_thrust_charges_and_lunges` (new):
- the tuning (0.4 s, 1.5x), and Thrust costs 2 after Bloodletting;
- without the skill, a held button is only a cut; with it, a tap is still only a cut;
- held, the press cuts at once, the charge isn't ready at 0.35 s and is by 0.43 s, and letting go thrusts;
- on the floor it lunges 35 to 80 px;
- at a Monodron it deals exactly heavy x 1.5 x `blade_mult()`, and the lunge stops short of the foe;
- in the air it strikes but carries you nowhere;
- a blow spends the charge, so letting go after it doesn't thrust.

Full suite: 2744 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | Unchanged (the thrust is a new move, but it is scored with the tree). |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | The Blade branch goes past Bloodletting, with the tree's signature melee skill. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Unchanged. |

Weighted score: 96.2125 (up from 96.1875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio, Stability and Faithfulness are tied at 98, the lowest apart from Art. All weigh 5, so pass 150 takes Audio, the one longest since its last pass (143).
