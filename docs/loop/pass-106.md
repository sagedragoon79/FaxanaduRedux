# Pass 106: the completion screen

Systems (94.75) was tied for lowest with Movement, apart from Art. This pass builds the completion screen from bible 11, one of the unbuilt systems. The ending already existed, so it hangs on that.

## What the save already tracked

- Play time (`data.play_time` plus the unsaved `GameState.play_time`), deaths and clears are all in `GameState.data`. The pass-100 round-trip test already covers them, so nothing new had to be saved.
- The other numbers can be worked out from what the save holds:
  - rooms visited: `data.visited`;
  - treasures taken: `data.collected` against the World catalog's `treasures`;
  - hidden rooms found: the flag `secret:<room>`, which a room sets when you first step inside its cover;
  - bosses beaten: the `boss:<id>` flags.
- The only addition is to the World catalog: each room now says whether it has a hidden room (`secret`).

## The card

`Completion.tally(catalog)` (in `scripts/data/completion.gd`) counts four things against the whole game:

| Row | Found | Out of |
| --- | --- | --- |
| Rooms explored | visited rooms | 113 catalogued rooms (all but the gym) |
| Hidden rooms | `secret:` flags | 7 rooms with a `secret:` cover |
| Treasures | collected item and chest ids | 106 |
| Bosses | `boss:` flags | 13 |

The percent is the average of the four shares, rounded down, so 100% means every row is whole.

The ending's thanks card now shows the following (`EndingScreen.start(..., completion)`):
1. "Thank you for playing".
2. The percent in large type, "of the world".
3. The four rows. They count up over 1.2 s as the card fades in, and a whole row turns gold.
4. Rank, time and deaths, and the clear count from the second clear on.

`game.gd` passes the tally when the ending starts.

Screenshot: `/mnt/project-files/pass-106/completion.png` (`--ending=2,thanks` from Eolis with two bosses flagged). The layout is centred on a colon-free gutter, with labels right-aligned and values left-aligned. It fits the 360 px height with room for the secret ending's two lines. Everything is drawn with `PixelFont`.

The bible also promises a boss rush and a cloak glow at 100%. Neither is built yet; the bible now says so.

## Tests

`test_systems.gd`:
- `test_completion_tallies_rooms_hidden_rooms_treasures_and_bosses`:
  - nothing counts on a new save;
  - each find counts once;
  - the percent is the rounded-down average;
  - everything found is 100%.
- `test_the_whole_world_is_counted`: the real catalog has more than 100 rooms, at least 5 hidden rooms and more than 50 treasures.
- `test_the_thanks_card_counts_up_the_completion`:
  - the card carries the tally;
  - its rows are found against total;
  - it draws through the count;
  - with no tally it falls back to rank, time and deaths.

Full suite: 2004 checks, all passing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94.75 | Unchanged. |
| Combat and enemies | 15 | 95 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | The completion screen is built: one of the four unbuilt systems. The boss rush, Guru Trials and cloak dyes remain. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.225 (up from 94.125).

## Next

Movement (94.75) is the lowest apart from Art. Pass 107 audits the rest of bible 6 that earlier passes didn't pin:
- the coyote time and jump buffer windows, corner and ledge correction (6.2);
- wall slide and wall jump numbers (6.3);
- double jump (6.4);
- pogo (6.6).

Each gets a test that asserts its number. Anything off gets fixed.
