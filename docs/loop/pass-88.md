# Pass 88: The secret ending

The Sunken Spring and the Battle Suit are in, so the secret ending the bible promises (section 11 and the Easter eggs) can be built: reach the Evil One with no deaths while wearing the Battle Suit.

## What changed

- **Deaths are counted**:
  - `GameState.fresh()` has `deaths: 0`.
  - `World._on_player_died` adds one each time the player falls.
  - The count lives in the save and loads back with it.
- **`GameState.secret_ending()`**: true when there are no deaths and the Battle Suit is worn. `begin_ending()` then also sets `cleared_secret`.
- **EndingScreen**:
  - `start(rank, seconds, secret, deaths)`.
  - `cards()` adds three cards to the epilogue (`SECRET_EPILOGUE`):
    1. The Sunken Spring wakes as a fourth, ringing spring under the roots.
    2. Its water climbs the trunk to the crown.
    3. The crown flowers in gold and white.
  - The thanks card now shows deaths for everyone. The secret card adds "The Source runs again." and "A flawless climb, in the Warden's Battle Suit."
- **`game.gd`**:
  - It passes the secret ending and the death count to the ending.
  - New `--secret` option to screenshot it with `--ending`.

## Tests

`test_systems.gd`:
- `test_deaths_are_counted_and_kept_in_the_save`
- `test_the_secret_ending_needs_no_deaths_and_the_battle_suit`
- `test_the_secret_ending_adds_the_sources_cards`
- `test_the_game_plays_the_secret_ending_for_a_flawless_run`

Full suite: 1668 checks, all passing.

## Screenshots

`/mnt/project-files/pass-88/`:
- `source_wakes.png`: the Source's water climbing the trunk.
- `secret_thanks.png`: the thanks card.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91.5 | Unchanged. |
| Combat and enemies | 15 | 91.25 | Unchanged. |
| World and level design | 15 | 96.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 96.25 | Unchanged. |
| Systems | 10 | 92 | A death count and a second ending that rewards the hardest run. |
| Audio | 5 | 92 | Unchanged. |
| Stability and performance | 5 | 92 | Unchanged. |
| Faithfulness | 5 | 94 | The bible's secret ending is in. |

Weighted score: 91.94 (up from 91.89; 91.9375 unrounded).

## Next

Back to the deferred list, by the lowest category apart from Art (deferred). Combat and Movement are tied lowest at 91.25 and 91.5, so pass 89 takes Borabohra's third phase, then Pakukame's. Both add boss and combat depth.
