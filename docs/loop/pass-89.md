# Pass 89: Borabohra's third phase

The bible's third phase for the Storm Roc (8.6) has been deferred since pass 60: "an aerial duel: you ride its updraft and pogo its head." Combat and Movement are the lowest categories apart from Art, so this pass builds it.

## What changed

- **`Updraft`** (`scripts/bosses/updraft.gd`) is a column of rising wind.
  - Before it is active, it only stirs dust on the floor where it will rise.
  - Once active, a player whose body centre is in it rides it up at 240 px/s (`Player.updraft`, set each frame like `gravity_scale`).
  - Riding it gives back the air moves.
  - Holding Down drops you out of the wind.
  - Anything rising faster than the wind (a jump, a pogo bounce) runs on under gravity.
- **Borabohra phase 3**, below a quarter of its health:
  - Every other move is **the gale**. Its tell is 0.8 s of wing beats while it flies to the open lane between the islands that is nearer you, with dust stirring on the floor. Then it hovers over the updraft for 3.5 s.
  - While it holds the gale:
    - The wind tops out 24 px above its body, so you rise past it, bob at the top, and drop onto its head with Down plus attack.
    - Blows from above land in full. Side blows are still cut to 30%.
    - It has no touch damage, and the storm waits.
  - Then it climbs back into the sky and the wind dies.
  - Grounding it with the conduits still works in this phase, and dives, volleys and storm bolts fill the gaps between gales.
- `--boss-hp` now also sets Borabohra's phase, so the duel can be screenshotted.

## Tests

`test_boss.gd`:
- `test_borabohra_duel_begins_below_a_quarter`
- `test_borabohra_holds_a_gale_over_an_open_lane`: the tell, the lane, the wind above its head, no touch, the storm waiting, damage from the side and from above, and no two gales in a row.
- `test_the_updraft_carries_you_up_to_pogo_its_head`
- `test_holding_down_drops_out_of_the_updraft`

`_roc_provoke` now also sets `_last_move`.

Full suite: 1689 checks, all passing.

## Screenshots

`/mnt/project-files/pass-89/updraft_duel.png`: the roc holding the gale over the left lane, with the player carried up past its head.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.75 | Riding an updraft and pogoing off a boss's head: a movement answer to a boss. |
| Combat and enemies | 15 | 91.5 | The pogo has a fight built around it. |
| World and level design | 15 | 96.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 96.75 | Borabohra has all three of the bible's phases. |
| Systems | 10 | 92 | Unchanged. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 94.25 | One more deferred bible phase built. |

Weighted score: 92.09 (up from 91.94; 92.0875 unrounded).

## Next

Pass 90: Pakukame's third phase, the other deferred boss phase.
