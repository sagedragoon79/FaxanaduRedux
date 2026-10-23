# Pass 29: Charts and map pins

The map half of bible 3.3: Cartographers who sell a zone's outline, and map pins. Systems was 77 going in.

## What changed

- **Charts.** A new item kind, `chart`, with a `zone`.
  - Buying one sets `GameState.data.charts[zone]`.
  - On the map (`MapScreen.shown()`), every room of a charted zone you have not visited draws as a dim outline in the
    zone's color.
  - Visited rooms and the room you are in draw as before.
- **Two Cartographers.** Their sheets are from `castgen.py`.
  - **Pell**, in the Eolis market (shop `eolis_charts`), sells the Chart of Eolis (40 g) and the Chart of the Trunk
    Hollows (250 g).
  - **Surveyor Brin**, a dwarf in Forepaw (shop `forepaw_charts`), sells the Chart of the Tower (400 g).
  - The shops show "Owned" once a chart is bought.
- **Map pins.** With the map open, Jump drops a gold pin where you stand, or lifts the pin within 48 px of you.
  - You can place at most 12 (`GameState.MAX_PINS`); a 13th fizzles.
  - Pins are saved (`GameState.data.pins`) and drawn on the map.
  - The legend shows the count ("Pin: Jump (1/12)").
- Screenshot options: `--charts=trunk,tower` and `--pin`.
- **Bible:** 3.3 records the pin controls and which Cartographer sells which chart.

## Tests

- `test_a_cartographer_chart_outlines_unseen_rooms`: hidden at first; the chart sells once; its zone's rooms show
  charted; other zones stay hidden; a visit shows a room in full.
- `test_map_pins_drop_and_lift_where_you_stand`: drop, lift, and the 12-pin limit.

607 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-29/`:
- `map.png`: Apolune with the Trunk and Tower charts. The whole Trunk Hollows shows dimmed in teal, the Tower's rooms in
  rust, and a pin sits on the player.
- `carto.png`: the Forepaw Survey shop with the Tower chart and its description.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 83 | Unchanged. |
| World and level design | 15 | 81 | Unchanged. |
| Art cohesion | 15 | 76 | Unchanged. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 80 | Charts and pins finish the map the bible describes. Item icons on the map would still help. |
| Audio | 5 | 72 | Unchanged. |
| Stability and performance | 5 | 73 | Unchanged. |
| Faithfulness | 5 | 72 | Charts and the old shopkeeper rhythm of towns. |

Weighted score: 80 (80.25, up from 79.90).

## Lowest categories and next pass

1. **Faithfulness (72)** and **Audio (72)**: the Tower's remaining rooms (17 of 26), and the wall-jump skip route (bible 4.3).
2. **Art (76)**: the player's HD Autosprite sheet coverage, and the remaining 1x elements (check the HUD and pickups at 2x).
