# Pass 277: every shelf asks the table's price

Category: Systems (last pass 269).

## Audit

I checked bible 9 to 12 against the systems the recent passes touched:
- **The Naga (273 to 275):** there is no bestiary, its gold joins the Tower's foes in the gold sheet (it is in the sheet's legend table), and a kill counts like any foe's.
- **`Sfx.LIFT` (270):** it changes only volume.
- **The Inventory's Supplies and Charts groups (269):** these hold. All eight charts are on sale, so "the towns' cartographers sell the rest" is true.
- **Executioner and Bloodletting:** these now meet the Foreman's real opening (276).

Then I compared every shelf in `data/shops.json` with bible 10.2's shop table. Nothing had held the two together, and they disagreed in two places:
- **The Forepaw Forge sold an Ointment for 280 g.** Every other shelf asks 300, the price the table gives. It had been 280 since pass 25, with no reason written down.
- **The Cartographer row said "every town, 200 to 800 g".** In fact six towns keep a cartographer: Eolis, Forepaw, Victim, Conflate, Daybreak and Dartmoor. The Eolis chart is 40 g. Bible 4's map paragraph listed the cartographers too, but left out Daybreak's bell-ringer.

## Fix

- `data/shops.json`: the Forge's Ointment is 300 g.
- Bible 10.2: the Cartographer row names the six towns, gives the price range (40 to 800 g), and says why Apolune and Mascon keep none: Eolis sells the Trunk's chart, and Victim and Conflate sell the Mist's.
- Bible 4's map paragraph now says "a cartographer in six of the eight towns" and adds Daybreak (700 g).
- New test `test_every_shelf_asks_the_shop_tables_price` (test_economy). It checks that:
  - every shelf's Ointment, Elixir, keys and scrolls cost the table's single price;
  - a Mana Dew or Life Fruit costs within its range and appears at most once on a shelf;
  - every chart costs 40 to 800 g;
  - the cartographers are the six named towns;
  - the table itself states each price the test holds.

  Put the Forge back to 280 and the test fails ("forepaw_smith: ointment at 280, not 300").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the shelves and the shop table now agree, and a test holds them. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 278 takes Audio (last pass 270).
