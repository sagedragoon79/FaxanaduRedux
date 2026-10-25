# Pass 91: The Magic Shield

The bible's tier-3 shield (5.2): "Magic Shield (3,600 g, reflects small projectiles on parry)". Its reflect mechanic has been deferred since Daybreak was built in pass 57. Combat is tied lowest apart from Art, so this pass builds it.

## What changed

- **`magic_shield`** (`data/items.json`): shield tier 3, guards 70%, `reflect: true`.
  - Calder's Stormward Armory in Daybreak sells it for 3,600 g, next to Full Plate.
  - `GameState.refresh_stats` sets `Player.reflects` from it.
- **The reflect** (`Player.receive_attack`): with the Magic Shield, a parry also catches shots in the new `small_projectile` group, even ones that are otherwise unparryable:
  - Sap Spitter globs and Meteor Slug globs, which no other shield can parry.
  - Pakukame's seeds, which any shield can parry; on a plain shield they just burst.
- **`ReflectedShot`** (new, `scripts/combat/reflected_shot.gd`): the caught shot flies back as a mote of shield light, its core glowing with the colour of what was caught.
  - It flies at 340 px/s toward the nearest foe within 260 px on the side you face, or straight ahead if none.
  - It strikes the first foe it meets for 16. Walls stop it, and the Hour Glass holds it.
- Projectiles that already turn back on any parry (harpy feathers, gear blades, shadow bolts) keep their own behaviour.
- A caught sap glob leaves no puddle.
- New screenshot option `--reflect` flings a shot from in front of the player.

## Tests

`test_enemies.gd`:
- `test_the_magic_shield_flings_a_sap_glob_back`: caught unhurt, flung forward, strikes the spitter for 16, no puddle.
- `test_other_shields_cannot_catch_a_sap_glob`
- `test_the_magic_shield_turns_seeds_into_shots`: a plain shield's seed just bursts; the Magic Shield's comes back green.
- `test_a_reflected_shot_seeks_the_nearest_foe_ahead`

`test_economy.gd`:
- `test_the_magic_shield_is_sold_in_daybreak_and_reflects`

Full suite: 1727 checks, all passing.

## Screenshots

`/mnt/project-files/pass-91/`:
- `calder_stock.png`: the Magic Shield in Calder's stock.
- `reflected_shot.png`: a reflected shot of sap light flying from the player.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.75 | Unchanged. |
| Combat and enemies | 15 | 92.25 | The parry gets a late-game payoff: lobbers' shots become your ammunition. |
| World and level design | 15 | 96.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.25 | Unchanged. |
| Systems | 10 | 92.25 | The third shield tier, a gear choice that changes how you play. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 94.75 | The bible's Magic Shield is in. |

Weighted score: 92.30 (up from 92.19; 92.3 unrounded).

## Next

Movement is now the lowest category apart from Art (91.75). Pass 92 gives the Branches their wind currents, and reverses them once the Spring of Sky is restored. The bible lists the reversal as a world-state change still to come.
