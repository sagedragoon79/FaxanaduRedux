# Pass 05: world

Date: 2026-10-23. Scope: World and level design (45) and the faithfulness gap from pass 04:
Apolune, the town of Trunk Hollows, and the bible's seamless scrolling between rooms.

## What was built

- **Apolune** (`levels/trunk/apolune.room`, two screens, reached through an arch in Shrine
  Hollow). Before the Spring of Trunk is restored it is nearly empty: the Guru (rest, save,
  skills), Hesk, the last townswoman, and Orrin, a dwarf who kept his head and points toward
  the Tower and the Mattock. Shop windows are boarded and a note says the shopkeepers fled to
  Eolis. Restoring the spring brings them back (bible 4.4): the armory and the provisions shop
  open, the windows light up and flicker, Hesk's lines change, and the sap in the lane hardens
  into amber. A chest on a balcony, and a cracked-bark wall sealing an alcove at the east end
  as a Mattock tease (the alcove's reward comes with the Mattock).
- **House fronts** (`HouseFront` prop, `prop: x, y, house`), drawn in code on the palette.
- **People who come and go:** an optional fourth field on `npc:` lines (`flag` or `!flag`).
- **New gear** (bible 5.2 and 10.2): Studded Mail (30% less damage, 1,100 g), Large Shield
  (guard blocks 70%, 900 g; shields now carry their own guard value), and the Elixir (1,500 g,
  carry one): a fatal hit drinks it and you rise where you fell with full health, a moment of
  slow motion and invulnerability.
- **Seamless scrolling:** side and shaft doors between rooms of the same zone now push the
  screen: the old view slides out the way you went while the new room slides in (0.34 s).
  Inner doorways and zone changes still fade. The pass-03 deviation is closed.
- `--shot-move=1` for screenshots holds a direction from the start (used to capture a scroll).

## Automated verification

311 checks pass (from 294). New: the Large Shield's guard value and a guarded hit, the Elixir
revives once and only one can be carried, Apolune's people before and after the spring and the
lit windows, scroll versus fade for side, inner and cross-zone doors. Reachability covers
Apolune (every room, pickup and chest reachable with the glove; no soft-locks), and every room
boots. Screenshots reviewed: Apolune before and after the spring, five frames of a scroll from
the Trunk entrance into the Sap Tunnel.

## Review against the bible

- 3.3 transitions: met (screen push within a zone, fade between zones).
- 4.4 "Apolune NPCs return" after the spring: met.
- 10.2 shops: Armorer in Apolune met; item shop has the Elixir but not yet the Ointment (it
  needs a use-item input, planned with the item wheel) or poison cure (no poison yet).
- Trunk Hollows has 11 of its 28 rooms.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 66 | Unchanged; gear tiers widen choices. |
| World and level design | 15 | 52 | A real town with world-state change, scroll transitions. Still 11 of 28 Trunk rooms. |
| Art cohesion | 15 | 53 | Town houses with lit windows. Enemies still placeholders. |
| Bosses | 10 | 55 | Unchanged. |
| Systems | 10 | 63 | Elixir, tiered shields, conditional NPCs. Options menu still missing. |
| Audio | 5 | 60 | Unchanged. |
| Stability and performance | 5 | 60 | Unchanged. |
| Faithfulness | 5 | 50 | Apolune, its returning folk, Studded Mail, Large Shield, Elixir. |

Weighted score: 64 (up from 62).

## Lowest categories and next pass

1. **Art cohesion (53):** enemies and NPCs in the player's rig style.
2. **Bosses (55):** arena reveal and stagger window for Rokusutahn.
3. **World (52):** more Trunk rooms toward 28 (a second shrine route, a Jack-door vault, a
   landmark), the Mattock alcove reward once the Tower exists.
4. **Systems (63):** options menu; Ointment with a use-item input.
