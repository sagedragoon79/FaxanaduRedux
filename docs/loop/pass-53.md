# Pass 53: the skill tree's second tier, and a Branches save round trip

A systems and stability pass. Before this, the tree had only the first two nodes of each branch (6 of 36). Act II
now has things to spend points on.

## What changed

- **Six new nodes** (`data/skills.json`, bible 9). Each one needs the node before it in its branch.
  - **Rising Cut** (Blade 3, 1 pt): an up-slash launches a small foe into the air (330 px/s), helpless for 0.5 s.
    "Small" means a walking foe of 40 HP or less (`Enemy.LAUNCH_MAX_HP`). Rooted foes (`Enemy.launchable`: Sap
    Spitter, Bog Myconid), fliers and bosses stay put. See `Enemy.launch()`.
  - **Mattock Mastery** (Blade 4, 1 pt): the downward strike deals 50% more damage, and stacks with Keen Edge.
  - **Deluge Pierce** (Arcana 3, 1 pt): water bolts pass through foes and strike each one in line once
    (`DelugeBolt.pierce`).
  - **Quick Draught** (Wanderer 3, 1 pt): you drink a Red Potion in 60% of the time.
  - **Second Stride** (Wanderer 4, 2 pt): a second air dash (`Player.bonus_air_dashes`). Landing, wall contact and
    pogo refill both charges. It does nothing until you own the Elven Stride.
- Effects are applied in `GameState.refresh_stats`, the same as the first tier, so a respec takes them back.
- **CI**: the job timeout went from 20 to 40 minutes, and the screenshot step is capped at 12. The suite now takes
  about 15 minutes and the screenshots about 5, which had cancelled pass 52's first run.
- **Bible 9** says which tiers are built and pins down the details above.

## Tests

- `test_economy.gd`:
  - `test_act_two_skills_chain_and_apply`: locked until the node before; all eleven nodes cost 13; every effect
    switches on; a respec removes them.
  - `test_quick_draught_drinks_faster`: healed within two frames of 0.6 x the drink time.
  - `test_second_stride_gives_two_air_dashes`: two air dashes, the third is refused, and landing refills both.
  - `test_rising_cut_launches_small_foes_only`: an up-slash nudges a Monodron without the skill and throws it over
    30 px with it. An Iron Dwarf and a Sap Spitter refuse to launch.
  - `test_mattock_mastery_hits_harder_downward`: a down strike deals slash x 1.1 x 1.5.
  - `test_deluge_pierce_strikes_every_foe_in_line`: a plain bolt hits one of two dummies, and a piercing bolt hits
    both.
- `test_rooms.gd`: `test_branches_state_survives_a_save_round_trip`:
  - Covers the Elven Stride (ability and collected pickup), boss:pakukame, the Branches chart, Conflate's guru and
    the Wanderer skills.
  - After loading, Second Stride is back on the player, the Stride doesn't reappear in the Windloft, and Pakukame
    doesn't return to the Crown-Leaf.

## Screenshots

`/mnt/project-files/pass-53/skills.png`: the Guru's skill list in Conflate. It now scrolls past eight rows, and the
locked nodes are dimmed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged (Second Stride is opt-in). |
| Combat and enemies | 15 | 87.5 | Rising Cut juggles and piercing bolts add choices. |
| World and level design | 15 | 91.5 | Unchanged. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 88.5 | Tree tier 2 in place (12 of 36 nodes), with real choices for Act II points. |
| Audio | 5 | 87.5 | Unchanged. |
| Stability and performance | 5 | 86 | Branches save round trip; CI no longer times out. |
| Faithfulness | 5 | 88 | Unchanged. |

Weighted score: 88.23 (up from 87.98).

## Lowest categories and next pass

Leaving Art aside, the lowest are Stability (86), then Combat and Audio (87.5). The world is now at its Daybreak
edge. Next is the opening of Daybreak, the upper Branches where Borabohra waits (bible 8.6): the first rooms past Conflate's north bough,
music, and a new enemy. Pakukame's phase 3 chase can come later.
