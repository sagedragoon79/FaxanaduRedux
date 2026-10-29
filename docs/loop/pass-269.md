# Pass 269: supplies and charts on the Inventory page

Category: Systems (last pass 261).

## Audit

I read bible 9 to 11 against the pause menu's pages:
- **Journey:** the completion shares, the guardians found, the Life Fruits, Mana Dews and skill points.
- **Equipment:** what you wear.
- **Inventory:** what you have found.

Two things you can buy are shown nowhere you would look for them:
- **The Elixir** (1,500 g, carry one) revives you when a blow would fell you, and once bought it showed nowhere at all. The HUD shows Ointments but not the Elixir, and the Inventory page listed neither. A player could not check whether they still carried one.
- **Charts:** since pass 261 every zone on the map has one for sale, eight in all. A bought chart showed only as dimmed rooms on the map, so nothing listed which you held or how many zones were still uncharted.

I also checked how recent additions sit in the systems, and they hold:
- the guardian's brood pays nothing (pass 266);
- King Grieve's guard is a room foe on the damage sheet (pass 268);
- the tavern hints are tested against the rooms (pass 265).

## Fix

- **Supplies** group: Ointments and the Elixir, with how many you carry ("x2") and what each does. An Ointment lasts `Player.OINTMENT_TIME`, 10 s, and the Elixir brings you back at full health.
- **Charts, n of 8** group: each chart you hold by name, and a greyed line for those not yet charted: "The towns' cartographers sell the rest". It goes once all eight are held. The total counts every chart in `data/items.json`, so a new zone's chart is counted with no code change.
- Test: `test_the_inventory_lists_supplies_and_charts` (`test_systems.gd`). It checks three things:
  - with nothing carried, neither group shows;
  - with two Ointments, an Elixir and two charts, the counts, the chart names and the greyed "6 not yet charted" line all show, and every line says what it does;
  - with all eight charts, the greyed line goes.

  The pass-205 inventory test still passes unchanged.
- Screenshot, looked at: `/mnt/project-files/pass-269/inventory.png` shows the Supplies and Charts groups with the Ointment's line under them.
- Bible 10.3, after the Inventory page.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: what you carry and chart is listed. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 270 takes Audio (last pass 262).
