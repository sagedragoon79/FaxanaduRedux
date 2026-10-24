# Pass 69: the Meteor Slug and the Drowned Market

Dartmoor's third enemy (bible 7), picked to play against the Hour Glass, and the first room of the lower city.

## What changed

- **Meteor Slug** (`scripts/enemies/meteor_slug.gd`, legend `s`). It is code-drawn at 2x.
  - A great grey slug under a lumpy shell of meteor-rock, molten in its cracks. It creeps (14 px/s) and turns at
    ledges and walls.
  - **Heave**: with you within 170 x 80 px its shell swells and its cracks blaze for 0.6 s (the tell), then it heaves
    three molten globs (`scripts/enemies/meteor_glob.gd`) in high arcs, one at you, one short and one long, 12 each,
    unparryable. It sags for 0.7 s afterwards, then waits 1.6 s before it can heave again.
  - **Embers** (`scripts/enemies/meteor_embers.gd`): a glob that lands on a floor leaves embers for 1.4 s that burn
    once for 8.
  - **Shell**: it turns blows from above, except while it sags after a heave. Its soft sides take every blow.
  - 40 HP, 10 to touch, 20 XP, 8 to 12 gold. A Rising Cut can't launch it.
  - **With the Hour Glass**: globs hang in the air and embers stop burning while time holds, so you can walk out from
    under a volley, or past a patch of embers.
- **Drowned Market** (`levels/dartmoor/drowned_market.room`, 53,-10, 80x23), through a new east door in the
  Waterfall Stair's top gallery:
  - Two Meteor Slugs on the market floor, under two plank stalls.
  - A fall of time-locked water pours into a spiked pit across the hall. Frozen, its lowest foothold lies flush with
    the floor, so the Hour Glass is the bridge.
  - Past it, a high stall with an 820-gold chest and a Crystal Dwarf behind a wall at the sealed stair to the king's
    halls.
- **Docs**: bible 7 has the slug as built, the Dartmoor note covers the market, and the README legend gains `s`.

## Tests

- `test_enemies.gd`:
  - `test_meteor_slug_swells_then_heaves_three_globs`: the swell lasts at least `MIN_TELEGRAPH`, three globs fly,
    they leave embers, and they burn a player standing still.
  - `test_meteor_slug_shell_turns_blows_from_above`.
  - `test_meteor_globs_and_embers_hold_still_in_stopped_time`.
- `test_rooms.gd`: `test_the_waterfall_stair_gallery_opens_on_the_drowned_market`.
- `test_reachability.gd`: `dartmoor/drowned_market` is in `MATTOCK_ROOMS` and `THUNDER_ROOMS`.
- The Dartmoor soak covers the market.

## Screenshots

`/mnt/project-files/pass-69/`:
- `market.png`: the market, a volley in flight.
- `market_frozen.png`: the fall frozen into a stair over the pit.
- `slug_20.png` and `slug_52.png`: the slug swelling, then heaving.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 89.75 | An enemy whose volleys the Hour Glass answers. |
| World and level design | 15 | 94 | The glass used as a bridge. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 89.75 | Unchanged. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.25 | Unchanged. |
| Stability and performance | 5 | 88.5 | Unchanged. |
| Faithfulness | 5 | 89.75 | Unchanged. |

Weighted score: 89.69 (up from 89.61; 89.6875 unrounded).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (88.5). Next: the stair down to King Grieve's halls past the market's
sealed gate, and the Clockwork Hound, then King Grieve.
