# Pass 03: M3 vertical slice

Date: 2026-10-23. Scope: milestone M3 (design bible 14), built as six slices, each merged
when CI was green (Sean: "push every slice, all recommendations approved").

## What was built

| Slice | PR | Contents |
| --- | --- | --- |
| A | #3 | Multi-room world, edge and inner doors, fades, save shrines, JSON saves, death purse per room, map screen, pickups (Glove, Life Fruit, Mana Dew, shards), chests, lore tablets, dialog box. |
| B | #4 | Data tables (items, shops, skills, NPCs), shops and gear, Jack Keys and doors, the 6-node skill tree with respec, 16 ranks with XP, the King's 1,500 gold, the Guru. |
| C | #5 | 15 rooms: Eolis (6) and Trunk Hollows (9), sap pools, secrets (a fake wall and a hidden pocket; Mattock walls come with the Tower), title menu, the reachability checker and its proofs. |
| D | #6 | Rokusutahn (three phases, tail weak point, sap platforms, floor tear, cinematic kill), boss arena seals and rewards (Elf Ring, skill point), the Spring of Trunk, amber sap, the Eolis fountain. |
| E | #7 | Code-generated zone tilesets (47 blob autotiles, darker wall interiors) and two parallax layers per zone. |
| F | #8 | Music system with crossfades, boss theme and ambience beds; placeholder loops until Sean's tracks arrive; title screen. |

## Automated verification

273 checks pass (from 95 at pass 02). New coverage includes: door pairs in every room, every
room boots with the player landing safely, the critical path order (Glove before the boss),
every pickup reachable, no soft-locks with or without the Glove or with amber, save and load
round trip, shops, skills, ranks, keys, boss seals, telegraphs, tail and plate damage, phase
thresholds, floor tear, sap platforms, rewards given once, spring and amber, autotile choice,
music routing. Screenshots reviewed for every room, all three boss phases, the title and menus.

## Review against the bible

- **Boss fight time** (target 2.5 to 5 min): estimated at about 2.5 min with the Hand Dagger
  and perfect play (5 stuck windows in phase 1, 3 dangles in phase 2, 3 ledge lunges in phase
  3), under 2 min with the Long Sword. Real play is slower, so it should land in range. Needs
  a playtest.
- **Deviations:** room transitions fade instead of scrolling seamlessly within a zone (3.3).
  Rokusutahn is drawn in code rather than as a rigged multi-part sprite (13.3). Both are
  listed below.
- **Missing from M3 scope:** final character art. The Autosprite tool is not connected to
  this environment, so no credits were spent and the ledger is empty. The player and enemies
  are still code-drawn placeholders on the master palette.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged; still no options for shake and flash. |
| Combat and enemies | 15 | 64 | Gear and skills feed damage; still placeholder animation and 3 enemy families. |
| World and level design | 15 | 45 | 15 rooms in two zones, reachability proven, secrets, landmarks (plaza fountain, root chamber, spring). Missing Apolune, seamless scrolling, and most of the zone's 28 rooms. |
| Art cohesion | 15 | 40 | Palette-true tilesets and parallax per zone, depth-shaded walls. Characters and props are still code placeholders; no foreground decor or particle layers. |
| Bosses | 10 | 55 | Rokusutahn has 3 phases, tests the wall climb, cinematic kill, phase-marked bar. Placeholder visuals, untested by a human. |
| Systems | 10 | 60 | Save and load, shop, skill tree, ranks, map all tested. Missing fast travel and a settings menu. |
| Audio | 5 | 60 | Music per zone, boss theme, ambience beds, 29 SFX. Music is a placeholder until Sean's library. |
| Stability and performance | 5 | 60 | Soak clean; no frame-time capture yet. |
| Faithfulness | 5 | 40 | King, Guru, ranks, keys, the first spring and ring, Rokusutahn. |

Weighted score: 57 (up from 34).

## Lowest categories and next pass

1. **Art cohesion (40):** the player sprite set via Autosprite once the connector or an API
   key is available (log every call); until then, a code-drawn animation set for the player
   and enemies (anticipation, smears, recovery per 12.4), foreground decor and ambient spore
   particles in the Trunk.
2. **World and level design (45):** seamless in-zone scrolling transitions, Apolune town, and
   the rest of Trunk Hollows toward its 28 rooms, with a Mattock tease (cracked wall seen early).
3. **Bosses (55):** a pre-fight arena reveal, a stagger window for Rokusutahn, a rigged sprite.
4. **Systems:** the options menu (shake, flash, rumble, volume, rebinding), Ointment and Elixir.
5. **Playtest:** Sean playing the slice is the most valuable input now (bible 15.3).
