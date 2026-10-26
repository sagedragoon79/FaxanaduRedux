# Faxanadu Reborn: Game Design Bible

*Working title. Version 1.0, 2026-10-22. Owner: Claude (build team). Approver: Sean.*

This is the single source of truth for the remake. Every thread that builds code, art, levels or audio works from this document. When a build decision contradicts it, either the build changes or this document is updated in the same pull request, with the reason.

---

## 1. Vision

**One line:** A dying World Tree, a wandering elf, and a meteor-born evil, rebuilt as a hand-crafted, interconnected 2D action metroidvania with HD pixel art and movement that feels as good as the best of the genre.

**Pillars** (every feature must serve at least one):

1. **Movement is the joy.** Running, jumping, wall-kicking, pogoing and dashing feel crisp, forgiving and expressive. A player should enjoy moving through an empty room.
2. **The Tree is one place.** The whole world is a single climb, from roots to canopy to the meteor at its crown. Every zone is physically connected, and you can see places you cannot reach yet.
3. **Faxanadu's soul, modern body.** Keep the melancholy tone, the towns and Gurus, the rings and keys, the ranks and titles, the springs and the Evil One. Replace the stiff controls, password saves and grinding with modern systems.
4. **Weight and impact.** Every hit lands with hit-stop, flash, shake, particles and sound. Bosses are spectacles with readable, fair patterns.
5. **Curiosity pays.** Every dead end hints at a secret. Secrets reward with power, lore or gold, never with nothing.

**Reference games for feel and structure:** Hollow Knight (world density, pogo, map), Celeste (jump forgiveness math), Dead Cells (combat juice), Blasphemous and Ender Lilies (HD pixel mood), Ori (traversal flow), Castlevania: Symphony of the Night (towns-and-castle RPG layer).

**Target experience:** 10 to 12 hours for the main path, about 16 hours for 100%. Desktop first (Windows, Linux, macOS) with full gamepad support; Steam Deck verified as a stretch goal.

**IP note:** Faxanadu belongs to Konami (via Hudson Soft). Nothing is ripped from the original: all sprites, music and text are new. Names and structure are kept as a fan remake. If Sean ever wants a public commercial release, we rename people and places in one pass (all names live in a single localization table to make that trivial).

---

## 2. Story and Tone

**Premise.** The elf wanderer returns home to Eolis after years away and finds the town at the roots of the World Tree starving. The spring water that fed the Tree has stopped, monsters roam the trunk, and the dwarves who lived in the Tree have vanished or turned hostile. A meteor struck the crown of the Tree years ago. Inside it, the Evil One has been corrupting the dwarves and drinking the Tree's life.

**Arc.**
- **Act I (Roots and Trunk):** The King of Eolis sends you to find out why the springs failed. You restore the first spring and discover that the dwarves were not invaders but victims.
- **Act II (Mist and Branches):** You climb into the fog and the high canopy, restore the other two springs, and learn that the dwarf king, Grieve, made a pact with the meteor to save his people.
- **Act III (Dartmoor and Zenis):** You face King Grieve in his drowned capital, then your own shadow, then enter the meteor-fortress Zenis to destroy the Evil One. The Tree blooms again.

**Tone.** Melancholy and quiet between fights, fierce in fights. Towns are warm pockets of light. Text is sparse and a little old-fashioned (the original's translated strangeness is kept as flavor: Gurus speak in mantras, NPCs give cryptic hints).

**Restoration as feedback.** Each spring you restore visibly changes Eolis (the fountain fills by a third, NPCs return, shops stock new items) and changes the world (see section 4.4).

---

## 3. World Structure

### 3.1 Overview

The world is one vertical map: **the World Tree**, about **190 rooms** across 7 zones plus 2 optional areas. The player climbs upward overall, but each zone sprawls horizontally and loops back on earlier zones through shortcuts.

```
                          [7 ZENIS - the Meteor Fortress]
                                       |
                 [6 DARTMOOR - drowned dwarf capital]----(Sunken Spring, optional)
                          /                    \
        [5 BRANCHES - Daybreak]          [5b Canopy Spires]
                  |                             |
        [4 BRANCHES - Conflate] ---------------+
                  |
   [3 MIST - Victim] ---- [3b Mist Marsh - Mascon]
                  |                   |
   [2 TOWER OF TRUNK - Forepaw] ------+
                  |
   [1 TRUNK HOLLOWS - Apolune]
                  |
           [0 EOLIS - hub town] ---- (Guru Trials, optional, unlocks over time)
```

### 3.2 Zones

| # | Zone | Town | Rooms | Theme and mood | Key mechanic | Bosses |
|---|------|------|-------|----------------|--------------|--------|
| 0 | **Eolis** | Eolis | 10 | Stone town carved into the roots, warm lamplight, dry fountain | Hub, shops, King, Guru, fountain shows progress | none |
| 1 | **Trunk Hollows** | Apolune | 28 | Tunnels through living wood, glowing fungus, amber sap | Sap pools slow you; root-gates | Rokusutahn |
| 2 | **Tower of Trunk** | Forepaw | 26 | Dwarven mining tower bolted into the trunk, gears, minecarts | Vertical climb; cracked stone; elevators | Zoradohna |
| 3 | **The Mist** | Victim, Mascon | 34 | Fog-drowned limb-marsh, lanterns, rotting boardwalks | Fog limits vision; lanterns; water levels | Ripasheiku, Zorugeriru |
| 4 | **Branches (Conflate)** | Conflate | 24 | Sunlit canopy, enormous leaves, wind | Wind currents (legend `>`/`<`: carry you while airborne, turned by the Spring of Sky, 6.9); bounce-pods (legend `@`: land on one and it throws you about nine tiles up, 6.6) | Pakukame |
| 5 | **Branches (Daybreak) and Canopy Spires** | Daybreak | 26 | Sky islands, storms, ruined elf shrines | Lightning conduits; air dash routes | Borabohra |
| 6 | **Dartmoor** | Dartmoor | 28 | Flooded dwarf capital, meteor crystals growing through masonry | Time-stop puzzles; illusory walls | King Grieve, Shadow Eura |
| 7 | **Zenis** | none | 14 | Inside the meteor: organic stone, alien light, gravity wrong | Gauntlet using every ability | The Evil One |
| opt | **Sunken Spring** | none | 8 | Under Dartmoor, the original source of the springs | Underwater swimming (Deluge-drained rooms) | Optional: The Drowned Warden |
| opt | **Guru Trials** | Eolis | 6 | Abstract mantra-space, monochrome | Pure platforming challenges | none |

**Guru Trials (pass 113, the first two of six):** `levels/trials/`, the mantra-space, is off the map and out of the completion count (`World.OFF_MAP`). The Guru in the Temple of Mantras gains a "Guru Trials" row (cleared/built). It is dry until a spring flows, and its list shows each built trial as Sealed (with the springs it needs), Open, or your best time. Trials open two by two, one pair per spring restored (`Trials.LIST`); a trial whose room isn't built isn't offered. Choosing one carries you to its start (`P`), and the clock runs from that moment: the trial's name, the clock and your best (or "First walk") sit top center on the HUD. In a trial a hazard costs time, never health: it sets you back on your last footing with a hurt flash. The bell at the far end (`prop: x, y, trial_goal`) rings when touched. It shows your time, keeps your best (`GameState.data.trials`, trial id -> seconds), and the first clear rings a Mantra Shard out of it (bible 10). After 1.2 s the mantra carries you back to where you stood by the Guru. The pause menu gains "Leave the trial", which stops the clock and returns you there uncleared. Look: pale grey masonry with no moss or warmth, a void behind with great faint broken mantra rings and pale slabs hanging nearer, pale flecks in the air; the bell hangs in a stone frame with a slow glow. Sound (pass 116): music `trials` (D lydian at 92 over a drone that never changes chord, a dry tick on every eighth like the trial's clock, a soft pulse to run to, and a bell chanting a four-bar mantra above), ambience `amb_trials` (a hollow void hum that breathes, thin air, far chimes of the mantra rings), `trial_begin` as the mantra carries you in (a shimmer rising a fifth), `trial_bell` at the end (a struck bronze bell with inharmonic partials ringing long), and `trial_record` on a new best (three bright rising notes). Built: **Mantra of Walls** (three pillars over spikes, thorned on their far sides and with thorn bulbs in the gaps; climb each with the Climbing Glove from the nub at its foot) and **Mantra of Edges** (1- and 2-wide pillars over a spiked floor, four tiles apart and at changing heights, then four slats under a low ceiling that allows only short hops, then rising pillars to the bell). Both are proved clearable with the glove alone by `test_every_guru_trial_can_be_cleared_with_the_glove`. Planned: Thorns and Winds (two springs), Stillness and Falling (three). The cosmetics the bible pairs with trials (cloak dyes) come with the dye pass.

**Dartmoor begins (pass 63):** `levels/dartmoor/`, below Dartmoor's upper gate at the end of Daybreak (the Sky Key opens it; a shaft past it drops into the zone). The Upper Stair (60,-11, 40x45) is the dwarf kings' old trade stair: nine landings switch back down a drowned colonnade to the Upper Gate-Hall (59,-10), with broken pillars, a shrine and the west way choked with stone and crystal for now. Look: squat dark dwarf masonry with a teal tide line on every block where the flood stood, veins of magenta meteor crystal forcing through the joints of exposed faces, teal waterweed for a cap; behind, a sunken great hall of colossal pillars and arches with crystal clusters glowing on the far walls and dark water below, and nearer, broken colonnades run through with crystal spears. Decor: crystal shards, drowned dwarf helms, fallen masonry, crystal stalactites, seeping drips, wall crystals and dead braziers. Crystal dust hangs in the air. Music `dartmoor` (D phrygian at 70: a dirge of deep hall pads, an octave bass, a low tolling bell and far-off crystal chimes) and ambience `amb_dartmoor` (a still water drone, drops into pools, a trickle, a faint crystal hum). Pass 64 opened the Gate-Hall's west way onto the Flooded Hall (57,-10, 60x23), the old hall of audience: broken pillars, a crystal-spiked pit, a gallery with a chest, and two Crystal Dwarves. Pass 65 opened its west wall onto the Sunken Stair (56,-10, 40x45), five landings down a drowned colonnade over a crystal-spiked trench, and below it the Onyx Crypt (55,-9), the masons' tomb, where the Black Onyx lies on a dais. Both rooms hide a secret behind an illusory wall up a run of hidden planks, so the Onyx pays off at once on the way back. In pass 66 the way on became the main-route illusory wall: the crypt's hidden chamber hides its west door to the Drowned Nave (53,-9, 80x23), where the king's guard knelt. It has broken hanging pillars, two galleries, a spiked pit, two Shade Knights and a Crystal Dwarf, and a Mantra Shard up hidden planks under the vault. In pass 67 the Hour Glass came to its west end: it stands on a plinth by the stopped water-clock with a shrine beside it, and the west door opens on the Waterfall Stair (52,-10, 40x45), two shafts of falling water that only a frozen moment lets you climb, to a gallery with a Life Fruit and a chest. In pass 69 the gallery's east door opened on the Drowned Market (53,-10, 80x23), where the lower city sold its ore: Meteor Slugs creep its floor, a fall of time-locked water pours into a spiked pit across the hall (frozen, its lowest foothold lies flush with the floor, so the glass is the bridge), and past it a Crystal Dwarf guards the stair down to the king's halls. In pass 70 that stair's last stone cracked: a doorway at the market's east end leads down the King's Stair (55,-8, 40x45), where the king's fall pours down the stair-well. The upper flight's only way down is through the water, and the only way back up is a frozen climb with a dry niche halfway to wait out the glass. At its foot, by a shrine, the King's Kennels (56,-7, 80x23) hold three Clockwork Hounds among their stalls, a spiked drain, and the kennel-master's loft up hidden planks with a chest. Their east end opens on King Grieve's Throne Hall (58,-7, 60x23, pass 71), a bare hall with his dais at the east end.

**Daybreak as built (pass 54):** `levels/daybreak/`, entered by the Crown-Leaf's east door. Storm Ledge (a fallen causeway span over thorns: pogo it or stride it), Sky Steps (one-way island shelves stacked up a tall room, each gap past any jump, so an air dash at the top of the leap is the way up; storm crystals bristle on the cliffs so nothing can be climbed around them) and the Broken Shrine (a shrine, a Life Fruit, and the fallen bridge to Daybreak town). Look: pale ashlar shrine stone with gold inlay, a violet storm sky with lightning and drifting islands, rain driven on the wind. Music `daybreak` (E dorian at 116, thunder toms) and ambience `amb_daybreak` (gusting wind, rain, rolling thunder).

**Daybreak town (pass 57):** the Broken Shrine's east door opens on the Fallen Bridge (52,-11), the great elf bridge broken into floating spans a stride apart, with hornets in the wind and a beetle on the old footing below (a fall walks you back to the near pier; storm crystals on the far pier stop a climb round). Past it, Daybreak (54,-11), the bell town on the last great island: a Guru, Calder the Armorer (Full Plate), Scribe Ysolde (the Fire scroll), Grocer Wenna, Bell-Ringer Tamsin on the bell loft gallery (the Daybreak chart), the Mayor (who names Borabohra) and the old Bellkeeper (who points at the bramble-choked bell cellar, where a Potion Shard waits for Fire). Music `daybreak_town` (G mixolydian at 92, a carillon over warm pads). The Spires beyond, with Borabohra and the Thunder spell, come next.

**The Spires begin (pass 58):** a passage through the town's bell tower (from the bell-loft gallery) leads to the Spire Foot (56,-11), the old lift-house, where the Thunder scroll lies on the conductor's lectern and one dead conduit stands before a conduit gate. Past it the Spire Stair (57,-12, 40x45) climbs old landings to a silver hatch that opens only when both its conduits wake (one on the floor, one on a landing), and above it to a chest on the top landing below the roost. The Storm Harpy came in pass 59. In pass 60 the top landing's east door opens on the Roost (58,-12), Borabohra's arena (8.6). In pass 62 the Roost's east door, sealed with the arena until the roc falls, opens on the Spring of Sky (60,-12): the spring on a dais, and past it Dartmoor's upper gate (legend `g`), shrine stone with a gold lightning glyph that only the Sky Key opens. The way down to Dartmoor beyond it comes with that zone.
**The Sunken Spring begins (pass 86):** `levels/sunken/`, the optional zone under Dartmoor. The way in is the last stone of the Meteor Rise: three cracked stones in the floor at its foot (the Mattock breaks them) over a shaft that is still full of water, so it is the zone's first swim (bible 6.8). The shaft drops into the Spring Gate (60,-6, 40x45), a drowned cistern of pale limestone with two Spring Eels, a chest and a potion shard on the bottom, and a dome of trapped air whose shelf holds a shrine. Let go of the controls in the shaft and the water floats you back up into the Rise. Its east door, on the bottom, opens on the Drowned Aqueduct (61,-5, 80x23), the dwarves' old culvert up to their city: the water stands at row 9 under four broken arch tops you can climb out onto, two walls hang down into the water so you swim under them, three eels hunt it, a Mantra Shard sits on an arch and a dry gallery at the east end holds a chest. Under the water at its east end the Source Hall (63,-5) is a black pool beside a dry shore with a Shade Knight, a Life Fruit on a shelf, and a sign: the Source lies deeper still, and the way to the Drowned Warden (8.10) opens in a later pass. Look: limestone laid down by the spring in wavy strata like the rims of terraced pools, pocked, with a blue-green mineral stain; behind, a flooded cavern of stepped pools under slanting light, and nearer the aqueduct's arches on their piers with weed swaying up from the bottom. Decor: rimstone dams, spring pearls, waterweed, limestone straws, seeps of the spring's light and flowstone. Specks of light rise through the water. Music `sunken` (E dorian at 64: tidal pads, a pluck rippling through each chord like light on water seen from below, a far bell) and ambience `amb_sunken` (a deep pressure hum, a current washing through stone, bursts of bubbles).

