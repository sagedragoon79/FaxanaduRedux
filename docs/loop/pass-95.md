# Pass 95: Tilte

Bible 4.1 lists Tilte, the homing spirit orb, as a supporting spell. 10.2 prices it at 2,500 g in Daybreak, and the skill tree names Tilte Swarm. The scriptorium has said "Tilte waits for its spell" since pass 57. This pass builds both.

## What changed

- **`TilteOrb`** (new, `scripts/combat/tilte_orb.gd`):
  - It leaves the hand drifting up and forward, and hangs for 0.15 s with its halo pulsing fast. That is the tell that it is choosing.
  - Then it locks on the nearest live foe within 240 px. A foe behind counts as twice as far, so it prefers what you face, but it will wheel round for the only foe in reach.
  - It flies at 230 px/s, turning at most 6 rad/s, so a quick foe can slip it.
  - It strikes the first foe it touches for 14, and walls stop it. With no foe in reach it sails straight on until it fades after 2.2 s.
  - It lights the fog. Each hit chimes (`tilte_hit`, new in `sfxgen.py`).
- **Spells:**
  - `tilte` costs 22 MP and comes last in the Next Spell order.
  - The player casts through `Spells.cast_all`, so one cast can throw several projectiles.
- **The scroll:** `tilte_scroll` is sold at the Bell-Tower Scriptorium in Daybreak for 2,500 g.
- **Tilte Swarm** (Arcana, after Deluge Pierce, 2 points):
  - Tilte throws three orbs fanned 0.5 rad apart, each for 10, at the cost of one cast.
  - `Player.tilte_swarm` is set in `refresh_stats`.
- New screenshot option `--skills=ID[,ID]`.
- Bible 4.1, 9 and 10.2 are updated.

## Tests

`test_combat.gd`:
- `test_tilte_wakes_then_seeks_the_nearest_foe`: the cost, a single orb, the hang while it wakes, the lock-on and the 14 damage.
- `test_tilte_turns_back_for_a_foe_behind`
- `test_tilte_swarm_fans_three_orbs`: three orbs for one cast, a real fan, 10 each.

The Next Spell test now leaves Tilte out.

`test_economy.gd`:
- `test_the_tilte_scroll_is_sold_in_daybreak` (and the skill reaching the player)

Full suite: 1791 checks, all passing.

## Screenshots

`/mnt/project-files/pass-95/`:
- `tilte_wake.png`: an orb waking at the hand on the Fallen Bridge.
- `tilte_swarm.png`: Tilte Swarm's three orbs fanning out toward a Thunder Beetle.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 92.5 | Unchanged. |
| Combat and enemies | 15 | 92.75 | A spell for foes you can't line up: fliers, foes above and behind. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 97.5 | Unchanged. |
| Systems | 10 | 93.25 | The last bought spell, and a new skill node. |
| Audio | 5 | 92 | A new hit chime; still the lowest category apart from Art. |
| Stability and performance | 5 | 92.5 | Unchanged. |
| Faithfulness | 5 | 95.75 | The bible's Tilte and Tilte Swarm are in. |

Weighted score: 92.76 (up from 92.69; 92.7625 unrounded).

## Next

Audio (92) is the lowest category apart from Art. Pass 96 is an audio pass: boss-phase stingers and music changes at phase breaks, and a review of the mix.
