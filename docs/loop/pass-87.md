# Pass 87: The Drowned Warden

The second slice of the Sunken Spring: its guardian, the hardest fight in the game (bible 8.10), which drops the Battle Suit.

## What changed

- **The way in**: the Source Hall's east wall now opens (door 2) on **the Wellspring** (64,-5, 60x45).
  - The room is a deep pool from row 20 down.
  - An entry ledge and a far ledge each have steps down to the water.
  - Two islands sit level with the surface, and a plank runs over the middle.
  - Its sign warns you; the Source Hall's sign now points the way.
- **The Drowned Warden** (`scripts/bosses/drowned_warden.gd`, boss id `drowned_warden`, 520 HP, code-drawn at 1.25x):
  - It is a colossus of limestone and bronze with lamp eyes and a trident. It wades waist-deep through the islands, which hide its lower half.
  - **Thrust**: it aims at you, the aim setting late in a 0.6 s tell, and stabs 150 px along that line. A parry staggers it for 1.4 s.
  - **Wave**: a 0.7 s tell, then a `TidalWave` (new) runs the surface. Jump it or dive under it, which uses the swimming from pass 86. In phase 3 a second wave comes from the far side.
  - **Geyser** (phase 2+): it sinks out of reach and stalks you underwater. The water boils at your spot for 0.6 s, then it bursts up and hangs open for 1.3 s.
  - **Undertow** (phase 3): the current drags you in, then it slams around itself (parryable).
  - **Armor**: its stone halves frontal blows. From above (the plank is there for pogos), from behind, or while it is open, blows land in full.
  - **Phases**: at two-thirds and one-third it roars into the next phase, and its tells shrink to 0.88x and then 0.75x, never under `Enemy.MIN_TELEGRAPH`.
- **The Battle Suit** (`data/items.json`, armor tier 4, 60% less damage):
  - BossArena rewards can now carry `armor`, which is equipped at once.
  - Every shop armor then shows as owned.
  - This is the secret ending's second requirement.
- **Music** `warden` (E minor at 126).
- **Arena seals** are iron in the Sunken Spring.

## Tests

- `test_boss.gd`, nine new tests, covering:
  - the arena waking the Warden
  - fair telegraphs in all three phases
  - the thrust, its armor, and the parry opening it
  - a tidal wave missing a diver but catching a stander
  - waves from the tell, and the doubled waves in phase 3
  - the geyser stalk, tell, hit, and the open window
  - the undertow pull and slam
  - the phase roars
  - the Battle Suit reward
- The music list now includes `sunken`, `amb_sunken` and `warden`.
- `test_reachability.gd`: the Wellspring is in the Mattock and Thunder lists. The soak and door walk cover it with the rest of the zone.
- Full suite: 1655 checks, all passing.

## Screenshots

`/mnt/project-files/pass-87/warden.png`: the Warden thrusting at a player on the near island.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.5 | Unchanged. |
| Combat and enemies | 15 | 91.25 | Unchanged. |
| World and level design | 15 | 96.75 | The Wellspring arena, built around swimming. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 96.25 | A water boss whose answers are diving, pogoing from the plank and parrying. |
| Systems | 10 | 91.75 | The Battle Suit, the last armor tier. |
| Audio | 5 | 92 | The Warden's theme. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 93.5 | Unchanged. |

Weighted score: 91.89 (up from 91.74; 91.8875 unrounded).

## Next

Pass 88: the secret ending (bible section 11 and the Easter eggs). Reach the Evil One with no deaths and the Battle Suit, and the ending changes. It needs a death counter in `GameState`, then a variant of the EndingScreen.
