# Pass 345: the Elixir restores magic and power, as the manual says

Category: Faithfulness (last pass 337).

## Audit

- **What passes 338 to 344 touched.** They held numbers (foes, gates, guardians, gold, audio, saves, movement) and changed none of the original's facts. The faithfulness checklist (`test_the_faithfulness_checklist_is_all_here`) and the gear table (`test_the_originals_twelve_pieces_of_gear_are_all_here`) still pass on main.
- **The manual against the remake, again.** The NES manual (archive.org scan) has items that earlier audits had not quoted. Each is checked below:
  - **Red Potion, Ointment, Glove, Poison, Mattock, Hour Glass, the spells:** each is already quoted and held (passes 305, 321, 329, 337).
  - **Keys:** "You need these to open doors. There are five types." Jack, Queen, King, Ace and Joker are all held by the checklist.
  - **Mantra:** "A Mantra is a Password which will allow you to continue play." Bible 1.3 names the password's replacement by saves.
  - **The Elixir:** "Medicine that will restore your magic and power." The remake's Elixir revived you at full health, but `Player._drink_elixir` left the magic where it was. A mage who died with no magic got up with no magic. **No deviation note said so,** and the 5.2 row said only "full health". The test checked HP only.

## Fix

- `Player._drink_elixir` now fills the magic as well as the health.
- Bible 5.2: the Elixir row says "full health and full magic". A new **The Elixir (pass 345)** note quotes the manual and keeps one change that is the remake's own: the fatal hit drinks the Elixir, and you carry only one.
- Test: `test_elixir_revives_once_and_is_limited_to_one` empties the magic before the fatal hit, checks that the revive fills it, and checks that the bible quotes the manual.
- Mutation check: an Elixir that leaves the magic alone fails the test (7 checks passed, 1 failed).

The only on-screen change is the MP bar refilling on a revive, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score. The Elixir now does what the manual says, and the bible quotes it. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 346 takes Combat (last pass 338).