**Victim (pass 145):** the first of the Mist's two towns, and the first town of the original's eight that the remake had left out. `levels/mist/victim.room` (25,-8, 80x23), west of the Feather Hollow: a shelf at the Hollow's west wall leads in, so the town is reached with the Lantern Key, through the room where the Wing Boots wait. Victim is the lamp town on the boardwalks, built before the fog and never left. Its miners went down the drowned stair to dig meteor stone for the dwarf king's gold and came back as the Drowned Dwarves of the mire (bible 7). There it has:
- a Guru (save, skills and a Mantra Path stop);
- Keymaster Odo (Jack 150 g and Queen 400 g keys, ointment and elixirs; bible 10.2 names Victim as a key master's town);
- Fogwalker Bram on a plank loft, selling the Mist chart (500 g);
- Marta, a miner's widow, and Lamplighter Nell, who both have new lines once the Tree blooms (4.4).

The fog lies over the town at 0.6 (0.88 out in the marsh). It is lit by four lamp posts (prop `lamp`, `TownLamp`: a lantern on an iron arm whose flame clears an 84 px pocket of fog), so the street is a string of warm pockets with dark between. Its houses are boardwalk houses (`HouseFront` in the `mist` style: reed-grey planks, a damp dark frame) whose windows burn from the first visit, unlike Apolune's, which wait for their people. Music `victim` is the Mist's B minor waltz come in out of the cold: D major in 3/4 at 84, the same music-box pluck on two and three but dry and near, warm pads, a walking bass and a lamp-bell on every other downbeat. The bed stays the Mist's. **Mascon**, the second Mist town, is still planned: east beyond the black water past the Scorched Hall, whose sign already points to it.

### 3.3 Room and map rules

- **Room size:** multiples of one screen (640x360 px internal = 40x22.5 tiles of 16 px). Rooms are 1x1 up to 4x3 screens.
- **Camera:** room-bounded; camera locks to room edges; transitions are seamless scrolls (no fade) within a zone and a brief fade between zones. The scroll is a screen push: the old view slides out the way the player went while the new room slides in (0.34 s). Inner doorways (Up to enter) fade, since there is no direction to scroll. Coming up a shaft you arrive inside the floor door of the room above, still rising; fall back before you clear it and that door takes you back down (pass 146), instead of letting you drop out of the room.
- **Save points:** each town has a Guru (save, respec, rank-up). Plus 2 to 3 **Meditation Shrines** per zone (save only). No room is more than 4 rooms from a save or a shortcut back to one.
- **Fast travel:** unlocked after the first spring: Guru-to-Guru travel through the "Mantra Path" menu. Speaking to a Guru marks that Guru as a stop; the Guru's menu lists every other stop you have met, and choosing one fades you to a step beside that Guru. Before any spring flows the row is shown but dry, so players learn it exists.
- **Map:** auto-maps visited rooms. The Cartographer in each town sells the zone outline (empty rooms shown dimmed). Map pins (custom markers) available from the start: with the map open, Jump drops a pin where you stand or lifts the one there, up to 12. Cartographers so far: Pell in the Eolis market (Eolis 40 g, Trunk Hollows 250 g), Surveyor Brin in Forepaw (Tower 400 g), and Skywatcher Orin in Conflate (Mist 500 g, Branches 650 g), and Fogwalker Bram in Victim (Mist 500 g, pass 145). Doors, gates and items get icons once seen. Built: shrines, key doors still shut (pass 127, see 4.5) and Treasure Sense's star (pass 100).
- **Landmarks:** every zone has at least 3 visually unique landmark rooms (a giant statue, a waterfall, a crashed airship-dwarf barge) so players can navigate by memory. The Tower's are the great winch in Winch Hall (still until Forepaw is freed, then turning), the Forepaw forge, and the Smelter's hanging crucible pouring molten ore.

---

## 4. Progression

### 4.1 Abilities (the gates)

Abilities are permanent and listed in acquisition order. Each one opens new routes in every earlier zone.

| # | Ability | Faxanadu root | What it does | Gate it opens | Found in |
|---|---------|---------------|--------------|---------------|----------|
| A0 | **Wanderer's Kit** (start) | (original hero) | Run, jump, variable jump, slash, up-slash, Red Potion flask | none | Start |
| A1 | **Climbing Glove** | Glove | Wall slide and wall jump | Tall shafts, narrow chimneys | Trunk Hollows, mid-zone shrine |
| A2 | **Mattock** | Mattock | Down-strike in the air: **pogo** off enemies, spikes and thorn bulbs; breaks cracked stone | Cracked walls and floors, thorn-bulb chains, spike corridors | Tower of Trunk, after a mini-boss |
| A3 | **Wing Boots** | Wing Boots | **Double jump** (feathers burst), refreshed by pogo and wall touch | Wide gaps, high ledges | The Mist, Victim side: on a perch in Feather Hollow (27,-8), west of the Victim Causeway |
| A4 | **Deluge** (spell) | Deluge | Water bolt: puts out flame barriers, fills basins (floating platforms rise) | Fire seals, dry basins | The Mist, Mascon side: a drowned scribe's scroll on the Marsh Road (32,-7), east of the Sunken Chapel |
| A5 | **Elven Stride** | (new, elven) | **Air dash** with brief invulnerability; passes through mist curtains | Mist curtains, long horizontal gaps, wind walls | Branches: the Windloft shrine (46,-10), up Conflate's north bough; a warden's cache across the North Bough's gap is the first stride gate |
| A6 | **Thunder** (spell) | Thunder | Bolt that arcs to conductors; powers elevators and doors | Dead conduits | Daybreak: the Spire Foot (56,-11), through the bell tower |
| A7 | **Black Onyx** | Black Onyx | Passive: illusory walls shimmer; hidden platforms faintly visible | Illusory walls (secrets and one main route in Dartmoor) | Dartmoor, early |
| A8 | **Hour Glass** | Hour Glass | Stops time for 2.5 s (cooldown 8 s): freezes falling water, crushers, platforms, projectiles | Time puzzles, waterfall stairs | Dartmoor, mid-zone |

**Hour Glass as built (pass 67):** its own button, Hour Glass (T or E; left stick click). No MP. Time stops for 2.5 s, and the glass runs back for 8 s from when it was turned. The world drains to a cold blue while it holds. Enemy projectiles (feathers, gears, globs, seeds, rubble, spikes, shockwaves, storm bolts, and since pass 120 the Marsh Hag's mire hand, mark or risen) hang where they are and harm no one until time runs again, and time-locked water freezes into footholds. You and the enemies themselves go on, except the Clockwork Hounds (pass 70), which are clockwork and stop dead: it is a tool for puzzles and for slipping through a volley, not a pause button.
| A9 | **Elf, Ruby, Dworf and Demon Rings** | Rings | Story keys: the four rings open the gate of Zenis | The Zenis gate | Rokusutahn, Zoradohna, Zorugeriru, King Grieve |
| A10 | **Dragon Slayer** | Dragon Slayer | The only blade that can hurt the Evil One's core | Final boss | Zenis, inside the gate |

Supporting spells (optional, combat-focused, found or bought): **Fire** (arcing fireball, burns bramble walls for secrets), **Tilte** (homing spirit orb; built pass 95: 22 MP, 14 damage. It leaves the hand drifting up and forward and hangs 0.15 s, pulsing, then locks on the nearest foe within 240 px, a foe behind counting as twice as far, and flies at 230 px/s, turning at most 6 rad/s, so a quick foe can slip it; walls stop it; 2,500 g at the Daybreak scriptorium), **Death** (screen-wide, very expensive, late secret; built pass 132: 40 MP of a base 60, so one cast from a full flask. A ring of black light rolls out from you to 300 px over 0.45 s, through walls, and every foe it passes takes one blow of 36 that no shield faces; bosses take half, 18. It tolls a deep knell (`death_wave`). The scroll (legend `{`) lies in the King's Kennels in Dartmoor, beside the kennel-master's chest on the loft that only hidden planks reach. It is last on the Next Spell cycle. Mantra of Death, the Arcana node after Time Thief (pass 134, 3 points), halves its cost: 20 MP, 17 with Thrift).

**Fire as built (pass 57):** sold by Daybreak's scribe for 1,200 g (the Mascon shop comes with Mascon). 20 MP; the ball is thrown forward and up (170 px/s across, 150 up, falling at 520 px/s²), so it lands about seven tiles ahead and arcs over a low foe's head at point-blank range. It bursts on a wall, floor or foe, scorching every foe within 20 px for 18 and lighting every bramble in reach. It lights the fog as it flies. The Next Spell button (G or O; right stick click) cycles the spells you own, and the HUD's magic-bar gem shows the equipped spell's color. The save keeps the choice.

### 4.2 Critical path

1. Eolis: talk to the King, get 1,500 gold, buy a weapon. The Guru teaches saving. Enter the roots.
2. Trunk Hollows: Climbing Glove. Boss **Rokusutahn**. Restore the **Spring of Trunk** (first third of the fountain). Get the **Elf Ring**.
3. Tower of Trunk: Mattock. Boss **Zoradohna**. Elevator shortcut back to Eolis. Get the **Ruby Ring** (from Zoradohna, whose defeat frees the dwarves of Forepaw).
4. The Mist: Wing Boots (Victim side), Deluge (Mascon side, in either order). Bosses **Ripasheiku** (optional-feeling but required for the lantern key) and **Zorugeriru**. Restore the **Spring of Mist** (second third). Get the **Dworf Ring**.
5. Branches (Conflate): Elven Stride. Boss **Pakukame**.
6. Branches (Daybreak) and Spires: Thunder. Boss **Borabohra**. Restore the **Spring of Sky** (fountain full; Eolis celebrates). Borabohra drops the **Sky Key** that opens Dartmoor's upper gate.
7. Dartmoor: Black Onyx, Hour Glass. Boss **King Grieve** gives the **Demon Ring**. Boss **Shadow Eura** guards the Zenis gate.
8. Zenis: Dragon Slayer, gauntlet, **The Evil One**. Ending.

*Ring sources, final:* Elf Ring (Rokusutahn), Ruby Ring (Zoradohna), Dworf Ring (Zorugeriru), Demon Ring (King Grieve).

### 4.3 Sequence breaks (deliberate)

Expert players can skip ahead, and the game must never soft-lock if they do:
- Pogo chains in the Mist let skilled players reach Conflate before Wing Boots.
- A wall-jump route skips most of the Tower of Trunk after Zoradohna is beaten: the Old Flue, a three-screen chimney with no ledges above the Tower Foot, then the Rafters under the tower's crown, straight to the top of the Mine Shaft. It skips the lift, Forepaw, the Mine Mouth and the shaft climb. An iron damper (legend `Q`) seals the flue until the winch turns.
- ~~Hour Glass can be reached before Black Onyx with precise dashes.~~ Changed in pass 66-67: the Onyx's main-route illusory wall leads to the Hour Glass, so it now always comes second. A dash skip can come back with the lower city.
All story triggers check items, not route order.

### 4.4 World-state changes

| Trigger | Change |
|---------|--------|
| Spring of Trunk restored | Sap pools in Trunk Hollows harden into walkable amber; new route to a secret; Apolune NPCs return; Eolis fountain 1/3 |
| Zoradohna defeated | Forepaw dwarves freed (Forepaw town behind the lift: Guru, smith, elder, miners; its own theme); the Forepaw lift runs again, stopping at the town, the Tower Foot and a cage at the East Gate of Eolis down the outside of the trunk (the elevator shortcut home; press Up in a cage to pick a stop); dwarf smith opens (weapon upgrades) and his forge burns again (a hearth, bellows and an anvil that rings and throws sparks); the great winch in Winch Hall turns again and hauls open the Old Flue's damper in the Tower Foot (the wall-jump skip route of 4.3); the Forepaw Deep Workings open east of the town (Mine Mouth, Mine Shaft, Rail Gallery, Mine Vault, Smelter, and two side rooms: the Sorting Floor, a loop from the Mine Mouth up into the Mine Vault, and the Slag Heap under the Smelter), the ore road toward the Mist, which leaves the Smelter's east end for the Fog Cut, the Drowned Stair and Lantern Landing, a shrine where the boardwalk to Victim is out, with the Sunken Chapel, Ripasheiku's lair, past its east door |
| Ripasheiku defeated | Her lanterns go dark and she gives up the Lantern Key, which opens the way to the Spring of Mist and Zorugeriru. The key's light parts the bound fog (a pale wall of unmoving mist, legend `Y`, that tells you it wants a lantern) sealing the shaft above Lantern Landing; it parts for good and the key is kept. Beyond it the Veiled Rise climbs to the Victim Causeway, a spiked boardwalk dip on the road west to Victim, and past it Feather Hollow, where the Wing Boots wait on a perch below a Life Fruit only a second jump reaches. Her chapel's east door opens on the Marsh Road toward Mascon, where the Deluge scroll lies before a fire seal; the Scorched Hall waits behind it, the Dry Cistern past that, and past the cistern the Spring of Mist, Zorugeriru's lair |
| Zorugeriru defeated | Dworf Ring; the Spring of Mist's tanks stay full, and the spring on its shelf can be cleared; the arena's east door opens on the Windward Climb, where bounce-pods throw you up out of the Mist into the Branches (the Sunlit Bough, then Leaf Landing, a shrine on the elves' leaf road) |
| Spring of Mist restored | Fog lifts by half in the Mist (vision radius grows); drowned boardwalks resurface (legend `b`: one-way planks over the spiked dips of the Fog Cut and the Victim Causeway, nothing before); fountain 2/3 |
| Spring of Sky restored | The storm breaks: Daybreak's rain thins to a drizzle (Motes.SETTLES). Eolis festival: the fountain runs full, a piper plays in the plaza and Old Wena rejoices (pass 62). The Branches' wind currents turn and blow the other way (pass 92), carrying you into the Thicket Road's sealed wind niche. The final shop tier comes in on the sky road (pass 93, 10.2): the Giant Blade in Eolis and a Life Fruit in Daybreak |
| King Grieve defeated | Dartmoor drains; Sunken Spring entrance opens |
| Evil One defeated | Post-game: the Tree blooms (built pass 141, below). ~~Palette shift to spring colors~~ waits for the art polish phase. ~~All enemies respawn as "remnants"~~: foes already return when you re-enter a room, and they are the Tree's own creatures, so they stay as they are for the 100% cleanup |

**The Tree blooms (pass 141):** a save that has seen the ending (flag `cleared`) carries on into a changed world.
- **Blossom:** a second particle layer drifts pink petals down through every living zone of the Tree: Eolis, the Trunk, the Tower, the Mist, the Branches and Daybreak (`Motes.BLOSSOM`, `World.blossom`). There are 40 at a time, each two pixels long, turning end over end as it sways.
- **The meteor's air settles:** Dartmoor's crystal dust thins to 35% and Zenis's cyan spores to 20% (`Motes.SETTLES`, now keyed by any flag).
- **People:** sixteen people (everyone a cleared save can meet who talks rather than trades) say something new once the Tree blooms, through a `lines_cleared` list in `data/npcs.json` that takes over from their other lines (`Npc.lines`). The King marvels at the flowering, Old Wena fishes petals out of the fountain, the dwarves of Forepaw mourn Grieve as a king, Dartmoor's mason chips grey crystal out of dry walls, and Hrothgar's digger points you to the smith with your Meteor Shards.
- The ending still returns you to the title. Continue picks up the cleared save where you last rested.

### 4.5 Gate visual language

Every gate has a consistent, readable look so players remember it:
- **Cracked stone:** pale crack lines, small pebbles fall when you are near (Mattock).
- **Thorn bulbs:** red glowing pods on spike vines (pogo targets).
- **Fog (the Mist):** a grey-green murk over every Mist room hides all but a pocket of sight around you (about 7 tiles), the lanterns hung through the zone (about 4 tiles each) and the glow of a shrine. The fog drifts and bands like dithered pixel fog. Restoring the Spring of Mist thins it by half and widens your sight by half. A room can set its own density with `fog:`. Lights that matter to play (a boss's lanterns, a Marsh Hag's wisp and her mark, spells, abilities) are lit before the decor's lanterns, so a room crowded with lanterns can never leave a foe dark (pass 120).
- **Mist curtains:** shimmering vertical fog with a faint elven rune (Elven Stride).
- **Fire seals:** red runic flames (Deluge). They block like a wall, burn for 10 on touch and light the fog around them. One Deluge bolt douses every seal in the room for good, in a hiss of steam (legend `Z`, a column of three under a stone arch).
- **Dry basins:** cracked mud basins with a water-line stain (Deluge). A Deluge bolt cast across the tank (from its rim is enough) fills it over a second, drowning anything left in it, and a raft floats up to the stain and stays there as a one-way platform for good. The first is the Dry Cistern (mist 34,-7) east of the Scorched Hall, whose shelf over the tank's middle only the raft reaches; Zorugeriru's basins work the same way (legend `u` for the mud bed, a row of `=` for the stain).
- **Bramble walls:** a knot of dry thorn-vine, crossed vines with pale thorns (Fire, legend `w`). Blades only snag in it. A fireball sets it alight and the flames creep tile to tile through the whole knot, which burns to ash in about a second and stays burnt. Fire is optional, so bramble only ever hides secrets, never the way on.
- **Dead conduits:** copper coils with a dim blue spark (Thunder). A Thunder bolt that passes within 72 px of one (not behind it) leaps to it in an arc and wakes it for good: the coil glows and lights the fog. When every conduit in a room is awake, the room's conduit gates (elf-silver shutters with a lightning glyph, legend `k`; a conduit is legend `c`) slide up for good (flag `conduits:<room>`). Thunder as built: 18 MP, a fast bolt (380 px/s) that strikes one foe for 16.
- **Illusory walls:** a 1-pixel seam visible only with Black Onyx. As built (pass 65): any fake wall (`%`, or a `secret:` cover) gets a thin violet seam round its edge that breathes and sweeps with light once the Onyx is carried. Hidden planks (legend `i`) are one-way planks that are always solid but drawn only through the Onyx, at about 40% opacity; a leap of faith finds them without it, so they guard secrets and never the only way on.
- **Time-locked water:** waterfalls with clock-glyph droplets (Hour Glass). As built (pass 67, legend `f`, a block of cells): flowing, it bears down at 260 px/s on anything in it, so you can't jump or climb up through it, though you can walk out. While time is stopped it stands still, a pale frozen column with footholds every three rows up from its bottom (one-way ledges), a stair you climb before time runs on.
- **Key doors:** Jack, Queen, King, Ace and Joker doors with a card-suit glyph. As built (pass 117): every card door is three tiles tall (legend `J`, made a higher card by a `lock: x, y, kind` header line) and wears its suit: the Jack is oak with iron bands and a gold spade, the Queen red lacquer with gold bands and a heart, the King blackened iron with a gold club, the Ace elf-silver with a blue diamond, and the Joker violet with green bands and a gold star that winks. Walk into one holding its own key and it opens for good and spends that key; any other card's key does nothing. The map's status line lists the keys you hold, and since pass 127 the map marks every key door you have seen and not yet opened: a little slab in its card's color (the Sky Gate in its shrine stone) with a gold band, standing where the door stands, until the door opens (legend "Locked door"). A key bought zones later has somewhere to go. Card doors guard vaults, never the way on: a roofed pocket behind the door with a chest worth more than the key (header `chest: x, y, gold`). Built: the Jack door in the Deep Roots, the Queen vault in Feather Hollow (900 g), the King vault in the North Bough (1,800 g), the Ace vault on the Spire Stair (3,200 g) and the Joker vault on the Meteor Rise (5,000 g). The keys are sold by the grocers on the road to each one (Queen at Apolune, King at Conflate, Ace at Daybreak, see 10.1). The one Joker Key is never sold: it lies on the stall-plank of the Drowned Market (`prop: x, y, joker_key`). Sounds (pass 122): walking into a door without its key rattles the latch, with two dull knocks against the bolt (`door_locked`), once per touch; the key turning clicks through the wards, draws the bolt back with a thunk and rings a small bright chime (`key_turn`). The Sky Gate uses the same two.
- **Root-gates (Trunk Hollows):** a woven pillar of living roots beaded with sap. No ability opens it: find and strike the room's Root Heart, a pulsing amber bulb, and every gate in the room draws back into the ceiling for good. A puzzle of finding, not of power, so the zone has gates before the Climbing Glove.

---

## 5. Player and Combat

### 5.1 Stats

| Stat | Start | Max | Raised by |
|------|-------|-----|-----------|
| Health (HP) | 5 masks of 20 HP (100) | 12 masks (240) | Life Fruit: 2 fruits = +1 mask (14 fruits) |
| Magic (MP) | 60 | 150 | Mana Dew: each +10 (9 dews) |
| Red Potion flask | 2 charges, heals 40 HP | 5 charges, heals 70 HP | Potion Shards (3 shards = +1 charge; 9 shards) and skill tree |
| Attack | Weapon base | | Weapons, smith upgrades, skill tree |
| Defense | Armor base | | Armor, shields |

HP is shown as masks (chunks), so damage is readable at a glance, while the math uses HP for fine tuning.

### 5.2 Weapons and armor (Faxanadu tiers)

| Slot | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------|--------|--------|--------|--------|
| Blade | Hand Dagger (start, fast, short) | Long Sword (400 g) | Giant Blade (2,800 g, slow, huge arc; built pass 93: slash 15, heavy 28, reach 16) | Dragon Slayer (found in Zenis; built pass 80: slash 18, heavy 30, reach 12) |
| Armor | Leather (200 g) | Studded Mail (1,100 g) | Full Plate (4,200 g) | Battle Suit (secret: the Drowned Warden, 60% less damage) |
| Shield | Small Shield (150 g) | Large Shield (900 g) | Magic Shield (3,600 g, reflects small projectiles on parry) | Battle Helmet (secret, +1 mask) |

Each blade has its own swing speed and reach, so a weapon change is a play-style change, not just a number. The dwarf smith in Forepaw upgrades each blade twice (+15% each) for gold plus Meteor Shards. (Built: Hrothgar's Forepaw Forge sells Temper Blade I for 700 g and II for 1,600 g, per blade, so a new blade starts untempered.)

**Meteor Shards (built pass 140):**
- Splinters of the meteor, flung down the Tree when it struck the crown: a black rock heel with three magenta crystal spurs and a cyan light beating in the crack between them. Legend `(`.
- Temper Blade II costs one besides its gold (`"shards": 1` on the shop entry); Temper I is gold alone. Without one the forge shows "Needs shard", and the temper's line says how many you carry. A shard is spent when the smith folds it in.
- Five lie in the world, one more than there are blades, so one can go to a blade you later put down: on the Crown Lookout above the potion shard (Tower, near the smith), above the Scorched Hall's platform (the Mist), in the Sunlit Bough's hidden pocket (Branches), in the Broken Shrine's hidden pocket (Daybreak), and at the end of a Meteor Rise shelf (Dartmoor). They count as treasures for completion and Treasure Sense.
- Carried in `GameState.data.meteor_shards`.

**Giant Blade (built pass 93):**
- Slash 15, heavy 28, and 16 px more reach than the dagger.
- Its side slash sweeps 20 px taller, so it covers you from head to heel and catches fliers and crawlers a plainer blade misses (`arc` in `data/items.json`).
- Every swing takes 30% longer to recover (`swing` 1.3), so its pace is about the Long Sword's damage per second, traded for reach and coverage. Commit to a cut and space your foes.
- It is drawn two pixels broader, with a larger smear.
- Eolis Arms sells it for 2,800 g once the Spring of Sky is restored (10.2). With the Dragon Slayer in hand it shows as owned.

**Battle Helmet (built pass 118):**
- The shield slot's fourth tier, found and never sold. It lies in a hidden pocket at the meteor's Threshold (`zenis/threshold`), behind fake wall west of the shrine (`secret: 1, 17, 6, 19`), so the Black Onyx's seam shows the way in. It is laid by `prop: x, y, battle_helmet`.
- Touch it and it goes straight on in the shield's place, like the Dragon Slayer in the blade's. Your health fills to the new top.
- It guards 70% and its parry turns shots back like the Magic Shield, and it is worth one more mask (+20 HP, `hp` in `data/items.json`). The mask comes from the gear, not the base stat, so a save keeps it through `refresh_stats`.
- Every shield in a shop shows as owned once you wear it.

**Magic Shield (built pass 91):**
- It guards 70%, like the Large Shield.
- A parry also catches small shots no other shield can parry: Sap Spitter globs and Meteor Slug globs (group `small_projectile`). It catches Pakukame's seeds too, which any shield can parry.
- The caught shot flies back as a mote of shield light, glowing with the colour of what it caught (`ReflectedShot`). It goes at 340 px/s toward the nearest foe within 260 px on the side you face, or straight ahead, and strikes the first foe it meets for 16.
- Feathers, gears and shadow bolts already turn back on any shield's parry, and still do.
- A caught sap glob leaves no puddle.

You start with no shield: Block and parry come with the Small Shield, the first purchase most players make in Eolis. Gear values live in `data/items.json`:

| Item | Values |
|------|--------|
| Hand Dagger | 8 light / 14 heavy |
| Long Sword | 11 light / 19 heavy, +8 px reach |
| Leather Armor | 15% less damage taken (minimum 1) |
| Small Shield | Guard halves damage (5.3) |
| Studded Mail | 30% less damage taken |
| Large Shield | Guard blocks 70% of a hit |
| Elixir | Carry one; a fatal hit uses it and revives you in place at full health |

### 5.3 Combat moves

- **Slash:** 3-hit ground combo, 2-hit air combo. Each hit pushes the player back 4 px (knockback against enemy on hit; `slash_recoil` 120 px/s, raised from 90 in pass 105, which only gave 2.3 px). A hit stops a foe's thinking for 0.18 s (`Enemy.HITSTUN`); the heavy finisher drives it back 1.8x as hard and holds it 1.8x as long (0.32 s), so a full combo buys a breath.
- **Up-slash:** hits above. In midair, an up-slash that lands on a foe holds you up: a fall turns into a 150 px/s rise (`up_slash_pop`, about 7 px), once per swing, never adding to a jump (built pass 105; it applies to every foe, not only launcher types, so juggling a flier slows your fall without letting you climb).
- **Down-strike (Mattock):** see pogo in 6.6.
- **Parry (shield):** tap Block within 0.12 s of a hit: no damage, 140 ms hit-stop, enemy staggered. Holding Block reduces damage by the shield's percent but drains MP.
- **Spells:** one equipped spell on the Spell button, cycled with the Next Spell button (the shoulders are taken by Dash and Block, so it is the right stick click on a pad; changed in pass 57). MP regenerates slowly and on melee hits.
- **Damage taken:** 0.8 s invulnerability, 0.15 s hit-stop, knockback, screen flash. The flash is a red glow at the screen's edge that fades in about 0.4 s; it never covers the middle, and the Flashes option scales it (built pass 98).
- **Low health (built pass 98):** at one mask (20 HP) or less, a muffled heartbeat sounds every 0.85 s and the screen's edge pulses faintly red in time with it. It stops the moment you heal above a mask.

**Starting combat values** (in `scripts/player/combat_tuning.gd`, asserted by tests):

| Value | Setting |
|-------|---------|
| Light hit / heavy third hit | 8 / 14 damage (Hand Dagger) |
| Combo window, cooldowns | 0.40 s to chain; 0.20 s, 0.20 s, 0.38 s after hits 1 to 3 |
| Attack buffer | 0.15 s |
| Parry window | 0.12 s from the Block press; 140 ms hit-stop, enemy staggered 1 s, +6 MP |
| Guard (Small Shield) | 50% less damage, 8 MP per blocked hit, 40% walk speed |
| Knockback when hit | 160 px/s back, 220 px/s up, 0.18 s control lock |
| Low health | 20 HP or less: heartbeat every 0.85 s, red edge pulse |
| MP | 60 max, +2/s, +4 per melee hit on an enemy |
| Red Potion | 2 charges, +40 HP, 0.7 s to drink, cancelled (charge kept) if hit |
| Deluge | 15 MP, 12 damage, 300 px/s |
| War Glove (rare drop, 7) | blade hits x1.5 for 15 s |
| Gold coins | Magnet after 0.4 s within 100 px |

### 5.4 Death and recovery

On death you return to the last Guru or shrine. You drop **60% of carried gold** as a glowing purse where you died. Reach it to recover it; die first and it is gone. XP and items are never lost. This keeps tension without the original's harsh losses.

---

## 6. Movement and Game-Feel Spec

All numbers are at the internal resolution (1 unit = 1 px at 640x360). Tile = 16 px. Player collision box = 12x40 px (sprite about 48x56). These are starting values for the movement prototype, tuned there and then frozen.

### 6.1 Ground movement

| Parameter | Value |
|-----------|-------|
| Max run speed | 165 px/s (about 10 tiles/s) |
| Ground acceleration | 1,800 px/s² (reaches max in about 0.09 s) |
| Ground deceleration | 2,600 px/s² |
| Turnaround boost | deceleration x 1.6 when input opposes velocity |
| Slope handling | snap to slopes up to 45°, no speed loss going up. Built in pass 115: 45° slope tiles (legend `/` rising east, `\` rising west) in every zone's tileset. You run up and down them at full run speed along the slope without leaving the ground (4 px floor snap), stand still on one without creeping, and jump from one as from flat ground. A slope's face is floor, never a wall: the Climbing Glove doesn't catch on it and the ledge clip leaves it alone. The box rests on its downhill corner, so the sprite is drawn down onto the slope (up to 6 px). Walkers treat a ramp as the end of their patrol. In the gym's hill, Leaf Landing's hump, the king's dais, the Spring of Sky's dais and the Ore Vault's mound |

### 6.2 Jump

| Parameter | Value |
|-----------|-------|
| Full jump height | 72 px (4.5 tiles) |
| Time to apex | 0.36 s |
| Gravity (rising) | 1,111 px/s² (derived: 2h/t²) |
| Jump velocity | 400 px/s (derived: 2h/t) |
| Gravity (falling) | rising x 1.6 |
| Jump cut (release early) | vertical velocity x 0.45 |
| Apex hang | gravity x 0.5 while holding jump and \|vy\| < 40 px/s |
| Max fall speed | 520 px/s; 620 px/s while holding down |
| Air acceleration | 1,400 px/s²; air deceleration 900 px/s² |
| Coyote time | 0.10 s, off any footing: a solid floor, a one-way platform, a ledge that vanishes from under you (a Bark Knight's lance), a ledge into a wind current or drift pocket, and the water (pass 111) |
| Jump buffer | 0.12 s (works on ground, wall and double jump; a double jump pressed late in an air dash fires the frame the dash ends) |
| Corner correction | nudge up to 6 px horizontally on head bump; 4 px vertically on ledge clip, including while wall-sliding with the Climbing Glove (the clip steps you onto the ledge instead of catching you in a slide). Both limits are inclusive (pass 107). The ledge clip covers one-way platforms too: having no side to bump, their lip is found from above, and a drop-through is never lifted back (pass 111) Head correction (pass 139): moving across in the air, level or falling (a dash, a jump past its peak), a head that clips the top edge of an opening by up to 4 px (`head_correction_px`) is nudged down into it instead of stopping dead on the lip. A wall met below the head is left alone. |
| Minimum jump height | about 18 px (tap) |

### 6.3 Wall slide and wall jump (Climbing Glove)

| Parameter | Value |
|-----------|-------|
| Wall slide speed | max 90 px/s (falls slowly with dust particles) |
| Wall stick | 0.08 s before pushing away detaches |
| Wall jump velocity | 220 px/s outward, 380 px/s up (pushing away from the wall) |
| Climb jump velocity | 120 px/s outward, 380 px/s up (neutral or toward the wall; lock 0.06 s) |
| Input lock after wall jump | 0.10 s, then control blends back over the next 0.10 s (the blend starts when the lock ends; until pass 107 the two ran together, so there was no blend) |
| Same-wall climb | allowed (neutral wall jump goes up and slightly out, Hollow Knight style) |
| Wall coyote | 0.08 s after leaving a wall |

### 6.4 Double jump (Wing Boots)

| Parameter | Value |
|-----------|-------|
| Height | 48 px (3 tiles), velocity 326 px/s |
| Count | 1, refreshed by ground, wall touch, pogo, and stride seeds (the dash-reset orbs, pass 97: legend `r`, a glowing elf-seed floating in open air. Touched in the air with a double jump or dash spent, it bursts and gives both back, then grows again after 2.5 s. With nothing spent it stays whole. Seeds only help and never gate a route. In the gym over the dash gap, and three in the Sky Steps) |
| Feel | feather burst, small upward squash, wing whoosh |

### 6.5 Air dash (Elven Stride)

| Parameter | Value |
|-----------|-------|
| Speed and duration | 380 px/s for 0.15 s (about 57 px) |
| Gravity during dash | none; exits with vy = 0 |
| Invulnerability | first 0.10 s |
| Charges | 1 in air (2 with skill node), refreshed like double jump |
| Ground dash | yes, same values, 0.25 s cooldown. It hugs the floor (pass 121): a dash begun on the ground snaps to the floor from 10 px (`ground_dash_snap`, against the run's 4 px), so it rides a slope down as it already rode one up, instead of sailing off the ramp into the air. A ledge of a whole tile or more still drops away beneath it, and an air dash never snaps |
| Dash buffer | 0.10 s (pass 146), like the jump's: a dash pressed when it can't go yet (on the cooldown, or in the air with the dash spent) is held and goes the first frame it can, at the cooldown's end, on the landing, or when a kill with Wanderer's Grace or a stride seed gives the dash back. Pressed earlier than that, it's dropped. Without the Elven Stride a press isn't held, so picking it up never fires a stale dash |
| Afterimages | 3 ghost frames, elf-green tint |

### 6.6 Pogo (Mattock down-strike)

| Parameter | Value |
|-----------|-------|
| Trigger | attack + down while airborne |
| Hitbox | 28x24 px below the feet, active 0.14 s |
| Bounce | sets vy = -380 px/s (more than a jump cut, less than a full jump); holding jump gives -420 |
| Refreshes | double jump and dash |
| Valid targets | enemies, projectiles marked pogo-able, thorn bulbs, spikes, lanterns, cracked-stone tops |
| Hit-stop on pogo | 45 ms |
| Bounce-pod (Branches) | landing on a pod from above sets vy = -600 px/s (about 9 tiles of rise in play); release doesn't cut it; refreshes double jump and dash. The pod isn't solid, so walking into it does nothing, and a hop onto it launches |

### 6.7 Juice checklist (all required before the movement milestone closes)

- **Squash and stretch:** jump 0.85x1.2 for 3 frames; land 1.25x0.8 scaled by fall speed; wall jump stretch toward direction.
- **Dust:** on run start, turnaround, land, wall slide (every 0.06 s, the overshoot carried so the beat holds at 60 fps), wall jump, and a dash: a kick of dust thrown back off the heel on the ground, a pale puff of air in midair (pass 104). The dash also leaves a trail of afterimages.
- **Hit-stop:** 50 ms normal hit, 90 ms heavy, 140 ms parry, 200 ms boss stagger (each phase break, pass 98), 350 ms boss kill (with slow-mo ramp): `Feel.boss_kill(seconds)` freezes 350 ms, then runs at 0.3x easing back up to full speed (quadratic) over the boss's slow-motion time, 1 to 1.5 s. Every boss uses it (pass 104; until then the kills held only 120 to 200 ms and the slow motion ended in a step).
- **Screen shake:** trauma model (shake = trauma²), decays 1.5/s. Light hit 0.15, heavy 0.3, boss slam 0.6. Option to reduce or turn it off.
- **Flash:** enemy flashes white for 2 frames on hit; player flashes red and blinks during invulnerability, and the screen's edge flashes red (pass 98, 5.3).
- **Camera:** look-ahead 48 px in facing direction (eased over 0.4 s); vertical look-down when holding down for 0.4 s, and look-up (pass 133) when holding Up standing still for 0.4 s, 72 px each way (on a ladder Up climbs instead, and the climb lead takes over); lerp smoothing with deadzone 16x24 px. On a ladder (pass 130) the camera leads 64 px the way you climb, eased over 0.5 s, and drops the sideways look-ahead; hanging still keeps the lead, and stepping off eases it back.
- **Wide camera (pass 94):** a room with `camera: wide` in its header (big arenas, sky rooms) eases the framing out over about 0.6 s to 0.8 scale, showing 25% more each way (800x450 world pixels). It never frames past the room's edges: a room too small for the full pull-out gets as much as fits. Leaving for a normal room snaps back at once. The world still renders on whole render pixels, the HUD and PixelFont are unscaled, and the weather motes tile across the wider view.
- **Rumble:** on gamepads, light for hits, strong for damage and boss slams. A landing from 7 tiles or more thuds with a light rumble and a little shake (pass 97); an ordinary jump's landing doesn't shake.
- **Sound:** layered footsteps per surface; distinct jump, double jump, wall jump, dash, pogo and land sounds.
- **Particles:** spark burst on hit (pass 98: `HitSpark`, a white core, an opening ring and five rays thrown along the swing, with a hot orange rim so it reads over the foe's white flash; it sits where the blade meets the foe, holds through the hit-stop, lasts 0.14 s, and the heavy finisher's is 1.6x), gold coins that bounce and magnet to the player after 0.4 s.
- **Input:** every action responds on the same frame it is pressed. 60 fps physics, fixed timestep; rendering uncapped with interpolation.

### 6.8 Swimming (the Sunken Spring)

Deep water (legend `a`) is a volume, not a surface: while the middle of the body is in it the player swims. Numbers live in `movement_tuning.gd` (Swimming group).

| Parameter | Value |
|-----------|-------|
| Float | the body eases toward rising at 50 px/s, so it comes to rest with its middle at the surface and the head out |
| Sink | holding Down eases it toward sinking at 120 px/s |
| Drag | 520 px/s² toward the float or sink speed |
| Stroke | a jump press under water sets vy = -230 px/s (weaker than a jump); no limit on strokes |
| Jump out | with the head above the surface a jump press is a full ground jump (and swimming refreshes the double jump and air dash). The water counts as footing for coyote time, so the frames the bob lifts the body clear still jump out at once (pass 111) |
| Across | 0.7x run speed |
| Attacks, dash | work as on land; the dash ignores the water |
| Breath | none: swimming is about routes and foes, not a timer |
| Feel | a "dive" splash and spray when the body crosses the surface fast; a soft "swim" whoosh per stroke; the water is drawn over the bodies in it, translucent, with a rippling waterline, drifting caustics and bubbles |

The reachability checker treats a spot with the feet in water as a standing spot: it swims to the water cells beside, above and below, and from a spot with the head out (no water two rows up) it jumps out a little short of a floor jump (rise 3, 3 across).

### 6.9 Wind currents (the Branches)

Bands of wind blow across the open sky between Conflate's boughs (legend `>` blows east, `<` west). A current only carries you while you are airborne, and only while the middle of your body is in it. Numbers live in `movement_tuning.gd` (Wind group).

| Parameter | Value |
|-----------|-------|
| Push | 200 px/s added to your horizontal target speed (with it you outrun a run, against it you hang nearly still) |
| Bear up | falling, your fall eases to level at 2,400 px/s², so you sail the band; a jump rises through it as normal |
| Ground | none: standing on a floor or platform inside a band, you aren't moved |
| Drop out | hold Down to fall out of it |
| Reversal | once the Spring of Sky is restored (`spring:sky`), every current in the Branches blows the other way (pass 92) |
| Look | a faint wash of the sky, streaks racing downwind and torn leaves tumbling with them |

The reachability checker rides a current downwind (turned after `sky_spring`) from wherever a jump or fall enters it, adding every spot it can stand on or drop to with Down, and at the band's end it lands or falls on. The Thicket Road's sealed niche (its chest) faces the far side of a current, so only the turned wind carries you into it.

### 6.10 Feather Fall (skill, pass 101)

The Wanderer skill Feather Fall [2] (after Second Stride, needs the Wing Boots) turns a held Jump into a glide once the double jump is spent. The numbers live in `movement_tuning.gd` (Feather Fall group).

| Parameter | Value |
|-----------|-------|
| When | airborne, falling, double jump spent, Jump held, Down not held, not on a wall |
| Glide fall speed | 60 px/s (a normal fall reaches 520) |
| Settling | a fast fall brakes to glide speed at 1,500 px/s²; a slow one falls into it at the normal fall gravity |
| Air control | unchanged (1,400 / 900 px/s², run speed 165), so a glide carries about 2.75 px across for every 1 px down |
| Leaving it | release Jump, or hold Down to drop at full speed; landing, a wall, a dash, water, wind or an updraft end it |
| Feel | a wide squash and a soft whoosh (`glide`) as it opens; the cloak-spread apex pose held; a feather shed every 0.14 s |

The glide replaces gravity while it lasts. It doesn't refresh any air move, so it never opens a route a double jump and a dash couldn't reach. It makes long drops readable and gentle, and makes crossing wide gaps easier for players who bought it.

### 6.11 Ladders (pass 124)

The original Faxanadu is a game of ladders: every climb in the World Tree went up one. The remake's wall jump, double jump and pods do most of that work now, but ladders are still the plain way up between floors, where no ability is needed. Legend `"`: a column of ladder cells. The top cell is also a plank (a one-way platform), so you can stand on a ladder's top. Numbers live in `movement_tuning.gd` (Ladders group).

| Parameter | Value |
|-----------|-------|
| Take hold | Up with the body on a ladder (on the ground or in the air), or Down standing on its top. Not mid-dash, mid-swing, swimming or drinking. Taking hold refreshes the double jump and the air dash |
| Climb speed | 90 px/s up or down (Up, Down); no gravity, so let go of both and you hang |
| Centering | the body slides onto the middle of the rungs at 240 px/s |
| Top | climbing past the top steps you onto its plank; Down there climbs back on |
| Bottom | climbing down onto a floor lets go; climbing off the bottom of a ladder that hangs in the air lets you fall |
| Jump | leaves with a full ground jump, moving the way you hold (run speed) |
| Dash | a stride leaves the ladder and dashes as usual |
| Regrab | after you jump or are knocked off, the same ladder can't be grabbed for 0.25 s |
| Hits | any damage knocks you off the rungs |
| Attacks | none while climbing (as in the original): jump off to fight |
| Feel | the wall pose's reach, cycling only while you climb; a hollow knock and a creak of the rungs (`ladder`) about every 8 px |
| Camera | leads 64 px up or down the way you climb (6.7, pass 130), so a long shaft shows where you are going |
| Look | two wooden rails and two rungs per tile, drawn behind the tiles so the top plank caps them |

The reachability checker treats a spot with the feet on a ladder as a standing spot: it climbs to the ladder cells above and below and over the top onto the plank, and jumps from a ladder as from the floor.

**Where ladders go (pass 125):** where the original put them, between floors that already connect, so a ladder is the plain way up and never a key. They go in shafts you otherwise climb by a zigzag of planks, and never in a shaft that is an ability gate (the Fungus Shaft is the Glove's). `test_ladders_never_open_a_gated_room` takes every ladder out and checks that, before the Glove and with it, the ladders open no room the bare rooms keep shut. Placed so far:
- the Hollow Mouth: floor to the high plank under the way to the Mossy Overhang;
- the Tower Foot: the floor up the right wall to the ledge at the Winch Hall door, beside the plank zigzag;
- the Mine Shaft: the bottom of the shaft up the right side, through the upper floor beside the miners' doors.

---

## 7. Enemies

About 4 to 5 enemy families per zone plus variants (recolors with new behavior). Names reuse the original's monster names where they exist.

| Zone | Enemies |
|------|---------|
| Trunk Hollows | Monodron (one-eyed hopper), Hornet (swooper), Rot Dwarf (shield-bearing walker), Grub Lump (crawls over floors, walls and ceilings; from a ceiling it shivers for 0.45 s, then drops on you), Sap Spitter (turret; lobs sap globs that leave a slowing puddle for 4 s) |
| Tower of Trunk | Iron Dwarf (plated walker: raises a hammer for 0.65 s, slams, and sends a shockwave along the floor that a hop clears; his plate halves blows except from above or while the hammer is stuck in the floor for about 1 s), Minecart Rider (a dwarf hunched in an ore cart: trundles the floor; with you level and ahead he hauls the brake for 0.6 s, wheels shrieking, then charges the length of the floor. Jump him. At a wall or the floor's end the cart stops dead and tips over for about 1 s, the rider dazed and open; otherwise the iron tub turns most blows except from above), Gear Bat (clockwork flier: roosts under ceilings, wakes when you pass, hangs off to one side of you, whirs the gear on its back for 0.5 s and flings it; the gear flies out, slows and returns to the bat; parry it and it flies home and staggers the bat), Rock Golem (mini-boss: the Foreman, a golem in a foreman's lamp-helm with the Mattock wedged in its back. 220 HP; its rock halves blows except from above or while stunned. Pound: fists up 0.75 s, a slam with a shockwave each way. Throw: a boulder overhead 0.6 s, then lobbed at you. Charge: scrapes 0.85 s, then barrels across the hall; hitting a wall stuns it 1.8 s and shakes rocks from the ceiling, each marking its spot 0.7 s before it falls. Below half: tells 25% shorter, faster charge, the pound also drops rocks. Beating it gives the Mattock) |
| The Mist | Lantern Ghost (a hooded wisp of a drowned dwarf that drifts through wood and stone; out in the fog it is all but invisible and shows only near light. Close in, its eyes flare for 0.55 s, bright even in the murk, then it lunges and fades back), Bog Myconid (a squat marsh mushroom rooted in the mud. Come within about five tiles and its cap swells for 0.6 s while its gills glow, a light that shows through the fog; then it bursts into a spore cloud 40 px across that drifts up, stings for 8 on contact and again every 0.7 s, and can't be parried. It thins away in 2.4 s. Spent, its cap sags open for 1.1 s and takes half again the damage, so the answer is to back off and then strike), Drowned Dwarf (built in pass 108: a Victim miner the marsh took, risen with the anchor he drowned on, his skin gone blue-white and his beard matted with weed. He lies sunk in the mire with only his helm's crest and a trickle of bubbles showing, and there he can't be hit and does no harm. Come within about five tiles, level with him, and he hauls himself out over 0.7 s, taking half again the damage while half out of the mud. Then he shambles after you at 26 px/s. Close in, he heaves the anchor overhead, water pouring off it, for 0.6 s (pose, white pulse, a low groan), and slams it down in front of him for 18. The slam can be parried. It buries the anchor in the mud for 0.8 s, and every blow lands at half again. Lose him (out of sight for 3 s) and he sinks back into the mire to wait. 46 HP, contact 10 once risen. Legend `p`; in Marsh Road, Victim Causeway, Drowned Stair, Veiled Rise and Feather Hollow), Marsh Hag (built in pass 119: a bent crone of the drowned villages in a shawl of dry reeds, moss for hair, leaning on a crooked willow staff with a green marsh-wisp caught in its crook. The wisp is a light, so she shows through the fog from far off. She spots you from about 15 tiles and shuffles nearer at 22 px/s until you are within 11. Come within four tiles and she backs away from you at 34 px/s, still facing you, for up to 1.2 s; then she stands and hexes anyway. Her hex: she draws herself up and raises the staff, the wisp flares (pose, white pulse, a cackle over welling bubbles), and a ring of bubbling green bog light marks the floor or plank under your feet, all for 0.6 s. Then a hand of black mud bursts up out of the mark for 12, which can't be parried: step off the mark. Strike her mid-hex and the spell breaks: the mark fizzles, the staff clatters into the mud and she gropes for it for 1.0 s, taking every blow (the breaking one too) at half again. So the answer is to close in, through the fog, toward her light. She hexes every 1.6 s. 30 HP, contact 6. Legend `?`; in the Fog Cut, across the dip, and on a plank over the Victim Causeway's dip) |
| Branches (Conflate) | Leaf Mantis (a mantis the green of the leaves, folded on a bough like one more leaf cluster and harmless to touch. Come within about seven tiles and level with it and it rears and spreads its scythes for 0.5 s, then lunges along the bough for 0.25 s and slashes for 16; it stops at the bough's end. The slash can be parried. A lunge leaves it overreached for 0.8 s, taking half again the damage; then it stalks you and unfolds again, or folds back into a leaf once it has lost you for 2 s. Striking a folded one springs it open); Bark Knight (pass 110: a knight the Tree grew in living bark, with a lance of green bough. He paces the branch roads at 22 px/s. Come level with him within about five tiles in front and he braces, lance back and eyes lit, for 0.6 s, then thrusts it out to about four tiles for 16; the thrust can be parried. Then he roots for 1.1 s with the lance left out stiff as a bough, a one-way ledge you can stand on, drop through (Down + Jump, as any one-way) or pogo off to get over him. His bark is a guard of three plates: each blow on it deals a quarter, rounded up, and knocks off a plate; bare heartwood he takes full damage. Rooted, the bark doesn't guard him, but one plate grows back as he pulls free. 54 HP; legend `!`); Seed Bomber (pass 114: a pod-bellied canopy bird with leaf wings and a husk of hard seeds for a belly. Within about 15 tiles it keeps five tiles over your head, out of reach of a plain slash. Right above you it squeezes the husk, wings up, belly swelling and glowing, seeds rattling, for 0.5 s, then drops a seed that stings for 10 if it lands on you. On a branch or plank the seed sputters for 0.6 s, seams blinking faster and its reach showing, then bursts in thorns 28 px around for 12, unparryable. Strike the seed (or parry it as it falls) and it flies back up into the bird, bursting there for 18 and knocking it out of the sky: it lies dazed on its back for 1.4 s taking blows at half again, then climbs back up. You can pogo off a seed, too. 28 HP, touch 8; legend `;`, in Thicket Road and North Bough) |
| Branches (Daybreak) | Storm Harpy (a winged hunter, storm-grey and violet with white hair and gold talons. Within about 16 tiles she hangs 4 or 5 tiles to one side of you and 5 above, out of reach of a plain slash. Her tell: she rears and throws her wings up with a screech for 0.55 s, then flings a fan of three feathers at you (8 each, 200 px/s, 15° apart). They can be parried, and a parried feather flies back and strikes her for 12. After a volley she sags about two tiles for 0.8 s, winded and in reach of a jump, then waits 1.4 s before the next. HP 30), Thunder Beetle (a beetle as big as a dog, storm-violet with a gold stripe, trundling the shrine stones at 28 px/s and turning at ledges. Its shell turns 70% of a side blow but none from above, so pogo it. Come within about four tiles and its wing cases lift and crackle with static for 0.6 s, then it discharges a ring of lightning 46 px around itself for 14 that can't be parried and reaches above the shell too: get off and get clear. Spent, its cases hang open for 1.1 s and every blow lands in full; it can't charge again for 1.4 s), Spire Sentinel (built in pass 123: a knight of pale shrine stone the elves set to guard their stairs, helmed and crested, with a halberd and the Sky Key's gold lightning cut into its breastplate. It is stone while you watch it: as long as you face it, it never moves and every blow clinks off. Turn your back within about 13 tiles and its eyes light and it grinds after you along the floor at 64 px/s, and the moment you turn round it is stone again. So climbing away from one is the danger, not fighting it. In reach (about 2.5 tiles) it raises the halberd overhead while the glyph blazes, 0.6 s (pose, white pulse, a rising hum), and slams it down in front for 16. The slam can be parried, which staggers it; a slam that lands or misses buries the blade for 1.2 s. Either way the stone cracks open with bright seams and every blow lands in full. 40 HP, contact 8. Legend `]`; at the Spire Foot and at the bottom of the Spire Stair) |
| Dartmoor | Crystal Dwarf (meteor-fused; built in pass 64: magenta crystal has grown out of his back like a shell and swallowed his right arm. He trudges toward you; with you ahead and within about seven tiles he raises the crystal fist, blazing, for 0.6 s, then drives it into the floor, 16 to anything right in front, and six crystal spikes erupt along the floor toward you one after another, 20 px apart and 0.09 s apart, each glowing on the floor for 0.18 s before it stabs up 26 px for 12, unparryable: jump or dash them. His fist stays rooted for 0.9 s, and then every blow lands. The rest of the time his crystal back turns any blow from behind, and only a pogo from above gets past it. 48 HP), Shade Knight (parry-heavy; built in pass 66: the drowned ghost of a king's guard in a dwarf great helm, a tower shield on his arm, mist where his knees should be. The shield turns every blow from the front, and two blows on it in a row bring a quick riposte, 0.36 s tell, a cut for 14. He advances behind it to about four tiles, then draws his blade back, a cold light gathering at its point, for 0.55 s and thrusts, sliding forward, for 18. Then he raises it, 0.38 s, and cuts down for 14. Both blows can be parried, and a parry leaves him reeling, shield wide. If the pair finishes he stands winded for 0.7 s, shield low. Blows from behind or from above always land. 56 HP), Clockwork Hound (built in pass 70, the clockwork enemy: one of King Grieve's brass hunting dogs, still running on the spring the king last wound. It trots after you; within about seven tiles it crouches and its key spins up, ratcheting, eyes blazing, for 0.45 s, then pounces in an arc aimed to land on you and bites for 14. Its brass plating turns half of every blow. Parry the bite and it tumbles onto its back for 1.3 s, belly bare, and every blow lands in full. It is clockwork, so the Hour Glass stops it dead, mid-leap or not; it is the one enemy time stops. 44 HP), Meteor Slug (built in pass 69, the Hour Glass's enemy: a great grey slug under a lumpy shell of meteor-rock, molten in its cracks. It creeps along the floor and turns at ledges. With you within about ten tiles its shell swells and its cracks blaze for 0.6 s, then it heaves three gobbets of molten rock in high arcs, one at you, one short, one long, 12 each, unparryable; where one lands on a floor it leaves embers that burn for 8 over 1.4 s. The Hour Glass holds globs and embers still and harmless, so you can walk out from under a volley. The shell turns pogos except in the 0.7 s it sags after a heave; its soft sides take every blow. 40 HP) |
| Zenis | Remixes of every family, corrupted with meteor crystal |
| Not yet built (pass 123) | **Planned**: none; every planned foe is built (the Seed Bomber in pass 114, the Marsh Hag in pass 119, the Spire Sentinel in pass 123). **Cut**: the Mist Wisp (the Lantern Ghost is the Mist's wisp), the Wind Imp (the Storm Harpy already holds Daybreak's air) and the Sky Ray (the Branches' wind currents make the open sky the challenge there). |
| Sunken Spring | Spring Eel (built in pass 86, the swimming enemy: a long pale eel gone blind in the dark water, with a lamp of the spring's light grown on its brow. It never leaves the water; it weaves back and forth near where it lives. Within about seven tiles it draws back into an S, its lamp blazing, for 0.5 s, then darts straight at where you were at 300 px/s and bites for 14. The dart stops dead at the water's edge, so the bank is safe. Spent, it hangs slack for 0.8 s and takes every blow at half again. 30 HP. Legend `l`, a water cell with the eel in it) |

Every enemy has: a readable telegraph (minimum 0.35 s wind-up with a pose, a flash and a sound, section 13.3), a hurt reaction, a death animation with a dissolve, and drops (gold, MP orbs, rare items). Besides gold, about 1 kill in 12 leaves **bread** (heals 15, the original's staple) and 1 in 10 a **mana orb** (+12 MP); both wait on the floor for 10 s. From the Tower of Trunk on, some enemies (Iron Dwarf, Gear Bat) leave Faxanadu's **Poison** about 1 kill in 14: a violet skull flask that is a hazard to step around while collecting. Walking over it poisons you for 8 s, costing 2 health a second but never the last point; your health masks and sprite turn green. Bread, resting at a shrine or Guru, or dying cures it, and an Ointment keeps it off.

**Rare drops (pass 147):** "rare items" had never been built: no foe left anything but gold, bread, mana and poison. Now about 1 kill in 40, from any foe anywhere (`Drop.rare_chance` 0.025), leaves one of the original's rare items. Both wait on the floor like bread, and both are drawn in code:
- **War Glove** (60% of rare drops). This is the original's Glove, renamed so it can't be mistaken for the Climbing Glove. It looks like a red leather fighting glove with a gold-studded cuff. Walking over it puts it on: for 15 s every blade hit, the pogo and a Riposte included, lands 1.5x as hard (`war_glove_mult` and `war_glove_time` in `combat_tuning.gd`, through `Player.blade_mult()`). Red sparks rise off the sword hand while it lasts. A red fist and a draining bar sit on the HUD beside the Ointment's row, and the bar blinks in its last 3 s. Another glove starts the time over, and dying takes it off. It turns a lucky drop into a short push: clear the room while it burns.
- **Ointment** (40%). It goes in your pouch like a bought one (up to 3). With the pouch full and none on, it goes straight on, as the original's did; with one already on, it is wasted.

**The dissolve (pass 126):** until pass 126 a foe simply vanished in a puff of debris. Now its body stays where it fell for 0.45 s (`Enemy.DISSOLVE`). It flashes white, then breaks up pixel by pixel (one world pixel, two art pixels, at a time), the top a little first, each mote glowing pale gold as it goes (`shaders/dissolve.gdshader`). Then it is gone (freed, or hidden until it respawns). The dying body is harmless and can't be struck or touched, and the gold, drops and death sound come at once as before. Every foe that dies through `Enemy.die` uses it. Bosses keep their own deaths and go at once when they reach `Enemy.die`.

---

## 8. Bosses

Each boss has: a pre-fight arena reveal, 2 or 3 phases, an ability it tests, a "stagger" window, a cinematic kill (slow-mo, white flash, shatter), and a reward. Health bars show phase markers.

### 8.1 Rokusutahn, the Root-Gnawer (Trunk Hollows)
- **Concept:** A colossal armored grub that has been chewing the Tree's taproot dry. Its segments are plated in bark; its face is a wheel of mandibles.
- **Arena:** a cylindrical root chamber with wooden ledges on both walls.
- **Tests:** wall jumping (just earned).
- **Phase 1:** bursts out of a wall and lunges across the room; you wall-jump over it. Its tail segments are the weak point.
- **Phase 2:** burrows into the ceiling and rains sap clumps that harden into temporary platforms.
- **Phase 3 (below 30%):** tears the floor away; the fight continues on the wall ledges only.
- **Reward:** Elf Ring, 1 skill point, restores the Spring of Trunk.
- **Reveal:** on entry the walls shake, the banner names him, and he bursts out of the wall across from you, roars with his mandibles spinning, and pulls back in before the first lunge. Nothing he does in the reveal hurts.
- **Stagger:** while he is stuck in a wall or dangling from the ceiling, tail hits build poise damage. At 48 he staggers for 2 s: plates crack open and every segment takes full damage, not just the tail.

### 8.2 Zoradohna, the Hammer of Forepaw (Tower of Trunk)
- **Concept:** A dwarf champion fused with a mining engine, piloting a walking siege drill: a rust-red riveted hull on two piston legs, a bronze drill, two exhaust stacks and a glass cockpit with the dwarf inside. The dwarf inside is still conscious and begging to be stopped.
- **Arena:** the Forepaw Lift (tower 19,-4), a one-screen lift platform in an elevator shaft, reached from the Forepaw Gate. From phase 2 the lift rises: girders and cable marks stream down the shaft wall behind the fight. (Built as one screen with the rise drawn behind it, rather than a scrolling arena, so the fight stays readable.)
- **Tests:** pogo. The hull lets only a quarter of a side blow through; down-strikes on the stacks and cockpit land in full and bounce you (Mattock), so the fight is won from above. Ramming a wall or diving into the floor leaves the drill stuck (1.5 s / 1.1 s), open to any blow.
- **Phase 1:** drill charges (spins up 0.8 s, then rams across the lift; dodge onto the side ledges or jump it) and stomps (rears up 0.7 s, then slams a shockwave out each way).
- **Phase 2 (below 65%):** the lift rises; debris falls every 2.4 s, one rock over you, each marked 0.7 s before it drops (dodge it). Every third attack the drill runs to a wall, climbs it, marks your spot on the floor (0.7 s) and dives at it. Tells are 20% shorter, never under the minimum.
- **Phase 3 (below 30%):** the cockpit bursts open on the meteor-crystal harness that binds the dwarf. Side blows glance off completely; strikes from above hit the harness for 1.5x.
- **Reward:** Ruby Ring and a skill point; frees Forepaw. Later: unlocks the dwarf smith and the elevator to Eolis (section 4.4).

### 8.3 Ripasheiku, the Lantern Widow (The Mist)
- **Concept:** A spider-wraith that carries the souls of the drowned as lanterns on her legs. She is invisible except where her lanterns glow.
- **Arena:** the Sunken Chapel (mist 30,-7, 60x23), east of Lantern Landing: a drowned nave under fog of 0.92, with two side ledges and a high central ledge.
- **Tests:** reading by light; double jump.
- **Body:** 260 HP. Her four lanterns are separate targets on her legs, and each is a light in the fog (70 px). A lantern breaks in one blow and costs her 18 HP. Each broken lantern frees a soul that clings to her as pale fire, so she shows a little more (8% plus 16% a lantern). Her tells always show at least 80%, so they stay readable in the murk.
- **Phase 1:** she stalks in the dark. Close up she sweeps her front legs (0.55 s tell); farther off she rears and pounces at where you stand (0.65 s tell).
- **Phase 2 (below 66%):** she climbs to the vault and hangs there. Web: a thread flickers toward you (0.6 s), then a strand shoots along it (360 px). If it catches you it reels you toward her for 0.9 s; a dash breaks free. Drop: she shivers (0.6 s), marking a shadow below, then falls on you and lies stunned for 1.3 s, taking 1.5x damage.
- **Phase 3 (below 30%, or all lanterns broken):** she comes down for good. She is fully visible, fast, and desperate, with tells a quarter shorter (never under the minimum).
- **Reward:** Lantern Key (opens the path to Zorugeriru), Mana Dew, a skill point.

### 8.4 Zorugeriru, the Mist Hydra (The Mist)
- **Concept:** A three-headed serpent made of fog and bone, coiled around the Spring of Mist. Only the head that is solid at the moment can be hurt.
- **Arena:** the Spring of Mist (`mist/spring_of_mist`, east of the Dry Cistern): the spring on a shelf in the middle with the hydra's coil wrapped around it, three dry tanks across the floor (dry basins, 4.5), floating debris between them and steps up to the shelf. The water level changes across phases. The tanks are part of the fight: dry again on every try, full for good once he is beaten.
- **Tests:** Deluge (filling the tanks raises rafts, the high ground) and air control.
- **Phase 1:** the three heads take turns being solid (about 3.4 s each); the solid head hangs low over its tank and follows you along its lane. It rears back (0.6 s, its eyes flash and a ring marks where it will strike), bites down at you, and lies where it bit for about a second, open to blows; a parried bite stuns it longer. A mist head breathes: mist wells at its jaws and pools on the floor below it (0.7 s), then a low bank of fog rolls along the floor toward you (12 damage, can't be parried): jump it or stand on the tank walls. Blows on a mist head pass through.
- **Phase 2 (below 60%):** the three heads turn to mist and keep breathing; eyes glint in the coil. The fourth head comes out only once all three tanks are full: Deluge each one and its raft floats up. It hangs high under the shelf and bites no lower than the rafts and walls. Phase 1 can't be cut short past phase 2.
- **Phase 3 (below 30%):** the fourth head sinks, the coil bursts and the spring floods the arena to the tanks' rims; feet under the water take 8 damage a second. Fight on the rafts, the tank walls and the debris. The three heads take turns again, a quarter faster (never under `Enemy.MIN_TELEGRAPH`), and the fog rolls along the water's surface.
- **Reward:** Dworf Ring and a skill point. With him gone the spring can be cleared (press Up at it), which restores the Spring of Mist.
- **Sound:** his own theme (`zorugeriru`), a roar at the start and at each phase change, a growl-and-clack bite, a throaty mist breath, and a rushing flood.
- **Look:** code-drawn at 2x for now (the body and necks in bone-ringed green scale, the heads in whole pixels; mist heads are see-through fog in the same shape). An HD sheet can come in the art polish pass.

### 8.5 Pakukame, the Devouring Bloom (Branches, Conflate)
- **Concept:** A carnivorous flower the size of a house, rooted in a leaf, with a turtle-shell bulb that snaps shut. Pakukame "chomps" (paku-paku).
- **Arena:** the Crown-Leaf (47,-10), east of the Windloft: a giant leaf over open sky, the Bloom rooted in its middle, bounce-pods at both ends and high perches above them.
- **Tests:** air dash through its vine lashes and over the gaps it bites in the leaf.
- **Body:** only the head can be struck. The shell turns 70% of a blow; after a bite the jaws hang open on the leaf for 1.3 s (the weak point) and every blow lands in full. 260 HP.
- **Phase 1:**
  - Bite (within about seven tiles): the head rears back, jaws parting, for 0.55 s, then lunges down where you stand for 24. Parried, the jaws hang open 0.9 s longer.
  - Vine whip (farther off): a vine coils at the root for 0.6 s, then lashes 170 px along the leaf on your side for 16, too long to parry. Jump it, or stride through it on the dash's invulnerability.
  - Seed spit (alternating with the whip): the bulb swells for 0.5 s and spits three seeds in arcs, 12 each, parryable.
- **Phase 2 (below half):** tells a fifth shorter (never under 0.35 s). Every other bite tears a four-tile chunk out of the leaf where it lands, up to three gaps with thorns below, never next to the root or the walls. You stride or bounce across, and strike the open jaws from the gap's edge.
- **Phase 3:** it uproots and chases you along a falling leaf (short chase sequence).
  - **As built (pass 90), below a quarter:**
    - When its head next draws back, it spends 1.2 s wrenching its root out of the leaf (the tell). The crown-leaf, cut loose, starts to fall (`LeafFall`): wind and torn leaves rush up past it, and the player weighs 85% while it falls, so jumps hang longer.
    - The Bloom scuttles after you on its roots at 80 px/s, slower than your run. It keeps 48 px from the walls and stops 40 px short of you.
    - Its bites lunge: the whole plant hops up to 80 px in behind its jaws. Every other bite still tears the leaf.
    - Get past it by running under its head or striding through it, and strike the jaws where they land.
    - When it dies the wind dies away.
  - **Deviation:** the chase stays inside the Crown-Leaf arena rather than scrolling along a separate falling leaf. The whole leaf is falling, which keeps the fight in one room and its doors sealed.
- **Look:** code-drawn at 2x (a green stem, two great leaves at the root, a shelled bulb with gold-rimmed jaws, white teeth and a red maw, and a ring of pink petals). Its own theme, `pakukame`.
- **Reward:** skill point, large gold drop, and the way east from the crown-leaf toward Daybreak (the Crown-Leaf's east door, sealed with the rest of the arena until the Bloom falls; built in pass 54). (Changed in pass 50 from "the Conflate gate opens": the town is the zone's save and shop stop, so it opens to you on arrival. Pass 52 put the arena past the Windloft, so the Bloom guards the way onward instead.)

### 8.6 Borabohra, the Storm Roc (Branches, Daybreak)
- **Concept:** A titanic thunderbird nesting on the highest spire, its feathers made of rain clouds.
- **Arena:** three floating islands; the camera pulls out wide.
- **Tests:** Thunder (charge the conduits on each island to ground the bird) and everything in the air.
- **Phase 1:** dive bombs and feather volleys; ground it by powering conduits.
- **Phase 2:** a storm; lightning hits the tallest point, so stay low or use it.
- **Phase 3:** aerial duel: you ride its updraft and pogo its head.
- **Reward:** Sky Key, restores the Spring of Sky.
- **As built (pass 60):** the Roost (58,-12, 60x29 since pass 94), east off the top landing of the Spire Stair. Three stone islands float over a cloud-stone floor, each with a dead conduit on top, with wooden landings stepping up to them. 320 HP. In the air it is mostly cloud and blows land at 30%; it touches for 14 as it flies.
  - Feather volley: it hangs still and throws its wings wide for 0.6 s (screech), then flings a fan of five storm feathers (8 each). A parried feather flies home and hits it for 12. A player perched high on the islands always gets the volley rather than a dive.
  - Dive bomb: it rises, screaming, and fixes on you for 0.65 s, then stoops through where you stood and on past it for 22, unparryable. Stride through it or get out of the line. It climbs back into the sky after.
  - Grounding: wake all three conduits with Thunder (the bolt leaps to a dead conduit within 72 px, so cast from the island or from beneath it) and lightning arcs from each to the bird. It falls to the floor and lies stunned for 4.5 s, taking blows in full. Then it shakes the charge off, the conduits go dead and it climbs again, so every grounding means waking all three again. The roost's conduits leave no world flags.
  - Code-drawn at 2x, drawn half again larger than its body box (a storm-blue body with a pale chest, a gold hooked beak, a crest, and wings of chained cloud billows with flight feathers and rain trailing under them). Its own theme, `borabohra` (E minor at 150). Reward: the Sky Key and a skill point.
  - Phase 2 (pass 61, below half): the storm breaks. Every 3.2 s a bolt marks the tallest point for 0.6 s (a thread of light from the sky and a glow where it lands), then strikes that column for 18, unparryable. The tallest point is you, if you stand three tiles or more above the floor; otherwise it is one of the dead conduits, and the bolt wakes it. So the storm will wake conduits for a player who stays low, and punishes one who climbs. In return, a woken conduit now drains after 6 s unless all three are awake together, so the storm alone is too slow: you still Thunder at least one yourself, in time. The volley throws seven feathers.
  - Phase 3 (pass 89, below a quarter): the duel. Every other move is the gale. It flies to whichever of the two open lanes between the islands is nearer you, beating its wings for 0.8 s while dust stirs on the floor where the wind will rise. Then it hovers there for 3.5 s over an updraft, a column of rising wind from the floor to a little above its head. The wind carries you up at 240 px/s and gives back your air moves. Hold Down to drop out of it onto the bird's head. While it holds the gale, blows from above (the pogo) land in full and it doesn't touch you, and the storm waits. Side blows are still turned by its cloud. Grounding it with the conduits still works.
  - The wide camera (pass 94, 6.7): the Roost has six rows of open sky above the fight and the camera pulls out wide, so all three islands, the bird and the storm are in frame at once. The roc keeps to the 16 rows above the floor. (The Spring of Sky is restored in pass 62.)

### 8.7 King Grieve, the Drowned Sovereign (Dartmoor)
- **Concept:** The dwarf king who bargained with the meteor. Tragic, regal, half crystal. He fights with a great-axe and royal guards he summons.
- **Arena:** a flooded throne room; the water clock on the wall drains during the fight.
- **Tests:** Hour Glass (freeze his crystal shards in the air and use them as platforms) and parrying.
- **Phase 1:** honorable duel; heavy axe combos with clear parry windows.
- **Phase 2:** summons crystal guards; shards fly; time-stop them into stepping stones to reach his crown.
- **Phase 3:** the meteor takes control; his body cracks; frantic, faster, corrupted patterns.
- **Reward:** Demon Ring; the dwarves of Dartmoor are freed; Dartmoor drains.
- **As built (pass 71, phases 1 and 2):** `scripts/bosses/king_grieve.gd`, code-drawn at 2x (a broad dwarf in a flood-rotted robe and a gold-edged mantle, a beard to his belt, the back of him grown over with magenta crystal, crystal grown up through his crown, a great-axe whose blade is half crystal), in the Throne Hall (`dartmoor/throne_hall`, 58,-7, 60x23) off the King's Kennels, the dais at its east end six tiles high. 320 HP. Reward: the Demon Ring and a skill point.
  - Phase 1, the duel: he walks you down. Close in, he raises the axe overhead, its edge glinting, for 0.6 s and chops for 20, then draws it back low for 0.4 s and sweeps for 16. Both can be parried, and a parry leaves him reeling for 1.2 s, open to every blow. Otherwise his crystal half turns half of every blow. Keep away and he crouches 0.6 s and leaps after you, bringing the axe down for 22 (unparryable) with a shockwave rolling each way.
  - Phase 2, the throne (below half): he leaps onto the dais, plants the axe and wards himself in crystal: blows from the side do nothing, and crystal thorns along the dais burn anyone who climbs up beside him (10). Every 3.2 s his crown blazes for 0.5 s and four crystal shards (`scripts/bosses/crystal_shard.gd`) glow in the floor for 0.4 s, nearest the dais first, a quarter-second apart, then shoot up to the vault at 140 px/s, 12 to anything they pass through. Rising together they make a moving stair, highest by the throne. Turn the Hour Glass and they hold where they are with flat tops to stand on; when time runs again a held shard cracks and falls. Climb them and strike down on his crown: he is thrown from the dais, open to every blow for 1.8 s, and duels again (tells at 0.8x) for 7 s before he climbs back.
  - Phase 3 (pass 72, below a fifth): the meteor takes him. He roars and cracks open for 1.4 s, untouchable, crystal light blazing through the cracks, and comes down off the throne for good. Frantic now, he walks you down at 1.8x, his tells at 0.65x (never under the minimum), and every chop and sweep ends with the axe raised again (0.45 s at full, shorter frantic) and driven into the floor: six crystal spikes burst out in a line toward you, 22 px and 0.08 s apart (jump them). Cracked, he turns no blow, and a parry still throws him reeling.
  - The water-clock (pass 72, room prop `water_clock`): a tall bronze-framed glass column of flood-water by the west wall. Full before the fight, it drains with his health and stands empty once he is beaten.
  - His theme, `grieve` (pass 72): the Dartmoor dirge risen into a march, D phrygian at 112, war drums, a tolling bell, crystal stabs on the offbeats.
  - After him (pass 73): a door behind the throne, barred by the fight's iron until he is beaten, leads up the Meteor Rise (60,-9, 40x68), eleven switchback shelves of crystal-choked shaft with his guard still on them (Crystal Dwarves, Shade Knights, a hound), to the Zenis Gate (61,-9): a shrine, and the gate of Zenis, black meteor-iron with four ring sockets that glow for the rings you hold. It does not open yet: Shadow Eura (8.8) waits before it. The Sunken Spring's way down is marked, sealed, at the foot of the Rise (optional, M7). As built (pass 86): three cracked stones in the Rise's floor, under the sign; the Mattock breaks them, and the flooded shaft below drops into the Sunken Spring.
  - Dartmoor drains (pass 73, a first step): once he is at rest the drowned dwarves wake. His steward Hrafna stands by the empty throne and a mason in the Drowned Market, both saying the water is going down. The time-locked water stays where it is: the water-clocks still hold their hour, so the Hour Glass routes are unchanged. A lower tide line in the tiles and backdrop is deferred to the art pass.

### 8.8 Shadow Eura, the Mirror (Dartmoor, Zenis gate)
- **Concept:** A shadow copy of the player, made from every fight the meteor has watched. Uses your abilities and your equipped spell.
- **Arena:** a mirrored hall with a reflective floor; the player's reflection is the boss.
- **Tests:** mastery of all movement.
- **Phase 1:** mirrors your inputs with a delay.
- **Phase 2:** acts on its own, using your highest-level skill tree branch against you.
- **Phase 3:** splits into two; one is real (only the real one shows in the floor reflection).
- **Reward:** the Zenis gate opens.
- **As built (phase 1, pass 74):** the gate hall (`dartmoor/zenis_gate`) is laid out symmetrically, with a landing at
  each end, and a faint seam of light marks the mirror line down its middle. The shadow (`scripts/bosses/shadow_eura.gd`)
  stands where you were 0.6 s ago, mirrored across that line, in your own pose, drawn as your sprite cut out of the dark
  with a violet rim. Each swing you make comes back at you 0.6 s later from its side, its blade glinting for 0.4 s first,
  so you can only reach each other where you meet at the line, and a blow you land is answered. Step away from the echo
  or parry it: a parried echo leaves it reeling and out of the mirror for 1.2 s. If you hold still for 2.2 s it sinks
  into the floor and rises right behind you, blade raised for 0.45 s, then cuts. Until phases 2 and 3 are built it has
  150 HP, and beating it gives a skill point. The gate does not open yet, because Zenis beyond it is not built.
- **As built (phase 2, pass 75):** HP is now 240, and below half the glass bursts. The shadow is untouchable for 1 s,
  then steps out with real physics and fights with the skill tree branch you have the most nodes in (Blade on a tie or
  an empty tree):
  - **Blade:** two cuts and a lunging heavy blow (tells 0.4/0.4/0.5 s).
  - **Arcana:** it keeps about 150 px away and casts shadow bolts (0.5 s tell); parry one and it flies back into the
    shadow.
  - **Wanderer:** it air-dashes through you (0.45 s tell), and once, below a quarter health, it stops to drink a
    draught (+12%) that a blow spills.
  - A parried blow staggers it for 1.2 s. It has its own theme, `eura` (E minor, reversed pads, and a lead echoed a
    beat late from the other side).
- **As built (phase 3, pass 76):** below a fifth it splits in two (`SPLIT_TIME` 0.8 s, untouchable). The false
  double appears on your far side, out of the walls, and half the time the two trade places as they part. Both fight as
  in phase 2. Only the real one shows a faint upside-down reflection in the floor under its feet, and the boss bar
  follows it. Strike the false one and it swells for `BURST_TELL` (0.45 s), then bursts for 10 damage (unparryable)
  around itself, and the real one loses nothing. The real one splits again 3.5 s later. Beat the real one and the false
  one goes with it.

### 8.9 The Evil One (Zenis)
- **Concept:** Not a demon king but a parasite: a vast eye-flower of meteor crystal rooted into the Tree's crown, feeding through veins of light.
- **Arena:** the heart of the meteor; three arenas in sequence.
- **Phase 1 (The Throne):** a humanoid avatar in armor duels you; standard boss.
- **Phase 2 (The Veins):** the avatar shatters; you climb a vertical chamber cutting light-veins while the core fires beams (uses wall jump, dash, pogo, Hour Glass).
- **Phase 3 (The Core):** only the Dragon Slayer can hurt the core; each strike restores a spring's light and the Tree fights alongside you (roots lash the core).
- **Reward:** ending; credits climb up the Tree from Eolis to the crown.
- **The way in, as built (pass 77):** the gate of Zenis stands against the east wall of the gate hall, and the hall's
  door 2 is behind it. While shut, it bars the way from floor to vault. Once all four rings are held and
  `boss:shadow_eura` is set, its leaves swing back on the meteor's cyan light and you walk through into `levels/zenis/`:
  - **Threshold** (62,-9): a landing and a shrine, flesh pillars grown up from the floor and down from the vault, a
    spiked trench, and a Shade Knight and a Crystal Dwarf.
  - **Heart Stair** (63,-10, 40x45): switchback shelves of meteor flesh with a Meteor Slug, Crystal Dwarf, Shade
    Knights and a Clockwork Hound. At the top, the heart is not open yet.
  - Zenis has its own tiles (`paint_meteor`: rounded cells of black-violet scar tissue with blood-red seams and cyan
    pores), backdrops (ribbed walls, light veins, a red glow below), decor (polyps, veins, tendrils, wall eyes),
    cyan spore motes, a theme (B locrian over a heartbeat, detuned pads) and an ambience (breathing drone, heartbeat,
    glassy whines).
  - **Corrupted foes, as built (pass 78):** every foe spawned in a Zenis room is `corrupted` (a room header
    `corrupted:` overrides it either way). Corruption is one remix applied to every family rather than new
    species: x1.5 health, double gold and experience, poison drops, a violet cast and meteor crystal grown out of
    the back with red veins and a cyan eye that beat with the meteor's heart. When it dies it leaves a
    **Meteor Seed**: a crystal that hangs where it died and swells for 0.7 s, then bursts in a ring (30 px,
    10 damage, unparryable). One slash or a pogo cracks it harmlessly, so pressing forward is safer than
    backing off, and seeds give a corrupted fight a rhythm of pogo chains. The Hour Glass holds seeds.
  - **Wrong gravity, as built (pass 79):** pockets of `GravityDrift` (legend `v`) where the player keeps 40% of
    their weight (`Player.gravity_scale`, gravity and top fall speed alike). A plain jump rises about 11 tiles and
    a fall drifts down. Leave the pocket mid-flight and the true pull takes hold. They read as violet columns
    with cyan motes rising through them. Only the player is affected. The movement numbers in section 6 are
    unchanged; the pocket scales them. The reachability checker allows a 9-tile rise from inside a pocket when
    the column is drift up to the landing.
  - **Drift Well** (64,-11, 40x45), beyond the Heart Stair's upper door: three drift pockets carry you up
    nine-tile ledges a jump could never reach, past a slug, a hound, a Crystal Dwarf, a hornet in the second
    pocket and a Shade Knight. A shrine is at the top. The heart beyond is not open yet.
  - **The Dragon Slayer and the Heart Gate, as built (pass 80):** the Drift Well's top platform runs to an upper
    door into the **Heart Gate** (65,-11, 56x23). A hall with a Shade Knight, a Crystal Dwarf and a hound leads
    past a drift pocket to the flesh. The pocket lifts you to an altar where the **Dragon Slayer** lies (legend
    `&`; tier 4 blade: slash 18, heavy 30, reach 12). Taking it puts it straight into your hand. The way on is
    closed by a **heart seal** (legend `+`, `HeartSeal`): a wall of living flesh with a seam of cyan light and a
    watching eye. Every other blade glances off it, and one cut with the Dragon Slayer tears it open for good.
    Beyond it, the heart (the Evil One's arenas) is next.
  - **Phase 1, as built (pass 81):** the Heart Gate's door 2, past the flesh, opens on the **Throne of Zenis**
    (`zenis/throne`, 67,-11, 60x23, `boss: evil_avatar`), a long hall with two hanging planks and the throne's
    dais at the east end. The **Avatar on the Throne** (`EvilAvatar`, 360 HP, code-drawn at 1.3x) is a knight of
    black meteor crystal with a horned crown, a slit of light for eyes and a crystal greatsword. It stalks you
    and chooses from four attacks:
    - **Cleave** (close, tell 0.55 s): a wide overhead arc, 20 damage, parryable.
    - **Lunge** (middle, tell 0.5 s): a crouch, then a drive across the floor, 18 damage, parryable.
    - **Pull** (tell 0.6 s, a raised glowing palm): the meteor's wrong gravity drags you toward it for 1.2 s,
      then it bursts in a 52 px ring, 14 damage, unparryable. Run or dash against it.
    - **Rain** (far, tell 0.6 s): crystal spikes erupt in a line toward you, each marking its spot.

    It uses pull at least every fourth attack. Its plate halves blows to its front; its back, its crown and a
    parried guard (1.2 s reeling) are bare. Below half health its tells shrink to 0.75x (never under 0.35 s), its
    cleave comes back for a second swing and its pull is stronger. Beaten, the avatar shatters ("The Avatar
    Shatters", 1 skill point) and the light flees up the veins. Phase 2 (The Veins) is next. Theme: `evil_one`
    (B locrian at 120, a quickened double-kick heartbeat, a bass that drops a tritone, a cold lead).
  - **Phase 2, as built (pass 82):** the throne's door 2, high on its east wall, opens on **The Veins**
    (`zenis/veins`, 69,-13, 40x68, `boss: evil_veins`), a tall shaft of meteor flesh climbed on zigzag one-way
    ledges three rows apart. At its vault hangs the **core** (`EvilCore`), a crystal eye-flower that watches you.
    No blade reaches it. It feeds through six **light veins** (legend `x`, `LightVein`) grown above the ledges up
    the shaft; one cut (or a pogo, which also bounces you) severs a vein, and its health bar is the veins still
    lit (10 each). While you climb it fires **core beams** (`CoreBeam`) at you: the line flickers for its tell
    (0.6 s) and then burns for 0.35 s, 16 damage, unparryable. Below half (three veins left) the tell is 0.45 s,
    volleys come every 1.6 s instead of 2.2 s, and every other volley is a pair of beams fanned to either side of
    you (stand still between them). The Hour Glass holds the core and its beams. With the last vein cut the core
    gutters ("The Veins Go Dark", 1 skill point); the veins stay dark for good (`boss:evil_veins`). Deviation:
    the bible asked for wall jump and dash here too; the as-built shaft is a ledge climb so the beams are the
    pressure, and wall jumps are allowed but not required. Phase 3 (The Core) is next.
  - **Phase 3, as built (pass 83):** a door high on the Veins' east wall, reached from a ledge under the vault,
    opens on **The Heart of the Meteor** (`zenis/heart`, 70,-13, 60x23, `boss: evil_one`), a long chamber with two
    low ledges. The **heart** (`EvilHeart`, 300 HP, `PHASES [0.66, 0.33]`) hangs far above the floor, a crystal
    eye-flower with petals all around it, out of any blade's reach. It drifts after you and attacks every
    2.0 / 1.7 / 1.4 s (by phase):
    - **Beam** (a `CoreBeam`; the line flickers for its 0.6 s tell, 0.45 s in phase 3).
    - **Seeds**: three Meteor Seeds around you that swell for 0.7 s and burst. Crack them or step clear.
    - **Wave** (phase 2 on): crystal gathers under it for its tell, then spikes run out along the floor both ways.

    **The Tree fights alongside you:** every 7 / 6 / 5 s (the first after 4 s) the floor under the heart cracks and
    glows green for 0.8 s, and a **root** (`TreeRoot`) whips up, binds it and drags it to the floor for 2.4 s. Only
    then can it be hurt, and only by a swing of the Dragon Slayer (other blades and magic glance off). Each third
    of its life cut away frees one of the springs' stolen lights (`HeartLight`, three sockets in the vault): the
    socket fills with blue light and pours a shaft down, the player regains a quarter of their health, and the
    roots come quicker. In phase 3 the heart bursts as the root lets go (56 px, 14 damage, unparryable), flashing
    for the last 0.5 s it is held, so step back before the release. The Hour Glass holds the heart and its roots:
    stopping time while it is bound is time to cut. Beaten, it dies for good ("The Heart of the Meteor Dies",
    `boss:evil_one`, 1 skill point) and every light goes home. Deviation: the bible had each strike restore a
    spring; as built it is each third, so the restoration lands as a beat rather than a trickle. The ending and
    credits are next.
  - **The ending, as built (pass 84):** four seconds after the heart dies (the banner shows first) the game
    marks the save `cleared` (and counts `clears`), freezes the world and plays the **EndingScreen** to its own
    theme (`ending`: the Eolis lydian come home at 76 bpm, a rising arpeggio for the climb):
    1. **Epilogue**: the World Tree against the night, the dead meteor at its crown. Its cyan light drains
       away as motes, then the three springs in the trunk light one by one, under four cards ("The heart of the
       meteor is dead." ... "And in Eolis, the fountain fills.").
    2. **Credits**: the view climbs the Tree from the houses of Eolis at its roots, past each zone's name
       (Eolis, the Trunk, the Tower, the Mist, the Branches, Daybreak, Dartmoor, the Crown), the springs running
       clear in the trunk, branches and leaves thickening, the sky warming from night to dawn. It ends on the
       crown in leaf where the meteor was, with the sun coming up. The credits rise over the trunk.
    3. **Thanks**: "Thank you for playing", the completion card (section 11, pass 106), your rank and time played; a press returns to the title.

    Jump or attack turns an epilogue card early and holds the climb at 4x; pause skips to the thanks card,
    which ignores presses for its first second. The save is written with the cleared flag (save room and
    spot unchanged), so Continue resumes at your last shrine.
  - **The secret ending, as built (pass 88):** the save counts every death of the run (`deaths`, World adds one
    each time the player falls; a new game starts at 0). If the heart dies with `deaths` at 0 and the Battle Suit
    worn (`GameState.secret_ending()`), the save is also marked `cleared_secret` and the epilogue runs three more
    cards: "Far under Dartmoor, the Sunken Spring wakes." (a fourth spring lights under the roots, ringing),
    "Its water climbs the whole Tree, root to crown." (a column of spring light rises up the trunk) and "No one
    saw you fall. The Tree remembers that." (the crown flowers in gold and white). Every thanks card now shows
    your deaths; the secret one adds "The Source runs again." and "A flawless climb, in the Warden's Battle
    Suit." Shoot it with `--ending=SECONDS[,PART] --secret`.

### 8.10 Optional boss
- **The Drowned Warden (Sunken Spring):** an ancient guardian of the spring source; the hardest fight in the game; drops the Battle Suit.
  - **As built (pass 87):** the Source Hall's east wall opens on **the Wellspring** (64,-5, 60x45): a deep pool from row 20 down, an entry ledge and a far ledge with steps down to the water, two islands level with the surface and a plank over the middle. The Warden (`DrownedWarden`, 520 HP, boss id `drowned_warden`, music `warden`: E minor at 126, a rolling bass under a galloping beat and a fast ripple) is a colossus of pale limestone and green bronze with a dwarf-king's helm, lamp eyes and a trident, standing waist-deep; it rises out of the deep to begin and wades the pool between the islands (they hide its lower half).
    - **Thrust** (within about 12 tiles): the trident draws back, aimed at you and tracking for most of the 0.6 s tell, tines glowing, then drives 150 px along that line for 18. Parry it and it reels for 1.4 s, open.
    - **Wave** (farther, and every third attack in phase 1): arms raised and the water churning for 0.7 s, then a `TidalWave` runs across the surface at 230 px/s, 40 px tall and 24 px deep, 16 unparryable. Jump it, or dive under it (swimming, 6.8). In phase 3 a second wave follows from the far side.
    - **Geyser** (phase 2+, every third attack): it sinks out of sight (untouchable) and stalks you under the water, a trail of bubbles the only sign; the water boils at your spot for 0.6 s, then it bursts up through it in a 44 px column of water, 20 unparryable, and hangs streaming for 1.3 s, open to every blow.
    - **Undertow** (phase 3, every fourth attack): its chest lamp opens (0.6 s) and the current drags you toward it at 85 px/s for 1.4 s; then the trident goes up (0.45 s) and it slams around itself for 22, parryable.
    - Its stone halves blows from the front; from above (the plank is there for a pogo), from behind, reeling or hanging open it takes them all. At two-thirds and one-third it roars (1 s, untouchable) into the next phase; tells shrink to 0.88x and 0.75x, never under `Enemy.MIN_TELEGRAPH`. Contact hurts for 14.
    - **Reward:** the **Battle Suit** (armor tier 4, 60% less damage) goes straight on (BossArena reward key `armor`), with a skill point; every armor in the shops then shows as owned. It crumbles and sinks back into the spring.

Mini-bosses (about one per zone): The Foreman (rock golem), Marsh Hag Matriarch, Bark Knight Captain, Clockwork Alpha.

---

## 9. Skill Tree

The **Guru** in each town teaches skills. Points come from:
- **Ranks:** XP from kills raises your title, using the original's 16 ranks (Novice, Aspirant, Battler, Fighter, Adept, Chevalier, Veteran, Warrior, Swordman, Hero, Soldier, Myrmidon, Champion, Superhero, Paladin, Lord). Each rank after Novice = 1 point (15 total).
- **Bosses:** 1 point each from the 9 main bosses (9 total).
- **Mantra Shards:** hidden secrets; 3 shards = 1 point (15 shards, 5 points).

That is **29 points** available against a tree that costs **54** in total, so players must choose. Respec at any Guru for gold (200 g, then 400 g, 600 g and so on, capped at 2,000 g).

Rank XP thresholds (in `GameState.RANK_XP`): 0, 40, 100, 180, 300, 460, 660, 900, 1,200, 1,560, 2,000, 2,500, 3,100, 3,800, 4,600, 5,500. Starting enemies give 5 XP (Rot Dwarf 12), so the Trunk Hollows take a careful player to about Fighter. Ranks rise the moment you pass a threshold and give the point right away; the Guru is where you spend it. As in Faxanadu, the title itself is the Guru's to give: the next time you visit one after ranking up, the Guru names you by your new title ("From this day you shall be called ADEPT") to a short fanfare while the music dips, then opens the usual menu. Higher ranks hear grander words. `GameState.data.named_rank` remembers the last title named.

Three branches, 12 nodes each. Costs in brackets. Nodes deeper in a branch need the one before.

Nodes are built tier by tier as the acts that need them arrive. In the game now: Blade 1-4, Arcana 1-3 plus Tilte Swarm (after Deluge Pierce, 2 points: three orbs fanned 0.5 rad apart, 10 damage each, for one cast's MP; pass 95) and Wanderer 1-4 (`data/skills.json`). Rising Cut lifts any walking foe of 40 HP or less (`Enemy.LAUNCH_MAX_HP`) and leaves it helpless for 0.5 s; rooted foes (Sap Spitter, Bog Myconid), fliers and bosses stay put. Deluge Pierce strikes each foe in the bolt's path once. Second Stride does nothing until you own the Elven Stride.

**The Act III tier (pass 100).** Ten more nodes take the built tree from 15 points to 36, past the 29 points the game hands out (38 with Feather Fall, pass 101), so a full build needs choices:
- **Blade**, after Mattock Mastery: Riposte [2], Keener Edge [2], Bloodletting [2].
  - Riposte: a parry answers with a free heavy cut at the foe that swung (`Player._riposte`).
  - Keener Edge stacks with Keen Edge, for +20% melee damage in all.
  - Bloodletting heals 2 HP per hit on a staggered foe.
- **Arcana**, after Tilte Swarm: Thrift [2], Chain Thunder [2], Time Thief [2].
  - Thrift makes spells cost 15% less.
  - With Chain Thunder, a Thunder bolt that strikes a foe leaps to the 2 nearest other foes within 110 px, one after another, for 75% damage each. The arcs fall from above, so shields don't stop them.
  - Time Thief makes the Hour Glass hold 3.5 s instead of 2.5 s (`TimeStop.start(extra)`, `TimeStop.total`).
- **Mantra of Death (pass 134)**, the Arcana branch's capstone, after Time Thief [3]: the Death spell costs half its MP (`Player.MANTRA_OF_DEATH_MULT`, applied after Thrift by `Player.spell_cost`), so 20 MP, or 17 with Thrift. The scroll alone already unlocks Death, so the node's "unlocks the spell" half is dropped; its menu line says it needs the scroll. The built tree now costs 41 points against the 29 the game gives.
- **Wanderer**, after Second Stride: Feather Fall [2] (pass 101, see 6.10), Treasure Sense [2], Resilience [2], Last Stand [2], Second Wind [3].
  - Treasure Sense puts an orange star on every room the map shows (seen or charted) that still holds an item or chest. The World's catalog lists each room's treasures.
  - Resilience adds one mask (`GameState.RESILIENCE_HP`).
  - Last Stand: below 20% health, you take 25% less damage.
  - Second Wind: once between rests (a shrine, a Guru or a respawn), a killing blow leaves you at 1 HP.
- **Wanderer's Grace (pass 142)**, the Wanderer branch's capstone, after Second Wind [3]:
  - A dash lets harm pass through you for 0.2 s instead of 0.1 s (`Player.GRACE_INVULN`, `Player.dash_invuln`).
  - Any foe's death gives back the air dashes you have spent (`Enemy.die` calls `Player.on_kill`), with a puff of feathers and a catch of wind. So a kill in midair can be dashed out of, and a run of kills across a gap can carry you over it.
  - The built tree now costs 44 points (Wanderer 19 over 10 nodes) against the 29 the game gives.

Deviations, and why:
- The build order skips Thrust, Wildfire and the rest. They are bigger mechanics and still come later in their branches.
- Light Step is dropped: a dash's own invulnerability already carries you over spikes, so the node did nothing.
- Pathfinder is dropped: shrines already refill potions.
- Treasure Sense takes Light Step's place in the build order, at 2 points.

**Blade (melee)**
1. Keen Edge: +10% melee damage [1]
2. Fourth Strike: ground combo gains a 4th heavy hit [2]
3. Rising Cut: up-slash launches small enemies [1]
4. Mattock Mastery: pogo deals +50% damage [1]
5. Riposte: parry triggers an automatic counter-slash [2]
6. Thrust: hold attack 0.4 s for a charged lunge (Faxanadu's thrust) [2]
7. Keener Edge: +10% melee damage [2]
8. Bloodletting: hits on staggered enemies heal 2 HP [2]
9. Whirlwind: air spin attack [2]
10. Heavy Hand: heavy hits stagger elites faster [2]
11. Executioner: +35% damage to staggered bosses [3]
12. Dragon Heart: charged lunge releases a shockwave [3]

**Arcana (spells)**
1. Clear Mind: +20 max MP [1]
2. Siphon: melee hits restore +50% more MP [1]
3. Deluge Pierce: water bolts pierce [1]
4. Chain Thunder: Thunder jumps to 2 more targets [2]
5. Wildfire: Fire leaves a burning patch [2]
6. Tilte Swarm: Tilte fires 3 orbs [2]
7. Thrift: spells cost 15% less [2]
8. Mana Shield: blocking costs MP instead of HP when shield breaks [2]
9. Overflow: full MP doubles spell damage for the next cast [2]
10. Time Thief: Hour Glass lasts 1 s longer [2]
11. Elemental Mark: spells mark enemies; melee hits on marked enemies deal bonus damage [3]
12. Mantra of Death: unlocks the Death spell if the scroll is owned; halves its cost [3]

**Wanderer (movement and survival)**
1. Deep Pockets: +1 Red Potion charge [1]
2. Gold Sense: coins magnet from farther away; +10% gold [1]
3. Quick Draught: drinking a potion is 40% faster [1]
4. Second Stride: 2 air dashes [2]
5. Feather Fall: hold jump to glide slowly after double jump [2]
6. Light Step: no spike damage while dashing [1]
7. Treasure Sense: map shows rooms with unfound secrets [2]
8. Resilience: +1 mask [2]
9. Last Stand: below 20% HP, take 25% less damage [2]
10. Pathfinder: shrines restore potion charges [2]
11. Second Wind: once per rest, survive a lethal hit with 1 HP [3]
12. Wanderer's Grace: dash invulnerability +0.1 s and dash refreshes on kill [3]

---

## 10. Shops and Economy

### 10.1 Currency

**Gold** only. Enemies drop gold scaled by zone; chests and secrets give lumps.

| Zone | Typical enemy drop | Chest | Time to afford the next zone's best item by normal play |
|------|--------------------|-------|---------------------------------------------------------|
| Trunk Hollows | 2 to 6 g | 50 to 150 g | about 20 min |
| Tower of Trunk | 5 to 12 g | 150 to 300 g | about 25 min |
| The Mist | 10 to 25 g | 300 to 600 g | about 30 min |
| Branches | 20 to 40 g | 500 to 900 g | about 30 min |
| Dartmoor and Zenis | 35 to 70 g | 800 to 1,500 g | n/a |

The goal: buy one key upgrade per zone without grinding, and buy everything only if you explore.

### 10.2 Shops

| Shop | Location | Sells |
|------|----------|-------|
| Weapon smith | Eolis, later Forepaw dwarf smith | Blades, smith upgrades |
| Armorer | Eolis, Apolune, Daybreak | Armor, shields |
| Item shop | every town | Ointment (10 s invulnerability, 300 g; carry up to 3, rubbed on from the pause menu), Elixir (auto-revive, max 1, 1,500 g), Poison cure (80 g), Mana Dew (one per shop, 500 to 1,200 g), Life Fruit (one per shop, 800 to 2,000 g) |
| Key master | Eolis, Victim, Dartmoor | Jack (150 g), Queen (400 g), King (900 g), Ace (1,800 g) keys; the Joker key is found. As built (pass 117), the grocers are the key masters: every grocer sells Jack Keys, Apolune's the Queen, Conflate's the King and Daybreak's the Ace, each a zone before its door. Victim's Keymaster Odo (pass 145) is the one key master by trade: Jack and Queen Keys, the Queen for the Feather Hollow's vault next door, with ointment and elixirs |
| Cartographer | every town | zone map outlines (200 to 800 g), map pins |
| Spell scrolls | Mascon, Daybreak | Fire (1,200 g), Tilte (2,500 g) |
| Guru | every town | save, skill tree, respec, rank-up |

Daybreak as built (pass 57): Calder sells Full Plate (tier 3, 45% less damage, 4,200 g); the Magic Shield (3,600 g, parry reflects small projectiles) joined his stock in pass 91 (see 5.2). The scribe sells Fire, and Tilte (2,500 g) since pass 95. The grocer sells Elixir, Ointment, Jack keys and a Mana Dew (1,200 g, once), and the bell-ringer the Daybreak chart (700 g).

**The final tier (pass 93):** a shop entry can name a GameState flag (`requires`), and it stays off the shelf until that flag is set (`Shop.shelf`). With the Spring of Sky restored (`spring:sky`), trade returns on the sky road: Eolis Arms stocks the Giant Blade (2,800 g, 5.2) and Daybreak's grocer a Life Fruit (2,000 g, once), the top of the Life Fruit range. (Deviation: the bible paired the Giant Blade with no shop or moment. It arrives here because the sky road is what the Spring of Sky restores, and because by then the player can afford it.)

**Gold sinks:** respecs, Ointments and Elixirs, keys for optional doors (each guards a reward), smith upgrades, cosmetics (cloak dyes, 6 total, purely visual). **As built (pass 136):** Ilse the Dyer keeps Ilse's Dyeworks in Eolis's Market Row. She sells six cloak dyes: Ember Red 300 g, Tide Blue 500, Dusk Violet 800, Ash Grey 1,200, Saffron 1,800 and Night 2,500. A new dye goes straight on. One you own, or the Warden Green you start in, is worn again for nothing ("Wear"; the one on shows "Worn"). The save keeps `dyes` and `dye`. The player sheet's cloak is its only green, so `shaders/cloak_dye.gdshader` recolors every green texel to the dye and keeps its shading (`PlayerVisual.dye_look`). The bible's "Lord" glow is the seventh dye: see 11.

---

## 11. Secrets

Target: **at least 3 secrets per zone room-cluster**, about 70 total.

**Hidden rooms in every zone (pass 131):** the Mist, the Branches and Daybreak, 29 rooms between them, had hidden no room at all; their secrets were chests in plain sight. Each now hides one behind a fake wall at floor level, where a curious player walks into the stone: in the Veiled Rise, the hollow corner block west of the Drowned Dwarf (500 g); in the Sunlit Bough, the hollow foot of the west buttress (600 g); and in the Broken Shrine, a cell in the cliff east of the shrine (700 g). The Black Onyx shows each seam on the way back. `test_every_large_zone_hides_a_room` holds every zone of five rooms or more to at least one hidden room.

**Cracked-stone caches (pass 135):** after the Tower, only one room in Dartmoor asked for the Mattock again, so it stopped mattering once its own zone was done, and Eolis never asked for it at all. Four caches now sit behind cracked stone, each with its prize in plain sight through the gap: in the West Gate, beside where a new game starts, a Life Fruit in a niche in the town wall (the first thing the game shows you that you can't have yet); in the Scorched Hall (the Mist), a Mana Dew beside the shelf's Life Fruit; in the North Bough (the Branches), a Mana Dew in a niche on the west wall; and in the Spire Foot (Daybreak), a Mantra Shard hollowed into the west block. That brings Mana Dew to the table's 9, Life Fruit to 13 and cracked stone to 13 rooms. `test_every_large_zone_hides_something_behind_cracked_stone` keeps every zone of five rooms or more (but Zenis, which holds no side treasure) asking for the Mattock, and the reachability checker keeps the West Gate's fruit shut until the Mattock is found.

| Type | Count | How it's hidden | Reward |
|------|-------|-----------------|--------|
| Breakable walls (Mattock) | 18 | Cracked stone, sometimes faint | Gold, Life Fruit |
| Illusory walls (Black Onyx) | 10 | Seam visible only with Onyx | Mantra Shards, lore |
| Key doors | 12 | Visible, need a card key | Equipment, spells, shortcuts |
| Life Fruit | 14 | Mix | +HP |
| Mana Dew | 9 | Mix | +MP |
| Potion Shards | 9 | Mix | +flask |
| Mantra Shards | 15 | Mostly hard platforming | Skill points |
| Meteor Shards | 5 (pass 140; was 10) | Hard rooms, hidden pockets | The smith's second temper (5.2). Each blade takes one, so five (one per blade and one spare) replace the planned ten, and none drop from foes: a shard is a find, not a grind |
| Guru Trials | 6 | Unlock as springs are restored | Cosmetics, a Mantra Shard each |
| Lore tablets | 12 | Dwarf ruins | Story, map hints |

**Easter eggs:** a hidden room in Eolis rendered in authentic 8-bit NES palette and resolution, with the original's music style; the Guru recites the old password mantra as a joke ("Your mantra is..."): resting with him shows a 16-letter mantra made from your progress (`GameState.mantra()`); it is never typed back in. A secret ending if you reach the Evil One with no deaths and the Battle Suit.

**Completion screen:** shows % with category ticks; 100% unlocks a boss rush and a "Lord" title glow on the cloak. As built (pass 106), it is the ending's thanks card: "Thank you for playing", then one percent "of the world" in large type, and four rows counted up over 1.2 s as the card fades in. The rows are rooms explored, hidden rooms (rooms with a `secret:` cover whose flag `secret:<room>` is set), treasures (the catalog's item and chest ids collected) and bosses beaten. The percent is their average, rounded down, so 100% means every row is whole. A whole row turns gold. Below come rank, time and deaths, plus the clear count from the second clear on (`Completion.tally`, `EndingScreen.completion_rows`). The boss rush is not built yet. The cloak's glow is (pass 136): a clear at 100% sets the `lord` flag (`Completion.award`), and the Lord's Gold appears on Ilse's shelf, free. A pale gold cloak with a band of light running down the cloth.

---

## 12. Art Style Guide (HD Pixel Art)

### 12.1 Resolution and scale

- **World resolution:** 640x360 world pixels. All gameplay numbers (movement, hitboxes, rooms, tiles) are in world pixels.
- **Render density 2x (changed 2026-10-23):** the world renders at 1280x720, two render pixels per world pixel
  (`GameCamera.DETAIL`). Sean's reference for the hero is high-detail pixel art about 200 px tall; at one pixel per
  world pixel a 48 px hero loses the face and armor detail. Character sheets marked `"density": 2` are drawn at double
  detail in the same world size. Older 1x art still draws correctly (each pixel becomes 2x2) and moves to 2x over the
  polish passes: hero first, then enemies and bosses, then NPCs, tiles and decor. Done so far (2026-10-23): the
  hero, the Monodron, Hornet and Rot Dwarf (re-imported free from their clips), Rokusutahn, the Iron Dwarf, the Foreman,
  Zoradohna, Ripasheiku and the zone tiles (the small Gear Bat stays code-drawn at 2x).
- **Smooth camera with crisp pixels:** render the world into a SubViewport of 642x362 world pixels (1 px margin) at
  render density, upscale with a sharp-bilinear shader (`shaders/sharp_pixels.gdshader`: nearest at integer scales,
  a one-pixel edge blend at 1.5x for 1080p), then offset the image by the camera's remainder below one render pixel.
  UI renders at native resolution on top, so text can be sharp.
- **Tile size:** 16x16 world px, drawn from 32x32 atlas tiles at 2x density (`TilesetFactory.DENSITY`; tile layers are scaled by one half, so cell coordinates are unchanged). Large props are free-form.
- **Decor and backgrounds** are painted at 2x too: decor cells are 16x32 world px from 32x64 atlas cells (`"density": 2` in the zone's decor JSON), and the 640x480 parallax layers are 1280x960 images scaled to world size.
- **Character size:** in world pixels, player sprite about 48x56 px on a 64x64 canvas, counting the blade and cloak (the
  body itself is about 20x46, matching the 12x40 hitbox). At 2x density the hero sheet is 128x128 per cell, about 96 px
  tall. Standard enemies 32 to 64 px. Bosses 160 to 400 px tall (multi-part, rigged).

### 12.2 Palette

- One **master palette of 64 colors** (stored in `art/palette/master.gpl` and as a Godot resource). Every asset is quantized to it,
  except the HD (2x density) characters made in Autosprite: each of those sheets keeps its **own palette of 56
  colors** cut from its reference clip (plus the master outline and the neutral stone ramp). Quantizing them to the
  master ramps turned the hooded hero's leather red and flattened his armor detail, which is what Sean asked for
  (2026-10-23). They stay limited-palette pixel art (a test caps each sheet at 96 colors).
- Each zone uses a **sub-palette of 24 to 32** of those colors, plus 4 accent colors.
- No pure black (#000) or pure white (#fff). Darkest is a deep blue-violet; lightest is a warm cream.
- **Hero look (changed 2026-10-23):** a tall, slender hooded elf ranger after Sean's own reference
  (`/mnt/project-files/autosprite/sean-halfling-reference.png`): charcoal hood over brown hair, pointed ears, layered
  brown leather armor with brass buckles, a dark green cloak with gold trim that trails and shows movement, leather
  boots. Sean rejected the earlier green tunic and blond hair because it read as Link from Zelda; avoid that combination.
  The brown leather sits close to the Trunk's brown bark, so the hero gets a thin cool rim light on his top and back
  edges (manifest `"rim"` in `art/autosprite/manifest.json`, applied at import) to stand off it.
- **Zone moods:** Eolis warm amber and stone grey; Trunk Hollows brown, amber, fungus cyan; Tower of Trunk iron, rust, lamp orange; Mist grey-green, bone, lantern yellow; Branches leaf green, sky blue, cloud white; Daybreak storm violet, gold; Dartmoor flooded teal, crystal magenta; Zenis black-violet, alien cyan, blood red.

### 12.3 Rendering rules

- **Outlines:** 1 px selective outlines (darker shade of the local color, not black). Characters get a full outline for readability; backgrounds get none.
- **Light source:** top-left key light by default; zones may override with in-scene lights.
- **Shading:** 3 to 5 tones per material; hue-shift shadows toward blue/violet and highlights toward yellow.
- **Dithering:** only in backgrounds and skies; never on characters.
- **Anti-aliasing:** manual, sparing, on large curves only.
- **Readability layers:** foreground silhouette (darkest, blurred-free), gameplay layer (highest contrast), midground (desaturated 30%), far background (desaturated 60%, lighter). Gameplay layer must pass a grayscale contrast check against the background.
- **Lighting:** Godot 2D lights with normal maps on tiles and characters (normal maps generated by code from height maps). Glow on emissive pixels (fungus, lanterns, crystals) via the WorldEnvironment glow pass, kept subtle.

### 12.4 Animation

- Base rate 12 fps for most animation; key actions (attack, dash) use held frames and smear frames for snap.
- Every attack has anticipation (1 to 3 frames), action (1 to 2 frames with a smear), and recovery (2 to 4 frames).
  Exception: the player's own swings skip anticipation and open on the strike frame, because the hitbox is live on
  the press (section 5) and a wind-up would read as input lag. The recovery frames carry the weight instead. Enemies
  always telegraph (section 7).
- The scarf and hair are secondary motion driven by code (verlet chain), not hand-animated, so they react to real movement.

### 12.5 Parallax

4 to 6 layers per zone: sky or deep background, far silhouette, mid background, gameplay tiles, foreground decor, foreground silhouettes. Plus particle layers (spores, mist, rain, leaves).

---

## 13. Asset Production Plan

### 13.1 Tools and when to use each

| Method | Best for | Why |
|--------|----------|-----|
| **Autosprite** (API or MCP, about 500 credits) | Character animations: player, enemies, bosses, NPCs | Generating consistent multi-frame character animation is the hardest, most expensive thing to do by code. Spend credits only here. |
| **Code-generated pixel art** (Python + Pillow/NumPy scripts in `tools/art/`) | Tilesets, autotile variants, props, UI, icons, fonts layout, VFX sprites, normal maps, palettes, recolors | Deterministic, free, reproducible, easy to iterate in the loop. |
| **Blender** (MCP) | Large background paintings, boss parts that rotate, sky gradients, 3D-to-pixel renders of complex shapes (gears, Tree trunk, meteor) | Render low-res with flat shading, then quantize to the palette and clean up by code. |
| **Other art-app MCPs** (Aseprite, Krita, Photoshop, as available) | Cleanup passes, palette remaps, sprite sheet packing, hand-fixing artifacts in Autosprite output | Precision edits. |
| **Godot shaders and particles** | Hit flashes, dissolves, water, fog, wind sway, glow, screen effects | Runtime effects cost no art budget. |
| **Sean's free music library** | Music | Sean supplies; Claude curates, loops and masters. |
| **Code-synthesized SFX** (sfxr-style generator plus layering) and free CC0 SFX packs | Sound effects | Fast, free, tunable. |

### 13.2 Autosprite credit budget

**Real costs** (2026-10-23): a side-view animation is **5 credits** on the turbo tier (a 2 s clip) or **10 credits**
on the pro tier (a 4 s clip); a weapon attack move is 5 (one engine only), a pose 3, a portrait 1, a new character 1
(turbo) or 3 (pro or pixel art), and **uploading our own image as a character is free**. Re-cutting a finished clip at
another size or frame count (`regenerate_single_spritesheet`) is **free**, so every clip is re-cut at its full rate
(about 24 frames per second, 256 px) and the import picks the frames.

**Tier: chosen by result, never by price.** Sean asked for HD quality over the cheapest option (2026-10-23). For
humanoids, **pro**: on the same run clip pro stayed in clean side profile with more readable limbs, while turbo drifted
to a three-quarter view. For simple non-humanoid creatures, **turbo in reference mode**: the pro Monodron clip invented a
second creature and morphed into a legged, front-facing design, while turbo reference kept the exact base on every
frame (it is also the mode Autosprite calls the most consistent).

**Style lock:** each character starts from its code-drawn sprite (tools/art/spritegen.py, castgen.py) blown up 10x and
uploaded free. That soft blow-up animated poorly (the test idle turned three-quarter and barely moved), so the base is
first redrawn once as an **HD side-view pose** (`generate_pose`, 3 credits, prompt names the outfit and "strict side
profile facing right"), and that pose is uploaded free as the character the clips are made from. The player's base
is Autosprite character `cmvkgu36o002f1g8yyrxrwqbp`, the hooded ranger (12.2); the first player set, on the
Link-like design Sean rejected, is retired. When `generate_pose` fails on a base (it failed, refunded, twice
each for the Hornet and the Rot Dwarf), a pro `create_character` from a written description (3 credits) is the fallback. `tools/art/autosprite_import.py` brings every clip back to the
palette, scale and outline of 12.3 (`--loop` finds a clean cycle in a full-rate sheet); `tools/art/autosprite_fetch.py`
stores the source sheets compactly in `art/autosprite/`. One clip feeds several game animations (the jump clip gives
rise, apex and fall; the sword combo gives slash 2, slash 3 and the down strike).

**Swords:** attack-move clips draw the sword. Where the blade is visible in a frame it is kept (on the stone and sky
ramps) and the frame is marked `art_blade`, so the game does not draw a second one; where the clip blurs it out
the game draws its own blade from the code rig's angle. The hooded hero's clips show the sword in every picked swing
frame, so all five swings use the art blade; at 2x density a code-drawn blade would also look coarse beside the art.
Showing the equipped weapon (longer blades, recolors) is a later job.

**Heavy attacks from poses:** a custom clip of a big weapon can drift (the Iron Dwarf's slam clip grew a second
hammer head). Short attacks whose game animations are only a few key frames are made from `generate_pose` stills
(3 credits each) instead: `tools/art/autosprite_poses.py` keys out the white ground and any floor patch, keeps the
figure, and packs the stills on one spot (hips on the cell's middle) into a source sheet. A figure drawn too dark for
the game's rooms gets a manifest `"gain"` before its palette is cut; the Iron Dwarf also gets a lamp-orange rim.
A second look that changes one spot (Zoradohna's phase 3: hatch open, crystal harness) is one more pose of the
standing still, and `tools/art/autosprite_transplant.py` carries that change onto every other pose (turned and moved
to where the spot sits). A spinning drill is the still with its thread slid along the axis
(`tools/art/autosprite_screw.py`). Neither costs credits. Stills that each drew the floor at a different height (a
spider that crouches, rears or lies on her back) are packed with `rest=1`, so the lowest pixel of each rests on the
floor. Ripasheiku's sheet is made of poses alone (castgen writes empty placeholder frames for it); states without
their own still borrow the nearest one, and her lanterns, souls and web stay code-drawn on top.

Balance after the hooded hero's set, Rokusutahn's parts, the Iron Dwarf, the Foreman, Zoradohna and Ripasheiku: 22 credits, about 7 poses. The redesign (concepts, the new base and its
leg fix, a trial clip and the full set) cost 145 and came out of the NPC and reserve lines.

| Use | Clips | Credits | Share |
|-----|-------|---------|-------|
| Tests (turbo idle, turbo vs pro run), spent | 3 | 20 | 4% |
| Player, first design (retired), spent | 13 | 113 | 23% |
| Player redesign, spent: concepts, base and leg fix, trial idle + run, full set of 10 pro clips and 2 sword moves | 14 | 145 | 30% |
| Enemies in the game now (Monodron, Hornet, Rot Dwarf): HD pose + move + attack each | 6 | 69 | 14% |
| NPCs: only if credits are topped up (they stay code-drawn) | 0 | 0 | 0% |
| Bosses, Rokusutahn spent: three pro stills (head, plate, tail) | 3 | 9 | 2% |
| Zoradohna (boss) spent: base and six poses; open look and drill spin made by code | 0 | 21 | 4% |
| Ripasheiku (boss) spent: base and seven poses | 0 | 24 | 5% |
| Bosses still to come: stills or key clips for their rigged parts | 3 | 10 | 2% |
| Tower enemies, Iron Dwarf spent: base, walk clip, a rejected slam clip, five poses | 2 | 38 | 8% |
| Foreman (mini-boss) spent: base, walk clip, seven poses | 1 | 34 | 7% |
| Reserve for later enemies, fixes and regeneration | | 7 | 1% |
| **Total** | | **490** | |

If credits run short, cut NPC clips first (they can stay code-drawn), then enemies (more recolors, more code frames),
never the player. Every clip is judged against the code-drawn sheet it would replace; the better one ships (the
manifest in `art/autosprite/` says which animations are imported). Sean can buy more credits; the budget above is
what the first 500 cover.

**Rigged boss parts:** a part that turns or changes state rather than moving like a body is made from **one pro still**
(`create_character`, 3 credits) and its frames are built by code: `tools/art/autosprite_spin.py` turns a ring
around a still hub (Rokusutahn's mandible wheel, 24 frames for a full turn), and `tools/art/autosprite_parts.py`
draws state frames over a still (cracked plates, the glowing tail). A clip is kept for parts that truly animate.

**Credit rules:** never regenerate a whole set to fix one frame (fix by hand or by code, or re-cut free); request at
the canonical size so no upscaling is needed; batch similar requests; log every call in `art/autosprite-ledger.csv`
with date, asset, cost and result.

### 13.3 Full asset list

**Legend:** AS = Autosprite, CODE = code-generated, BL = Blender then quantize, APP = art-app cleanup, SH = shader/particles, SEAN = Sean's library.

**Code rig and Autosprite:** every character also has a code-drawn version on a small 2D rig (`tools/art/spritegen.py`,
`castgen.py`), shaded and outlined to the rules in 12.3, in the same sheet format (PNG plus JSON with per-frame points).
Autosprite clips replace it animation by animation through `art/autosprite/manifest.json`. Since 2026-10-23 all 17 of
the player's animations are Autosprite (pro tier), including a new death collapse, and so are the three enemies in the
game (Monodron, Hornet, Rot Dwarf); the boss and NPCs are still code-drawn.

#### Player (AS, cleanup APP; scarf CODE)
idle (8 frames), run (10), run-start (3), turn (3), jump-rise (3), jump-apex (2), fall (3), land (3), double jump (5), wall slide (4), wall jump (4), dash (4 + afterimages SH), slash 1/2/3 (5 each), air slash (5), up-slash (5), down-strike/pogo (4), charged thrust (6), parry (4), cast spell (6), drink potion (8), hurt (3), death (10), meditate/save (6), item-get pose (4), door enter (4). Weapon swaps: blade drawn as a separate layer (CODE) so the 4 blades share animations.

#### NPCs (AS idle + talk; portraits CODE from the sprite, then APP)
King of Eolis, Guru (re-skinned per town by CODE), Eolis townsfolk (4), dwarf smith, Key master, Cartographer, Shopkeeper (2 variants), Forepaw dwarf (3 variants by recolor), Princess/King's daughter (story).

#### Enemies (AS; variants CODE recolor)
About 30 families from section 7, each with idle/move, attack telegraph, attack, hurt, death. Mini-bosses: 4 (AS).

#### Bosses
Each boss is built as a **rigged multi-part sprite** (separate head, limbs, segments) animated with Godot's Skeleton2D and AnimationPlayer. That keeps credit cost low and gives smooth, huge motion.
- Parts: AS for faces and key poses, BL for mechanical or rigid parts (Zoradohna's drill, Borabohra's cloud-wings via BL render, the Evil One's core), CODE for glow, cracks, veins.
- 10 bosses: Rokusutahn, Zoradohna, Ripasheiku, Zorugeriru, Pakukame, Borabohra, King Grieve, Shadow Eura (CODE: player sprite with a shadow shader, almost free), the Evil One (3 forms), the Drowned Warden.

#### Tilesets (CODE, refined APP)
One per zone, 9 total (Eolis, Trunk Hollows, Tower of Trunk, Mist, Conflate, Daybreak, Dartmoor, Zenis, Sunken Spring). Each: 47-tile autotile set for ground, 47 for a second material, platforms (one-way), walls, slopes (22.5° and 45°), ladders, spikes/thorns, background wall tiles, and gate tiles (cracked stone, mist curtain, fire seal, conduit, illusory). Generated from a material spec (palette ramp + noise + edge rules) so new zones are cheap.

#### Backgrounds (BL + CODE)
4 to 6 parallax layers per zone (about 45 layers). Blender scenes of the Tree, branches, meteor; rendered at low res, quantized, edges cleaned. Skies and fog gradients by CODE with dithering.

#### Props (CODE, some BL)
Doors (5 key doors + boss doors), chests (3 sizes), Guru shrine, meditation shrine, fountain (4 water states), lanterns, gears, minecarts, signs, banners, crystals, bounce pods, conduits, elevators, breakable pots, item pedestals, about 120 props total.

#### VFX (CODE sprite sheets + SH)
Hit sparks (3 sizes), slash smears (per blade), dust puffs (5 types), landing ring, wall-slide dust, double-jump feathers, dash afterimages, pogo star, coin sparkle, spell projectiles and impacts (Deluge, Thunder, Fire, Tilte, Death), heal glow, level-up burst, enemy dissolve, boss shatter, water splash, ambient particles (spores, mist, leaves, rain, embers, crystal motes).

#### UI (CODE)
HP masks, MP bar, flask icons, boss bar with phase ticks, gold counter, minimap, full map tiles and icons, pause menu, inventory grid, skill tree screen (node icons: 36), shop screen, dialogue box with portrait frame, title screen (BL key art + CODE logo), settings menus, controller glyphs (Xbox, PlayStation, Switch, keyboard), damage numbers (optional toggle). Font: a custom 5x7 bitmap face made by CODE (`tools/art/fontgen.py`, every glyph drawn in the script; `PixelFont` builds it at runtime). It is used for everything, the title logo included, and it only scales by whole numbers (1x for body text, 2x for banners, 4x for the logo), so text stays on the pixel grid. Outlines are stamped one texel around, since bitmap fonts have no outline. (Changed in pass 40 from "a free licensed font such as m5x7": a font drawn in code needs no license check and matches the NES lettering more closely.)

#### Item icons (CODE, APP touch-up)
All weapons, armor, shields, rings, keys, spells, consumables, shards, abilities: about 60 icons at 24x24.

#### Audio
- **Music (SEAN, curated by Claude):** title, Eolis (and festival variant), Guru/shrine, each zone (7 + 2 optional), mini-boss, boss (a shared boss theme, plus a signature theme for each zone boss that has a strong idea: placeholder themes exist for Zoradohna's drill engine, Ripasheiku's hunting waltz and Zorugeriru's surge, three head-voices trading a motif across the stereo field; `BossArena.BOSSES` names each fight's track), Evil One (3 phases), ending, credits. About 22 tracks. Each zone track gets a "restored" variant (filter/arrangement change) when its spring returns.
- **SFX (CODE synth + CC0 packs):** about 180 effects across movement, combat, UI, ambience, bosses.
- **Phase breaks (pass 96):** when a boss's health crosses one of its `PHASES` marks, `BossArena` plays the `phase_break` stinger (a deep impact, a reversed swell and a ringing fifth), ducks the music under it and the screen shakes. Then the boss theme rises a semitone, and its tempo with it (`Music.intensify`, `pitch_scale` 2^(1/12) per phase, eased over 0.8 s), the old key-change lift. A new track starts back as written.
- **Attack sounds (pass 102):** every enemy and boss attack is heard as well as seen. Entering a telegraph state plays a rising cue at once, picked by what is coming: `tell_blade` (a scrape climbing in pitch: a blade drawn back), `tell_heavy` (a low groan swelling up: a slam, dive or plunge), `tell_charge` (a wobbling hum rising to a whine: a shot or spell), or the zone foe's own call (a buzz, screech, wail, swell). The strike has its own sound (a `whoosh` for swoops and lunges, `slash`, `heavy`, `zap` and so on), and every death plays `enemy_die`. `test_every_attack_tell_and_strike_has_a_sound` scans the enemy and boss scripts and fails on any attack state that starts in silence.
- **Foe voices (pass 112):** the shared tells are for the older foes and the bosses. A foe built later gets its own tell and strike, made in its own material, so it can be told apart by ear even off screen. The Bark Knight has `bark_creak` (a stick-slip creak of wood under strain, climbing), `lance_thrust` (a woody rush ending on a thock), `root_grip` (a low crunch with splinters) and `bark_chip` (a dry crack over a hollow knock, louder on the last plate). The Drowned Dwarf has `anchor_heave` (a sodden groan with bubbles rising through it and water pouring) and `anchor_slam` (an iron thud into mud and a wet slap). The Leaf Mantis has `mantis_unfold` (a leaf rustle, then a chitter) and `scythe` (two thin cuts a hair apart). The Seed Bomber has `seed_rattle` (hard seeds rattling in a husk, faster and higher) and `seed_drop` (a pop and a short falling whistle); its seed has `seed_fuse` (a sputtering hiss that climbs) and `seed_burst` (a husk cracking and thorns spraying). The Marsh Hag has `hag_hex`, `mire_grasp` and `hag_fumble` (pass 119). The Spire Sentinel has `sentinel_grind` (stone dragged on stone over a low rumble, as it moves behind your back), `sentinel_raise` (stone creaking up over an electric hum that climbs) and `sentinel_slam` (a deep thud, a crack and grit) (pass 123). `test_the_newer_foes_have_voices_of_their_own` checks that each foe plays its own sounds and that no other script does.
- **Locks (pass 122):** a locked door is heard as a door, not a spell. The card doors and the Sky Gate had borrowed `fizzle` (the spell-fail sound) when locked and the plain `door` creak when opened. Now they rattle their latch (`door_locked`) and the key turns with its own click, bolt and chime (`key_turn`); see 4.5, Key doors.
- **The map (pass 128):** the map is a sheet of parchment and sounds like one. It had opened, closed and taken pins with `blip`, the menu cursor's beep. Now opening it rustles as it unrolls and settles with a soft flap (`map_open`), closing folds it with a dull pat (`map_close`), a pin goes in with a tiny tick and a bright ring (`pin`), and lifting one rings falling with the tick of it coming free (`pin_lift`). A full map still fizzles.
- **Fields and the cloak (pass 137):** the wind currents of the Branches, Borabohra's updraft and the wrong-gravity pockets of Zenis had changed how you move without a sound. Now a current or updraft catching you blows past in a gust (`wind_catch`), a pocket lifting your weight rises in a hollow, glassy shimmer (`drift_in`), and leaving it drops into a low hum and a soft thud (`drift_out`). Each sounds once as you cross the edge, and waits `Player.FIELD_CUE_GAP` (0.3 s) before it may sound again, so hovering on an edge does not chatter. At Ilse's Dyeworks a dye goes on with a cloth swish (`cloth`). Wearing one you own again plays no coin, since nothing is paid.
- **After the end (pass 143):** on a cleared save the music follows the Tree's bloom (4.4) through `Music.after_the_end` (table `Music.AFTER_THE_END`):
  - **Eolis** plays its festival variant, `eolis_bloom`. It is the town theme a touch quicker (100), with a bell doubling the arpeggio an octave up, a frame drum and a bell answering the lead.
  - **The dead meteor goes still.** Zenis drops its heartbeat track for `zenis_still`: B minor at 60, the pads in tune where they had beaten against each other, no pulse, and once per pass a far bell climbing a B major chord. Its bed becomes `amb_zenis_still`: the breath and heartbeat are gone, leaving a thin hollow wind, stone ticking as it cools and now and then a crystal cracking with a soft chime.
  - Other zones keep their themes, and a fight still plays its fight.
- **Mix (pass 96):** `python3 tools/audio/levels.py` measures the peak and the loudness of the audible part of every sound, track and bed. `--check` fails if any of them clips (peak at -0.1 dBFS or over) or strays more than 9 dB from its group's median. Generated music is normalized to -3 dBFS (it had been -1.4, and the Vorbis encoder's overshoot clipped 22 of 25 tracks past full scale), with `Music.MUSIC_DB` raised 1.7 dB to -8.3 to keep its place in the mix. The death sound was 10 dB over the effects' median and is now in line.
- **Ambience:** one bed per zone (wind, drips, creaking wood, storm), and a room can name another (`ambience:`). In the Tower, the halls hum with machinery (amb_tower), the Old Flue and the Rafters howl with wind, a rattling shutter and creaking beams (amb_heights), and the Deep Workings drip, with carts rumbling through the rock and far-off picks (amb_mine). The Guru Trials' mantra-space has its own theme and bed (`trials`, `amb_trials`, pass 116).
- **Footsteps:** each step plays the sound of the ground underfoot (`Room.surface_at`): stone in Eolis, moss on the Trunk's living wood, iron on the Tower's plates, hollow planks on every one-way platform, and a squelch in sap. A room can name another surface with `surface:`. A landing layers the surface step under the land thud, louder the harder the fall.

---

## 14. Technical Architecture (Godot)

- **Engine:** Godot 4.7.2 stable (pinned in CI and `tools/godot-version.txt`). GDScript with static typing.
- **Renderer:** Forward+ (2D lights, glow); verify Compatibility renderer as a fallback for low-end machines.
- **Physics:** custom kinematic controller on CharacterBody2D with hand-written movement (no built-in floor snapping surprises), fixed 60 Hz.
- **Structure:**
  - `autoload/` GameState, SaveSystem (JSON, 3 slots, autosave on rest), EventBus, AudioDirector, InputRouter (rebinding, buffering), RoomManager. As built, saving lives in GameState: one JSON file per slot in user://, written safely and read defensively (15.3, pass 109).
  - `scenes/player/`, `scenes/enemies/<family>/`, `scenes/bosses/<boss>/`, `scenes/rooms/<zone>/<room>.tscn`, `scenes/ui/`.
  - `data/` items, enemies, shops, skill tree, dialogue as `.tres` resources or JSON (so balance changes never touch code).
- **Level authoring for an AI team:** rooms are described in a text format (`levels/<zone>/<room>.room`: an ASCII tile grid plus a YAML header for doors, entities and camera). A runtime loader (`scripts/world/room_loader.gd`) builds TileMapLayer nodes and entities from them, so no generated scenes need to be kept in sync. Text levels diff cleanly in pull requests and are easy for agents to write and review. A world graph file (`levels/world.yaml`) lists room connections, which feeds the map screen and a reachability checker.
- **Reachability checker:** a tool that simulates the player's movement envelope (jump heights, dash distance) per ability set and proves every required item is reachable in order and that no soft-lock exists. It runs in CI.
- **Testing:** GUT unit tests for systems; scripted input replays for the movement controller with asserted metrics (jump height, dash distance, coyote window); headless boot of every room; screenshot capture per room under a virtual display (Xvfb) for visual review.
- **Performance budget:** 60 fps locked on a mid-2018 laptop GPU; under 1.5 GB RAM; rooms load in under 100 ms (preload neighbors).
- **Full-screen effects** that snap to world pixels (the Mist's fog) render at one texel per world pixel in their own small viewport and are scaled up: a quarter of the fragments of the 2x scene, and the same look. Their noise comes from a small tileable texture, not per-fragment hashing.
- **Accessibility:** full remapping, screen-shake and flash toggles, game speed slider (70 to 100%; steps of 10), assist options (extra invulnerability, infinite double jump in Guru Trials only off by default), colorblind-safe gate icons, subtitles for all voiced grunts. *Interim (pass 09):* the options menu has shake (full, half, off), flashes (full, reduced, off), rumble, music and sound volume and game speed, and the keyboard can be rebound; gamepad remapping comes with controller glyphs.

---

## 15. Milestones and the Build Loop

### 15.1 Milestones

| # | Milestone | Done when |
|---|-----------|-----------|
| M0 | **Repo and pipeline** | Godot project, folder layout, CI (headless tests, export builds for Windows and Linux, room screenshot job), art tool scripts, Autosprite ledger, this bible committed |
| M1 | **Movement prototype** | Graybox gym with every movement ability toggleable; all section 6 values implemented; juice checklist complete; replay tests passing |
| M2 | **Combat core** | Slash combos, pogo, parry, spells framework, hit-stop and shake, 3 test enemies, damage and death loop |
| M3 | **Vertical slice** | Eolis + Trunk Hollows in final art; shop, Guru save and skill tree (first 6 nodes), map, gold drop, Rokusutahn, one secret of each type available, music and SFX in |
| M4 | **Act I complete** | Tower of Trunk, Zoradohna, smith, fast travel, world-state change 1 |
| M5 | **Act II complete** | Mist, Branches (both), 4 bosses, all springs, all spells |
| M6 | **Act III complete** | Dartmoor, Zenis, King Grieve, Shadow Eura, Evil One, ending |
| M7 | **Content complete** | Optional areas, Drowned Warden, all secrets, Guru Trials, boss rush, completion screen |
| M8 | **Polish loop** | Iterate until the confidence target in 15.3 is met |

### 15.2 The iteration loop

Every milestone runs the same loop, and M8 runs it until done:

1. **Build:** implement the next slice of work as pull requests.
2. **Verify automatically:** CI runs unit tests, movement replays, the reachability checker, a headless boot of every room, a performance capture, and screenshots of every room.
3. **Review:** a reviewer pass compares screenshots and metrics against this bible (palette compliance, contrast check, telegraph timings, economy curve, secret counts) and files issues.
4. **Score:** fill in the vision rubric (15.3). Write the score and the open issues to `docs/loop/pass-NN.md`.
5. **Fix:** the next pass takes the lowest-scoring categories first.
6. **Stop** when the confidence target is met; otherwise go to step 1.

The loop runs as a scheduled routine once the repo exists, and Sean gets one short message per completed milestone with a downloadable build. Sean's playtests are welcome but never required to keep the loop moving.

### 15.3 Vision rubric (confidence score)

| Category | Weight | Measured by |
|----------|--------|-------------|
| Movement feel | 20 | Section 6 values met in replays; juice checklist; frame-perfect input response; zero stuck states in fuzzed input tests |
| Combat and enemies | 15 | Telegraph times, hit-stop, every enemy has full animation set, damage balance sheet within targets |
| World and level design | 15 | Room count, landmarks, save spacing, reachability proof, sequence breaks safe, secrets per zone |
| Art cohesion | 15 | Palette compliance 100%, contrast check pass, no missing animations, parallax per zone, screenshots reviewed |
| Bosses | 10 | Each has 2 to 3 phases, tests its ability, cinematic kill, balanced HP (target fight time 2.5 to 5 min) |
| Systems | 10 | Save/load round-trip, shop, skill tree, map, fast travel, settings all tested |
| Audio | 5 | Every action has SFX, every zone has music and ambience, mix levels in range |
| Stability and performance | 5 | 60 fps budget, no crashes in a 2-hour soak bot run, load times |
| Faithfulness to Faxanadu | 5 | Checklist: towns, Gurus, ranks, rings, keys, springs, all original bosses, Evil One |

**Stability measures (pass 99):** the journey soak (`test_soak.gd`) walks the world twice, door to door with mashing play between. It rests and Continues into a fresh world every 20 rooms and opens the pause and skills screens on the way. The second lap must leave no live objects, orphan nodes or tree nodes behind. No frame of play (room loads aside) may pass 50 ms. Anything a room will need mid-play is loaded while the room loads: a boss arena loads its boss's sprite sheet and music (`BossArena.warm`), because a fight starts mid-play. Every sound effect loads with the game (`Sfx.load_all`, about 20 ms once, 2.2 MB), so no first slash or phase break waits on the disk (pass 103). Every boss fight is timed for 15 s of mashing with a phase knocked off every 5 s (`test_every_boss_fight_holds_the_frame_budget`): the average frame must stay under 8 ms and the 99th percentile under 16.6 ms, and nothing may load from disk once the fight has begun.

**After the end (pass 144):** every soak had run on a fresh save, so the post-game world (4.4: the blossom layer, `Music.after_the_end`, every boss arena idle) and Wanderer's Grace (`Player.on_kill` on every death) had never been walked. `test_a_journey_after_the_end_stays_lean` runs the journey on a cleared save: every boss beaten, every spring running, the Wanderer branch learned. Each lap walks 100 doors out of Eolis and 50 out of the dead meteor's Threshold, resting and continuing every 20 rooms (each Continue must still be cleared). The checks:
- the second lap leaves no orphan nodes, no growth in the tree and fewer than 50 live objects behind;
- no frame of play passes 50 ms;
- no engine or script error is logged (`ErrorCatcher`);
- blossom drifted, Zenis played still and Eolis its festival.

**Saves and settings (pass 109):** no file the game reads can crash it or leave it half-loaded.
- **Writing.** Saves and `settings.cfg` are written to a `.tmp` file, read back whole, and only then swapped in, with the previous file kept as `.bak` (`GameState.write_safely`). A write that fails leaves the last good file untouched.
- **Loading.** A damaged file (empty, cut off, not JSON, not a save) falls back to its `.bak`. If neither reads, the load is refused and the game in play is left as it was. The title's Continue then starts a new journey with a note, rather than failing.
- **Sanitizing.** Whatever loads is rebuilt on a new game's data (`GameState.sanitize`):
  - every key is present and has its own type, and a wrong type falls back to the default;
  - lists keep only well-formed entries (skills, rings, pins, Guru stops), and the save point and purse must be whole;
  - numbers are finite and never negative, and health, MP and flasks never fall below a new game's;
  - keys from a newer build are kept.
- **Missing rooms.** A rest in a room this build lacks wakes you at the new-game spot.
- **Settings.** Each option must be the right type and in range, or it takes its default; only a real keycode is bound.
- **Older files (pass 129).** A settings file from an earlier build has no line for the actions added since. It loads with those actions on their default keys and logs nothing. It had logged an engine error for each missing action.
- **Saves naming what a build lacks (pass 138).** A save can name a skill node, blade, ring or dye that this build doesn't have (renamed, or from a newer build). Unlearning skills used to stop at such a node with a script error, after taking the gold and before refunding any points. Now an unknown node refunds nothing and the respec goes through. The save keeps each skill and dye once, as strings, so a skill listed twice can't be refunded twice. An unknown blade falls back to the Hand Dagger untempered: it had taken the missing blade's temper. An unknown dye leaves the cloak as it is. `test_a_save_naming_things_this_build_lacks_plays_on` runs such a save through loading, dressing, the skill list, the dyer and a respec with `ErrorCatcher` listening.
- **Tests.** `test_systems.gd` covers each case. `ErrorCatcher` (in `tests/`) lets a test check that a moment logs no engine errors at all.

**Exit rule:** weighted score of at least 95, no category below 85, zero open blocker bugs, and a full bot playthrough from new game to credits succeeds.

**Honest limit:** an automated score cannot fully measure "feel". The rubric uses measurable proxies benchmarked against the reference games. A short playtest by Sean at M1 (movement) and M3 (slice) would be the single most valuable input, but the loop does not wait for it.

---

## 16. Open Questions (decided by default, revisit any time)

| Question | Default decision |
|----------|------------------|
| Title | "Faxanadu Reborn" (working) |
| Voice acting | None; grunts and efforts only |
| Difficulty modes | One tuned difficulty plus assist options |
| Platforms | Windows and Linux first; macOS next; Steam Deck stretch |
| Localization | English only at launch; all text in a string table |
| Original music remixes | No direct remixes of NES tracks (IP); new themes inspired by their mood |

---

*End of design bible v1.0.*
