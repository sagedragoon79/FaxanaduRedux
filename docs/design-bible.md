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

The world is one vertical map: **the World Tree**, **126 rooms** across 7 zones plus 2 optional areas (the plan said about 190; see below). The player climbs upward overall, but each zone sprawls horizontally and loops back on earlier zones through shortcuts.

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
| 0 | **Eolis** | Eolis | 7 (10 planned) | Stone town carved into the roots, warm lamplight, dry fountain | Hub, shops, King, Guru, fountain shows progress | none |
| 1 | **Trunk Hollows** | Apolune | 28 | Tunnels through living wood, glowing fungus, amber sap | Sap pools slow you; root-gates | Rokusutahn |
| 2 | **Tower of Trunk** | Forepaw | 26 | Dwarven mining tower bolted into the trunk, gears, minecarts | Vertical climb; cracked stone; elevators | Zoradohna |
| 3 | **The Mist** | Victim, Mascon | 14 (34 planned) | Fog-drowned limb-marsh, lanterns, rotting boardwalks | Fog limits vision; lanterns; water levels | Ripasheiku, Zorugeriru |
| 4 | **Branches (Conflate)** | Conflate | 10 (24 planned) | Sunlit canopy, enormous leaves, wind | Wind currents (legend `>`/`<`: carry you while airborne, turned by the Spring of Sky, 6.9); bounce-pods (legend `@`: land on one and it throws you about nine tiles up, 6.6) | Pakukame |
| 5 | **Branches (Daybreak) and Canopy Spires** | Daybreak | 9 (26 planned) | Sky islands, storms, ruined elf shrines | Lightning conduits; air dash routes | Borabohra |
| 6 | **Dartmoor** | Dartmoor | 14 (28 planned) | Flooded dwarf capital, meteor crystals growing through masonry | Time-stop puzzles; illusory walls | King Grieve, Shadow Eura |
| 7 | **Zenis** | none | 8 (14 planned) | Inside the meteor: organic stone, alien light, gravity wrong | Gauntlet using every ability | The Evil One |
| opt | **Sunken Spring** | none | 4 (8 planned) | Under Dartmoor, the original source of the springs | Underwater swimming (Deluge-drained rooms) | Optional: The Drowned Warden |
| opt | **Guru Trials** | Eolis | 6 | Abstract mantra-space, monochrome | Pure platforming challenges | none |

**As built (pass 323).** The Rooms column was the plan's until pass 323, and the overview promised about 190 rooms. The game has 126 room files (the gym aside). The Trunk, the Tower and the Trials were built as planned. The zones after them came out at a third to two thirds of the plan, in rooms of about the same size (1,200 to 1,900 tiles on average, Zenis and the Sunken Spring the largest). Each still holds its towns, its guardians and its ability gates (4.1, 4.2), so what fell short was the filler between them, not a beat of the critical path. Where a zone fell short, the column says so, for example "14 (34 planned)". `test_the_bible_counts_each_zones_rooms` holds each count and the total to `levels/`. A later pass that adds rooms changes the count with them.

**Guru Trials (pass 113, the first two of six; the third in pass 155, the fourth in 160, the fifth in 162, the sixth and last in 168):** `levels/trials/`, the mantra-space, is off the map and out of the completion count (`World.OFF_MAP`). The Guru in the Temple of Mantras gains a "Guru Trials" row (cleared/built). It is dry until a spring flows, and its list shows each built trial as Sealed (with the springs it needs), Open, or your best time. Trials open two by two, one pair per spring restored (`Trials.LIST`); a trial whose room isn't built isn't offered. Choosing one carries you to its start (`P`), and the clock runs from that moment: the trial's name, the clock and your best (or "First walk") sit top center on the HUD. In a trial a hazard costs time, never health: it sets you back on your last footing with a hurt flash. The bell at the far end (`prop: x, y, trial_goal`) rings when touched. It shows your time, keeps your best (`GameState.data.trials`, trial id -> seconds), and the first clear rings a Mantra Shard out of it (bible 10). After 1.2 s the mantra carries you back to where you stood by the Guru. The pause menu gains "Leave the trial", which stops the clock and returns you there uncleared. Look: pale grey masonry with no moss or warmth, a void behind with great faint broken mantra rings and pale slabs hanging nearer, pale flecks in the air; the bell hangs in a stone frame with a slow glow. Sound (pass 116): music `trials` (D lydian at 92 over a drone that never changes chord, a dry tick on every eighth like the trial's clock, a soft pulse to run to, and a bell chanting a four-bar mantra above), ambience `amb_trials` (a hollow void hum that breathes, thin air, far chimes of the mantra rings), `trial_begin` as the mantra carries you in (a shimmer rising a fifth), `trial_bell` at the end (a struck bronze bell with inharmonic partials ringing long), and `trial_record` on a new best (three bright rising notes). Built: **Mantra of Walls** (three pillars over spikes, thorned on their far sides and with thorn bulbs in the gaps; climb each with the Climbing Glove from the nub at its foot) and **Mantra of Edges** (1- and 2-wide pillars over a spiked floor, four tiles apart and at changing heights, then four slats under a low ceiling that allows only short hops, then rising pillars to the bell). Both are proved clearable with the glove alone by `test_every_guru_trial_can_be_cleared_with_the_glove`. Planned: Thorns and Winds (two springs), Stillness and Falling (three); built since: Thorns (155), Winds (160) and Stillness (162). The cosmetics the bible pairs with trials (cloak dyes) came in pass 164: see **Mantra dyes** in 10. **The Mantra of Thorns (pass 155), the third:** opened by the second spring, and built for the Glove and the Mattock (`Trials.LIST` gains `needs`, the abilities a course is built for; the reachability test checks each trial with exactly those). A pogo course 96 tiles long: a 20-tile corridor of spikes from the start ledge (pogo along it), a pit under a chain of five thorn bulbs four tiles apart (the bulbs are the fast way; fall in and you pogo the spikes to the far wall and climb it), then two bulbs rising to a slab that hangs from the east wall over more spikes, with the bell on it. Nothing climbs to the slab, so the last two bulbs are the only way up; without the Mattock the bell can't be reached. A simple pogo-playing hand (walk right, jump off edges, steer over the next bulb, strike down while falling) clears it in the real game in about 12 s. **The Mantra of Winds (pass 160), the fourth:** opened with Thorns by the second spring, and built for the Glove and the Wing Boots. It teaches the Branches' wind currents (6.9) a zone ahead, over spikes. The course is 100 tiles long:

1. Jump from the start ledge into a current that carries you over a 25-tile spike pit to a pillar.
2. Climb the wall that rises beside the pillar.
3. Leap off the wall's top into a high current that drops you on a second pillar.
4. Make a jump of five rows, too high without the Boots, up to a hanging plank.
5. Step into the last current, and hold Down to let go over the bell's slab. Ride it on and it throws you onto spikes.

The mantra-space has no weather, so its winds never turn with the Spring of Sky (`WindCurrent.dir`, and `Reach.wind_dir` for `trials/` rooms), and pale flecks ride them instead of leaves. The checker clears it with the Glove and Boots, before and after the Spring of Sky. It cannot clear it without the Boots, or with the winds taken out even with the Stride. In the real game, the first current carries a jump from the ledge to the pillar. The Guru now also keeps a trial sealed until you hold what it is built for (`Trials.missing`, `Trials.ready`): the springs can flow before the Wing Boots are found, and then the row says "Its footholds want the Wing Boots."

**The Mantra of Stillness (pass 162), the fifth:** opened by the third spring, and built for the Glove and the Hour Glass. Time-locked water (`f`, 4.5) is the whole course, and the waits between turns of the glass (2.5 s still, 8 s to run back) are part of the mantra: be still. `levels/trials/stillness.room` (72 x 56):

1. From the start, still the fall at the end of the hall and climb its four footholds to a ledge.
2. A curtain of water hangs from the void over a spiked pit. Still it, jump onto its footholds, climb three of them, and jump to the far ledge. Flowing, it beats you down onto the spikes.
3. Climb a long fall of seven footholds. A dry niche halfway lets you step out and wait for the glass to run back. A quick climber can skip it.
4. Reach the bell at the end of the top ledge.

The checker reaches the bell with the Glove and the Hour Glass, and the niche on the way. Without the glass, it can't reach even the first ledge, even with the Boots, the Stride and the Mattock. In the real game, short hops climb the first fall within one turn of the glass. **Stilled water is never safe footing:** a foothold of frozen water melts when time runs on, so standing on one no longer sets the place a hazard puts you back (`Player._on_stilled_water`). Until pass 162 a fall onto spikes after the curtain thawed could set you back into the flowing water, which carried you down again. Planned: the Mantra of Falling (three springs).

**The Mantra of Falling (pass 168), the sixth and last:** opened by the third spring with Stillness, and built for the Glove alone: the one trial about letting go. `levels/trials/falling.room` (40 x 90) is a descent, start at the top, bell at the bottom:
1. **The steps:** five three-tile ledges fall away under a 38-tile spike floor, each four or five rows below the last and three or four columns over, east, west, east. Walk off and steer: there is no climbing back.
2. **The well:** off the last ledge, a gap in the spike floor drops you into a well crossed by three planks. Drop through each (Down + Jump).
3. **The needle:** walk west off the well's floor into a nine-tile shaft 28 rows deep. Thorn bulbs stand in it every four rows, left of center, then right, so only a fall held to the middle column comes through clean. The bell stands on a three-tile slab at the bottom, with spikes either side.

The checker falls to the bell with the Glove. In the real game, a bot that only steers its falls and drops through the planks rings the bell in about 7.2 s with no set-back. The mantra time is 10 s, so a clean run has to fall without stopping on each ledge. The dye is Plummet Umber. All six of the trials bible 3.1 plans are now built.

**Dartmoor begins (pass 63):** `levels/dartmoor/`, below Dartmoor's upper gate at the end of Daybreak (the Sky Key opens it; a shaft past it drops into the zone). The Upper Stair (60,-11, 40x45) is the dwarf kings' old trade stair: nine landings switch back down a drowned colonnade to the Upper Gate-Hall (59,-10), with broken pillars, a shrine and the west way choked with stone and crystal for now. Look: squat dark dwarf masonry with a teal tide line on every block where the flood stood, veins of magenta meteor crystal forcing through the joints of exposed faces, teal waterweed for a cap; behind, a sunken great hall of colossal pillars and arches with crystal clusters glowing on the far walls and dark water below, and nearer, broken colonnades run through with crystal spears. Decor: crystal shards, drowned dwarf helms, fallen masonry, crystal stalactites, seeping drips, wall crystals and dead braziers. Crystal dust hangs in the air. Music `dartmoor` (D phrygian at 70: a dirge of deep hall pads, an octave bass, a low tolling bell and far-off crystal chimes) and ambience `amb_dartmoor` (a still water drone, drops into pools, a trickle, a faint crystal hum). Pass 64 opened the Gate-Hall's west way onto the Flooded Hall (57,-10, 60x23), the old hall of audience: broken pillars, a crystal-spiked pit, a gallery with a chest, and two Crystal Dwarves. Pass 65 opened its west wall onto the Sunken Stair (56,-10, 40x45), five landings down a drowned colonnade over a crystal-spiked trench, and below it the Onyx Crypt (55,-9), the masons' tomb, where the Black Onyx lies on a dais. Both rooms hide a secret behind an illusory wall up a run of hidden planks, so the Onyx pays off at once on the way back. In pass 66 the way on became the main-route illusory wall: the crypt's hidden chamber hides its west door to the Drowned Nave (53,-9, 80x23), where the king's guard knelt. It has broken hanging pillars, two galleries, a spiked pit, two Shade Knights and a Crystal Dwarf, and a Mantra Shard up hidden planks under the vault. In pass 67 the Hour Glass came to its west end: it stands on a plinth by the stopped water-clock with a shrine beside it, and the west door opens on the Waterfall Stair (52,-10, 40x45), two shafts of falling water that only a frozen moment lets you climb, to a gallery with a Life Fruit and a chest. In pass 69 the gallery's east door opened on the Drowned Market (53,-10, 80x23), where the lower city sold its ore: Meteor Slugs creep its floor, a fall of time-locked water pours into a spiked pit across the hall (frozen, its lowest foothold lies flush with the floor, so the glass is the bridge), and past it a Crystal Dwarf guards the stair down to the king's halls. In pass 70 that stair's last stone cracked: a doorway at the market's east end leads down the King's Stair (55,-8, 40x45), where the king's fall pours down the stair-well. The upper flight's only way down is through the water, and the only way back up is a frozen climb with a dry niche halfway to wait out the glass. At its foot, by a shrine, the King's Kennels (56,-7, 80x23) hold three Clockwork Hounds among their stalls, a spiked drain, and the kennel-master's loft up hidden planks with a chest. Their east end opens on King Grieve's Throne Hall (58,-7, 60x23, pass 71), a bare hall with his dais at the east end. Since pass 241 the hall is titled **Fraternal Castle**, the original's name for the castle where the dwarf king kept the Dragon Slayer and the Demon Ring; the King's Stair's sign says it goes down to Fraternal Castle, and the kennels' sign calls the throne its heart. In pass 169 a plank lid over the kennels' old spiked drain became a shaft down to Alpha's Den (57,-6), where the Clockwork Alpha waits (section 8).

**Daybreak as built (pass 54):** `levels/daybreak/`, entered by the Crown-Leaf's east door. Storm Ledge (a fallen causeway span over thorns: pogo it or stride it), Sky Steps (one-way island shelves stacked up a tall room, with storm crystals bristling on the cliffs so nothing can be climbed around them; an elven veil before the exit ledge makes the Stride the way out, pass 227) and the Broken Shrine (a shrine, a Life Fruit, and the fallen bridge to Daybreak town). Look: pale ashlar shrine stone with gold inlay, a violet storm sky with lightning and drifting islands, rain driven on the wind. Music `daybreak` (E dorian at 116, thunder toms) and ambience `amb_daybreak` (gusting wind, rain, rolling thunder).

**Daybreak town (pass 57):** the Broken Shrine's east door opens on the Fallen Bridge (52,-11), the great elf bridge broken into floating spans a stride apart, with hornets in the wind and a beetle on the old footing below (a fall walks you back to the near pier; storm crystals on the far pier stop a climb round). Past it, Daybreak (54,-11), the bell town on the last great island: a Guru, Calder the Armorer (Full Plate), Scribe Ysolde (the Fire scroll), Grocer Wenna, Bell-Ringer Tamsin on the bell loft gallery (the Daybreak chart), the Mayor (who names Borabohra) and the old Bellkeeper (who points at the bramble-choked bell cellar, where a Potion Shard waits for Fire). Music `daybreak_town` (G mixolydian at 92, a carillon over warm pads). The Spires beyond, with Borabohra and the Thunder spell, come next.

**The Spires begin (pass 58):** a passage through the town's bell tower (from the bell-loft gallery) leads to the Spire Foot (56,-11), the old lift-house, where the Thunder scroll lies on the conductor's lectern and one dead conduit stands before a conduit gate. Past it the Spire Stair (57,-12, 40x45) climbs old landings to a silver hatch that opens only when both its conduits wake (one on the floor, one on a landing), and above it to a chest on the top landing below the roost. The Storm Harpy came in pass 59. In pass 60 the top landing's east door opens on the Roost (58,-12), Borabohra's arena (8.6). In pass 62 the Roost's east door, sealed with the arena until the roc falls, opens on the Spring of Sky (60,-12): the spring on a dais, and past it Dartmoor's upper gate (legend `g`), shrine stone with a gold lightning glyph that only the Sky Key opens. The way down to Dartmoor beyond it comes with that zone.
**The Sunken Spring begins (pass 86):** `levels/sunken/`, the optional zone under Dartmoor. The way in is the last stone of the Meteor Rise: three cracked stones in the floor at its foot (the Mattock breaks them) over a shaft that is still full of water, so it is the zone's first swim (bible 6.8). The shaft drops into the Spring Gate (60,-6, 40x45), a drowned cistern of pale limestone with two Spring Eels, a chest and a potion shard on the bottom, and a dome of trapped air whose shelf holds a shrine. Let go of the controls in the shaft and the water floats you back up into the Rise. Its east door, on the bottom, opens on the Drowned Aqueduct (61,-5, 80x23), the dwarves' old culvert up to their city: the water stands at row 9 under four broken arch tops you can climb out onto, two walls hang down into the water so you swim under them, three eels hunt it, a Mantra Shard sits on an arch and a dry gallery at the east end holds a chest. Under the water at its east end the Source Hall (63,-5) is a black pool beside a dry shore with a Shade Knight, a Life Fruit on a shelf, and a sign: the Source lies deeper still, and the way to the Drowned Warden (8.10) opens in a later pass. Look: limestone laid down by the spring in wavy strata like the rims of terraced pools, pocked, with a blue-green mineral stain; behind, a flooded cavern of stepped pools under slanting light, and nearer the aqueduct's arches on their piers with weed swaying up from the bottom. Decor: rimstone dams, spring pearls, waterweed, limestone straws, seeps of the spring's light and flowstone. Specks of light rise through the water. Music `sunken` (E dorian at 64: tidal pads, a pluck rippling through each chord like light on water seen from below, a far bell) and ambience `amb_sunken` (a deep pressure hum, a current washing through stone, bursts of bubbles).

**Victim (pass 145):** the first of the Mist's two towns, and the first town of the original's eight that the remake had left out. `levels/mist/victim.room` (25,-8, 80x23), west of the Feather Hollow: a shelf at the Hollow's west wall leads in, so the town is reached with the Lantern Key, through the room where the Wing Boots wait. Victim is the lamp town on the boardwalks, built before the fog and never left. Its miners went down the drowned stair to dig meteor stone for the dwarf king's gold and came back as the Drowned Dwarves of the mire (bible 7). There it has:
- a Guru (save, skills and a Mantra Path stop);
- Keymaster Odo (Jack 150 g and Queen 400 g keys, ointment and elixirs; bible 10.2 names Victim as a key master's town);
- Fogwalker Bram on a plank loft, selling the Mist chart (500 g);
- Marta, a miner's widow, and Lamplighter Nell, who both have new lines once the Tree blooms (4.4).

The fog lies over the town at 0.6 (0.88 out in the marsh). It is lit by four lamp posts (prop `lamp`, `TownLamp`: a lantern on an iron arm whose flame clears an 84 px pocket of fog), so the street is a string of warm pockets with dark between. Its houses are boardwalk houses (`HouseFront` in the `mist` style: reed-grey planks, a damp dark frame) whose windows burn from the first visit, unlike Apolune's, which wait for their people. Music `victim` is the Mist's B minor waltz come in out of the cold: D major in 3/4 at 84, the same music-box pluck on two and three but dry and near, warm pads, a walking bass and a lamp-bell on every other downbeat. The bed stays the Mist's. **Mascon**, the second Mist town, came in pass 148 (below).

**Mascon (pass 148):** the Mist's second town and the last of the original's eight to be built. `levels/mist/mascon.room` (33,-6, 80x23) lies under the Scorched Hall and the Dry Cistern. A shaft in the Scorched Hall's floor, beside the sign that always said "The Mascon road runs on east under black water", drops down a ladder onto the old barge road. East of the landing the road is drowned: a 20-tile dip of black water over spikes, with a row of drowned boardwalks (legend `b`) that rise when the Spring of Mist flows (4.4), as on the Fog Cut and the Victim Causeway. Before the spring, a skilled player can pogo along the spikes with the Mattock and climb the far side with the Glove; after it the town is a walk. The ladder climbs back out. Past the water is the stilt town where the marsh-folk stayed and fished:
- a Guru (save, skills, a Mantra Path stop);
- Scribe Orla, who sells the Fire scroll (1,200 g), as 10.2 planned, a zone before Daybreak's scribe sells it too;
- Eelwife Brannagh's stores (ointment, elixir, Jack Keys);
- Old Teague the Poler, who poled the dwarf king's ore barges down this road, and has post-game lines.

Like Victim, it has boardwalk houses lit from the start, three lamp posts, and fog at 0.6. Music `mascon` is a poler's song: E dorian in 3/4 at 72, a low plucked line over an open-fifth drone that never moves, a soft drum stroke on each downbeat like a pole set in the mud, and a lead that dips and rises like a barge. With Mascon, seven of the original's eight towns stand with a Guru and shops: Eolis, Apolune, Forepaw, Victim, Mascon, Conflate and Daybreak. The eighth, Dartmoor, is the drowned city itself; its steward and mason come back once King Grieve falls. **Dartmoor wakes (pass 159):** in the original, Dartmoor is the last town, with a Guru and a key shop before the final climb, and 10.2 names it a key master's town. Once King Grieve falls, the Drowned Market is a town again. Its slugs and crystal dwarf are gone (room header `calm: boss:king_grieve`: once the flag is set the room spawns no foes). A Guru stands there, the last before Zenis, and the Mantra Path can reach him. Keymaster Sigrun, a dwarf, keeps "Sigrun's Locks": Jack, Queen, King and Ace keys, Ointment and Elixirs, but never the Joker, which still lies on the stall-plank above. With Dartmoor, all eight of the original's towns stand with a Guru and a shop. Since pass 179 the east end of the boardwalk (door 2) opens on the Matriarch's Mire, where the Marsh Hag Matriarch waits (section 8).

### 3.3 Room and map rules

- **Room size:** multiples of one screen (640x360 px internal = 40x22.5 tiles of 16 px). Rooms are 1x1 up to 4x3 screens. **As built (pass 331):** every room on the map is at least one screen (40x23 tiles) and no more than 4x3 screens (160x68). Most are whole screens (40x23, 80x23, 40x45, 40x68, 120x23, 80x45), but 14 are a screen and a half wide (60 tiles: arenas and halls such as the Crown-Leaf, the Throne Hall and Zenis's last rooms, and the Roost, 60x29) and the Heart Gate is 56; the camera stops at a room's edges, so a part screen only means the camera travels less. The Guru Trials are off the map and keep their own shapes (96x20, 72x56, 40x90 and others): two are shorter than a screen, and the mantra-space's void fills the view below them. `test_every_room_keeps_the_bibles_size` holds the bounds.
- **Camera:** room-bounded; camera locks to room edges; transitions are seamless scrolls (no fade) within a zone and a brief fade between zones. The scroll is a screen push: the old view slides out the way the player went while the new room slides in (0.34 s). Inner doorways (Up to enter) fade, since there is no direction to scroll. Coming up a shaft you arrive inside the floor door of the room above, still rising; fall back before you clear it and that door takes you back down (pass 146), instead of letting you drop out of the room. Through any door, the arrival is the new room's first safe spot (pass 151): a hazard met before the first landing, such as spikes under a drop, sets you back there, never at the last room's footing. Every floor and ceiling door ends on footing (pass 299): down one, you fall onto tiles with no hazard beside them, which the set-back keeps; up one, a steer to either side lands you beside the floor door instead of dropping back in, even a steer begun a quarter second after you arrive (pass 304: a player's time to see the new room and react; the Old Flue, the tightest, fails at 0.35 s). The rise (`World.RISE_SPEED`, 430 px/s) has room to spare: the Alpha Den, the tightest ledge, still lands at 370 and fails at 340. Played with no abilities, so neither the Glove nor the Boots is needed for it. A gate under a ceiling door (the flue damper, bound fog) shuts only the way up; you can't come down to it while it is shut.
- **Save points:** each town has a Guru (save, respec, rank-up). Plus 2 to 3 **Meditation Shrines** per zone (save only). No room is more than 4 rooms from a save or a shortcut back to one. **As built (pass 331):** the distance rule decided where shrines went, not the count, so the count follows each zone's size and its towns: Trunk Hollows 4, Tower of Trunk 5, The Mist 1 (with the Gurus of Victim and Mascon), Branches (Conflate) 2, Branches (Daybreak) 1 (with Daybreak's Guru), Dartmoor 5, Sunken Spring 1 (four rooms), Zenis 3, and Eolis none (its Guru). `test_every_zone_has_the_shrines_the_bible_counts` holds these to `levels/`. Held by `test_no_room_is_far_from_a_rest` since pass 195, counting doors walked to the nearest Meditation Shrine or Guru; where foes hit at double (Dartmoor, the Sunken Spring and Zenis, 5.5) the limit is 3. The test found one room over the limit: the Bell Loft at the top of the Tower, a dead end five doors from the nearest rest (the Mine Vault's shrine, by the Crown Lookout, the Rafters, the Mine Shaft and the Rail Gallery, or Forepaw's Guru by the Mine Mouth), with Gear Bats roosting the whole way. The Crown Lookout now has a shrine of its own, by the sign where the dwarves watched for the Mist, so the climb to the tower's crown ends somewhere to rest.
- **Fast travel:** unlocked after the first spring: Guru-to-Guru travel through the "Mantra Path" menu. Speaking to a Guru marks that Guru as a stop; the Guru's menu lists every other stop you have met, and choosing one fades you to a step beside that Guru. Before any spring flows the row is shown but dry, so players learn it exists.
- **Map:** auto-maps visited rooms. A cartographer in six of the eight towns sells each zone's outline (empty rooms shown dimmed). Map pins (custom markers) available from the start: with the map open, Jump drops a pin where you stand or lifts the one there, up to 12. Cartographers so far: Pell in the Eolis market (Eolis 40 g, Trunk Hollows 250 g), Surveyor Brin in Forepaw (Tower 400 g), and Skywatcher Orin in Conflate (Mist 500 g, Branches 650 g), Fogwalker Bram in Victim (Mist 500 g, pass 145), and the bell-ringer in Daybreak (Daybreak 700 g). **Sounder Hulda (pass 261):** Dartmoor and the Sunken Spring under it had no chart, the two zones with the most hidden rooms. Hulda, a dwarf who swam the drowned halls by memory for forty years, stands in the Drowned Market once King Grieve is at rest and the water is down. She sells Dartmoor (750 g) and the Sunken Spring (800 g). Every zone the map draws now has a chart for sale, all but Zenis, the meteor no one has drawn. `test_every_zone_on_the_map_has_a_chart_for_sale`. Doors, gates and items get icons once seen. Built: shrines, key doors still shut (pass 127, see 4.5) and Treasure Sense's star (pass 100).
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
| A3 | **Wing Boots** | Wing Boots | **Double jump** (feathers burst), refreshed by pogo and wall touch | Wide gaps, high ledges; on the critical path, the Elven Stride hung in the Windloft's open air (pass 232) | The Mist, Victim side: on a perch in Feather Hollow (27,-8), west of the Victim Causeway |
| A4 | **Deluge** (spell) | Deluge | Water bolt: puts out flame barriers, fills basins (floating platforms rise) | Fire seals, dry basins | The Mist, Mascon side: a drowned scribe's scroll on the Marsh Road (32,-7), east of the Sunken Chapel |
| A5 | **Elven Stride** | (new, elven) | **Air dash** with brief invulnerability; passes through mist curtains | Mist curtains, long horizontal gaps, wind walls | Branches: the Windloft shrine (46,-10), up Conflate's north bough; a warden's cache behind an elven veil in the North Bough is the first stride gate (pass 216, see below) |
| A6 | **Thunder** (spell) | Thunder | Bolt that arcs to conductors; powers elevators and doors | Dead conduits | Daybreak: the Spire Foot (56,-11), through the bell tower |
| A7 | **Black Onyx** | Black Onyx | Passive: illusory walls shimmer; hidden platforms faintly visible | Illusory walls (secrets and one main route in Dartmoor) | Dartmoor, early |
| A8 | **Hour Glass** | Hour Glass | Stops time for 2.5 s (cooldown 8 s): freezes falling water, crushers, platforms, projectiles | Time puzzles, waterfall stairs | Dartmoor, mid-zone |

**Hour Glass as built (pass 67):** its own button, Hour Glass (T or E; left stick click). No MP. Time stops for 2.5 s, and the glass runs back for 8 s from when it was turned. The world drains to a cold blue while it holds. Enemy projectiles (feathers, gears, globs, seeds, rubble, spikes, shockwaves, storm bolts, since pass 120 the Marsh Hag's mire hand, mark or risen, and since pass 228 Rokusutahn's sap, Zorugeriru's mist breath and a Bog Myconid's spores) hang where they are and harm no one until time runs again, and time-locked water freezes into footholds. You and the enemies themselves go on, except the Clockwork Hounds (pass 70), which are clockwork and stop dead: it is a tool for puzzles and for slipping through a volley, not a pause button. Its last three quarter-seconds tick, and time running again rushes (pass 230; see the sound notes in 13.3). One rule holds it (pass 228): anything a foe looses that can strike you stops with the glass, whether it flies, falls, rolls or hangs in the air, and only the foes' own bodies go on. Until then the sap Rokusutahn shakes down, Zorugeriru's mist breath and a Myconid's spores kept dripping, rolling and stinging in stopped time. `test_the_hour_glass_holds_every_loosed_hazard` checks the three and reads every script under `scripts/bosses/` and `scripts/enemies/` for any other hazard that ignores the glass.
| A9 | **Elf, Ruby, Dworf and Demon Rings** | Rings | Story keys: the four rings open the gate of Zenis | The Zenis gate | Rokusutahn, Zoradohna, Zorugeriru, King Grieve |
| A10 | **Dragon Slayer** | Dragon Slayer | The only blade that can hurt the Evil One's core | Final boss | King Grieve gives it up (Dartmoor), as in the original: he swallowed it (pass 217; it lay on a Zenis altar before) |

Supporting spells (optional, combat-focused, found or bought): **Fire** (arcing fireball, burns bramble walls for secrets), **Tilte** (homing spirit orb; built pass 95: 22 MP, 14 damage. It leaves the hand drifting up and forward and hangs 0.15 s, pulsing, then locks on the nearest foe within 240 px, a foe behind counting as twice as far, and flies at 230 px/s, turning at most 6 rad/s, so a quick foe can slip it; walls stop it; 2,500 g at the Daybreak scriptorium), **Death** (screen-wide, very expensive, late secret; built pass 132: 40 MP of a base 60, so one cast from a full flask. A ring of black light rolls out from you to 300 px over 0.45 s, through walls, and every foe it passes takes one blow of 36 that no shield faces; bosses take half, 18. It tolls a deep knell (`death_wave`). The scroll (legend `{`) lies in the King's Kennels in Dartmoor, beside the kennel-master's chest on the loft that only hidden planks reach. It is last on the Next Spell cycle. Mantra of Death, the Arcana node after Time Thief (pass 134, 3 points), halves its cost: 20 MP, 17 with Thrift).

**Fire as built (pass 57):** sold by Daybreak's scribe for 1,200 g (the Mascon shop comes with Mascon). 20 MP; the ball is thrown forward and up (170 px/s across, 150 up, falling at 520 px/s²), so it lands about seven tiles ahead and arcs over a low foe's head at point-blank range. It bursts on a wall, floor or foe, scorching every foe within 20 px for 18 and lighting every bramble in reach. It lights the fog as it flies. The Next Spell button (G or O; right stick click) cycles the spells you own, and the HUD's magic-bar gem shows the equipped spell's color. The save keeps the choice.

**The spells' power (deviation, pass 329):** the original's manual ranks its five spells by power against Deluge: Fire "has 1.5 times the power of Deluge", Thunder "has four times the power of Deluge", Death "has six times the power of fire" (nine Deluges), and Tilte "is superior to all other forms of magic". The remake keeps Fire's ratio exactly (18 against Deluge's 12) and nothing else. Thunder strikes for 16 and Death for 36 (18 on a guardian), and Tilte for 14, because each of the remake's spells is a tool with its own job, not a rung on one ladder. Deluge and Thunder open gates (basins, fire seals, conduits), Thunder chains between foes, Fire arcs over cover and burns brambles, and Tilte homes on a foe you cannot reach. Their price is their MP, and the shared 0.35 s cast cooldown keeps a stronger spell from replacing the blade. At the original's ratios, a 108-damage Death would end any foe in the game in one cast, and most guardians in three or four. Death still hits hardest, as the original's ranking has it. Tilte's homing is its superiority. `test_the_faithfulness_checklist_is_all_here` holds the quotes and Fire's ratio.

**The Wing Boots' gate on the critical path (pass 232):** the table gives the Boots "wide gaps, high ledges", but the reach checker found they opened no room at all: with every earlier ability and no Boots, the same rooms were reached as with them, so the Boots only reached two secrets (the Feather Hollow perch and the Sky Steps purse). A core movement ability was optional. Now the Elven Stride hangs in the Windloft's open air (`branches/windloft`, 24,11), its centre 136 px over the floor and at least 15 tiles from the entry ledge and the east wall, where its old plinth and the one-way plank above it are gone. A plain jump lifts the head 112 px, the second jump 160 px, so the Boots come before the Stride, and the Stride before Daybreak (pass 227). The sign says so: "They hung the Stride where only a second step in the air can reach it." Proved with the real controller, since the checker can't prove "out of reach" (`test_the_stride_in_the_windloft_needs_the_wing_boots`): 13 timings each straight up, from a run, off the entry ledge, and wall-jumping off the east wall near the vault with the Glove never reach it without the Boots; with them, a jump and a second jump under it do (9 of 13). The checker agrees (`BOOT_GATES`); it now lets a jump touch a pickup up to 8 rows over the cell you stand in with the Boots, 6 without (`Reach.TOUCH_RISE`, `BOOT_TOUCH_RISE`), both short of the real reach. Climbing back out to the North Bough is the Glove's wall climb up the ledge's face.

**The Stride's gate on the critical path (pass 227):** the Sky Steps were meant to be climbed with the Stride, "each gap past any jump", and the reach checker kept Daybreak shut without it (`STRIDE_ROOMS`). But the checker's jumps fall short of real ones (pass 216), and the real controller crossed the last leap, from the top island to the exit ledge, with a plain running jump: 270 of 300 jump and second-jump timings with the Wing Boots made it, and one with no boots at all. So Daybreak, Thunder and everything past them opened without the Stride. An elven veil (`|`, 4.5) now stands in the column before the ledge (x33, rows 4 to 9, from the ceiling to the ledge's top), so only a dash passes. `test_the_sky_steps_exit_needs_the_stride` plays it: 27 jump and second-jump timings with the boots never stand on the ledge, and a jump and a dash with the Stride do. The sign at the foot still says what to do: "An elf would dash the last of it, in the air." Screenshot: `/mnt/project-files/pass-227/sky_steps_veil.png`.

**Each secret holds against the abilities found before it (pass 211):** the Wing Boots always come before the Elven Stride (the Mist before the Branches), so a Stride secret must be out of reach of a double jump too. Until pass 211 the North Bough's warden cache (a Life Fruit on a one-tile plank over the gap) sat five tiles from the bough's ledge at a five-tile rise, so the Wing Boots took it and the Stride gated no pickup at all. It now hangs one row lower and one tile further west, and the west shelf under it ends a tile sooner: from the ledge it is seven tiles across at a four-row rise, and from the shelf six across at a five-row rise. Each is one tile past a double jump and well inside a double jump with an air dash. The Sky Steps' purse on the climb's first island is a double jump up from the island below, so it is listed with the Wing Boots' secrets, which is what it always was; the Stride still gates the Sky Steps' upper islands. `test_elven_stride_crosses_the_gap_to_the_warden_cache` now starts with the Wing Boots. **Correction (pass 216):** a real jump disproved this. The reach checker's envelopes are kept *under* what the player can do, so that a route it passes is comfortable in play. That makes them right for proving a place can be reached, but they can't prove a place is out of reach. A scripted run in the actual room took the Life Fruit with a single jump, no boots at all. The gap was never a gate. The fruit now sits in a sealed alcove under the North Bough's ceiling, behind an elven veil (below). That is a gate in the physics itself, so it holds whatever a jump can do. Any future secret that is meant to be out of reach should be sealed by a gate tile, never just set at a distance. **The boots secrets checked (pass 219):** the same doubt applied to the two Wing Boots secrets, so pass 219 ran real jumps at them. The Sky Steps' purse failed: its island stood four rows (64 px) over the island below it, and a plain running jump off that island's edge landed on it. The island now stands five rows up (80 px). That is past the 72 px apex of any single jump, a ceiling in the physics rather than an estimate of distance, and the thorn bulbs lining the wall beside it leave nothing to climb. `test_the_sky_steps_purse_needs_the_wing_boots` runs the jump both ways: without the boots it falls short, and with them it lands. The purse moved from 6,20 to 6,19 (`MOVED_PICKUPS`). Feather Hollow's Life Fruit was thought to hold on the same bound, its perch plank six rows (96 px) over the nearest plank. **Correction (pass 235):** a real jump disproved that too. The apex bounds the feet, but a pickup is touched by the head, 40 px above them. Running off the lower plank's west end, a plain jump lifted the head into the fruit in six of fourteen timings. The perch now stands a row higher (plank at row 7, fruit at 18,6, `MOVED_PICKUPS`). The fruit's cell begins 128 px over the lower plank, past the head's 116 px reach, and the Boots' second jump lands on the perch: their feet rise 124 px. `test_the_feather_hollow_perch_needs_the_wing_boots` proves it with the real controller. Without the Boots, none of fourteen running jumps off the plank takes the fruit, nor do jumps from the floor under it or leaps off the west wall with the Glove. With the Boots, a jump and a second jump off the plank take it. The reach checker's Boots envelope now allows a seven-row rise across two tiles (`Reach.BOOT_JUMP`), the same 12 px margin under the real feet rise that the plain jump keeps. So for a pickup, the bound to beat is the head's reach, not the apex. A height past the apex, with no wall to climb, is the one distance that is a real gate: across, the checker's short jumps always undersell a real one.

### 4.2 Critical path

1. Eolis: talk to the King, get 1,500 gold, buy a weapon. The Guru teaches saving. Enter the roots.
2. Trunk Hollows: Climbing Glove. Boss **Rokusutahn**. Restore the **Spring of Trunk** (first third of the fountain). Get the **Elf Ring**.
3. Tower of Trunk: Mattock. Boss **Zoradohna**. Elevator shortcut back to Eolis. Get the **Ruby Ring** (from Zoradohna, whose defeat frees the dwarves of Forepaw).
4. The Mist: Wing Boots (Victim side), Deluge (Mascon side, in either order). Bosses **Ripasheiku** (optional-feeling but required for the lantern key) and **Zorugeriru**. Restore the **Spring of Mist** (second third). Get the **Dworf Ring**.
5. Branches (Conflate): Elven Stride. Boss **Pakukame**.
6. Branches (Daybreak) and Spires: Thunder. Boss **Borabohra**. Restore the **Spring of Sky** (fountain full; Eolis celebrates). Borabohra drops the **Sky Key** that opens Dartmoor's upper gate.
7. Dartmoor: Black Onyx, Hour Glass. Boss **King Grieve** gives the **Demon Ring** and the **Dragon Slayer**, the sword he swallowed (pass 217). Boss **Shadow Eura** guards the Zenis gate.
8. Zenis: gauntlet, **The Evil One**. Ending.

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
| Ripasheiku defeated | Her lanterns go dark and she gives up the Lantern Key, which opens the way to the Spring of Mist and Zorugeriru. The key's light parts the bound fog (a pale wall of unmoving mist, legend `Y`, that tells you it wants a lantern) sealing the shaft above Lantern Landing; it parts for good and the key is kept. Beyond it the Veiled Rise climbs to the Victim Causeway, a spiked boardwalk dip on the road west to Victim, and past it Feather Hollow, where the Wing Boots wait on a plank below a perch whose Life Fruit only a second jump reaches. Her chapel's east door opens on the Marsh Road toward Mascon, where the Deluge scroll lies before a fire seal; the Scorched Hall waits behind it, the Dry Cistern past that, and past the cistern the Spring of Mist, Zorugeriru's lair |
| Zorugeriru defeated | Dworf Ring; the Spring of Mist's tanks stay full, and the spring on its shelf can be cleared; the arena's east door opens on the Windward Climb, where bounce-pods throw you up out of the Mist into the Branches (the Sunlit Bough, then Leaf Landing, a shrine on the elves' leaf road) |
| Spring of Mist restored | Fog lifts by half in the Mist (vision radius grows); drowned boardwalks resurface (legend `b`: one-way planks over the spiked dips of the Fog Cut, the Victim Causeway and the Mascon road (pass 148), nothing before); fountain 2/3 |
| Spring of Sky restored | The storm breaks: Daybreak's rain thins to a drizzle (Motes.SETTLES). Eolis festival: the fountain runs full, a piper plays in the plaza and Old Wena rejoices (pass 62). The Branches' wind currents turn and blow the other way (pass 92), carrying you into the Thicket Road's sealed wind niche. The final shop tier comes in on the sky road (pass 93, 10.2): the Dwarvish Broad Sword in Eolis and a Life Fruit in Daybreak |
| Bark Knight Captain defeated (optional, pass 178) | By Conflate's east door, Squire Ithil had warned of the Thorn Yard's Captain and that fire was the one thing his bark feared; he now speaks of the yard won back (`conflate_squire`, then `conflate_squire_glad`) |
| King Grieve defeated | Dartmoor drains; Sunken Spring entrance opens. **The water, as built (pass 259):** until then Dartmoor's drowning was only in what people said: no hall had water in it. Now the Flooded Hall and the Drowned Nave stand in still water (`tide: 19`, `Tide`): a tile deep across the floor and filling the spike pits, translucent so the spikes still show, with a pale breathing surface. Wading splashes (the steps sound `wade`, their own slosh since pass 262; `mud` until then). It is not deep enough to swim, and it neither slows you nor hides a hazard. Pass 272 holds all three: in the Flooded Hall's water the run reaches full speed, a jump rises its full height, you never swim, and the spike pit under the surface still hurts (`test_wading_neither_slows_nor_floats_nor_hides_the_spikes`). Once he is at rest both halls are dry, with a teal tide mark where the surface stood and silt on the floor. The Upper Gate-Hall stays dry, since its sign already says the water stood there once. The Flooded Hall's sign has a line for after. `test_dartmoor_drains_when_king_grieve_is_at_rest`. Screenshots: `/mnt/project-files/pass-259/flooded_hall.png`, `flooded_hall_drained.png` |
| Clockwork Alpha defeated (optional, pass 178) | Once King Grieve's fall wakes the Drowned Market, Houndkeeper Brand, who wound the king's hounds for forty years, tells of the Alpha still pacing its den under the kennels; once it is wound down he sleeps easy and blesses the Life Fruit it kept. A room's person can now name several conditions, space-separated, all of which must hold (`Room.flags_hold`: `boss:king_grieve !boss:clockwork_alpha`) |
| Marsh Hag Matriarch defeated (optional, pass 179) | In Mascon, Reedcutter Siobhe stands by the east door and warns of the Matriarch in the mire past it, and of how her brother learned to break a hex; once the Matriarch sinks for good she can cut reeds in the east mire again |
| Evil One defeated | Post-game: the Tree blooms (built pass 141, below). ~~Palette shift to spring colors~~ waits for the art polish phase. ~~All enemies respawn as "remnants"~~: foes already return when you re-enter a room, and they are the Tree's own creatures, so they stay as they are for the 100% cleanup |

**Every guardian's hall answers its fall (pass 267):** most arenas' signs already read differently once their guardian was beaten. The Trunk's chewing stops, the Spires' nest is empty, and the Hound's chain has run down. Seven still spoke of theirs as alive:
- the Sunken Chapel's lanterns "still burn" after Ripasheiku's go dark, and the landing above it still said something sings there;
- the crown-leaf still grew "nothing but the Bloom";
- the Thorn Yard's knight still kept the watch;
- the Roost still told you to wake the conduits and call the storm down;
- the Wellspring's Warden still "has never let anyone near it";
- the Gate of Zenis and the Throne Hall did not change;
- the Foreman's doorway still spoke of its golem at work.

Each now has a `[boss:<id>]` line that reads once its guardian is beaten (Old Cormac's word on the chapel is in the past tense too). `test_every_guardians_hall_answers_its_fall` holds every sign in an arena outside Zenis to a word for after, and reads the doorways before and after. Zenis's halls are left as they are, since the ending follows them.

**The spring keepers (pass 249):** in the original a man stood before each of the three springs, and the spring woke with him: an Elixir for the Spring of Trunk, a sleeper woken with water at the spring in the sky. The remake's springs stood empty, cleared with a press of Up and no one to say what they were. Each now has its keeper, standing beside it (`trunk_keeper`, `mist_keeper`, `sky_keeper` in `data/npcs.json`, each with a `_glad` self once the spring flows):
- **Odran**, a dwarf of the Trunk, at the Spring of Trunk from the start. His father swore it took an Elixir to wake a spring (the original's riddle); it takes someone to clear the spout. Once it flows he names the two springs higher up and the keepers waiting at them.
- **Ilka**, of Victim, at the Spring of Mist once Zorugeriru is beaten (no one stands in the fight), who watched the coil from the cistern stair. Once it flows, the fog thins, and Ilka warns that the sky's keeper is a sleeper.
- **Arel**, an elf, at the Spring of Sky, who slept while the roc sat on it (the original's dozing keeper), and once it flows points down through the clouds to Dartmoor.
Each has a word once the Tree blooms. Deviation: the keepers don't wake the springs themselves, and no spring asks for an Elixir. Clearing a spring stays the player's act (a press of Up), so the critical path asks for no gold. `test_every_spring_has_its_keeper` holds where each keeper stands, and when.

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
- **Mist curtains:** shimmering vertical fog with a faint elven rune (Elven Stride). Built in pass 216 as the **elven veil** (legend `|`, `StrideVeil`), because the name "mist curtain" had gone to the Mist's bound fog (`Y`, the Lantern Key). The veil is a column of silver-green strands over a soft teal body, with a pale elven rune that breathes. It sits on its own collision layer (`Player.LAYER_VEIL`), which the player's mask drops while dashing, and keeps dropped until the player is clear of it (`Player.passes_veils`), so a dash that ends inside lets you out. Walking or jumping into it, it is a wall. Ground and air dashes both pass it, and it flares with a rush and two glassy notes (`veil`). Without the Stride, touching it says "An elven veil. Only a warden's stride passes it." Only the player is stopped, so foes are kept out of veiled spaces. The reach checker treats it as solid until the Stride is found. Tests: `test_an_elven_veil_lets_only_a_dash_through` and `test_the_warden_cache_needs_the_stride`.
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
| Health (HP) | 5 masks of 20 HP (100) | 14 masks (280) | Life Fruit: 2 fruits = +1 mask (18 fruits: 13 in the rooms, one at each of the 4 grocers, 1 from the Clockwork Alpha) |
| Magic (MP) | 60 | 220 | Mana Dew: each +10 (16 dews: 9 in the rooms, one at each of the 4 grocers, 3 from Ripasheiku, the Bark Knight Captain and the Marsh Hag Matriarch) |
| Red Potion flask | 2 charges, heals 40 HP | 6 charges, each still 40 HP | Potion Shards (3 shards = +1 charge; 9 shards) and Deep Pockets (+1). Pass 321: this row had said 5 charges healing 70 HP, though nothing ever raised the heal and the shards and Deep Pockets make 6. Pass 243: the Trunk and the Tower had grown 18 shards, enough for 8 charges; nine (three in the Trunk, six in the Tower) became chests of gold at the same cells, so a save that took one finds the chest already open |
| Attack | Weapon base | | Weapons, smith upgrades, skill tree |
| Defense | Armor base | | Armor, shields |

HP is shown as masks (chunks), so damage is readable at a glance, while the math uses HP for fine tuning.

**The Red Potion (deviation, pass 321):** the original's manual says of it: "It will completely restore the hero's power." Each potion was one item, bought at a shop and drunk whole. The remake's Red Potion is a flask of charges, each a fixed 40 HP that nothing raises, which a Guru's rest refills. A full heal on demand would make every fight up to the last mask safe and make the masks themselves meaningless; a fixed sip that takes 0.7 s and is lost to a blow keeps a drink a choice made in a lull, and the flask's growth (Potion Shards, Deep Pockets) is a reward for exploring that a stack of bought potions would not be. The full restore the original's potion gave is kept where it belongs: the Guru's rest and the Elixir.

### 5.2 Weapons and armor (Faxanadu tiers)

| Slot | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------|--------|--------|--------|--------|
| Blade | Short Sword (start, fast, short; called the Hand Dagger before pass 184) | Long Sword (400 g) | Dwarvish Broad Sword (2,800 g, two-handed, slow, huge arc; built pass 93 as the Giant Blade, renamed pass 186: slash 17, heavy 32, reach 16) | Dragon Slayer (King Grieve's, given up when he falls, as in the original (pass 217); built pass 80: slash 18, heavy 30, reach 12) |
| Armor | Leather (200 g) | Studded Mail (1,100 g) | Full Plate (4,200 g) | Battle Suit (secret: the Drowned Warden, 60% less damage) |
| Shield | Small Shield (150 g; wards 20% of sorcery, pass 225) | Large Shield (900 g; wards 30%) | Magic Shield (3,600 g, reflects small projectiles on parry; wards 40%) | (none: the Battle Helmet has its own slot since pass 185) |
| Helmet | Battle Helmet (secret: +1 mask, 10% less damage, wards 20% more sorcery) | | | |

**The original's gear, and what changed (pass 193).** The original sold twelve pieces of gear: four weapons, four armors and four shields. All twelve are in the remake. Where one changed, this table says how and why. `test_the_originals_twelve_pieces_of_gear_are_all_here` keeps it true: each original name must be an item, or a row here naming the item that took its place, and each id in `GameState.RENAMED_ITEMS` must have a row.

| Original | In the remake | Changed in | Why |
|----------|---------------|------------|-----|
| Hand Dagger | Short Sword (`short_sword`, from `hand_dagger`) | pass 184 | Sean: every swing of it is a slash, so it reads as a short sword. The dagger idea became the thrown Rune Dagger. |
| Giant Blade | Dwarvish Broad Sword (`dwarvish_broad_sword`, from `giant_blade`), two-handed | pass 186 | Sean: a name with a maker, and two hands with no shield, so its weight is a real trade. |
| Battle Helmet | Battle Helmet, in its own Helmet slot | pass 185 | Sean: worn as a shield, it cost you the Magic Shield's parry. Now it adds a mask and 10% less damage on top of any shield. |
| (none) | Rune Dagger, a thrown tool beside the blade | pass 184 | Sean's idea: a ranged answer before the spells. It is not a weapon tier and takes no temper. |

**Shields ward sorcery (pass 225).** The original's manual gives a shield one job: it resists enemy magic (Small 50%, Large 75%, Magic 90%, and the Battle Helmet "intercepts almost all"). The remake's shields guarded and parried but did nothing against a hex you didn't block. Now a worn shield also wards a foe's sorcery, guarding or not: Small 20%, Large 30%, Magic 40%, and the Battle Helmet adds 20%, to at most 60% (`ward` in `data/items.json`, `Player.magic_ward`, `GameState.MAX_WARD`). The shares are kept under the original's so that guarding, a parry and the damage sheet (5.5) still matter. Sorcery is the group `Player.MAGIC`: the Marsh Hags' and the Matriarch's hex (`MireGrasp`), Shadow Eura's bolts, King Grieve's crystal shards and the meteor core's beam. Blows, bites, breath, storm and thrown things are not sorcery. A shield on the back of a two-hander wards nothing; the helmet still does. Nor does a shield taken off for the Rune Dagger (pass 313): the original had no thrown dagger, and its shield, once bought, was always on the arm and always resisting magic. In the remake the off hand holds a shield or the dagger (Sean's rule, below), so taking the dagger gives up the shield's ward along with its guard and parry, and only the helmet's ward stays. That is a choice the original never asked for, kept honest by the Equipment page's Ward figure. Test: `test_a_shield_wards_a_foes_sorcery`.

The other nine (Long Sword, Dragon Slayer, Leather Armor, Studded Mail, Full Plate, Battle Suit, Small Shield, Large Shield, Magic Shield) keep their names and their place. The original replaced gear as you bought it; the remake keeps it (pass 186, above).

**The original's relics, the Pendant and the Magical Rod (pass 201).** The original hid two more finds that sold nowhere, and until pass 201 the remake had neither. Both are now found once and kept, laid by `prop:` lines and counted as treasures (`Room.FOUND_PROPS`); their numbers live in `combat_tuning.gd` (Relics).

| Relic | Where (original) | Where (remake) | Effect |
|-------|------------------|----------------|--------|
| Pendant | the end of the Tower of Suffer, in a corner of its guardian's room, easy to miss | the far corner of the Matriarch's Mire (`mist/hag_mire`, 37,16), the Mist's optional guardian's room | every blade hit lands a tenth harder (`pendant_mult` 1.1, through `Player.blade_mult`) |
| Magical Rod | Conflate, up a ladder on the right of the town | Conflate's high plank (73,7), up a new ladder at the town's east end | Deluge bolts strike half again as hard (`rod_deluge_mult` 1.5: 12 to 18, as the original's 6 to 9) |

Deviation: the original's Pendant was meant to raise attack, but a slip in its code made it lower it, so players learned to leave it behind. The remake gives it the effect it was meant to have, kept small (10%) so the damage sheet (5.5) still holds without it. The Rune Dagger's sting is not a blade hit and takes no Pendant. Held by `test_the_pendant_and_the_magical_rod` and `test_the_pendant_and_the_rod_can_be_reached`.

Each blade has its own swing speed and reach, so a weapon change is a play-style change, not just a number. The dwarf smith in Forepaw upgrades each blade twice (+15% each) for gold plus Meteor Shards. (Built: Hrothgar's Forepaw Forge sells Temper Blade I for 700 g and II for 1,600 g, per blade, so a new blade starts untempered.)

**Meteor Shards (built pass 140):**
- Splinters of the meteor, flung down the Tree when it struck the crown: a black rock heel with three magenta crystal spurs and a cyan light beating in the crack between them. Legend `(`.
- Temper Blade II costs one besides its gold (`"shards": 1` on the shop entry); Temper I is gold alone. Without one the forge shows "Needs shard", and the temper's line says how many you carry. A shard is spent when the smith folds it in.
- Five lie in the world, one more than there are blades, so one can go to a blade you later put down: on the Crown Lookout above the potion shard (Tower, near the smith), above the Scorched Hall's platform (the Mist), in the Sunlit Bough's hidden pocket (Branches), in the Broken Shrine's hidden pocket (Daybreak), and at the end of a Meteor Rise shelf (Dartmoor). They count as treasures for completion and Treasure Sense.
- Carried in `GameState.data.meteor_shards`.

**Dwarvish Broad Sword (built pass 93 as the Giant Blade; renamed and made two-handed in pass 186):**
- **Two-handed (Sean, pass 186):** while you hold it, your shield stays on your back. Block does nothing, so there is no guard, no parry, no Riposte and no Magic Shield reflect (`"two_handed": true`; `refresh_stats` clears `has_shield`). The shield's layer is never drawn, since the block pose never plays. To pay for that, it hits harder than it did: slash 17 and heavy 32 (was 15 and 28), about 13 damage per second of swinging against the Long Sword's 11.
- No room or fight needs a parry. Every parryable attack can also be dodged or outranged, and reachability never uses one. You can also swap back to a one-handed blade from the Equipment page at any time.
- 16 px more reach than the Short Sword.
- Its side slash sweeps 20 px taller, so it covers you from head to heel and catches fliers and crawlers a plainer blade misses (`arc` in `data/items.json`).
- Every swing takes 30% longer to recover (`swing` 1.3). Commit to a cut and space your foes. A player who dislikes the slow swing keeps the Long Sword and can swap back (Equipment, below).
- It is drawn two pixels broader, with a larger smear.
- Eolis Arms sells it for 2,800 g once the Spring of Sky is restored (10.2). Its id is `dwarvish_broad_sword`; a save naming `giant_blade` is carried over through `RENAMED_ITEMS`, tempers and all.

**Equipment: gear is kept (Sean, pass 186):**
- Every blade, armor, shield and helmet you buy, find or win goes into `GameState.data.gear` and is put on at once (`GameState.obtain_gear`). Nothing is thrown away. (The original replaced the slot; this changes it so a weapon is a choice, not only an upgrade.)
- The pause menu's **Equipment** page lists your gear by slot (Blades, Armor, Shields, Helmets), lowest tier first, marking what you wear. Choose an item to put it on (`GameState.wear`). Choose armor, a shield or a helmet you already wear to take it off; you always hold a blade. Tempers stay with each blade.
- **Numbers and the cloak (pass 189):**
  - Each blade's detail on the Equipment page, and on a blade shop's shelf, gives its numbers as you would swing it, with tempers in (`Menus.blade_numbers`), e.g. "Cuts 17, heavy 32, reach +16, 30% slower". Before this, the only way to learn what "slow" or "hits harder" meant was to buy the blade and try it.
  - The page ends with a **Cloak** section: Warden Green, every dye bought or won, and the Lord's Gold once it is yours (`Menus.cloak_dyes`). Choose one to put it on anywhere (`Menus.choose_equipment`), as gear is. Ilse's shelf still sells the dyes and puts them on too.
  - Every detail fits the menu's three-line box, which a test checks with all gear owned. Two item texts were cut to fit: the Broad Sword's, and the Magic Shield's, which had run to four lines under a two-hander since pass 186.
- **What you wear, added up (pass 229):** armor and the helmet stack by what each lets through (the Battle Suit under the Battle Helmet stops 64%, not 70%), and the ward (5.2, pass 225) is the shield's plus the helmet's, capped at 60% and lost to a two-hander. None of it showed anywhere, so the page's footer now gives the totals as `refresh_stats` works them out, e.g. "Armor 64%   Ward 60%" (`Menus.worn_totals`), and the subtitle says what each means ("Armor stops blows; a ward turns sorcery"). A shield slung for a two-hander says it gives no guard or ward. Test: `test_the_equipment_page_adds_up_what_you_wear`. Screenshot `--wear=A,B` owns and wears gear for it.
- A shop shows only what you have as Owned. A lower tier you never bought can still be bought.
- Saves from before pass 186 keep what they wore, plus the Short Sword.
- The worn armor still decides the secret ending (the Battle Suit, 11) and the hero's body set; the blade in hand still decides whether the Evil One's heart can be cut (the Dragon Slayer).
- With the paper-doll setup, each slot is its own layer, so a swap changes the look at once.

**The Inventory page (pass 205):** the Equipment page shows only what you wear. A found ability, spell, relic, ring or key was known only by the banner at its pickup, so a player who missed the Pendant's line had no way to learn it was in the pack. The pause menu gains **Inventory**, under Equipment. It is read only, and lists what you have under headers, in a fixed order: Abilities (Climbing Glove, Mattock, Wing Boots, Elven Stride, Black Onyx, Hour Glass, Rune Dagger), Spells (the readied one marked Ready), Relics (Pendant, Magical Rod), Rings with how many of the four you hold, Keys with their counts, and the Potion, Mantra and Meteor Shards you carry toward their next whole. Each row's line says what the thing does: the pickup's banner line, or for the Mattock the Foreman's, and for Fire and Tilte their scroll's. Nothing you lack is shown, so the page spoils no find, and a new game shows "Nothing yet". `Menus.inventory_rows`. Test: `test_the_inventory_page_lists_what_you_have_found`.

**Supplies and charts on the Inventory page (pass 269):** the page listed abilities, spells, relics, rings, keys and shards, but nothing you carry to use, and no charts. An Elixir showed nowhere at all once bought. Only the pause menu's "Use Ointment" row counted Ointments. Charts showed only as dimmed rooms on the map, so nothing told you which zones were still uncharted. Now a **Supplies** group lists Ointments and the Elixir with how many you carry and what each does. A **Charts, n of 8** group lists each chart you hold, and a greyed line counts those not yet charted ("The towns' cartographers sell the rest."). `test_the_inventory_lists_supplies_and_charts`. Screenshot: `/mnt/project-files/pass-269/inventory.png`.

**Short Sword (renamed pass 184):** the starting blade was called the Hand Dagger, but every swing of it is a slash, so Sean renamed it. Its id is `short_sword`; a save that still names `hand_dagger` (equipped, or in its tempers) is carried over by `GameState.sanitize` through `RENAMED_ITEMS`, tempers and all.

**Rune Dagger (built pass 184):** an elven throwing dagger bound by a rune, a tool beside the blade rather than a blade (Sean's idea, pass 184). It answers the one gap in the kit before the spells: a way to reach a hornet or a turret without spending magic.
- **Where:** on the floor of the Trunk's Hornet Gallery, by the entrance sign (legend `}`, `levels/trunk/hornet_gallery.room` at 8,21). The room teaches it: three hornets overhead and a Sap Spitter across the thorns. Since the dagger goes straight into a shield's hand here (the off hand, below), the room must be clearable with it alone, so each foe is in a throw's 160 px from ground with no thorns: straight up for a hornet, along the floor for the spitter. Two hornets hung 161 to 162 px up, a throw that only grazed them; pass 315 lowered each by a tile (to 8 and 11 rows down). `test_the_hornet_gallery_can_be_cleared_with_the_dagger` throws at each foe from its nearest safe spot.
- **The off hand (Sean, 2026-10-31):** the dagger is flicked from the left hand, the shield's arm, so the off hand holds a shield or the Rune Dagger, never both. The Equipment page's Shields section is now **Off Hand**: **Rune Dagger** first once found, which takes the shield off, then each shield owned. With a shield worn, Throw does nothing; with the hand free, there is no guard, parry or ward from a shield. Found while a shield is worn, the dagger goes straight into the hand (the shield to your back, as the banner says) so the Hornet Gallery that teaches it plays at once. It is a build choice: no boss needs a parry (5.2), and none needs the dagger. `GameState.offhand_free`, `Menus.OFFHAND_DAGGER`. Tests: `test_the_off_hand_holds_a_shield_or_the_rune_dagger`, `test_the_hand_dagger_is_the_short_sword_and_the_rune_dagger_is_found`.
- **Button:** Throw, on B or ; on the keyboard and the right bumper (RB) on a pad. Dash keeps the B button and the right trigger; the bumper it gave up was its third binding. Hold Up to throw it straight up.
- **Flight:** 420 px/s, point first, for 160 px (about ten tiles). It strikes the first foe it meets for 6, scaled by Keen Edge like the blade (`melee_mult`), with a 0.03 s hit-stop. Walls and gates stop it; it passes up through one-way planks. It lights the fog as it flies.
- **Return:** when its flight ends, on a foe, a wall or at the end of its reach, it breaks into motes of rune light and reforms at your hip 0.4 s later with a soft chime (`dagger_return`). One flies at a time. It costs no MP and is never lost; left in another room, it comes home all the same.
- **Not while** dashing, drinking, guarding, swinging, reeling from a hit or on a ladder. A press in the last 0.15 s before you can throw is held and goes the first frame you can, as Attack is (pass 192, `CombatTuning.throw_buffer`).
- **A sting, not a blow (pass 188):** it hurts what it hits, but what a blow does to a guard stays the blade's (and fire's). In bark (a Bark Knight, the Captain) it lands the bark's quarter and splits no plate; it stings a hexing Marsh Hag or the Matriarch without breaking the spell; and the bound Heart turns it even with the Dragon Slayer in hand. Elsewhere it is an ordinary hit from where it flew: Shadow Eura's false double still bursts, a Lantern Widow's lantern still breaks, armor still halves a hit on the front. `Enemy.take_throw` sets `Enemy.thrown` while the hit lands, and each guard reads it in `_modify_damage`.
- **Gates nothing.** Every route it could help with already has another answer, so reachability does not change and it is never required. It is not temperable (it is not in the blade slot), so the five Meteor Shards still cover the four blades.
- **Drawing:** code-drawn, in flight and as a pickup. The hero sheet is drawn empty-handed for a paper-doll setup (Sean, pass 184), so the blade and the dagger are separate layers over the body, never baked into it.
- Built in `scripts/combat/rune_dagger.gd` (`RuneDagger`) and `Player._try_throw`. Tests: `test_combat.gd` (flight, hit, one at a time, no MP, return, Up, walls and reach) and `test_systems.gd` (the rename, save migration, bindings, the pickup).

**Battle Helmet (built pass 118; its own slot since pass 185):**
- A helmet, in the equipment's fourth slot (`equipment.helmet`), found and never sold. It lies in a hidden pocket at the meteor's Threshold (`zenis/threshold`), behind fake wall west of the shrine (`secret: 1, 17, 6, 19`), so the Black Onyx's seam shows the way in. It is laid by `prop: x, y, battle_helmet`.
- Touch it and it goes straight on your head, like the Dragon Slayer into your hand. Your health fills to the new top. Your shield stays in hand.
- It is worth one more mask (+20 HP, `hp` in `data/items.json`) and takes 10% off every hit (`defense` 0.1). It does not guard or parry. The mask comes from the gear, not the base stat, so a save keeps it through `refresh_stats`.
- **Stacking with armor:** the helmet and the armor each cut what the other lets through, so the cuts multiply rather than add: damage taken is `(1 - armor) x (1 - helmet)`. Under the Battle Suit (60%) it lets 0.4 x 0.9 = 36% through (64% less damage); under Leather (15%), 76.5%. With no armor it is 10%. Damage taken is still at least 1.
- **Why its own slot (Sean, pass 185):** in the shield's slot it replaced the shield, so players with the Magic Shield had to choose between the shield's parries and the helmet's mask. As a helmet it adds to every build.
- **Old saves:** a save that wore it as a shield (`equipment.shield == "battle_helmet"`) wears it as a helmet, and its hand gets the Magic Shield: the helmet had guarded and turned shots exactly like the Magic Shield, and while it was worn every shield showed as owned in the shops, so nothing better could have been bought (`GameState.sanitize`).
- **Drawing (paper-doll):** the hero's sheets are drawn bare-headed. The helmet is its own layer: Sean's pixel helmet (his Autosprite pixel conversion of the right-side reference, `armor/battle-helmet/pixel-right.png`, kept at its own pixel grid in `art/battle_helmet/right.png`), shrunk by `tools/art/helmetgen.py` to 16 sheet px wide (about the bare head's width at the 2x density: Sean found 19 too big), outlined and written to `assets/sprites/battle_helmet.png`. `PlayerVisual._draw_helmet` sets it on the crown of the head, mirrored with the facing. It replaced the pass-185 code-drawn helmet, which Sean found too round and shiny. `autosprite_import.head_point` finds the crown in each frame's pixels on import (the cloak masked out, a blade or fist opened away, a crown that jumps over both neighbours dropped back), so every frame of `player.json` and of the five body sets carries a `head` point (manifest flag `"head": true`).

**Magic Shield (built pass 91):**
- It guards 70%, like the Large Shield.
- A parry also catches small shots no other shield can parry: Sap Spitter globs and Meteor Slug globs (group `small_projectile`). It catches Pakukame's seeds too, which any shield can parry.
- The caught shot flies back as a mote of shield light, glowing with the colour of what it caught (`ReflectedShot`). It goes at 340 px/s toward the nearest foe within 260 px on the side you face, or straight ahead, and strikes the first foe it meets for 16.
- Feathers, gears and shadow bolts already turn back on any shield's parry, and still do.
- A caught sap glob leaves no puddle.

You start with no shield: Block and parry come with the Small Shield, the first purchase most players make in Eolis. Gear values live in `data/items.json`:

| Item | Values |
|------|--------|
| Short Sword | 8 light / 14 heavy |
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
- **Thrust (Blade skill, pass 149):** hold Attack past 0.4 s and let go for a charged lunge (see 9).
- **Parry (shield):** tap Block within 0.12 s of a hit: no damage, 140 ms hit-stop, enemy staggered. Holding Block reduces damage by the shield's percent but drains MP.
- **Guard break (pass 242):** a guard held with less MP than a blow costs used to fail in silence: the shield stayed up in the guard pose, at guard speed, and the blow landed whole with only the hurt yelp, so it read as a guard that did nothing. Now it breaks: a dry crack of splitting wood over a dropping knock (`guard_break`, never the held guard's `guard`), a burst of guard dust and a shake. The blow still lands whole, and the shield stays down until Block is let go and raised again (`Player.guard_broken`), so you never hold up a guard you can't pay for. `test_a_guard_with_no_mp_breaks_and_drops`.
- **Spells:** one equipped spell on the Spell button, cycled with the Next Spell button (the shoulders are taken by Throw and Block, so it is the right stick click on a pad; changed in pass 57). MP regenerates slowly and on melee hits.
- **Damage taken:** 0.8 s invulnerability, 0.15 s hit-stop, knockback, screen flash. The flash is a red glow at the screen's edge that fades in about 0.4 s; it never covers the middle, and the Flashes option scales it (built pass 98). Every hit yelps (`hurt`). A blow that costs a whole mask (20 HP) or more after armor adds a low body thud and a crunch of grit under it (`hurt_heavy`, pass 198). Since passes 194 and 196 the deep zones' foes and guardians land such blows through par armor while the Trunk's do not, so you hear the difference a zone makes, and whether your armor keeps up.
- **Low health (built pass 98):** at one mask (20 HP) or less, a muffled heartbeat sounds every 0.85 s and the screen's edge pulses faintly red in time with it. It stops the moment you heal above a mask.

**Starting combat values** (in `scripts/player/combat_tuning.gd`). Every row is held to this table by `test_the_starting_combat_values_match_bible_5_3` (pass 202; until then about a third of the rows were only read back from the tuning by the tests that played them), and each has a play test. Since pass 330 `test_every_combat_number_is_written_in_bible_5_3` also reads this section: every number in the tuning must be written here, and each spell's row must name its own cost, damage and speed from `scripts/combat/spells.gd`. Until then only Deluge had a row, and Thunder's, Fire's, Tilte's and Death's numbers were held by nothing but tests that read them back from the code:

| Value | Setting |
|-------|---------|
| Light hit / heavy third hit | 8 / 14 damage (Short Sword) |
| Combo window, cooldowns | 0.40 s to chain; 0.20 s, 0.20 s, 0.38 s after hits 1 to 3 |
| Attack buffer | 0.15 s |
| Throw buffer (pass 192) | 0.15 s: a Throw pressed while you can't throw yet (a swing or a dash still out, a drink, the Rune Dagger still reforming) goes the first frame you can |
| Parry window | 0.12 s from the Block press; 140 ms hit-stop, enemy staggered 1 s, +6 MP |
| Guard (Small Shield) | 50% less damage, 8 MP per blocked hit, 40% walk speed; with less than 8 MP the guard breaks (pass 242) |
| Knockback when hit | 160 px/s back, 220 px/s up, 0.18 s control lock |
| Low health | 20 HP or less: heartbeat every 0.85 s, red edge pulse |
| MP | 60 max, +2/s, +4 per melee hit on an enemy |
| Red Potion | 2 charges, +40 HP, 0.7 s to drink, cancelled (charge kept) if hit |
| Deluge | 15 MP, 12 damage, 300 px/s |
| Thunder | 18 MP, 16 damage, 380 px/s |
| Fire | 20 MP, 18 damage in the burst, thrown at 170 px/s across and 150 px/s up |
| Tilte | 22 MP, 14 damage, homing; with Tilte Swarm (9) three orbs of 10 for one cast's MP |
| Death | 40 MP, 36 damage to every foe the ring passes; a guardian takes 18 |
| War Glove (rare drop, 7) | blade hits x1.5 for 15 s |
| Thrust (skill, 9) | hold Attack 0.4 s, let go: heavy hit x1.5, a 320 px/s lunge for 0.16 s on the floor, 0.35 s cooldown |
| Gold coins | Magnet after 0.4 s within 100 px |
| Relics (pass 201, 5.2) | the Pendant: blade hits x1.1; the Magical Rod: Deluge x1.5 |
| Death (5.4) | 60% of the purse dropped where you fell (on the last safe ground if that was not the room's own floor) |
| Spikes and thorns (pass 282) | 20 damage (one mask) before armor; you are set back on the last safe ground |
| Casting (pass 282) | 0.35 s between casts; a press made sooner casts nothing and is not saved |
| Bread / great loaf (pass 282, 7) | +15 HP / +40 HP (the loaf: a slain Naga's). A slain Bog Myconid always leaves bread (pass 289) |
| Drops (pass 290, 7) | each kill rolls once: bread 8%, a mana orb 10% (+12 MP), poison 7% (Tower foes on, `poison_drops`; skull-marked, sickens you), a rare item 2.5% (the War Glove 60%, else an Ointment). A foe with a sure drop (the Naga, the Myconid) leaves it instead of rolling. Taking any drop shows a toast that says what it gave (pass 301: the mana orb was the only one that showed nothing, so its +12 MP was nowhere a player could read it) |

### 5.4 Death and recovery

On death you return to the last Guru or shrine. You drop **60% of carried gold** as a glowing purse where you died. Reach it to recover it; die first and it is gone. XP and items are never lost. (Deviation, pass 297: in the original you also start again at the last Guru's House you visited and keep every item, but "his experience will be the lowest point for that rank and the amount of money he has when he recovers will also be determined by his rank" (the NES manual, https://archive.org/download/NESManuals/Faxanadu%20%28USA%29_text.pdf). So a death undid a rank's progress and took a share of gold no skill could win back. The remake keeps the restart and the items, never takes experience, and makes the gold a purse you can walk back to: the loss still stings, but it can be undone by playing well.) The purse is part of the save (`data.purse`: its room, where it lies and the gold in it, as `value`), so quitting and loading leaves it waiting. Until pass 250 loading asked for the gold under another name (`gold`) and threw every purse away, so a death followed by a load lost the 60% for good; a save that names it `gold` is still read. `test_a_dropped_purse_survives_a_save_and_load`. **Ground you can come back to (pass 293):** the purse is left where you fell only when you fell on the room's own floor. Killed in the air, on footing that can go (6.13) or by a hazard, you leave it on the last safe ground you stood on (`Player.safe_position`). It had lain wherever the blow found you. Killed in the Bloom's gap or Rokusutahn's pit, it lay in the pit, and the next time the room loaded the floor was whole again around it: the gold was buried in the tiles for good. `test_a_death_in_a_torn_pit_leaves_the_purse_beside_it`. **A purse on floor that tears (pass 300)** moves with the set-back spot to the nearer tile beside the new pit. Left on the leaf from a death earlier in the fight, it had hung over the thorns, and taking it back cost a mask. `test_a_purse_on_torn_leaf_moves_beside_the_gap`.

### 5.5 Damage balance sheet (pass 194)

The rubric (15.3) asks for a damage balance sheet within targets. Until pass 194 there was none, and drawing it up showed the curve upside down: a Rot Dwarf in the Trunk swung for 20, a Shade Knight in Dartmoor thrust for 18, and by then Full Plate took 45% off. Against the kit you carry there, the deep zones' worst blows cost half a mask where the Trunk's cost nearly one, while your health had doubled.

**Threat.** Every blow a foe or a foe's shot lands is multiplied by its zone's threat (`CombatTuning.ZONE_THREAT`, applied in `Player.receive_attack` through `Room.threat`). Since pass 196 a boss's arena takes its zone's threat too (below). A world hazard such as a fire seal stays at 1. Eolis, the gym and the Guru Trials are off the sheet and stay at 1.

| Zone | Threat | Par kit (the critical path's shops and finds by then) | Par slash | Hardest blow through par armor | Slashes to fell its foes |
|------|--------|------|-----------|------|------|
| Trunk | 1.0 | Long Sword, Leather | 11 | 17 (Rot Dwarf swing, a Hornet's touch) | 2 to 4 |
| Tower | 1.0 | Long Sword, Leather | 11 | 20 (Iron Dwarf slam) | 2 to 6 |
| Mist | 1.4 | Long Sword +1 temper, Studded Mail | 13 | 18 (Drowned Dwarf slam, Lantern Ghost lunge) | 2 to 4 |
| Branches | 1.5 | Long Sword +1, Studded Mail | 13 | 21 (a Hornet's touch) | 2 to 5 |
| Daybreak | 1.6 | Long Sword +2, Studded Mail | 14 | 22 (a Hornet's touch) | 2 to 4 |
| Dartmoor | 2.0 | Long Sword +2, Full Plate (the Dragon Slayer past King Grieve, since pass 218) | 14 (18) | 20 (Shade Knight thrust) | 3 to 4 |
| Sunken Spring | 2.0 | Dragon Slayer, Full Plate (it lies past King Grieve; pass 218) | 18 | 20 | 2 to 4 |
| Zenis | 2.0 | Dragon Slayer, Full Plate (foes corrupted, 1.5x health) | 18 | 26 (Iron Dwarf slam) | 2 to 6 |

**Targets**, held by `test_the_damage_balance_sheet_stays_within_its_targets`, which reads every room's foes, their `*DAMAGE` and `*CONTACT` constants and their shots:
- Each zone's hardest ordinary blow costs 0.75 to 1.4 masks (15 to 28 HP) through its par armor, and no foe anywhere hits harder than that.
- Every foe falls in 2 to 7 slashes of the par blade (heavy finishers, spells and skills only shorten it).
- Threat never falls along the critical path.

So a hit costs about a mask from the first root to the meteor, and what grows is your health (5 masks to 14): you get sturdier as you go, but no zone's foes go soft. Players ahead of par (the Broad Sword in Dartmoor, the Battle Suit and Helmet) feel it as power, and players behind it (Leather in Dartmoor: 31) feel the push to visit the smith and the armorer.

**The shield on the sheet (pass 226).** Since pass 225 a shield wards a foe's sorcery (5.2), but the sheet still weighed every blow through armor alone. The par kit now names a shield: the Small Shield in the Trunk and the Tower (Eolis, 150 g), the Large Shield from the Mist (Apolune, 900 g), the Magic Shield from Dartmoor (Daybreak, 3,600 g). A sorcerous blow (a script that joins `Player.MAGIC`) is weighed as the game takes it: threat, then the ward, then the armor. That showed the Marsh Hag Matriarch's hex, her whole threat, falling to 8 through the Large Shield and Studded Mail, under the guardians' floor of 10 (0.5 masks). The hex (`MireGrasp.DAMAGE`, the hags' too) is 16 now, where it was 12: 11 through the par kit, and 15 with no shield. The other sorcery stays as it was: Shadow Eura's bolts and King Grieve's shards were never their hardest blows, and the core's beam still costs 10 through the Magic Shield and Full Plate.

**The guardians (pass 196).** Pass 194 left the arenas at 1, meaning to tune each boss on its own. Drawing up their sheet showed that this made the deep guardians softer than the corridors leading to them. Through Full Plate, King Grieve's worst blow cost 12 and the Evil One's cleave 11, while a Shade Knight in Dartmoor's halls landed 20. Pass 196 lets each arena take its zone's threat (`Room.threat` has no boss exception, and `Player.receive_attack` scales a boss's blows and shots like any foe's). Hardest blow through the zone's par armor, after threat:

| Zone | Guardians (hardest blow) |
|------|--------------------------|
| Trunk | Rokusutahn 17 |
| Tower | Zoradohna 20, the Foreman 19 |
| Mist | Ripasheiku 20, Zorugeriru 15, the Marsh Hag Matriarch 11 (her hex, through the Large Shield's ward) |
| Branches | Pakukame 25, the Bark Knight Captain 21 |
| Daybreak | Borabohra 25 |
| Dartmoor | King Grieve 24, the Clockwork Alpha 22, Shadow Eura 22 |
| Sunken Spring | the Drowned Warden 24 |
| Zenis | the Evil One's avatar 22, its heart 15, its veins 10 (the core's beam, through the Magic Shield's ward) |

`test_the_guardians_hit_as_hard_as_their_zone` holds every guardian's hardest blow to 0.5 to 1.5 masks through par armor, and each zone's guardians to at least 0.75 masks. That way no boss is softer than the foes that lead to it. The Matriarch is the lowest: her threat is the hex, not her blows. Zorugeriru's rising flood (`HydraFlood`, 8) wears you down as a hazard does and is not scaled. A boss rush runs in the same arenas, so it takes the same threat, against the endgame kit a 100% save carries.

**The guardians' health (pass 204).** The rubric asks for balanced boss health (15.3), but nothing measured it. In slashes of the zone's par blade (5.5):

| Zone | Guardians (par slashes) |
|------|--------------------------|
| Tower | Zoradohna 24 (33 until pass 212), the Foreman 20 |
| Mist | Zorugeriru 24, Ripasheiku 20, the Marsh Hag Matriarch 18 |
| Branches | Pakukame 20, the Bark Knight Captain 19 |
| Daybreak | Borabohra 23 |
| Dartmoor | King Grieve 23, the Clockwork Alpha 19, Shadow Eura 18 (Dragon Slayer slashes; 320 HP since pass 218, was 240) |
| Sunken Spring | the Drowned Warden 38 (Dragon Slayer slashes; 680 HP since pass 218, was 520; optional, the hardest fight) |
| Zenis | the Evil One: its avatar 20, then its heart 17 (37 in all) |

`test_the_guardians_last_as_long_as_their_place` holds every guardian to 15 to 40 par slashes. Since pass 324 it also holds this table's counts to the code, and every guardian's health the bible names beside its class ("`DrownedWarden`, 680 HP") to its `MAX_HP`. The Warden's room note still said 520 HP from before pass 218, and nothing had caught it. A mini-boss (the Foreman, the Matriarch, the Bark Captain, the Clockwork Alpha) is no longer than 25 and never outlasts its zone's own guardian. The Evil One, avatar and heart together, is the longest fight on the critical path; only the optional Warden runs longer. No guardian outlasts the longest guardian of every later zone by more than two slashes (pass 212), so the fights grow, or at least hold, as the game goes on. Zoradohna had 360 HP, 33 par slashes: the second guardian ran longer than any required fight before the finale, and since her hull lets only a quarter of a side blow through, her real fight ran longer still. She has 260 now (24), level with Zorugeriru, the longest later guardian, and still above the Tower's Foreman. Her phases are fractions of her health, so they come at the same points in the fight. Rokusutahn's 600 is spread over a plated body (a quarter damage) and a soft tail, and the Evil One's veins are a climb, not a health bar, so neither is on the sheet. Heavy finishers, spells, the Pendant and skills only shorten a fight. Slashes are a proxy for the rubric's 2.5 to 5 minutes: most of a fight is spent reading tells and waiting for openings, not swinging.

**Past King Grieve (pass 218).** Since pass 217 King Grieve gives up the Dragon Slayer, so everything past his throne is fought with it (slash 18, against the Long Sword +2's 14): the Meteor Rise, the Zenis Gate and its mirror, and the Sunken Spring below the Rise. The sheet still assumed the Long Sword there. Shadow Eura fell in 14 Dragon Slayer slashes, under the sheet's floor of 15, and the optional Warden in 29, no longer the hardest fight. Each gets back its slash count: Shadow Eura 240 to 320 HP (18) and the Drowned Warden 520 to 680 (38). Their phases are fractions of their health, so they come at the same points. The sheet's par for the Sunken Spring is the Dragon Slayer, and Shadow Eura is measured against it (`PAST_GRIEVE_KIT`, `PAST_GRIEVE_BOSSES` in `test_combat.gd`). The Rise's foes still take 2 to 7 of its slashes. `test_the_sheet_past_king_grieve_holds_the_dragon_slayer` holds the kit to the game: Grieve's reward is that blade, and the Rise, the Zenis Gate and the Sunken Spring lie past his throne.

**A guardian's brood answers to the sheet (pass 258):** a foe a guardian calls into its fight is held to the same rows as a room foe: 2 to 7 slashes of its zone's par blade, and no blow past 1.4 masks through par armor. The Matriarch's daughters (Marsh Hags) and the Alpha's pack (Clockwork Hounds) also stand in rooms, so the sheet already held them. Pakukame's Liliths (8.5) stand nowhere else, and with 10 HP they fell to one slash of the tempered Long Sword (13). They have 20 now, two slashes. `test_a_guardians_brood_answers_to_the_sheet` finds every Enemy a guardian's script makes and requires it to be a room foe on the sheet, a guardian's shot on its row, or listed in `SUMMONED` with its zone and checked there.

**A brood that dies with its guardian pays nothing (pass 266):** the Bloom, the Matriarch and the Clockwork Alpha took their Liliths, daughter and hounds down with them by striking them as a blow would. So each one sprayed gold, rolled a drop, gave experience, counted as a kill for Wanderer's Grace, and stacked a kill's hitstop and shake onto the guardian's own death. None of it was the player's doing. Now they `perish` (`Enemy.perish`): they dissolve and cry out like any foe, but pay nothing, count as no kill, and leave the guardian's death its own weight. A brood the player strikes down still pays as written. `test_a_brood_that_dies_with_its_guardian_pays_nothing` also reads every guardian's script for a brood killed any other way.

---

## 6. Movement and Game-Feel Spec

All numbers are at the internal resolution (1 unit = 1 px at 640x360). Tile = 16 px. Player collision box = 12x40 px (sprite about 48x56). These are starting values for the movement prototype, tuned there and then frozen.

Every number in 6.1 to 6.6 and 6.8 to 6.12 is held to this text by a test that reads it from `MovementTuning` (`test_movement.gd`), and each one also has a test of what it does in play. The last left out were pinned in pass 208: the bounce-pod's launch (6.6), the glide's fall speed and brake (6.10), and the pogo's 45 ms hit-stop, which had been a bare number in the player's code and is now `pogo_hitstop`. Until pass 200 the run, the brakes, the turn, the jump cut and the fall limits were only read back from the tuning by their play tests, so a changed number would have moved its test along with it. Those pins still hold each number to a literal copied from here, so a number changed in the tuning and in its test together would have left this section saying the old one. Since pass 328, `test_every_movement_number_is_written_in_bible_6` reads this section itself: every number `MovementTuning` exports (62 of them) must be written somewhere in it, in a form the bible uses (165, 1,800, 0.10 s, 45 ms, 40%, or a derived one such as gravity to the whole px). A small number such as 2 is found almost anywhere, so the check catches the distinctive values, which are most of them.

### 6.1 Ground movement

| Parameter | Value |
|-----------|-------|
| Max run speed | 165 px/s (about 10 tiles/s) |
| Ground acceleration | 1,800 px/s² (reaches max in about 0.09 s) |
| Ground deceleration | 2,600 px/s² |
| Turnaround boost | deceleration x 1.6 when input opposes velocity |
| Analog walk (pass 183, Sean) | a stick walks into a run the farther it leans. Its lean (`PlayerInput.tilt`, 0 to 1 past the 0.35 deadzone) sets the pace, `MovementTuning.speed_fraction`: up to 0.45 it walks at 40% of a run (66 px/s); from there the pace climbs evenly to a full run at 0.9. Keys and the d-pad are always a full run, so every jump, dash and reach is the same at full tilt. The pace applies on the ground and in the air, so a light lean also places a short hop. Under 70% of a run the hero shows the `walk` pose: the sheet's `walk` clip once Sean's Autosprite walk is imported (`art/autosprite/manifest.json`), and until then the run clip slowed to the pace. Footsteps slow with it (up to 1.6x the run's 0.26 s) |
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
| Wall slide speed | max 90 px/s (falls slowly with dust particles, and the glove rasps: `wall_slide` on the catch and every 0.24 s after, pass 238) |
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
| Ground dash | yes, same values, 0.25 s cooldown. It hugs the floor (pass 121): a dash begun on the ground snaps to the floor from 10 px (`ground_dash_snap`, against the run's 4 px), so it rides a slope down as it already rode one up, instead of sailing off the ramp into the air. A ledge of a whole tile or more still drops away beneath it, and an air dash never snaps. Since pass 153 a thrust's lunge (9) hugs the floor the same way, and so does any slide on the floor still faster than a run (the end of a lunge or a dash), so a lunge that runs out halfway down a ramp doesn't hop off it |
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
| Swing timing (pass 256) | a slash or up-slash cuts for 0.10 s (`slash_active`) and the down-strike for 0.14 s. An up-slash or down-strike then recovers for 0.28 s (`attack_cooldown`) before the next swing, however fast Attack is pressed. A press in its last 0.15 s is held (`attack_buffer`, 5.3) and swings the frame it ends. A side combo's recoveries are combat numbers (5.3, `combo_cooldowns` 0.20, 0.20 and 0.38 for the heavy finisher). A blade's swing speed scales all of them (5.2). These two had been in `MovementTuning` since the prototype but in no table and no test |
| Bounce-pod (Branches) | landing on a pod from above sets vy = -600 px/s (about 9 tiles of rise in play); release doesn't cut it; refreshes double jump and dash. The pod isn't solid, so walking into it does nothing, and a hop onto it launches |

### 6.7 Juice checklist (all required before the movement milestone closes)

- **Squash and stretch:** jump 0.85x1.2 for 3 frames; land 1.25x0.8 scaled by fall speed; wall jump stretch toward direction.
- **Dust:** on run start, turnaround, land, wall slide (every 0.06 s, the overshoot carried so the beat holds at 60 fps), wall jump, and a dash: a kick of dust thrown back off the heel on the ground, a pale puff of air in midair (pass 104). The dash also leaves a trail of afterimages. **What the feet kick up takes the ground (pass 264):** the run, jump, landing and floor-dash puffs were the same pale dust everywhere, even in the Mist's marsh, in amber sap and in Dartmoor's standing water, though the steps there already sounded of mud, sap and water. They now take the ground underfoot (`Room.surface_at`, `Dust.GROUND_TINT`). Marsh mud flings dark brown clods and sap flings amber gobbets, and both fall back rather than drift. Standing water throws spray up from its surface (not from the floor under it), three drops more than the dust and higher, falling back in. Stone, moss, plank and iron keep the pale dust. `test_what_the_feet_kick_up_takes_the_ground_s_look`. Screenshot: `/mnt/project-files/pass-264/splash_24.png`.
- **Hit-stop:** 50 ms normal hit, 90 ms heavy, 80 ms when a foe falls, 150 ms when you are hit, 350 ms when you fall, 140 ms parry, 200 ms boss stagger (each phase break, pass 98), 350 ms boss kill (with slow-mo ramp): `Feel.boss_kill(seconds)` freezes 350 ms, then runs at 0.3x easing back up to full speed (quadratic) over the boss's slow-motion time, 1 to 1.5 s. Every boss uses it (pass 104; until then the kills held only 120 to 200 ms and the slow motion ended in a step). The kill, hurt and fall hit-stops were bare numbers in the code until pass 210; they now live in `CombatTuning` (`kill_hitstop`, `hurt_hitstop`, `death_hitstop`), held to this line by `test_the_starting_combat_values_match_bible_5_3` and in play by `test_a_kill_and_a_fall_hold_their_hit_stops`. A boss's own blows and the spells' hits keep their own.
- **Screen shake:** trauma model (shake = trauma²), decays 1.5/s. Light hit 0.15, heavy 0.3, boss slam 0.6. Option to reduce or turn it off.
- **Flash:** enemy flashes white for 2 frames on hit (pass 161: the flash and the tell pulses wash the foe's own silhouette white through `Enemy.wash` and `shaders/wash.gdshader`; until then fourteen code-drawn foes and bosses laid a translucent white box or disc over themselves, which read as a glitch); player flashes red and blinks during invulnerability, and the screen's edge flashes red (pass 98, 5.3).
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
| Against a wall | a current pressing you into a wall stops bearing you up, and you slide down the face (pass 224). It had held you hanging still: once the Spring of Sky turned the Thicket Road's band, a jump into it rode to the wind-niche with the head 16 px up against the lintel and stopped there, the opening just below, until you thought to hold Down. `test_the_wind_niche_needs_the_spring_of_sky` plays the real controller: 42 jump, second-jump and air-dash timings with the Wing Boots and the Stride never get in against the wind, and one jump with it turned does |
| Reversal | once the Spring of Sky is restored (`spring:sky`), every current in the Branches blows the other way (pass 92). The Guru Trials' currents never turn (pass 160) |
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
| Dash | a stride leaves the ladder and dashes as usual. Only a dash that goes lets go (pass 240): before the Elven Stride, or on the ground dash's cooldown, a dash press keeps you on the rungs instead of dropping you off them; a press on the cooldown is held (6.5) and goes when it ends |
| Regrab | after you jump or are knocked off, the same ladder can't be grabbed for 0.25 s |
| Hits | any damage knocks you off the rungs |
| Attacks | none while climbing (as in the original): jump off to fight |
| Feel | the wall pose's reach, cycling only while you climb; a hollow knock and a creak of the rungs (`ladder`) about every 8 px |
| Camera | leads 64 px up or down the way you climb (6.7, pass 130), so a long shaft shows where you are going |
| Look | two wooden rails and two rungs per tile, drawn behind the tiles so the top plank caps them |

**Held to the table (pass 280):** the take-hold row's rules and the attacks row had no test of their own until pass 280. `test_a_ladder_refreshes_air_moves_and_holds_no_attacks` checks three things. Catching a hanging ladder from the air with the double jump and the air dash spent gives both back. Up during a swing does not take hold until the swing ends. On the rungs, a swing, a Rune Dagger throw or a spell pressed there does nothing (no swing, no dagger, no mana spent, no bolt), and you stay on. Leaving out the refresh or the swing guard makes it fail.

The reachability checker treats a spot with the feet on a ladder as a standing spot: it climbs to the ladder cells above and below and over the top onto the plank, and jumps from a ladder as from the floor.

### 6.12 Sap (pass 248)

Amber sap in the Trunk Hollows' pools, and the puddles a Sap Spitter's globs leave for 4 s, hold your feet. The numbers live in `MovementTuning` (`sap_speed`, `sap_jump`); until pass 248 they were constants in the player's code, outside this section and its tests.

| Parameter | Value |
|-----------|-------|
| In the sap | the point 6 px above the feet lies in a sap tile (`Room.is_sap_at`) |
| Run | 50% of the pace (82 px/s at a full run) |
| Ground jump | leaves at 72% of its speed, 288 px/s: about 37 px of rise, a little over two tiles |
| What it doesn't hold | the double jump, the wall jump and the dash, at full strength: the way out. A dash in the sap goes at 380 px/s (`test_sap_never_holds_a_dash_and_lets_go_at_its_edge`) |
| Leaving | the run comes back the frame you step clear |
| Feel | the feet sink into the drawn sap, and each step squelches (13.3) |
| Spring of Trunk | once it is restored the pools harden into amber you walk on (4.4) |

**Where ladders go (pass 125):** where the original put them, between floors that already connect, so a ladder is the plain way up and never a key. They go in shafts you otherwise climb by a zigzag of planks, and never in a shaft that is an ability gate (the Fungus Shaft is the Glove's). `test_ladders_never_open_a_gated_room` takes every ladder out and checks that, before the Glove and with it, the ladders open no room the bare rooms keep shut. Placed so far:
- the Hollow Mouth: floor to the high plank under the way to the Mossy Overhang;
- the Tower Foot: the floor up the right wall to the ledge at the Winch Hall door, beside the plank zigzag;
- the Mine Shaft: the bottom of the shaft up the right side, through the upper floor beside the miners' doors.

### 6.13 Set back (pass 288)

A spike or a thorn (5.3: one mask) puts you back on the last safe ground. That is where you last stood on the floor with no hazard within 20 px either side or just below your feet.

**It must be the room's own ground.** Footing that can go is never kept as the safe spot. That covers:
- a cracked block you break;
- a Bark Knight's rooted lance, or the Captain's;
- a crystal shard;
- a gate or raft that opens or comes;
- a foothold of stilled water, which melts (pass 162).

Until pass 288, only the water was left out. Stand on a cracked block over spikes, then hop and pogo it to pieces: you fell onto the spikes and were set back into the air where the block had been, so you fell onto them again. That cost four masks in three seconds, and the loop never ended. Now only a floor of the room's tiles counts (`Player._on_fleeting_ground`). The set-back lands you on the floor you stood on before the block, for one mask.

`test_a_spike_never_sets_you_back_onto_footing_that_is_gone`.

**Nor the room's own ground once a guardian tears it away (pass 292).** The Bloom's phase-2 bite tears a four-tile chunk out of the leaf where it lands, with thorns below (8.5), and it lands where you stand. Your safe spot was that very tile, so the thorns set you back over the gap and you fell onto them again: five masks, and death, from one bite. Two things now keep it off. When a floor is torn (`Room.tear_floor`, the Bloom's leaf and Rokusutahn's pit), a safe spot over it moves to the nearer solid tile beside the pit. And a tile that is gone no longer counts as footing for the one frame its collision lingers (`Player._on_fleeting_ground`), so you can't take the spot back as you drop. The thorns cost one mask and set you on the leaf beside the gap. `test_a_torn_floor_never_sets_you_back_over_the_gap` (both sides of the root). **A ledge's corner is footing (pass 295):** the gone-tile check read the cell under the floor contact, and on a ledge's corner the contact lies on the line between two cells. The empty cell to its right was read, so standing on that corner never kept a safe spot: 150 of 63,792 floor frames in a walk through five zones' rooms. Both cells beside the line are read now, and the floor is gone only when both are empty. `test_a_ledge_corner_is_footing_for_the_set_back`. **A set-back is a fresh start (pass 296):** a dash pressed as you fell onto the spikes was still buffered when they set you back, and the set-back refills your air dashes, so it fired on arrival and carried you 64 px off the safe spot with no press of your own, often back toward the spikes. A set-back (`Player.set_back`, also the fall rescue under a room) now drops every buffered press (jump, dash, swing, throw) and the ledge's and wall's grace. You land facing the way you were, still. `test_a_set_back_drops_the_presses_buffered_on_the_way_down`.

(Deviation: spikes and their set-back come from the genre, not from the original, where harm comes from foes and a blow knocks you back. The Mattock's pogo (A2) is built around them, so the remake keeps them, and the set-back is the genre's rule for them.)

**Poison is no blow (pass 312).** Since pass 306 a poison tick takes up to 4 health, and passes 309 and 310 gave it a green number and a glug. It still never touches movement: no knockback, no hurt flash or invulnerability, no lost dash, slide or climb. A poisoned hero and a well one, given the same inputs, move frame for frame alike through a dash, a jump, a wall slide and a ladder climb with a tick landing in each (`test_a_poison_tick_never_touches_movement`). A hop over a flask before a door (pass 307) clears it from 22 to 58 px short at a run with a short hop and 22 to 94 px with a full jump; at a walk the window is 16 to 40 px with a full jump.

**A throw is drawn, not done (pass 320).** Sean's Rune Dagger flick (13.5, 2026-10-30) plays a low ready crouch over the legs' poses, and since his off hand (5.2) the dagger is a whole build's ranged tool, thrown all through a fight. The flick is drawn only: a throw never stops, slows or nudges the hero, and never costs a jump or a wall slide. `test_a_dagger_throw_never_touches_movement` runs a hero who throws on the run (frame 6), at the top of a jump (50) and in a wall slide (100) beside one who never throws, and their paths must match frame for frame. A throw that so much as added 20 px/s of fall parts them by frame 54.

---

## 7. Enemies

About 4 to 5 enemy families per zone plus variants (recolors with new behavior). Names reuse the original's monster names where they exist.

| Zone | Enemies |
|------|---------|
| Trunk Hollows | Monodron (one-eyed hopper), Hornet (swooper), Rot Dwarf (shield-bearing walker), Grub Lump (crawls over floors, walls and ceilings; from a ceiling it shivers for 0.45 s, then drops on you), Sap Spitter (turret; lobs sap globs that leave a slowing puddle for 4 s) |
| Tower of Trunk | Iron Dwarf (plated walker: raises a hammer for 0.65 s, slams, and sends a shockwave along the floor that a hop clears; his plate halves blows except from above or while the hammer is stuck in the floor for about 1 s), Minecart Rider (a dwarf hunched in an ore cart: trundles the floor; with you level and ahead he hauls the brake for 0.6 s, wheels shrieking, then charges the length of the floor. Jump him. At a wall or the floor's end the cart stops dead and tips over for about 1 s, the rider dazed and open; otherwise the iron tub turns most blows except from above), Gear Bat (clockwork flier: roosts under ceilings, wakes when you pass, hangs off to one side of you, whirs the gear on its back for 0.5 s and flings it; the gear flies out, slows and returns to the bat; parry it and it flies home and staggers the bat), Naga (pass 273, the original's serpent that floats up and down over the ladders: a sea-green hooded serpent the length of a man, legend `)`. It rises and sinks 40 px either way of its home along its own column, one swing every 3.2 s of game time, so a climb past it is timed to its swing. Level with it, its head within 24 px of your chest and you in front within seven tiles, it draws back and flares its hood with a hiss (`naga_hiss`) for 0.5 s, following your height along its column at up to 60 px/s (slower than a climb, never past its swing), then strikes straight out along that level at 260 px/s for 0.4 s (`naga_strike`) and bites for 16, and glides back to its column at 120 px/s, waiting 2 s before it hoods again. So a climb past it is timed to its strike (pass 275; until then its coil froze it in place and every climber holding Up was already above the bite): holding Up straight past is met nearly every time, while baiting it (climb into its level, drop back as it hoods, climb again once it has glided off the ladder) gets past every time (`test_a_climb_past_a_naga_is_timed_to_its_strike`). Since pass 274 the bite is a blow, as the Spring Eel's, the Hound's and the Mantis's are: a parry takes no harm and sets it reeling for 1 s. Its floating body only scrapes for 8, and only a wall ends a strike early (its long body grazing the floor once did, so a Naga never reached a hero on the ground; `test_the_nagas_bite_can_be_parried`). 22 HP. Slain, it always leaves the largest bread there is, as the original's did (pass 281): a great loaf, twice a bread's length, that heals 40 against a bread's 15 (`Drop.LOAF_HEAL`, through `Enemy.sure_drop`, which a foe leaves instead of rolling for a drop; `test_a_slain_naga_leaves_a_great_loaf`). So a climb that meets the serpent and wins is paid back in health. Both Nagas float over shafts whose floors open onto the room below, so until pass 283 a third of loaves fell out of the room: 30 of 72 tried in the Tower Foot and 18 of 72 in the Mine Shaft, through the gap or out a side door. Now no drop leaves its room (`Drop._keep_in_room`): one that pops past a side edge stops at it, and one that falls through a gap in the floor comes to rest on the floor at the gap's nearer edge (`test_a_nagas_loaf_lands_where_you_can_reach_it`, every kill point along the serpent's swing and strike, popping left, straight or right). One floats by the ladder of the Mine Shaft and one by the Tower Foot's. `test_the_naga_floats_its_column_and_strikes_level`), Rock Golem (mini-boss: the Foreman, a golem in a foreman's lamp-helm with the Mattock wedged in its back. 220 HP; its rock halves blows except from above or while stunned. Pound: fists up 0.75 s, a slam with a shockwave each way. Throw: a boulder overhead 0.6 s, then lobbed at you. Charge: scrapes 0.85 s, then barrels across the hall; hitting a wall stuns it 1.8 s and shakes rocks from the ceiling, each marking its spot 0.7 s before it falls. Below half: tells 25% shorter, faster charge, the pound also drops rocks. Reward: the Mattock (no skill point)) |
| The Mist | Lantern Ghost (a hooded wisp of a drowned dwarf that drifts through wood and stone; out in the fog it is all but invisible and shows only near light. Close in, its eyes flare for 0.55 s, bright even in the murk, then it lunges and fades back), Bog Myconid (a squat marsh mushroom rooted in the mud. Come within about five tiles and its cap swells for 0.6 s while its gills glow, a light that shows through the fog; then it bursts into a spore cloud 40 px across that drifts up, stings for 8 on contact and again every 0.7 s, and can't be parried. It thins away in 2.4 s. Spent, its cap sags open for 1.1 s and takes half again the damage, so the answer is to back off and then strike. As in the original, where the Myconid always drops health-restoring bread, a slain one always leaves a loaf of bread, +15 (pass 289, `Enemy.sure_drop`)), Drowned Dwarf (built in pass 108: a Victim miner the marsh took, risen with the anchor he drowned on, his skin gone blue-white and his beard matted with weed. He lies sunk in the mire with only his helm's crest and a trickle of bubbles showing, and there he can't be hit and does no harm. Come within about five tiles, level with him, and he hauls himself out over 0.7 s, taking half again the damage while half out of the mud. Then he shambles after you at 26 px/s. Close in, he heaves the anchor overhead, water pouring off it, for 0.6 s (pose, white pulse, a low groan), and slams it down in front of him for 18. The slam can be parried. It buries the anchor in the mud for 0.8 s, and every blow lands at half again. Lose him (out of sight for 3 s) and he sinks back into the mire to wait. 46 HP, contact 10 once risen. Legend `p`; in Marsh Road, Victim Causeway, Drowned Stair, Veiled Rise and Feather Hollow), Marsh Hag (built in pass 119: a bent crone of the drowned villages in a shawl of dry reeds, moss for hair, leaning on a crooked willow staff with a green marsh-wisp caught in its crook. The wisp is a light, so she shows through the fog from far off. She spots you from about 15 tiles and shuffles nearer at 22 px/s until you are within 11. Come within four tiles and she backs away from you at 34 px/s, still facing you, for up to 1.2 s; then she stands and hexes anyway. Her hex: she draws herself up and raises the staff, the wisp flares (pose, white pulse, a cackle over welling bubbles), and a ring of bubbling green bog light marks the floor or plank under your feet, all for 0.6 s. Then a hand of black mud bursts up out of the mark for 16 (12 until pass 226), which can't be parried: step off the mark. Strike her mid-hex and the spell breaks: the mark fizzles, the staff clatters into the mud and she gropes for it for 1.0 s, taking every blow (the breaking one too) at half again. So the answer is to close in, through the fog, toward her light. She hexes every 1.6 s. 30 HP, contact 6. Legend `?`; in the Fog Cut, across the dip, and on a plank over the Victim Causeway's dip), Marsh Hag Matriarch (mini-boss, pass 179: the hags' mother in a mire east of Mascon; see section 8) |
| Branches (Conflate) | Leaf Mantis (a mantis the green of the leaves, folded on a bough like one more leaf cluster and harmless to touch. Come within about seven tiles and level with it and it rears and spreads its scythes for 0.5 s, then lunges along the bough for 0.25 s and slashes for 16; it stops at the bough's end. The slash can be parried. A lunge leaves it overreached for 0.8 s, taking half again the damage; then it stalks you and unfolds again, or folds back into a leaf once it has lost you for 2 s. Striking a folded one springs it open); Bark Knight (pass 110: a knight the Tree grew in living bark, with a lance of green bough. He paces the branch roads at 22 px/s. Come level with him within about five tiles in front and he braces, lance back and eyes lit, for 0.6 s, then thrusts it out to about four tiles for 16; the thrust can be parried. Then he roots for 1.1 s with the lance left out stiff as a bough, a one-way ledge you can stand on, drop through (Down + Jump, as any one-way) or pogo off to get over him. His bark is a guard of three plates: each blow on it deals a quarter, rounded up, and knocks off a plate; bare heartwood he takes full damage. Rooted, the bark doesn't guard him, but one plate grows back as he pulls free. Fire catches living bark (pass 177): a fireball's burst burns every plate off at once and lands in full on the heartwood. 54 HP; legend `!`); Seed Bomber (pass 114: a pod-bellied canopy bird with leaf wings and a husk of hard seeds for a belly. Within about 15 tiles it keeps five tiles over your head, out of reach of a plain slash. Right above you it squeezes the husk, wings up, belly swelling and glowing, seeds rattling, for 0.5 s, then drops a seed that stings for 10 if it lands on you. On a branch or plank the seed sputters for 0.6 s, seams blinking faster and its reach showing, then bursts in thorns 28 px around for 12, unparryable. Strike the seed (or parry it as it falls) and it flies back up into the bird, bursting there for 18 and knocking it out of the sky: it lies dazed on its back for 1.4 s taking blows at half again, then climbs back up. You can pogo off a seed, too. 28 HP, touch 8; legend `;`, in Thicket Road and North Bough), Bark Knight Captain (mini-boss, pass 171: the first knight the Tree grew, in the Thorn Yard east of Conflate; see section 8); Lilith (pass 257: Pakukame's brood, loosed three at a time from its petals and found nowhere else, as in the original; a violet imp with petal wings that screeches 0.4 s before it dives, 8.5) |
| Branches (Daybreak) | Storm Harpy (a winged hunter, storm-grey and violet with white hair and gold talons. Within about 16 tiles she hangs 4 or 5 tiles to one side of you and 5 above, out of reach of a plain slash. Her tell: she rears and throws her wings up with a screech for 0.55 s, then flings a fan of three feathers at you (8 each, 200 px/s, 15° apart). They can be parried, and a parried feather flies back and strikes her for 12. After a volley she sags about two tiles for 0.8 s, winded and in reach of a jump, then waits 1.4 s before the next. HP 30), Thunder Beetle (a beetle as big as a dog, storm-violet with a gold stripe, trundling the shrine stones at 28 px/s and turning at ledges. Its shell turns 70% of a side blow but none from above, so pogo it. Come within about four tiles and its wing cases lift and crackle with static for 0.6 s, then it discharges a ring of lightning 46 px around itself for 14 that can't be parried and reaches above the shell too: get off and get clear. Spent, its cases hang open for 1.1 s and every blow lands in full; it can't charge again for 1.4 s), Spire Sentinel (built in pass 123: a knight of pale shrine stone the elves set to guard their stairs, helmed and crested, with a halberd and the Sky Key's gold lightning cut into its breastplate. It is stone while you watch it: as long as you face it, it never moves and every blow clinks off. Turn your back within about 13 tiles and its eyes light and it grinds after you along the floor at 64 px/s, and the moment you turn round it is stone again. So climbing away from one is the danger, not fighting it. In reach (about 2.5 tiles) it raises the halberd overhead while the glyph blazes, 0.6 s (pose, white pulse, a rising hum), and slams it down in front for 16. The slam can be parried, which staggers it; a slam that lands or misses buries the blade for 1.2 s. Either way the stone cracks open with bright seams and every blow lands in full. 40 HP, contact 8. Legend `]`; at the Spire Foot and at the bottom of the Spire Stair) |
| Dartmoor | Crystal Dwarf (meteor-fused; built in pass 64: magenta crystal has grown out of his back like a shell and swallowed his right arm. He trudges toward you; with you ahead and within about seven tiles he raises the crystal fist, blazing, for 0.6 s, then drives it into the floor, 16 to anything right in front, and six crystal spikes erupt along the floor toward you one after another, 20 px apart and 0.09 s apart, each glowing on the floor for 0.18 s before it stabs up 26 px for 12, unparryable: jump or dash them. Each spike cracks up through the floor with a dry snap and a glassy ping as it rises (`crystal_stab`, pass 246; its glowing mark is silent), so the chain ticks along the floor toward you; the same spikes serve King Grieve, the Evil One's avatar and the Evil Heart, and two that rise on one frame sound once. His fist stays rooted for 0.9 s, and then every blow lands. The rest of the time his crystal back turns any blow from behind, and only a pogo from above gets past it. 48 HP), Shade Knight (parry-heavy; built in pass 66: the drowned ghost of a king's guard in a dwarf great helm, a tower shield on his arm, mist where his knees should be. The shield turns every blow from the front, and two blows on it in a row bring a quick riposte, 0.36 s tell, a cut for 14. He advances behind it to about four tiles, then draws his blade back, a cold light gathering at its point, for 0.55 s and thrusts, sliding forward, for 18. Then he raises it, 0.38 s, and cuts down for 14. Both blows can be parried, and a parry leaves him reeling, shield wide. If the pair finishes he stands winded for 0.7 s, shield low. Blows from behind or from above always land. 56 HP), Clockwork Hound (built in pass 70, the clockwork enemy: one of King Grieve's brass hunting dogs, still running on the spring the king last wound. It trots after you; within about seven tiles it crouches and its key spins up, ratcheting, eyes blazing, for 0.45 s, then pounces in an arc aimed to land on you and bites for 14. Its brass plating turns half of every blow. Parry the bite and it tumbles onto its back for 1.3 s, belly bare, and every blow lands in full. It is clockwork, so the Hour Glass stops it dead, mid-leap or not; it is the one enemy time stops. 44 HP), Meteor Slug (built in pass 69, the Hour Glass's enemy: a great grey slug under a lumpy shell of meteor-rock, molten in its cracks. It creeps along the floor and turns at ledges. With you within about ten tiles its shell swells and its cracks blaze for 0.6 s, then it heaves three gobbets of molten rock in high arcs, one at you, one short, one long, 12 each, unparryable; where one lands on a floor it leaves embers that burn for 8 over 1.4 s. The Hour Glass holds globs and embers still and harmless, so you can walk out from under a volley. The shell turns pogos except in the 0.7 s it sags after a heave; its soft sides take every blow. 40 HP), Clockwork Alpha (mini-boss, pass 169: the hounds' brass sire in a den under the kennels; see section 8) |
| Zenis | Remixes of every family, corrupted with meteor crystal. As built (pass 161): besides the Dartmoor guard, the Threshold holds Gear Bats, a Storm Harpy and a Rot Dwarf, the Heart Stair a Leaf Mantis, an Iron Dwarf and a Thunder Beetle, the Drift Well a Lantern Ghost, and the Heart Gate a Bog Myconid and a Seed Bomber: a family from every zone, a dozen or more in all (`test_zenis_holds_a_remix_of_every_zones_foes`) |
| Not yet built (pass 123) | **Planned**: none; every planned foe is built (the Seed Bomber in pass 114, the Marsh Hag in pass 119, the Spire Sentinel in pass 123). **Cut**: the Mist Wisp (the Lantern Ghost is the Mist's wisp), the Wind Imp (the Storm Harpy already holds Daybreak's air) and the Sky Ray (the Branches' wind currents make the open sky the challenge there). |
| Sunken Spring | Spring Eel (built in pass 86, the swimming enemy: a long pale eel gone blind in the dark water, with a lamp of the spring's light grown on its brow. It never leaves the water; it weaves back and forth near where it lives. Within about seven tiles it draws back into an S, its lamp blazing, for 0.5 s, then darts straight at where you were at 300 px/s and bites for 14. The dart stops dead at the water's edge, so the bank is safe. Spent, it hangs slack for 0.8 s and takes every blow at half again. 30 HP. Legend `l`, a water cell with the eel in it) |

Every enemy has: a readable telegraph (minimum 0.35 s wind-up with a pose, a flash and a sound, section 13.3; every named wind-up of every foe and guardian, and every phase-quickened tell, is held to it as a whole by `test_every_wind_up_in_the_game_is_fair` since pass 234. The one shorter warning, a crystal spike's 0.18 s floor glow, only marks where a spike will rise after its caster's full tell), a hurt reaction, a death animation with a dissolve, and drops (gold, MP orbs, rare items). Besides gold, about 1 kill in 12 leaves **bread** (heals 15, the original's staple) and 1 in 10 a **mana orb** (+12 MP); both wait on the floor for 10 s. (Deviation, pass 297: the original's manual names only "food and money" from foes, with the rare items below. The mana orb is the remake's: magic here pays for every spell you cast (5.2), and the orb keeps a fight's magic coming between Gurus as bread keeps its health.) From the Tower of Trunk on, some enemies (Iron Dwarf, Gear Bat) leave Faxanadu's **Poison** about 1 kill in 14: a violet skull flask that is a hazard to step around while collecting. Walking over it poisons you for 8 s, costing 2 health a second but never the last point; your health masks and sprite turn green. Bread, resting at a shrine or Guru, or dying cures it, and an Ointment keeps it off. (Deviation, pass 305: the manual's Poison is one bite: "The hero's power will decrease by a fixed amount." The remake spreads it over 8 s, 16 health at most in the Tower and never the last point, so it reads as a sickness that bread can still settle, not a fine taken before you see it. The manual's Ointment protects the hero "from any enemy attack", and poison is no attack; that it keeps poison off too is the remake's.) **Poison bites as hard as the room's foes (pass 306):** poison is a foe's leaving, so each tick is scaled by the room's threat (5.5) as a blow is: 2 a second in the Tower, 3 in the Mist, the Branches and Daybreak, 4 in Dartmoor, the Sunken Spring and Zenis, where every foe drops it. A fixed 16 health was under 6% of a late hero's 280 while every blow beside it doubled, a flask not worth stepping around. It still never takes the last point, and an Ointment rubbed on mid-poison stops the rest of it (`test_poison_bites_as_hard_as_the_rooms_foes`).

**Rare drops (pass 147):** "rare items" had never been built: no foe left anything but gold, bread, mana and poison. Now about 1 kill in 40, from any foe anywhere (`Drop.rare_chance` 0.025), leaves one of the original's rare items. Both wait on the floor like bread, and both are drawn in code:
- **War Glove** (60% of rare drops). This is the original's Glove, renamed so it can't be mistaken for the Climbing Glove. It looks like a red leather fighting glove with a gold-studded cuff. Walking over it puts it on: for 15 s every blade hit, the pogo and a Riposte included, lands 1.5x as hard (`war_glove_mult` and `war_glove_time` in `combat_tuning.gd`, through `Player.blade_mult()`). Red sparks rise off the sword hand while it lasts. A red fist and a draining bar sit on the HUD beside the Ointment's row, and the bar blinks in its last 3 s. Another glove starts the time over, and dying takes it off. It turns a lucky drop into a short push: clear the room while it burns.
- **Ointment** (40%). It goes in your pouch like a bought one (up to 3). With the pouch full and none on, it goes straight on, as the original's did; with one already on, it is wasted.

**A fall out of the room (pass 291).** A foe knocked through a gap in its room's floor died to nothing: it fell on below the room for good, and its gold, drop and experience were lost with it. Fifteen walkers in fourteen rooms can be driven out this way, by blows alone: Monodrons and Rot Dwarves in the Trunk and the Tower, and a Marsh Hag in Fog Cut. Now a foe (never a guardian) that falls more than 24 px below its room's floor line dies as it goes (`Enemy._fall_out_of_room`, `FALL_MARGIN`). It counts as a kill, and its coins and drop come to rest at the gap's edge (`Drop.keep_in_room`, passes 283 and 285). `test_a_foe_knocked_out_of_its_room_falls_to_its_death` drives every walking foe in every room both ways and holds both. **A fall is a kill, not a blow (pass 298):** it pays, cries out and refills Wanderer's Grace like any kill. But it comes below the screen a moment after the blow that sent it, so the kill's 0.08 s freeze and its shake there only hitched the game for nothing you could see. A fall (`Enemy.fell`) now dies without them. `test_a_foe_that_falls_out_pays_without_a_kills_freeze`.

**The dissolve (pass 126):** until pass 126 a foe simply vanished in a puff of debris. Now its body stays where it fell for 0.45 s (`Enemy.DISSOLVE`). It flashes white, then breaks up pixel by pixel (one world pixel, two art pixels, at a time), the top a little first, each mote glowing pale gold as it goes (`shaders/dissolve.gdshader`). Then it is gone (freed, or hidden until it respawns). The dying body is harmless and can't be struck or touched, and the gold, drops and death sound come at once as before. Every foe that dies through `Enemy.die` uses it. Bosses keep their own deaths and go at once when they reach `Enemy.die`.

---

## 8. Bosses

Each boss has: a pre-fight arena reveal, 2 or 3 phases, an ability it tests, a "stagger" window, a cinematic kill (slow-mo, white flash, shatter), and a reward. Health bars show phase markers. **The openings, as built (pass 163):** each boss names its stagger window as `punishable()`, which Executioner and Bloodletting read (9). The windows are:

| Boss | Opening |
| --- | --- |
| Rokusutahn | his plates cracked by a stagger |
| Zoradohna | the drill stuck in a wall or the floor |
| Ripasheiku | fallen from the vault |
| Zorugeriru | a head lying where it bit |
| Pakukame | the jaws hanging open |
| Borabohra | grounded by its own lightning |
| The Foreman | stunned against a wall (rock never reels from a parry: none of its blows can be parried, pass 276) |
| The Bark Knight Captain | rooted after a thrust, planted after a vault, or reeling from a parry |
| The Marsh Hag Matriarch | groping for her staff after a broken hex, or reeling from a parry |
| The Clockwork Alpha | flipped by a parry, jammed in a wall, or stopped by the Hour Glass |
| King Grieve | reeling from a parry, or fallen |
| Shadow Eura | reeling from a parry, or spent after a blow of its own (the cut from behind, or a free cut, heavy, cast or dash) |
| The Drowned Warden | staggered, or exposed after a slam |
| The Evil One, phase 1 | reeling from a parry, or spent after its burst (the pull's end) |
| The Evil One, phase 3 | bound by the root |

Since pass 276 `test_every_opening_the_table_names_a_parry_for_opens_on_a_parry` holds the table to the fights: each guardian whose row names a parry is sent reeling in its own arena and must stand open, and the Foreman must not. Its row had said "or reeling from a parry" since pass 163, but its rock never reels (`Foreman.stagger` does nothing), so Executioner and Bloodletting had only the wall stun there all along.

**An opening without a shield (pass 314).** Sean's off hand (5.2) makes the Rune Dagger and a shield a choice, and the two-handed Broad Sword already put the shield on your back. Shadow Eura and the Evil One's first phase opened only on a parry, so a hero with the dagger in hand never saw Executioner or Bloodletting (9) work in either fight, against "so the skill has a window in every fight". Each now also opens when spent after its own move: Shadow Eura for the 0.6 s after the cut from behind (`recover`) or any free blow, cast or dash (`f_recover`), and the Evil One for the 0.7 s after its pull ends in the burst (`burst`; its plate is bare then too, as when it reels). A decoy has no opening. Every row that names a parry must name another way in: `test_every_guardian_opens_without_a_shield`.

The core (phase 2) has none: no blade reaches it, only the veins.

**What a win says (pass 220).** A guardian's win shows a banner: the prize's name and a line about it. Shadow Eura and the Evil One's avatar, veins and heart each had a line of their own written in `BossArena.BOSSES`, but no prize, so the banner took the plain branch and showed only "+1 skill point": the mirror's and the meteor's story lines were never seen. The reverse held for the five bosses whose banner tells their prize (the Lantern and Sky Keys, the Battle Suit, the Dragon Slayer): each gives a skill point and never said so. Now a boss with a line shows it, and a skill point is always told, in the banner for a boss with no line or in a toast under it for one with. Every line fits the banner's width. `test_every_guardians_win_says_what_it_gave` wins every arena (all but the Evil One's last, whose win starts the ending) and listens. **The Reward lines (pass 332):** the sections below still left out the skill point that King Grieve, Borabohra, Shadow Eura and the Evil One's three forms each give, and the Foreman's prize was told only in passing in 7. Every guardian now has a Reward line naming its prize and its skill point, or "no skill point" for the Foreman and the three mini-bosses. `test_every_guardians_reward_line_names_its_prize` holds each line to `BossArena.BOSSES`.

**A won fight stays won (pass 239).** A guardian dies in a dying window of 1.2 to 2.5 s (the slow-mo, flash and shatter) before its arena opens. Spikes, shards, the flood and any blow already swung stayed live in that window, so a hero at low health could land the killing blow and still die. If the respawn came before the arena opened, it took them back to their last rest with the boss already down but the arena never opened: no flag, no prize, the fight to do again. Now `BossArena.falling()` is true from the killing blow until the doors open, and the hero takes no harm in that time. `test_a_guardians_win_cant_be_lost_while_it_falls` has King Grieve's blows land before the killing blow, none after it, and the flag and the Dragon Slayer kept.

**The Rune Dagger against bosses (pass 188):** it reaches every boss that a blade does, for 6 a throw, and is meant as a way to keep up pressure from a distance, not a way around a fight's lesson. So it splits none of the Bark Knight Captain's plates, breaks none of the Matriarch's hexes and never cuts the Heart (5.2, the Rune Dagger). The two-handed Dwarvish Broad Sword (pass 186) cannot parry, and no boss needs a parry: every opening that a parry gives also comes some other way, or only feeds Executioner and Bloodletting. The Battle Helmet's slot and kept gear change nothing in a fight, apart from letting you swap blades at a pause. **Held since pass 316:** with Sean's off hand the dagger is a whole build's ranged tool, so `test_the_rune_dagger_reaches_every_guardian` fights each guardian of the Boss Rush order in its own arena and throws until one throw stings it, from a step to either side, from under it when it is high, and from the ground beside it when it stands below you. The Drowned Warden, waist-deep in the Wellspring, is reached only that last way: a throw from the ledges or the planks flies over its head, so the islands are where a dagger fights it. The veins and the bound Heart are left out, as above.

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
- **Tests:** reading by light, and keeping your blade ready in the dark. (Until pass 236 this line said double jump, but the Wing Boots lie past the fog her Lantern Key parts; at her chapel the player holds the Glove and the Mattock.)
- **Body:** 260 HP. Her four lanterns are separate targets on her legs, and each is a light in the fog (70 px). A lantern breaks in one blow and costs her 18 HP. Each broken lantern frees a soul that clings to her as pale fire, so she shows a little more (8% plus 16% a lantern). Her tells always show at least 80%, so they stay readable in the murk.
- **Phase 1:** she stalks in the dark. Close up she sweeps her front legs (0.55 s tell); farther off she rears and pounces at where you stand (0.65 s tell).
- **Phase 2 (below 66%):** she climbs to the vault and hangs there. Web: a thread flickers toward you (0.6 s), then a strand shoots along it (360 px). If it catches you it reels you toward her for 0.9 s; a slash cuts the strand, and so does the Elven Stride's dash once you have it. (Pass 236: until then only a dash broke free, and the Stride lies a zone past her, so a player caught at her chapel had no answer. `test_a_slash_cuts_ripasheikus_web` holds it with only the Glove and the Mattock.) Drop: she shivers (0.6 s), marking a shadow below, then falls on you and lies stunned for 1.3 s, taking 1.5x damage.
- **Phase 3 (below 30%, or all lanterns broken):** she comes down for good. She is fully visible, fast, and desperate, with tells a quarter shorter (never under the minimum).
- **Reward:** Lantern Key (opens the path to Zorugeriru), Mana Dew, a skill point.

### 8.4 Zorugeriru, the Mist Hydra (The Mist)
- **Concept:** A three-headed serpent made of fog and bone, coiled around the Spring of Mist. Only the head that is solid at the moment can be hurt.
- **Arena:** the Spring of Mist (`mist/spring_of_mist`, east of the Dry Cistern): the spring on a shelf in the middle with the hydra's coil wrapped around it, three dry tanks across the floor (dry basins, 4.5), floating debris between them and steps up to the shelf. The water level changes across phases. The tanks are part of the fight: dry again on every try, full for good once he is beaten.
- **Tests:** Deluge (filling the tanks raises rafts, the high ground) and air control.
- **Phase 1:** the three heads take turns being solid (about 3.4 s each); the solid head hangs low over its tank and follows you along its lane. It rears back (0.6 s, its eyes flash and a ring marks where it will strike), bites down at you, and lies where it bit for about a second, open to blows; a parried bite stuns it longer. A mist head breathes: mist wells at its jaws and pools on the floor below it (0.7 s), then a low bank of fog rolls along the floor toward you (12 damage, can't be parried): jump it or stand on the tank walls. Blows on a mist head pass through.
- **Phase 2 (below 60%):** the three heads turn to mist and keep breathing; eyes glint in the coil. The fourth head comes out only once all three tanks are full: Deluge each one and its raft floats up. While a tank is dry it shimmers (its stain glows, water beads under it), and each tank that fills douses the head above it: the head sags, its eye goes dark and it stops breathing, so the player sees each tank count (playtest; the toast names Deluge and repeats while tanks stay dry). It hangs high under the shelf and bites no lower than the rafts and walls. Phase 1 can't be cut short past phase 2.
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
- **Phase 2 (below half):** tells a fifth shorter (never under 0.35 s). Every other bite tears a four-tile chunk out of the leaf where it lands, up to three gaps with thorns below, never next to the root or the walls. Their thorns set you back beside the gap, never over it (6.13, pass 292). You stride or bounce across, and strike the open jaws from the gap's edge.
- **The brood (pass 257):** in the original, Pakukame looses Liliths three at a time until those are destroyed. The remake's Bloom had no brood, so the fight lost the one thing the original's was known for. From phase 2, when it would whip or spit from afar and none of its brood is left, it broods instead (the first far move below half, then no sooner than three moves after the last). The petals flare wide and spin for 0.7 s (a fifth shorter like every phase-2 tell, never under 0.35 s), with a rustling hum (`bloom_brood`, since pass 262), then three **Liliths** fly up out of them. A Lilith (`Lilith`, code-drawn) is a violet imp the size of a hand with pink petal wings: 20 HP (10 until pass 258, when the sheet found it fell to one slash of the Branches' par blade), harmless for its first 0.5 s while it clears the petals, then it hangs above and to one side of you, each of the three in its own place. It screeches with its wings flared for 0.4 s, dives at where you were (250 px/s for 0.45 s, 8 on touch) and climbs back on the other side. Struck down, a Lilith never returns. While any flies the Bloom only whips and spits; once all three are down it may brood again. They die with the Bloom, paying nothing (pass 266, 5.5). Test: `test_the_bloom_looses_its_liliths_three_at_a_time`. Screenshots: `/mnt/project-files/pass-257/brood_260.png`, `brood_320.png`.
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
- **Reward:** Sky Key and a skill point; restores the Spring of Sky.
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
- **Reward:** Demon Ring, the Dragon Slayer and a skill point; the dwarves of Dartmoor are freed; Dartmoor drains.
- **The swallowed sword (pass 217):** in the original, the Evil One can be destroyed only by the sword King Grieve swallowed, and beating him releases it. Until pass 217 the remake's Dragon Slayer lay on an altar in Zenis's Heart Gate, so Grieve's fight gave no more than a ring and the original's best-known story beat was lost. Now his reward (`BossArena.BOSSES.king_grieve.blade`) puts it straight into your hand, with the banner "Dragon Slayer": "He swallowed it to keep it from the meteor, and gives it up at rest. With it, the Demon Ring." The Heart Gate's altar is bare, with a sign: "An empty altar, cut to hold a sword. King Grieve swallowed the blade and took it down into Dartmoor." A save past Grieve that never took the sword from the altar gets it in hand (`GameState.sanitize`), so no old save is locked out of the heart. Since the throne lies past both Grieve and the flesh, reachability is unchanged. Tests: `test_king_grieve_defeat_gives_the_demon_ring_and_the_dragon_slayer`, `test_a_save_past_king_grieve_holds_the_dragon_slayer`, and the faithfulness checklist (no room lays legend `&`).
- **As built (pass 71, phases 1 and 2):** `scripts/bosses/king_grieve.gd`, code-drawn at 2x (a broad dwarf in a flood-rotted robe and a gold-edged mantle, a beard to his belt, the back of him grown over with magenta crystal, crystal grown up through his crown, a great-axe whose blade is half crystal), in the Throne Hall of Fraternal Castle (`dartmoor/throne_hall`, 58,-7, 60x23; titled Fraternal Castle since pass 241) off the King's Kennels, the dais at its east end six tiles high. 320 HP. Reward: the Demon Ring and a skill point, and since pass 217 the Dragon Slayer (below).
  - Phase 1, the duel: he walks you down. Close in, he raises the axe overhead, its edge glinting, for 0.6 s and chops for 20, then draws it back low for 0.4 s and sweeps for 16. Both can be parried, and a parry leaves him reeling for 1.2 s, open to every blow. Otherwise his crystal half turns half of every blow. Keep away and he crouches 0.6 s and leaps after you, bringing the axe down for 22 (unparryable) with a shockwave rolling each way.
  - Phase 2, the throne (below half): he leaps onto the dais, plants the axe and wards himself in crystal: blows from the side do nothing, and crystal thorns along the dais burn anyone who climbs up beside him (10). Every 3.2 s his crown blazes for 0.5 s and four crystal shards (`scripts/bosses/crystal_shard.gd`) glow in the floor for 0.4 s, nearest the dais first, a quarter-second apart, then shoot up to the vault at 140 px/s, 12 to anything they pass through. Rising together they make a moving stair, highest by the throne. Turn the Hour Glass and they hold where they are with flat tops to stand on; when time runs again a held shard cracks and falls. Climb them and strike down on his crown: he is thrown from the dais, open to every blow for 1.8 s, and duels again (tells at 0.8x) for 7 s before he climbs back.
  - Phase 3 (pass 72, below a fifth): the meteor takes him. He roars and cracks open for 1.4 s, untouchable, crystal light blazing through the cracks, and comes down off the throne for good. Frantic now, he walks you down at 1.8x, his tells at 0.65x (never under the minimum), and every chop and sweep ends with the axe raised again (0.45 s at full, shorter frantic) and driven into the floor: six crystal spikes burst out in a line toward you, 22 px and 0.08 s apart (jump them). Cracked, he turns no blow, and a parry still throws him reeling.
  - The household guard (pass 268): the concept above has him summon royal guards in phase 2, but until pass 268 the throne called only shards. Now the first wave of shards from the throne also calls a **Shade Knight** of his household guard (7, the drowned ghost of one of his own guard) up out of the flood. It rises with a splash at whichever end of the hall floor is farther from you: by the west wall, or just past the shards' reach. While it stands he calls no other. Once it falls, the second wave after calls the next, and no more than two come in a fight (`KingGrieve.GUARDS`, `GUARD_EVERY`). So the climb up the held shards has a parry fight on the floor below it, which is the fight's other test. His guard will not serve the meteor: when the meteor takes him (phase 3), and when he dies, it goes down with him (`Enemy.perish`, paying nothing, 5.5). `test_king_grieve_calls_his_household_guard_from_the_throne`. Screenshot: `/mnt/project-files/pass-268/guard_780.png`.
  - The water-clock (pass 72, room prop `water_clock`): a tall bronze-framed glass column of flood-water by the west wall. Full before the fight, it drains with his health and stands empty once he is beaten.
  - His theme, `grieve` (pass 72): the Dartmoor dirge risen into a march, D phrygian at 112, war drums, a tolling bell, crystal stabs on the offbeats.
  - After him (pass 73): a door behind the throne, barred by the fight's iron until he is beaten, leads up the Meteor Rise (60,-9, 40x68), eleven switchback shelves of crystal-choked shaft with his guard still on them (Crystal Dwarves, Shade Knights, a hound), to the Zenis Gate (61,-9): a shrine, and the gate of Zenis, black meteor-iron with four ring sockets that glow for the rings you hold. It does not open yet: Shadow Eura (8.8) waits before it. The Sunken Spring's way down is marked, sealed, at the foot of the Rise (optional, M7). As built (pass 86): three cracked stones in the Rise's floor, under the sign; the Mattock breaks them, and the flooded shaft below drops into the Sunken Spring.
  - Dartmoor drains (pass 73, a first step): once he is at rest the drowned dwarves wake. His steward Hrafna stands by the empty throne and a mason in the Drowned Market, both saying the water is going down. The time-locked water stays where it is: the water-clocks still hold their hour, so the Hour Glass routes are unchanged. Since pass 259 the Flooded Hall and the Drowned Nave stand in water until he is at rest and keep a tide mark after (4.4).

### 8.8 Shadow Eura, the Mirror (Dartmoor, Zenis gate)
- **Concept:** A shadow copy of the player, made from every fight the meteor has watched. Uses your abilities and your equipped spell.
- **Arena:** a mirrored hall with a reflective floor; the player's reflection is the boss.
- **Tests:** mastery of all movement.
- **Phase 1:** mirrors your inputs with a delay.
- **Phase 2:** acts on its own, using your highest-level skill tree branch against you.
- **Phase 3:** splits into two; one is real (only the real one shows in the floor reflection).
- **Reward:** a skill point, and the Zenis gate opens.
- **As built (phase 1, pass 74):** the gate hall (`dartmoor/zenis_gate`) is laid out symmetrically, with a landing at
  each end, and a faint seam of light marks the mirror line down its middle. The shadow (`scripts/bosses/shadow_eura.gd`)
  stands where you were 0.6 s ago, mirrored across that line, in your own pose, drawn as your sprite cut out of the dark
  with a violet rim. Each swing you make comes back at you 0.6 s later from its side, its blade glinting for 0.4 s first,
  so you can only reach each other where you meet at the line, and a blow you land is answered. Step away from the echo
  or parry it: a parried echo leaves it reeling and out of the mirror for 1.2 s. If you hold still for 2.2 s it sinks
  into the floor and rises right behind you, blade raised for 0.45 s, then cuts. Until phases 2 and 3 are built it has
  150 HP, and beating it gives a skill point. The gate does not open yet, because Zenis beyond it is not built.
- **As built (phase 2, pass 75):** HP is now 240 (320 since pass 218, 5.5), and below half the glass bursts. The shadow is untouchable for 1 s,
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
- **Reward:** a skill point for each of its three forms (the avatar, the veins and the heart), then the ending; credits climb up the Tree from Eolis to the crown.
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
    past a drift pocket to the flesh. The pocket lifts you to an altar where the **Dragon Slayer** lay (legend
    `&`; tier 4 blade: slash 18, heavy 30, reach 12) until pass 217; it is now King Grieve's (8.7), and the altar is bare. The way on is
    closed by a **heart seal** (legend `+`, `HeartSeal`): a wall of living flesh with a seam of cyan light and a
    watching eye. Every other blade glances off it, and one cut with the Dragon Slayer tears it open for good.
    Beyond it, the heart (the Evil One's arenas) is next.
  - **The Proving Scar, as built (pass 170):** the zone table promised Zenis a "gauntlet using every ability",
    and 4.2 puts it between the Dragon Slayer and the Evil One, but until pass 170 the Heart Gate opened straight
    onto the throne, and the climb to it asked for nothing past the Glove, the Hour Glass and the drift. Now the
    Heart Gate's door 2 opens on **The Proving Scar** (`zenis/proving_scar`, 67,-12, 80x45), a scar through the
    meteor that walks every earlier road once more, one gate after another:
    1. A **fire seal** that only Deluge puts out.
    2. A **chimney** 23 tiles tall with no ledge in it, climbed only with the Climbing Glove.
    3. Two **steps** six tiles high whose faces are lined with thorn bulbs, so no glove can climb them. Only the
       Wing Boots' second jump reaches the top.
    4. A **gap** nine tiles wide over a pit, crossed only with the Elven Stride's dash. A Storm Harpy hangs in the
       pit, and thorns line the far wall so you can't climb out of the pit onto the far side.
    5. A **conduit gate** that only Thunder wakes, guarded by a Shade Knight.
    6. A **plug of cracked stone** that only the Mattock breaks, over a shaft down to a hound.
    7. A shaft of **time-locked water**, climbed only while the Hour Glass holds it.
    8. An **illusory wall** at the top, which the Black Onyx shows.

    Past these, the last hall holds a shrine before the throne's door. Its foes are corrupted like every Zenis
    foe. The checker crosses the Scar with every ability and fails without any one of them
    (`test_the_proving_scar_asks_for_every_ability`). The throne and the arenas past it moved two screens east
    on the map (throne 69,-11, veins 71,-13, heart 72,-13), and Zenis now has 8 of its 14 rooms.
  - **Phase 1, as built (pass 81):** the Heart Gate's door 2, past the flesh (and since pass 170 the Proving Scar), opens on the **Throne of Zenis**
    (`zenis/throne`, 69,-11 since pass 170, 60x23, `boss: evil_avatar`), a long hall with two hanging planks and the throne's
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
    (`zenis/veins`, 71,-13 since pass 170, 40x68, `boss: evil_veins`), a tall shaft of meteor flesh climbed on zigzag one-way
    ledges three rows apart. At its vault hangs the **core** (`EvilCore`), a crystal eye-flower that watches you.
    No blade reaches it. It feeds through six **light veins** (legend `x`, `LightVein`) grown above the ledges up
    the shaft; one cut (or a pogo, which also bounces you) severs a vein, and its health bar is the veins still
    lit (10 each). While you climb it fires **core beams** (`CoreBeam`) at you: the line flickers for its tell
    (0.6 s) and then burns for 0.35 s, 16 damage, unparryable. The core's `zap` marks the line; since pass 244 the lance sears as it fires (`core_beam`: a whoomph of light, a falling whine, a low thrum), so the dodge has a beat to the ear. Until then every other tell-then-strike hazard in the game sounded its strike, and the beam, the final fight's main pressure, was silent (`test_a_cores_beam_sears_as_it_fires`). Below half (three veins left) the tell is 0.45 s,
    volleys come every 1.6 s instead of 2.2 s, and every other volley is a pair of beams fanned to either side of
    you (stand still between them). The Hour Glass holds the core and its beams. With the last vein cut the core
    gutters ("The Veins Go Dark", 1 skill point); the veins stay dark for good (`boss:evil_veins`). Deviation:
    the bible asked for wall jump and dash here too; the as-built shaft is a ledge climb so the beams are the
    pressure, and wall jumps are allowed but not required. Phase 3 (The Core) is next.
  - **Phase 3, as built (pass 83):** a door high on the Veins' east wall, reached from a ledge under the vault,
    opens on **The Heart of the Meteor** (`zenis/heart`, 72,-13 since pass 170, 60x23, `boss: evil_one`), a long chamber with two
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
  - **The ending, as built (pass 84):** four seconds after the heart dies (the banner shows first; since pass 247
    the four seconds stop while the game is paused, where the ending had come on under the pause menu and shut it, and
    the wait belongs to the arena, so a world torn down in them never ends the game; `test_the_ending_waits_out_a_pause_and_dies_with_its_world`) the game
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
  - **The farewell (pass 167):** Faxanadu ends with the hero thanked by Eolis and leaving it, a wanderer
    again. The remake's epilogue had stopped at the fountain. Two last cards now close every ending, after the
    secret one's too: "In Eolis, the King waits by the full fountain to thank you." and "But the wanderer is
    already on the east road, walking on." While they show, the hero (the player sheet's own run cycle, drawn as
    a dark shape against the dawn, `EndingScreen.FAREWELL`, `wanderer_x`) walks out of the foot of the Tree and
    off the east edge before the climb begins. The plain epilogue is now six cards (24 s), the secret one nine.

### 8.10 Optional boss
- **The Drowned Warden (Sunken Spring):** an ancient guardian of the spring source; the hardest fight in the game; drops the Battle Suit.
  - **As built (pass 87):** the Source Hall's east wall opens on **the Wellspring** (64,-5, 60x45): a deep pool from row 20 down, an entry ledge and a far ledge with steps down to the water, two islands level with the surface and a plank over the middle. The Warden (`DrownedWarden`, 680 HP (520 until pass 218), boss id `drowned_warden`, music `warden`: E minor at 126, a rolling bass under a galloping beat and a fast ripple) is a colossus of pale limestone and green bronze with a dwarf-king's helm, lamp eyes and a trident, standing waist-deep; it rises out of the deep to begin and wades the pool between the islands (they hide its lower half).
    - **Thrust** (within about 12 tiles): the trident draws back, aimed at you and tracking for most of the 0.6 s tell, tines glowing, then drives 150 px along that line for 18. Parry it and it reels for 1.4 s, open.
    - **Wave** (farther, and every third attack in phase 1): arms raised and the water churning for 0.7 s, then a `TidalWave` runs across the surface at 230 px/s, 40 px tall and 24 px deep, 16 unparryable. Jump it, or dive under it (swimming, 6.8). In phase 3 a second wave follows from the far side.
    - **Geyser** (phase 2+, every third attack): it sinks out of sight (untouchable) and stalks you under the water, a trail of bubbles the only sign; the water boils at your spot for 0.6 s, then it bursts up through it in a 44 px column of water, 20 unparryable, and hangs streaming for 1.3 s, open to every blow.
    - **Undertow** (phase 3, every fourth attack): its chest lamp opens (0.6 s) and the current drags you toward it at 85 px/s for 1.4 s; then the trident goes up (0.45 s) and it slams around itself for 22, parryable.
    - Its stone halves blows from the front; from above (the plank is there for a pogo), from behind, reeling or hanging open it takes them all. At two-thirds and one-third it roars (1 s, untouchable) into the next phase; tells shrink to 0.88x and 0.75x, never under `Enemy.MIN_TELEGRAPH`. Contact hurts for 14.
    - **Reward:** the **Battle Suit** (armor tier 4, 60% less damage) goes straight on (BossArena reward key `armor`), with a skill point; every armor in the shops then shows as owned. It crumbles and sinks back into the spring.

Mini-bosses (about one per zone): The Foreman (rock golem), Marsh Hag Matriarch, Bark Knight Captain, Clockwork Alpha. All four are built (the Matriarch last, in pass 179).

**The Bark Knight Captain (built pass 171).** `scripts/bosses/bark_captain.gd`, code-drawn at 3x: the first knight the World Tree grew, half again as tall as his Bark Knights, with five plates of bark over pale heartwood, a crown of living leaves and a bough lance six tiles long. He keeps the Thorn Yard (`branches/thorn_yard`, 46,-8, 40x23), through a new east gate in Conflate (door 3), on the `miniboss` theme. 240 HP. His moves, each with a tell of at least the minimum: His bough is footing like his knights' lances (pass 176, `test_the_captains_bough_holds_your_weight_until_he_pulls_free`): you land and stand on it, Down + Jump drops through it, the Mattock pogoes off it, and when he pulls it from under you the usual coyote time still lets you jump before you fall to the floor. Fire burns his whole bark coat off at once, as it does his knights' (pass 177); a plate still grows back each time he pulls free, so the Fire spell bought in Mascon is the Thorn Yard's answer to his guard, at 20 MP a cast.

- **Thrust** (0.65 s tell, braced with the lance back): when you are level and within about seven tiles he drives the lance out to 110 px for 18, parryable. Then he roots for 1.3 s and the lance stays out as a one-way bough you can stand on or pogo off.
- **Vault** (phase 2, 0.7 s tell): when you keep your distance or stand off his level, he pole-vaults high and comes down lance-first where you stood, for 20. He hangs planted in the floor for 1.4 s.

His bark works like his knights' (section 7): while he wears it, every blow chips one of five plates and lands a quarter. Bare, or open, he takes blows in full, and a blow while he is open chips nothing. Each time he pulls free of a root or a planted lance, one plate grows back, so a slow fight never strips him. He is open while rooted, while planted, and while reeling from a parried thrust (1.4 s). Below half his tells are 20% shorter. Reward: a Mana Dew (no skill point). He is not in the Boss Rush.

**The Marsh Hag Matriarch (built pass 179).** `scripts/bosses/hag_matriarch.gd`, code-drawn at 3x: the oldest of the Mist's hags and mother of all of them, grown huge and bent under a bell of dry reeds and a heap of moss, a great marsh-wisp in the crook of her willow staff. She keeps the Matriarch's Mire (`mist/hag_mire`, 35,-6, 40x23, fog 0.5), through a new east door at the end of Mascon's boardwalk (door 2), on the `miniboss` theme. Two plank shelves at either end and a high one in the middle give height to dodge from. 230 HP, contact 10. She fights as her daughters do, from a distance and through the fog, and her wisp (a light, brighter while she casts) shows where she is. Her moves, each with a tell of at least the minimum:

- **Hex** (her staple, 0.8 s tell, staff raised, a cackle over welling bubbles): rings of bog light mark the floor under you and to either side, 40 px apart (three marks; five below half). Then a mud hand bursts out of every mark (`MireGrasp`, 16 since pass 226, unparryable): step between them, or onto a plank. Strike her mid-hex and the whole spell breaks: every mark fizzles, the breaking blow lands in full, and she gropes for her staff for 1.4 s, open.
- **Sink** (0.5 s tell, bubbles and a gurgle as she settles): stay within five tiles of her for half a second and she sinks into the bog, untouchable for 0.6 s, and rises (0.4 s) at the far end of the mire from you. She drifts away from you as she walks, so you must chase her through the fog.
- **Call** (below half, every third move while no daughter walks; 0.7 s tell): she calls a Marsh Hag up out of the bog at the far side, never more than one at a time. The daughter sinks with her when she dies.

Her reed shawl halves every blow unless she is open: groping for her staff, or reeling from a parry (1.2 s; a parry also fizzles any marks). Below half her tells are 20% shorter. Her voice is her own (`matriarch_cackle`, `bog_sink`, `bog_rise`) over her daughters' hex sounds. Reward: a Mana Dew (no skill point). She is not in the Boss Rush. Tests: `test_boss.gd` (the Matriarch's tests, and `test_a_blow_mid_hex_breaks_the_spell_and_opens_her`).

**The Clockwork Alpha (built pass 169).** `scripts/bosses/clockwork_alpha.gd`, code-drawn at 3x: a great brass hound with a crown collar and a winding key in its back, the first of King Grieve's Clockwork Hounds. It waits in Alpha's Den (`dartmoor/alpha_den`, 57,-6, 40x23), under a plank-lidded shaft in the King's Kennels' floor, on its own `miniboss` theme. 260 HP; its plating halves every blow unless it is open. Its moves, each with a tell of at least the minimum:

- **Pounce** (0.6 s tell, a crouch and a ratchet): a leap at you with a bite of 18. It skids 0.55 s on landing.
- **Charge** (0.7 s tell, the key spinning): it runs at 300 px/s (340 in phase 2) for up to 2.6 s, with a body blow of 20. If it reaches a wall it jams there for 1.6 s, gears spilling.
- **Howl** (phase 2 only, 0.8 s tell): it winds a Clockwork Hound pup out of a grate at either end of the den, never more than 2 at once. Its pups run down when it dies.

It is open when a parry flips it (1.5 s on its back), when it is jammed in a wall, or while the Hour Glass is turned: clockwork stops dead in stopped time, in the air or not. Below half its tells are 25% shorter. Reward: a Life Fruit (no skill point; a mini-boss gives none). It is not in the Boss Rush, which keeps to the zone bosses and the Foreman.

---

## 9. Skill Tree

The **Guru** in each town teaches skills. Points come from:
- **Ranks:** XP from kills raises your title, using the original's 16 ranks (Novice, Aspirant, Battler, Fighter, Adept, Chevalier, Veteran, Warrior, Swordman, Hero, Soldier, Myrmidon, Champion, Superhero, Paladin, Lord). Each rank after Novice = 1 point (15 total).
- **Bosses:** 1 point each from the 12 guardians whose reward names one (12 total): Rokusutahn, Zoradohna, Ripasheiku, Zorugeriru, Pakukame, Borabohra, King Grieve, Shadow Eura, the Drowned Warden, and the Evil One's three forms (avatar, veins and heart). The Foreman and the three mini-bosses give their prize instead (8).
- **Mantra Shards:** hidden secrets; 3 shards = 1 point (15 shards, 5 points, plus one from each of the six Guru Trials: 7 points in all). Pass 243 turned the two spare shards the rooms had grown (17, so two never made a mantra) into chests, in the Slag Heap and on the Marsh Road.

That is **34 points** available against a tree planned at **68** in all (49 as built, over 27 nodes), so players must choose. (Pass 333: this line said 54, the first draft's total. The list below, three branches of twelve, has cost 68 since that draft, and nothing summed it. `test_the_bible_prices_the_skill_tree_as_built` now adds up the list's brackets, holds each built node's bracket to `data/skills.json`, and holds the built total and node count to the code.) **Counted since pass 253:** this line said 29, from the 9 main bosses planned. But the guardians built since then each give a point, so the game has handed out 34 since the Evil One's forms were built. Nothing checked it. `Completion.skill_points` now counts every source (ranks from `GameState.RANK_XP`, the guardians' rewards in `BossArena.BOSSES`, and the rooms' Mantra Shards plus one for each Guru Trial, three to a point). The Journey page shows "Skill points" earned against that whole. Earned is the points held plus what the learned skills cost, so learning and unlearning never move it. Test: `test_the_journey_counts_every_skill_point_the_game_gives` pins it at 34. Respec at any Guru for gold (200 g, then 400 g, 600 g and so on, capped at 2,000 g).

Rank XP thresholds (in `GameState.RANK_XP`): 0, 40, 100, 180, 300, 460, 660, 900, 1,200, 1,560, 2,000, 2,500, 3,100, 3,800, 4,600, 5,500. Starting enemies give 5 XP (Rot Dwarf 12), so the Trunk Hollows take a careful player to about Fighter. Ranks rise the moment you pass a threshold and give the point right away; the Guru is where you spend it. As in Faxanadu, the title itself is the Guru's to give: the next time you visit one after ranking up, the Guru names you by your new title ("From this day you shall be called ADEPT") to a short fanfare while the music dips, then opens the usual menu. Higher ranks hear grander words. `GameState.data.named_rank` remembers the last title named.

Three branches, 12 nodes each. Costs in brackets. Nodes deeper in a branch need the one before.

**What a skill waits on (pass 237).** A branch deepens in order, not by what you have found, so a skill can be learned before the ability or spell it works through. Mattock Mastery can be learned before the Foreman, Time Thief before the Hour Glass, and Feather Fall before the Wing Boots. Only Second Stride, Feather Fall, Tilte Swarm and Mantra of Death said so, and only in their own words. Now each of the nine names what it uses (`uses` in `data/skills.json`: the Mattock, Deluge, Tilte, Thunder, the Hour Glass, Death, the Stride twice, and the Wing Boots). Until that is found, its line in the tree ends "Does nothing until you find the Wing Boots." (`Skills.waits_on`, `Menus.skill_rows`). Nothing stops the choice, since a point spent ahead still pays off later, but the tree no longer spends a scarce point without saying so. `test_the_skill_tree_says_what_a_skill_waits_on` checks every "uses" against the real abilities. It also catches a skill whose text names an ability without one, and keeps every line within the menu's three.

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
- **Mantra of Death (pass 134)**, the Arcana branch's capstone, after Time Thief [3]: the Death spell costs half its MP (`Player.MANTRA_OF_DEATH_MULT`, applied after Thrift by `Player.spell_cost`), so 20 MP, or 17 with Thrift. The scroll alone already unlocks Death, so the node's "unlocks the spell" half is dropped; its menu line says it needs the scroll. The built tree now costs 41 points against the 34 the game gives (counted as 29 until pass 253).
- **Wanderer**, after Second Stride: Feather Fall [2] (pass 101, see 6.10), Treasure Sense [2], Resilience [2], Last Stand [2], Second Wind [3].
  - Treasure Sense puts an orange star on every room the map shows (seen or charted) that still holds an item or chest. The World's catalog lists each room's treasures.
  - Resilience adds one mask (`GameState.RESILIENCE_HP`).
  - Last Stand: below 20% health, you take 25% less damage.
  - Second Wind: once between rests (a shrine, a Guru or a respawn), a killing blow leaves you at 1 HP.
- **Wanderer's Grace (pass 142)**, the Wanderer branch's capstone, after Second Wind [3]:
  - A dash lets harm pass through you for 0.2 s instead of 0.1 s (`Player.GRACE_INVULN`, `Player.dash_invuln`).
  - Any foe's death gives back the air dashes you have spent (`Enemy.die` calls `Player.on_kill`), with a puff of feathers and a catch of wind. So a kill in midair can be dashed out of, and a run of kills across a gap can carry you over it.
  - The built tree now costs 44 points (Wanderer 19 over 10 nodes) against the 34 the game gives (counted as 29 until pass 253).
- **Thrust (pass 149)**, the Blade branch's eighth node, after Bloodletting [2]: Faxanadu's thrust, as a charged move.
  - The press still swings at once, so the charge builds through the first cut. Held past `thrust_charge` (0.4 s), the blade rings and a spark of light runs off its point. Let go and you thrust.
  - The thrust deals the heavy hit times `thrust_mult` (1.5) through `blade_mult()`, so Keen Edge and the War Glove count. Its point is a long, low box, 52 px past the body (a cut reaches about 34) and half a cut's height. It strikes every foe in it once and drives them back like a heavy hit.
  - On the floor it lunges at 320 px/s for 0.16 s, about 50 px. The lunge stops at the first foe it strikes and recoils like a cut, so it never carries you into a body. Off a ledge it ends, and you step off at no more than a run (pass 153; until then the lunge's full 320 px/s threw you about 67 px out past the lip, four times a run's step). Down a ramp it hugs the floor like a ground dash (10 px snap, 6.5) and rides the slope to the end. In the air the thrust strikes where you are and carries you nowhere, so it never crosses a gap the Elven Stride gates.
  - A blow, a dash, a guard, a drink, a ladder or the water spends the charge. Shadow Eura echoes a thrust as a cut.
  - The built tree now costs 46 points (Blade 13 over 8 nodes) against the 34 the game gives (counted as 29 until pass 253).
- **Executioner (pass 163)**, the Blade branch's ninth node, after Thrust [3]: melee blows on a boss in its opening land for 35% more (`executioner_mult` 1.35, in `combat_tuning.gd`). A common foe gets nothing more, nor does a boss on its guard.
  - Each boss names its opening (`Enemy.punishable()`; for a boss of pieces, `BossSegment.punishable()` asks the boss), so the skill has a window in every fight (8). Bloodletting heals on the same openings. Until now it read only a parry stagger, which most bosses never take.
  - The built tree now costs 49 points (Blade 16 over 9 nodes) against the 34 the game gives (counted as 29 until pass 253).

Deviations, and why:
- The build order skipped Thrust (built in pass 149), Wildfire and the rest. They are bigger mechanics and still come later in their branches.
- Light Step is dropped: a dash's own invulnerability already carries you over spikes, so the node did nothing.
- Pathfinder is dropped: shrines already refill potions.
- Treasure Sense takes Light Step's place in the build order, at 2 points.
- **Every number on a skill's page is the code's (pass 322).** Each built skill's in-game page (`data/skills.json`) and its line in this list name the number the code gives: the skill is learned alone and its effect read off the hero (`test_every_skill_page_names_the_number_it_gives`). Nothing held them before, so retuning Bloodletting or Quick Draught would have left both promising the old figure. Executioner's line here said "staggered bosses"; it pays on any opening (pass 314 gave every guardian one without a shield), as its page says.

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
11. Executioner: +35% damage to a boss in its opening (staggered, or any opening section 8 names) [3]
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

**As built (the gold sheet, pass 197).** Until pass 197 a table here promised drops of 35 to 70 g a foe in Dartmoor. In the code no foe paid more than 16 anywhere, so "scaled by zone" was not true: the chests carry the economy. Pass 197 makes it true by the same measure as the damage. A foe's gold is multiplied by its zone's threat (5.5, `Enemy.die` through `Room.threat`), so a Dartmoor foe pays double for hitting double. A Zenis foe pays double again for its corruption. A boss's purse (60 to 500 g) takes its arena's threat as well, as its blows do (pass 196). The numbers, from the rooms:

| Zone | Foe drop (after threat) | Chests (count, range) | Chest gold | One pass of foes |
|------|------|------|------|------|
| Eolis | none | 3: 60 to 1,987 | 2,167 g | none |
| Trunk Hollows | 2 to 9 g | 9: 90 to 150 | 1,080 g | about 240 g |
| Tower of Trunk | 2 to 14 g | 13: 160 to 300 | 2,980 g | about 420 g |
| The Mist | 4 to 17 g | 8: 180 to 900 | 2,780 g | about 260 g |
| Branches | 3 to 18 g | 7: 260 to 1,800 | 4,040 g | about 160 g |
| Daybreak | 3 to 26 g | 5: 380 to 3,200 | 5,220 g | about 190 g |
| Dartmoor | 16 to 32 g | 6: 520 to 5,000 | 8,640 g | about 540 g |
| Sunken Spring | 12 to 32 g | 2: 120 and 160 | 280 g | about 120 g |
| Zenis | 8 to 64 g (corrupted, x2) | none | none | about 1,080 g |

**Par without grinding**, held by `test_the_par_kit_is_affordable_without_grinding`. Start with the King's 1,500 g, open half the chests and fell each foe once. That is enough to buy the damage sheet's par kit (5.5) at the shops where it stands: the Long Sword and Leather in Eolis, Studded Mail in Apolune after the Trunk, Temper I in Forepaw after the Tower, and Temper II and Full Plate after Daybreak. About 3,700 g is left after Full Plate. Potions are a flask refilled at every rest, not bought, so the deeper damage costs no gold. Ointments (300 g) and the Elixir (1,500 g) keep their prices.

The goal: buy one key upgrade per zone without grinding, and buy everything only if you explore.

**Gold stays in the room (pass 285).** Pass 283 kept every food and item drop inside its room, but coins were left out. A coin falls until something stops it, so gold from a foe slain over a floor gap fell through and was lost unless the hero stood within the magnet's 100 px. Struck from a ladder with a Rune Dagger or a spell, the Tower's two Nagas lost 18 and 13 of 72 test coins down their shafts. Coins now keep to the room by the same rule as drops (`Drop.keep_in_room`): a coin stops at a side edge, and one that falls through a gap rests on the floor at the gap's nearer edge. `test_a_nagas_gold_lands_where_you_can_reach_it`.

**No drop rests at a side door (pass 307).** A drop or coin that reached a side edge stopped 8 px in, inside the door's cell, and one could also come to rest on the tile just inside. A door is three tiles tall, so a jump over a flask there meets the wall above the door and drops you on it: once pass 306 made poison bite 4 a second in the deep zones, a flask by a door was a toll on the way out unless you waited out its 10 s. Where the two tiles inside a side edge are open, `Drop.keep_in_room` now stops drops and coins on the second of them (`Drop.DOOR_CLEAR`, 40 px in). A hop from anywhere 20 to 44 px short of the flask clears it and lands short of the door (`test_a_drop_never_rests_in_a_doorway`); at one tile in, no hop of any timing did. Gold is drawn in by the magnet as before.

**No drop rests on spikes (pass 308).** Pass 300 moved a purse off the Bloom's torn leaf, but not the other drops. A Lilith struck down over a tear dropped its bread, mana or War Glove into the thorns, and bread lying on the leaf when it tore fell in after it. Taking it cost a blow, so the 2.5% War Glove was a trap. A drop that comes to rest on spikes, a torn pit's or a level's, now moves to the nearest floor beside them, at most four tiles up the pit's side (`Drop.SPIKE_STEP_RISE`). `test_a_drop_never_rests_in_the_thorns` tears the leaf under bread and drops a War Glove into the pit: both rest on the leaf and are taken without a blow. Gold needs no rule: the magnet draws coins out of a pit.

### 10.2 Shops

| Shop | Location | Sells |
|------|----------|-------|
| Weapon smith | Eolis, later Forepaw dwarf smith | Blades, smith upgrades |
| Armorer | Eolis, Apolune, Daybreak | Armor, shields |
| Item shop | every town | Ointment (10 s invulnerability, 300 g; carry up to 3, rubbed on from the pause menu), Elixir (auto-revive, max 1, 1,500 g), Mana Dew (one per shop, 500 to 1,200 g), Life Fruit (one per shop, 800 to 2,000 g). As built, every one of the original's eight towns has a keeper who sells an Ointment or an Elixir and one who sells Jack Keys, the original's tool shop and key shop (pass 209, `test_every_town_keeps_the_originals_shops`). The Mana Dew and Life Fruit stand in the larger towns' shops only (Eolis, Apolune, Conflate, Daybreak). The planned Poison cure (80 g) was dropped: poison lasts only 8 s (16 health in the Tower, 32 at most in the deepest zones), and bread, the Forepaw hospital and any rest at a shrine or Guru already clear it for free |
| Key master | Eolis, Victim, Dartmoor | Jack (150 g), Queen (400 g), King (900 g), Ace (1,800 g) keys; the Joker key is found. As built (pass 117), the grocers are the key masters: every grocer sells Jack Keys, Apolune's the Queen, Conflate's the King and Daybreak's the Ace, each a zone before its door. Victim's Keymaster Odo (pass 145) is the one key master by trade: Jack and Queen Keys, the Queen for the Feather Hollow's vault next door, with ointment and elixirs. **One key per door (pass 245):** each card has exactly one door in the world, yet every grocer cuts Jack Keys, so a second key of a card was gold for nothing. A shop stops selling a card's key once the keys you hold open every door of it still shut (`Shop.doors_shut`, read from the rooms by `World.world_locks`): the row reads "Enough" and says "Enough for every Jack door left", or "Its door stands open" once it is opened. `test_a_key_shop_sells_no_key_without_a_door` |
| Cartographer | Eolis, Forepaw, Victim, Conflate, Daybreak, Dartmoor | each zone's chart (40 to 800 g; one for every zone the map draws, Zenis aside), map pins. As built (pass 277): Apolune and Mascon keep none, since Eolis sells the Trunk's chart and Victim and Conflate the Mist's |
| Spell scrolls | Mascon, Daybreak | Fire (1,200 g), Tilte (2,500 g). As built: Mascon's Scribe Orla (pass 148) and Daybreak's Scribe Ysolde both sell Fire |
| Guru | every town | save, skill tree, respec, rank-up |

Daybreak as built (pass 57): Calder sells Full Plate (tier 3, 45% less damage, 4,200 g); the Magic Shield (3,600 g, parry reflects small projectiles) joined his stock in pass 91 (see 5.2). The scribe sells Fire, and Tilte (2,500 g) since pass 95. The grocer sells Elixir, Ointment, Jack keys and a Mana Dew (1,200 g, once), and the bell-ringer the Daybreak chart (700 g).

**Forepaw's hospital and larder (pass 175):** in the original, Forepaw kept a hospital, a meat store and an item shop, and the remake's Forepaw had only the smith and the surveyor, so it was the one town without an item shop. Now Provisioner Dagny keeps the Forepaw Larder (an Elixir 1,500 g, the Queen Key 400 g; her greeting offers the original's dried meat), and Physician Halvar keeps the hospital, the town's other house. Forepaw does not charge the one who silenced the drill, so his treatment is free: health and magic made whole and poison drawn out (`Npc.treat`, role `physician`). It neither saves nor refills the Red Potion flask, which stay the Guru's rest, so the shrine keeps its place; with nothing to mend he only talks. (Deviation: the original's hospital charged gold for treatment, 500 in Forepaw. A paid heal next to a free Guru rest would never be bought, so the remake makes it free and keeps the building and its role.)

**Mascon's tavern (pass 265):** the original's Mascon kept a bar, where the bar maid gave useful word and a man at the back told stranger things. The remake's Mascon had a Guru, a scribe, a grocer, a reedcutter and a ferryman, but no bar. Now the house by its Guru is **the Black Water**, under a tavern sign ("Ale, eel stew, and whatever the barges heard"). **Barmaid Brigid** stands at its door and **Old Cormac**, forty years an ore-barge poler, beside her; both are talkers drawn by `castgen.py`. What they say is true of the world, and the test holds it to the rooms:
- Brigid puts the Pendant (5.2, the original's Tower of Suffer prize) in the far corner of the Matriarch's mire past the east door, and Zorugeriru round the Spring of Mist past the Dry Cistern.
- Cormac names the messenger's boots at Feather Hollow by Victim, and warns of the Sunken Chapel.

Once the Tree blooms they have other words. (Deviation: no ale is sold, and the original's Mascon hospital, 1,000 g, stays Forepaw's alone, for the reason given above.) `test_mascon_keeps_the_originals_tavern`. Screenshot: `/mnt/project-files/pass-265/tavern.png`.

**The final tier (pass 93):** a shop entry can name a GameState flag (`requires`), and it stays off the shelf until that flag is set (`Shop.shelf`). With the Spring of Sky restored (`spring:sky`), trade returns on the sky road: Eolis Arms stocks the Dwarvish Broad Sword (2,800 g, 5.2; the Giant Blade until pass 186) and Daybreak's grocer a Life Fruit (2,000 g, once), the top of the Life Fruit range. (Deviation: the bible paired the Broad Sword with no shop or moment. It arrives here because the sky road is what the Spring of Sky restores, and because by then the player can afford it.)

**Gold sinks:** respecs, Ointments and Elixirs, keys for optional doors (each guards a reward), smith upgrades, cosmetics (cloak dyes, 6 total, purely visual). **As built (pass 136):** Ilse the Dyer keeps Ilse's Dyeworks in Eolis's Market Row. She sells six cloak dyes: Ember Red 300 g, Tide Blue 500, Dusk Violet 800, Ash Grey 1,200, Saffron 1,800 and Night 2,500. A new dye goes straight on. One you own, or the Warden Green you start in, is worn again for nothing ("Wear"; the one on shows "Worn"), here or, since pass 189, from the Equipment page anywhere (5.2). The save keeps `dyes` and `dye`. The player sheet's cloak is its only green, so `shaders/cloak_dye.gdshader` recolors every green texel to the dye and keeps its shading (`PlayerVisual.dye_look`). The bible's "Lord" glow is the seventh dye: see 11. **Mantra dyes (pass 164):** the Guru Trials' cosmetics. Each trial has a mantra time (`Trials.LIST` `mantra`): Walls 12 s, Edges 14, Thorns 15, Winds 14 and Stillness 32. Ring its bell within that time and the trial dyes your cloak a color of its own, with a toast: Mantra Slate (Walls), Ledge Coral (Edges), Thorn Rose (Thorns), Wind Jade (Winds), Still Frost (Stillness) and Plummet Umber (Falling, pass 168, a8703a). `GameState.earn_dye` owns it, puts it on, and sets the flag `dye:<id>`, which puts it on Ilse's shelf (price 0, `requires`) to wear again. The Guru's list names each open trial's mantra time and its dye, or says the dye is yours. The mantra times are set from each course's length and its waits: the Thorns pogo hand clears in about 12 s, and Stillness needs about 29 s with both waits at the niche. They ask for a clean run, not a perfect one.

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
| Life Fruit | 18 (13 in the rooms) | Mix, plus grocers and a mini-boss | +HP |
| Mana Dew | 16 (9 in the rooms) | Mix, plus grocers and three guardians | +MP |
| Potion Shards | 9 | Mix | +flask. Held with the rooms' Life Fruit (13), Mana Dew (9), Mantra Shards (15) and Meteor Shards (5) by `test_the_rooms_hold_the_finds_the_bible_counts` since pass 243 |
| Mantra Shards | 15 | Mostly hard platforming | Skill points |
| Meteor Shards | 5 (pass 140; was 10) | Hard rooms, hidden pockets | The smith's second temper (5.2). Each blade takes one, so five (one per blade and one spare) replace the planned ten, and none drop from foes: a shard is a find, not a grind |
| Guru Trials | 6 | Unlock as springs are restored | Cosmetics, a Mantra Shard each |
| Lore tablets | 12 | Dwarf ruins | Story, map hints |

**The signs remember (pass 251):** a sign was carved once and never changed, so the world told you of things long after they had happened. The Eolis fountain stayed "dry for a season" with all three springs flowing. Amber Falls said "when the spring runs again" after it had. Five bosses still "waited" or "drilled" after they were beaten, and the Spire Foot's gate stayed "cold" once it stood open. Now several sign lines may stand on one cell, and they make one tablet. A line may open with world flags in brackets, the same as a person's fourth field (`[spring:trunk]`, `[boss:king_grieve]`, `[!x]`). When the tablet is read, it shows the first line whose flags all hold, and a plain line holds always, so the plain line goes last as the old text. The tablet picks its line when you read it, so a spring cleared in its own room changes the sign there at once. 16 rooms have a line for afterwards: the plaza fountain (part full, then full), Amber Falls, the Spring of Trunk's spout, the Root Chamber's gate, the Scorched Hall, the Victim Causeway, the Spring of Mist and the Spring of Sky (each for the boss beaten, then the spring cleared), the Hag Mire, the Forepaw Lift's gate, the Spire Foot's gate, the Spire Stair, Alpha's Den, the King's Kennels, the Source Hall and the Windloft. Tests: `test_a_tablet_reads_what_the_world_has_become`, and `test_every_world_change_rewrites_its_sign`, which checks that every bracketed flag names a real boss, spring or room of conduits, that every cell ends on a plain line, and that each of these signs has its line.

**Easter eggs:** a hidden room in Eolis rendered in authentic 8-bit NES palette and resolution, with the original's music style; the Guru recites the old password mantra as a joke ("Your mantra is..."): resting with him shows a 16-letter mantra made from your progress (`GameState.mantra()`); it is never typed back in. A secret ending if you reach the Evil One with no deaths and the Battle Suit.

**Eolis of Old (pass 152):** the hidden room is built. In the Temple of Mantras, the stone at the east end is a fake wall over a small chamber with a door (`secret:` cover, so it counts as a hidden room). Up at the door goes to Eolis of Old (`eolis/old_eolis`, a room of its own on the map above the temple): the town as a cartridge drew it, with a fountain, a stair of square blocks, two tablets of new text and a chest of 1987 gold, the original's year. A room header `retro: true` turns on `RetroFilter`, a layer under the HUD that cuts the world into blocks of 2 world pixels (240 x 180 in a 4:3 frame with black bars, close to the NES's 256 x 240) and matches each block to the nearest of the NES palette's 55 colours (`shaders/retro.gdshader`; since pass 155 each block is exactly 2 x 2 world pixels: the world view draws at `GameCamera.DETAIL` with a pixel of margin, and the filter takes its scale from that, where it had divided the view's height by 360 and drawn blocks of 4.02 render pixels that drifted across the world's pixels). The HUD stays sharp, so the game's own controls still read. The music is `old_eolis`, a new tune in F major at 132 on the 2A03's four voices only: a 12.5% pulse lead, a 25% pulse playing the chords as fast arpeggios, the stepped 4-bit triangle walking the bass, and the noise channel for drums, all dry. It is not the original's town theme (16: no remixes of NES tracks). There is no ambience in the room.

**Completion screen:** shows % with category ticks; 100% unlocks a boss rush and a "Lord" title glow on the cloak. As built (pass 106), it is the ending's thanks card: "Thank you for playing", then one percent "of the world" in large type, and four rows counted up over 1.2 s as the card fades in. The rows are rooms explored, hidden rooms (rooms with a `secret:` cover whose flag `secret:<room>` is set), treasures (the catalog's item and chest ids collected; since pass 187 this includes the finds a `prop:` line lays, the Battle Helmet and the Joker Key, which had been left out of the percent, the Journey and Treasure Sense although they lie in rooms like any other find. `Room.FOUND_PROPS` lists them, and the catalog gives each the id the room gives its pickup) and bosses beaten. The percent is their average, rounded down, so 100% means every row is whole. A whole row turns gold. Below come rank, time and deaths, plus the clear count from the second clear on (`Completion.tally`, `EndingScreen.completion_rows`). The boss rush is built (pass 156, `BossRush`). The Guru of the Temple of Mantras offers it under the Guru Trials. It stays sealed until the `lord` flag is set, and the row then shows the best time. It runs all 13 guardians in the order of the critical path, with the Drowned Warden before Zenis. Each fight is in the boss's own arena, entered by door 1, the way you first came in, and starts the usual way as you walk in. You begin whole, with full magic and potions. Between fights a toast counts you on, and the mantra mends a third of your health and all your magic. The clock runs from the first arena to the last blow, and the HUD shows the count, the clock and the best time. Nothing is won again: no rings, keys, flags or gold, no doors open, and the Evil One's fall plays no ending. **Pass 260:** that held only for what the arena hands out. A guardian's real death still sprayed its gold, rolled a drop and gave its experience every rush (Rokusutahn paying on his own, the rest through `Enemy.die`), and so did any foe it called in (Liliths, daughters, hounds): a rush won some 3,000 experience and a purse each time. The rush test ended each fight by the arena's signal, so it never saw a real death. Now nothing that dies in a rush leaves gold, a drop or experience. `test_a_boss_rush_kill_wins_no_gold_or_experience` kills the first guardian and a foe beside it for real, and requires every script that pays on its own to ask the rush first. A blow that would kill you, with no Elixir to save you, ends the rush ("The Rush Ends") and carries you back to the Guru whole. Winning it keeps the best time in `data.trials["boss_rush"]` and carries you back too. "Leave the rush" in the pause menu stops it. Sound (pass 157): the arenas wait under the trials' theme (`trials`, the mantra-space carrying you on) in place of their zone's music, and each boss brings its own track when it rises. When a boss falls the theme returns, and the bronze bell of the trials rings soft with a warm swell rising a fourth as the mantra mends you (`rush_mend`). The win rings the bell three times up the major chord, the last left ringing (`rush_won`), with the record sting on a new best. A fall tolls the bell low and muffled over a sinking drone (`rush_fall`), and the music stops. Edges (pass 158): no one stands in an arena during a rush (King Grieve's steward waits outside it), and a shrine on the way (the Zenis gate's) allows no rest, so it neither refills nor saves. Once a rush is won or lost the clock stops, and a second fall does nothing. A move that finds the world mid-fade waits for it. The moves between arenas pause with the pause menu, and they do nothing once the world is gone (quit mid-rush). A new or loaded game always starts with no trial or rush under way. The cloak's glow is (pass 136): a clear at 100% sets the `lord` flag (`Completion.award`), and the Lord's Gold appears on Ilse's shelf, free. A pale gold cloak with a band of light running down the cloth.

**The Journey page (pass 172):** the percent was only ever shown on the ending's card, yet 100% gates the Lord's Gold and the boss rush, and the mini-bosses (section 8) now count among the guardians. So the pause menu has a **Journey** row, between Controls and Quit. It opens a read-only page with the same `Completion.tally` the ending uses:

**Life Fruits and Mana Dew on the Journey page (pass 180):** the planned 14 fruits and 9 dews counted only the finds in the rooms; the grocers' shelves (one of each per town shop, 10.2) and the mini-bosses' rewards had raised the real totals to 18 and 16 without the stat table above noticing, so the true ceiling is 14 masks and 220 MP (240 with Clear Mind). `Completion.stat_items` counts every source (the rooms' `L` and `W` cells, the shops' stock, the guardians' rewards) and reads a save's share from its health and magic, which nothing else raises. The Journey page shows Life Fruits and Mana Dew under the guardians, so a player hunting the last one knows how many remain. They stay outside the percent, which already counts the ones in the rooms as treasures. Test: `test_the_journey_counts_every_life_fruit_and_mana_dew` pins the totals to this table.

- the percent "of the world";
- rooms explored, hidden rooms, treasures and guardians beaten, each as found / total;
- under "Guardians found", every guardian whose arena you have entered, in the order of the climb (`Completion.GUARDIANS`), marked Beaten or Waits;
- a last line counting those not yet found.

An arena you have not entered is never named, so the page spoils nothing. The world catalog records each room's `boss:` header so the page can tell which rooms are arenas.

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
| **PixelLab** (API via `tools/art/pixellab.py`, or its MCP server in `.mcp.json`; token as a cloud network secret for api.pixellab.ai) | The hero and his gear (13.5, Sean 2026-10-30), and a second source for other generated art: characters with 4 or 8 directions, text and skeleton animation, sidescroller tilesets, map objects, UI, inpaint and pixel clean-up | Connected 2026-10-28 so art is not blocked on Autosprite credits. Sean asked for the hero and gear in PixelLab with quality first (5,000 generations a month). Log every call in `art/pixellab-ledger.csv`. |
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
- **Music (SEAN, curated by Claude):** title, Eolis (and festival variant), Guru/shrine, each zone (7 + 2 optional), mini-boss, boss (a shared boss theme, plus a signature theme for each zone boss that has a strong idea: placeholder themes exist for Zoradohna's drill engine, Ripasheiku's hunting waltz and Zorugeriru's surge, three head-voices trading a motif across the stereo field; `BossArena.BOSSES` names each fight's track), Evil One (3 phases), ending, credits. About 22 tracks. Each zone track gets a "restored" variant (filter/arrangement change) when its spring returns. As built (pass 150), the three springs' zones have one each (`Music.RESTORED`, keyed by the spring's flag): `trunk_restored` (the plucks opened up bright, a shaker over the hand drum, the bell melody doubled by a warm lead an octave down), `mist_restored` (the waltz a touch quicker at 72 and no longer muffled, with a lantern-bell where the heartbeat thumped, and less reverb as the fog lifts by half) and `daybreak_restored` (the storm broken: 100 bpm, held chords and a walking bass, no thunder rolls, the gusting plucks falling soft like drops off the leaves). Daybreak's storm bed becomes `amb_daybreak_restored`, a soft wind, a fine drizzle and drips, with no thunder. Each variant draws the same random notes in the same order as its zone track, so the melody is the same tune. Restoring a spring turns its room's music over 3 s (`Spring.RESTORE_FADE`), and a town keeps its own theme.
- **SFX (CODE synth + CC0 packs):** about 180 effects across movement, combat, UI, ambience, bosses.
  - **As built (pass 334):** **160 sound effects** (the plan said about 180), and **34 music tracks** with **14 ambience beds** (the plan said about 22 tracks). The 34 tracks are: a theme for each of the 10 areas (Eolis, the seven zones after it, the Sunken Spring and the Guru Trials); 6 for towns with their own (Forepaw, Victim, Mascon, Conflate, Daybreak's town, Old Eolis); 5 variants (the three restored springs, Eolis's festival `eolis_bloom` and Zenis's `zenis_still` after the end); the shared `boss` and `miniboss` themes and 9 guardians' own; and the title and the ending, which also plays under the credits. There is no Guru or shrine track: a Guru's room keeps its zone's theme. `test_the_bible_counts_the_games_sounds` holds the three counts to `assets/` and fails on a sound file the code never plays.
  - **Voices (pass 254):** `Sfx` plays through a pool of 12 voices. It handed them out in turn, so the thirteenth sound always took the oldest voice, however long that sound had left. Footsteps alone come several a second when you run, and a fight adds cuts, hits and tells, so a 2.4 s victory (`boss_won`) or a 1.4 s phase break was cut off within about a second of starting. Now each voice keeps the time its sound ends (its length over its pitch, in real time, since the mixer ignores pause and slow-mo). A new sound takes a free voice, or else the one nearest its end, so a long stinger stands through a busy moment and a footstep gives way. A burst of one sound in a single frame takes one voice: a spray of eight coins, which used to sum eight copies and take two-thirds of the pool, rings once. `Sfx.recent` still lists every ask. Test: `test_a_long_sound_keeps_its_voice_through_a_busy_moment`.
- **Phase breaks (pass 96):** when a boss's health crosses one of its `PHASES` marks, `BossArena` plays the `phase_break` stinger (a deep impact, a reversed swell and a ringing fifth), ducks the music under it and the screen shakes. Then the boss theme rises a semitone, and its tempo with it (`Music.intensify`, `pitch_scale` 2^(1/12) per phase, eased over 0.8 s), the old key-change lift. A new track starts back as written.
  - **A phase reached another way (pass 252):** the break watched health alone. Ripasheiku comes down for good once all four lanterns are broken (8.3), and the four cost her only 72 of 260 HP, so she entered her third phase above the first mark with no stinger, no stagger and no lift in the music. Her health then crossed the two marks later and rang twice for a change that had already happened. Now the arena also counts the boss's own `phase`: a boss in phase n has passed n - 1 marks, whichever came first. The last lantern is one break, straight to the second level, and the health marks after it ring nothing. Every other guardian moves its `phase` on the same marks, so nothing else changes. Test: `test_her_last_lantern_breaks_the_phase_as_her_health_would`.
- **Attack sounds (pass 102):** every enemy and boss attack is heard as well as seen. Entering a telegraph state plays a rising cue at once, picked by what is coming: `tell_blade` (a scrape climbing in pitch: a blade drawn back), `tell_heavy` (a low groan swelling up: a slam, dive or plunge), `tell_charge` (a wobbling hum rising to a whine: a shot or spell), or the zone foe's own call (a buzz, screech, wail, swell). The strike has its own sound (a `whoosh` for swoops and lunges, `slash`, `heavy`, `zap` and so on), and every death plays `enemy_die`. `test_every_attack_tell_and_strike_has_a_sound` scans the enemy and boss scripts and fails on any attack state that starts in silence.
  - **Tells the scan could not read (pass 278):** most guardians pick a move and enter it as `set_state(pick + "_tell")`, or through a helper (`_open`, `_tell`), and the scan reads only a named state. Fifteen tells of seven guardians started in silence and were heard only as the blow came: the Foreman's pound and throw, Zoradohna's drill and slam, Pakukame's bite, whip and spit, the Drowned Warden's thrust and undertow, King Grieve's chop, sweep and burst, Shadow Eura's cut, heavy, cast and dash, and every tell of the Evil One's avatar. Each now plays its cue as it starts, by what is coming: `tell_blade` for a cut, thrust, whip or lunge, `tell_heavy` for a chop, pound, slam, bite or heaved rock, `tell_charge` for a spell, spit, drill spinning up or gathering pull. Sounds the guardian already made at the start (the Foreman's charge roar, the Warden's wave swell, the brood's rustle) stay. `test_every_guardian_tell_is_heard_as_it_starts` fights every guardian in its arena for 25 s, pushing it past its phase marks halfway, and fails on any tell entered without a sound in that frame or the two after (35 tells across 14 guardians).
  - **Every tell heard, fought or driven (pass 284):** five tells never came up in 25 s of fighting (the Foreman's throw, the Drowned Warden's undertow, King Grieve's burst, Shadow Eura's cast and dash), so the test could not hear them. It now drives each one directly after the fight (`DRIVEN_TELLS` in `test_boss.gd`), setting the state that picks it and calling the guardian's own chooser, and fails if it enters in silence. It also reads every `_tell` named in each guardian's script: each must be heard in the fight, driven, or entered only through a literal state change with its sound on the same or the next three lines. A tell added later with none of these fails the test.
- **Foe voices (pass 112):** the shared tells are for the older foes and the bosses. A foe built later gets its own tell and strike, made in its own material, so it can be told apart by ear even off screen. The Bark Knight has `bark_creak` (a stick-slip creak of wood under strain, climbing), `lance_thrust` (a woody rush ending on a thock), `root_grip` (a low crunch with splinters) and `bark_chip` (a dry crack over a hollow knock, louder on the last plate). The Drowned Dwarf has `anchor_heave` (a sodden groan with bubbles rising through it and water pouring) and `anchor_slam` (an iron thud into mud and a wet slap). The Leaf Mantis has `mantis_unfold` (a leaf rustle, then a chitter) and `scythe` (two thin cuts a hair apart). The Seed Bomber has `seed_rattle` (hard seeds rattling in a husk, faster and higher) and `seed_drop` (a pop and a short falling whistle); its seed has `seed_fuse` (a sputtering hiss that climbs) and `seed_burst` (a husk cracking and thorns spraying). The Marsh Hag has `hag_hex`, `mire_grasp` and `hag_fumble` (pass 119). The Spire Sentinel has `sentinel_grind` (stone dragged on stone over a low rumble, as it moves behind your back), `sentinel_raise` (stone creaking up over an electric hum that climbs) and `sentinel_slam` (a deep thud, a crack and grit) (pass 123). `test_the_newer_foes_have_voices_of_their_own` checks that each foe plays its own sounds and that no other script does.
- **Mini-boss voices (pass 173):** the Clockwork Alpha and the Bark Knight Captain were built from shared sounds: the Alpha's tells used the hound's ratchet and its jam the generic break, and the Captain's vault the generic charge tell. Each now has a voice of its own for the moves that are only its own:
  - `key_wind`: the Alpha's great key turned through four heavy detents, a deep clank each, with a spring groan climbing behind. It plays on its intro, its pounce and howl tells, and its turn to phase 2.
  - `spring_jam`: a hard clang as it meets the wall, then its mainspring buzzing loose with gear teeth skittering.
  - `bough_vault`: the Captain's lance planted and flexed, a deep woody groan, then the bough throwing him up.
  - `lance_plant`: his lance-first landing, a deep wooden boom with roots tearing the floor.

  The Captain still speaks with his knights' creak, thrust, root and chip for the moves they share, so the family reads by ear (pass 171). The voices test now holds both mini-bosses to their own sounds.
- **The Bloom's brood and the tide (pass 262):** passes 257 and 259 had built their sounds from others. The Liliths screeched with the generic `buzz` and dove with `whoosh`, the Bloom's petal flare used the same buzz, and wading Dartmoor's water sounded like the Mist's mud. Now each has its own:
  - `lilith_screech`: a thin shriek rising through the beat of its wings (the 0.4 s tell).
  - `lilith_dive`: a falling whistle and the air torn past folded wings.
  - `bloom_brood`: the Bloom's petals flaring, a dry rustle swelling under a low many-winged hum (the 0.7 s tell).
  - `brood_loose`: the petals snapping open with a soft pop and a flurry of wings as the three fly out.
  - `step_wade`: the shin pushing water aside, and two drips falling back off the boot. `Room.surface_at` gives `wade` in standing water.

  The voices test holds the Lilith and the Bloom to their own sounds, and the tide test checks that a step in the water sloshes and is not mud.
- **Locks (pass 122):** a locked door is heard as a door, not a spell. The card doors and the Sky Gate had borrowed `fizzle` (the spell-fail sound) when locked and the plain `door` creak when opened. Now they rattle their latch (`door_locked`) and the key turns with its own click, bolt and chime (`key_turn`); see 4.5, Key doors.
- **Refusals (pass 286):** a press that does nothing is heard when the player needs telling why. An empty Red Potion flask had been silent, though it is the press most often made in trouble, while a spell short of MP and an Hour Glass still running back both `fizzle`. Now an empty flask has its own sound, `flask_empty`: a dry cork pop and two small glass rings, with no swallow after. It is a flask's sound, not a spell's, for the reason pass 122 gave the doors theirs. Each refusal sounds once per press and spends nothing. Two presses stay quiet on purpose: a drink at full health, and a cast inside its 0.35 s cooldown, where the cast you just made is still sounding. `test_a_refused_drink_cast_or_glass_is_heard_once`.
- **A mana orb (pass 294):** the orb a kill leaves 1 time in 10 (7) was taken with `blip`, the menu cursor's beep, the sound pass 128 took off the map for the same reason: a pickup in the world sounded like a menu. It now has its own, `mana_orb`: a soft breath of air under three glassy notes rising quickly up a major triad, each with a faint shimmer a fifth above. It is kept apart from bread's `heal`, so health and magic are told apart by ear. `test_kills_sometimes_drop_bread_or_mana`.
- **Poison an Ointment keeps off (pass 302):** every drop is heard as it is taken: bread and the loaf `heal`, the orb `mana_orb`, poison `hurt`, the War Glove and an Ointment `item`. Poison picked up under an Ointment only showed its line, "The Ointment keeps the poison off.", in silence. It now plays `ward` (-6 dB), the glassy ring of a ward turning harm. `test_every_drop_is_heard_as_it_is_taken` takes every kind of drop and requires a sound and a line for each.
- **A poison tick (pass 310):** since pass 306 a tick takes 2 to 4 health and since pass 309 it shows a green number, but it was the one loss of health with no sound. Each tick that bites now plays `poison_tick` (-4 dB): a small wet glug, a sine bubble sagging from 300 to 170 Hz with a smaller one behind it over murky noise. Its peak sits 3 dB under `hurt`'s, so a sickness never reads as a blow. A tick that takes nothing (the last point, under an Ointment) is silent. `test_every_poison_tick_is_heard`.
- **Rewards that sound (pass 165):** the newest rewards had no sound of their own. A blow that Executioner (9) drives into a boss's opening now cleaves with `execute`, played under the cut: a low body thud, a crack, and a short hard ring of the blade biting deep. A plain blow, or one on a boss on its guard, does not play it. A mantra dye won (10) rings out over the trial bell with `dye_won`: cloth swept open, and the bell struck high, three quick notes falling into a held chord. A clear that earns no dye rings the bell alone.
- **Bloodletting is heard (pass 318):** since pass 314 every guardian opens without a parry, so Bloodletting (9) heals in every fight, and a dagger build that cannot parry leans on it. Its heal was silent, felt only as a number on the masks. It now plays `bloodlet` as the health comes back: a warm, quiet double pulse like a heartbeat taking, two soft swells rising 180 to 260 Hz (peak -10.5 dB, well under the `hit` it rides on). It plays only when health is actually given, never at full. Test: `test_bloodletting_heals_on_a_staggered_foe`.
- **Gear that sounds like itself (pass 190):** the newest gear had borrowed sounds or none. A Rune Dagger that lands now bites with `dagger_hit`, a high tick of the point going in over a small dry knock, lighter than a blade's `hit`; until then a throw that struck was silent. The Dwarvish Broad Sword, two-handed and 30% slower, cuts with `broad_slash` and `broad_heavy`, a longer, lower rush of air with weight under it, in place of the light blades' `slash` and `heavy` (`Player.swing_sound`). On the Equipment page a blade taken in hand slides from its sheath and seats with a click (`sheathe`), and armor, a shield or a helmet buckles on, leather and a clink (`gear_on`); only a dye keeps the cloth swish (`Menus.equipment_sound`).
- **A dagger on stone (pass 326):** a Rune Dagger that struck a wall still borrowed the shield's `guard` clank (at -8 dB), so a throw at stone sounded like a block, and since Sean's off hand (5.2) a dagger build never blocks at all. It now pings with `dagger_ping` (`RuneDagger.WALL_SOUND`): a glancing steel ping of two inharmonic partials (2.86 and 4.17 kHz) over a gritty tick of the point, 0.14 s, peak -8 dB played at -4. It is brighter and shorter than `dagger_hit`, so stone and flesh are told apart by ear. A throw that runs out of reach stays silent apart from its rune light. `test_a_dagger_on_stone_pings_and_never_clanks_like_a_shield`.
- **The map (pass 128):** the map is a sheet of parchment and sounds like one. It had opened, closed and taken pins with `blip`, the menu cursor's beep. Now opening it rustles as it unrolls and settles with a soft flap (`map_open`), closing folds it with a dull pat (`map_close`), a pin goes in with a tiny tick and a bright ring (`pin`), and lifting one rings falling with the tick of it coming free (`pin_lift`). A full map still fizzles.
- **Fields and the cloak (pass 137):** the wind currents of the Branches, Borabohra's updraft and the wrong-gravity pockets of Zenis had changed how you move without a sound. Now a current or updraft catching you blows past in a gust (`wind_catch`), a pocket lifting your weight rises in a hollow, glassy shimmer (`drift_in`), and leaving it drops into a low hum and a soft thud (`drift_out`). Each sounds once as you cross the edge, and waits `Player.FIELD_CUE_GAP` (0.3 s) before it may sound again, so hovering on an edge does not chatter. At Ilse's Dyeworks a dye goes on with a cloth swish (`cloth`). Wearing one you own again plays no coin, since nothing is paid.
- **After the end (pass 143):** on a cleared save the music follows the Tree's bloom (4.4) through `Music.after_the_end` (table `Music.AFTER_THE_END`):
  - **Eolis** plays its festival variant, `eolis_bloom`. It is the town theme a touch quicker (100), with a bell doubling the arpeggio an octave up, a frame drum and a bell answering the lead.
  - **The dead meteor goes still.** Zenis drops its heartbeat track for `zenis_still`: B minor at 60, the pads in tune where they had beaten against each other, no pulse, and once per pass a far bell climbing a B major chord. Its bed becomes `amb_zenis_still`: the breath and heartbeat are gone, leaving a thin hollow wind, stone ticking as it cools and now and then a crystal cracking with a soft chime.
  - Other zones keep their themes, and a fight still plays its fight.
- **Big coins (pass 206):** since pass 199 gold comes in coins of 1, 5, 25 and 100, but every coin chimed the same two notes, so a 5,000 g chest sounded no richer than a single foe's few coins. The 25 and 100 g coins now ring `coin_big` (`Coin.sound`): the same rising chime a fourth lower, a third note above it, and a bell tail, 0.3 s against the small coin's 0.12 s, 2 dB louder in peak. The small coins keep `coin`. Test: `test_a_big_coin_rings_lower_and_longer`.
- **A guardian's fall (pass 222):** every boss win had played `item`, the same chime as a loaf of bread off the floor, while the boss theme faded out over 2.5 s on top of it, so the end of a fight sounded like a pickup. Now the win rings `boss_won` (`BossArena.WIN_SOUND`), the old 8-bit victory call: three quick brassy G's over a timpani roll, then a held C major chord with a low root, 2.4 s, ringing out as the boss theme drops away in 0.4 s (`BossArena.WIN_FADE`). It plays under the banner for every prize (the Dragon Slayer included) and under the skill-point toast, and between fights of a boss rush. Tests: `test_a_guardians_fall_rings_a_fanfare_of_its_own`, and `test_every_guardians_win_says_what_it_gave` listens for it in every arena.
- **The glass runs out, and a ward rings (pass 230):** the Hour Glass rang as it was turned and then went silent, so the only sign that stopped time was ending was the sand in the HUD, and frozen footholds melted and held shots flew on without warning. Now its last three quarter-seconds each tick (`glass_tick`, a dry clock tick), and time running again rushes (`glass_end`, air let go forward over a low thunk) (`Player._glass_cues`, `GLASS_TICKS`, `GLASS_TICK`). The shield's and helmet's ward (5.2, pass 225) turned part of a hex in silence; it now rings (`ward`, a bright glassy ring) under the hurt, and only for sorcery. Tests: `test_the_hour_glass_ticks_before_time_runs_again`, and `test_a_shield_wards_a_foes_sorcery` now listens for the ring.
- **The glove on the wall (pass 238):** the wall slide was the one movement state with nothing to hear. It shed dust every 0.06 s, but every jump, landing, dash, glide, pogo and step had a sound, and the slide had none. Now the glove rasps (`wall_slide`: leather dragged down bark, a short gritty flutter at -21 dB loudness, under the glide's -21.6). It plays as you catch the wall, at -4 dB, and every 0.24 s after while you slide, at -8 dB (`Player.WALL_SLIDE_SOUND`, `WALL_SCRAPE`), so a long slide is a steady scrape under the dust. `test_a_wall_slide_rasps_down_the_wall` counts the rasps over a second's slide, and with no Glove there is none.
- **Mix (pass 96):** `python3 tools/audio/levels.py` measures the peak and the loudness of the audible part of every sound, track and bed. `--check` fails if any of them clips (peak at -0.1 dBFS or over) or strays more than 9 dB from its group's median. Generated music is normalized to -3 dBFS (it had been -1.4, and the Vorbis encoder's overshoot clipped 22 of 25 tracks past full scale), with `Music.MUSIC_DB` raised 1.7 dB to -8.3 to keep its place in the mix. The death sound was 10 dB over the effects' median and is now in line.
- **Supplied music (pass 214):** a track Sean supplies takes the generated placeholder's name in `assets/music/`. The game had looked for `.ogg` first, and every placeholder is an `.ogg`, so a supplied `.mp3` or `.wav` was never heard. `Music.EXTENSIONS` now looks for `.mp3`, then `.wav`, then `.ogg` (`Music.path_for`). `musicgen.py` leaves alone any track with a supplied `.mp3` or `.wav`. A supplied `.ogg` replaces the placeholder's file, so don't regenerate that track afterwards. `levels.py` had measured only the `.ogg` files; now it measures whichever file each track plays from. A new CI job, `mix`, runs `levels.py --check` on every push, so a supplied track that clips, or sits more than 9 dB off the others, is caught before it merges. `test_a_supplied_track_replaces_its_placeholder` holds the order.
- **Headroom for the loudest cues (pass 270):** the hero's hurt sat 8.9 dB over the effects' median and the cut landing (`hit`) 8.0 over, so a single new quiet sound nudging the median tipped the mix check red (it did in pass 262). `levels.py` now asks every sound effect to keep `HEADROOM` (1.5 dB) inside the 9 dB spread. `sfxgen.py` saves `hurt` at gain 0.42 (was 0.6) and `hit` at 0.62 (was 0.8), about 12.5 dB RMS each, 6 over the median, and `Sfx.LIFT` plays them back 3.1 and 2.2 dB up on top of any caller's offset, so in game they are exactly as loud as before. A cue that must play louder than the mix allows is saved quieter and lifted the same way. Test: `test_the_loudest_cues_are_lifted_in_game_not_in_the_file`; the `mix` CI job holds the headroom.
- **Ambience:** one bed per zone (wind, drips, creaking wood, storm), and a room can name another (`ambience:`). In the Tower, the halls hum with machinery (amb_tower), the Old Flue and the Rafters howl with wind, a rattling shutter and creaking beams (amb_heights), and the Deep Workings drip, with carts rumbling through the rock and far-off picks (amb_mine). The Guru Trials' mantra-space has its own theme and bed (`trials`, `amb_trials`, pass 116). A boss rush plays the same theme in the arenas between fights (pass 157).
- **Footsteps:** each step plays the sound of the ground underfoot (`Room.surface_at`): stone in Eolis, moss on the Trunk's living wood, iron on the Tower's plates, hollow planks on every one-way platform, and a squelch in sap. A room can name another surface with `surface:`. A landing layers the surface step under the land thud, louder the harder the fall. Since pass 181 the Mist's marsh is mud (`step_mud`: a wet slap as the boot goes in and a small suction pop as it pulls free), where it had borrowed the Trunk's moss; its towns' boardwalks stay plank, and the four rooms the dwarves built (the Scorched Hall, the Dry Cistern, the Sunken Chapel and the Spring of Mist) are stone. The Matriarch's Mire is mud.

---

### 13.4 Hero body sets (paper doll)

The new hero is Sean's Autosprite character HeroStranger_Base (purple-haired elf, 2026-10-27), replacing the hooded
ranger clip by clip. The hero is drawn in layers so gear does not multiply animations:

- **Body + armor:** one full sheet per armor look, five in all: `hero_base` (no armor, green tunic), `hero_leather`,
  `hero_studded`, `hero_plate`, `hero_battle` (`PlayerVisual.ARMOR_SHEETS` maps the worn armor to its sheet). Each is
  an Autosprite character of its own run through the same clip list. A clip a set lacks plays from the old `player`
  sheet until it exists.
- **Weapon, shield, helmet, cloak:** separate layers drawn from per-frame anchors the importer finds in each frame
  (`detect: "hero"` in the manifest): `hand` (the leading fist, as the code rig's front hand), `head` (the crown of the
  head, from `head_point`, for the helmet and the hood), `neck`, and `back` (the nape of the shoulders, where a cloak hangs). Anchors are per set and
  per frame, so the sets do not need to be frame-synced. Attacks are drawn empty-handed.
- **Battle Suit + Battle Helmet:** worn together they swap to a body of their own, `hero_battle_helm` (Sean's HeroStranger_ElvenPlateArmor_ElvenBattleHelm, drawn with the helmet on; `PlayerVisual.HELMED_SHEETS`), and the helmet layer is not drawn over it. Its crown is the top of the figure (manifest `"head": "top"`). The bare-headed Battle Suit keeps its own Autosprite colors, which match this set; the pass-212 teal recolor toward the pixel helmet is dropped, since the pixel helmet now only goes over the other armors and the old clips. Now it is Sean's second take on this character with a hooded cloak drawn into the art (512 px cells, 56 frames: idle 6..50 step 2 at 7 fps, walk 28..53 at 34, run 2..16 at 40). The set carries the manifest flag `"cloak": true`, so `Cloak.shown()` hides the code cloak and hood over it (Sean found neither the code hood nor his pixel hood sprite matched). Its idle faces three-quarters toward the camera, unlike the other sets' profile idles. Clips it lacks (jump, attacks and the rest) still fall back to the ranger sheet with the pixel helmet and code cloak.
- **Scale:** all five share one scale, base idle = 46 world px (the ranger's height), so armor that stands taller or
  bulkier (plate, Battle Suit: about 1 px) shows it. Clips are 512 px cells at 14 fps; walk and run play every frame
  of one cycle, sped up until the planted foot keeps pace with the ground (run about 30 fps, walk up to 40).
- **Cloak** (`scripts/player/cloak.gd`, code-drawn, no credits): Sean's Elven cloak from his side views
  (`/mnt/project-files/armor/cloak-hood-up.jpg`, `cloak-hood-down.jpg`; its green #3f6a3f and gold #cba040 from his pixel cloak, `cloak-pixel-right.png`, which as a shrunk sprite hid the face at game scale): ankle length, flaring behind, gold trim
  down the front edge and the hem, a brooch at the shoulder. The cape is two verlet chains hung from the frame's
  `neck` and `back` points, behind the body; the hood is drawn over the head from `head`. **Hood down in a town, up
  everywhere else** (Sean, 2026-10-27; a town is a room where people stand and no foe or boss spawns,
  `Room.is_town()`), raised or lowered over 0.35 s when that changes, and always down under a helmet. It takes the
  worn dye's color (Warden Green is its own), so the 14 dyes need no extra art. The body sets themselves are drawn
  undyed, and while a clip falls back to the ranger's sheet (which draws its own cloak) the layer hides.

### 13.5 The PixelLab hero (2026-10-30)

Sean asked for the hero and his gear to be made in PixelLab, quality first. The base is **Sean's own PixelLab elf**
(character `b246489c`, "Right Facing relaxed": side view, 256 px canvas, the same purple-haired elf in the green tunic as
13.4's reference), so the look is his. Sources are in `art/pixellab/` (`hero/`, `mattock/`), packed into strip sheets by
`tools/art/pixellab_sheets.py` (`art/pixellab/sheets/<sheet>/`) and imported by the same importer as Autosprite clips
(`art/autosprite/manifest.json`, whose `dir` points at the strips): same scale (46 world px), palette, outline and rim.

- **What works, by mode:** armor tiers as **character states** (`create-character-state`, 25 generations each: leather,
  studded mail, full plate and Battle Suit all match Sean's T-pose references). Clips in **pixminimax** mode (about 2
  generations for 12 frames at 256 px) stay in strict profile when the prompt says so, and draw props well (the jump,
  walk, the Mattock pogo and swing). v3-mode attacks turned toward the camera on the recovery; skeleton-v3 jumps came
  out stiff. Outfit transfer works but costs 25 per 3 frames, too dear for whole clips.
- **Swords are drawn into the attack clips** (Sean, 2026-10-30): each armor's attacks are made holding each blade, not
  a separate sword layer. A state of the hero holding the weapon is made first, and the clip animates from it.
- **The Mattock is drawn** (Sean, 2026-10-30: "build out the mattock asset and swing animation"): a dwarven iron
  mattock, adze blade and pick, on an iron-banded ash haft. The pogo (`strike_down`) is the hero driving it straight down
  beneath his tucked knees: two frames of the pixminimax pogo clip, moved 58 source px down (`"lower"`) so the knees
  sit at the feet and the iron head reaches about 12 px below them, into the strike's 24 px hitbox. Hero sheets are 84
  px tall (`spritegen.ARMOR_CELL`, 23 px under the origin) to hold it. The strike plays to its end over the bounce
  (`PlayerVisual.FINISH`), since a pogo ends the attack the frame it lands. An overhead swing that breaks stone is
  made (`mattock/swing_mm`) for a later breaking pose; the item art is `mattock/item/02.png`.
- **Imported so far (`hero_base`):** idle, walk, run (Sean's own run clip), rise, apex, fall, the Mattock pogo, and
  (pixminimax, holding the Short Sword) the three-hit combo (a thrust, a rising cut and an overhead chop), the upward
  slash, dash, wall slide, hurt, death, drinking a potion and casting. Frames with artifacts are left out by `pick`
  (the dash's color smear, the hurt clip's red arrow, the cast's teal turn).
- **The armor tiers (`hero_leather`, `hero_studded`, `hero_plate`, `hero_battle`):** the same seventeen clips, made
  from each armor's state (movement, hurt, death, drink, cast), its state holding the Short Sword (the four attacks) and
  holding the Mattock (the pogo). Each clip starts from the state's own pose, so picks skip frame 0; some picks differ by
  armor where a take turned toward the camera or carries an effect (kept in the manifest). Pogos are made with "he stays
  high in the air the whole time and never touches the ground", since the first takes landed and struck the floor.
  They replace the Autosprite body sets. `hero_battle_helm`, the Battle Suit under the Battle Helmet, is made the same way
  from a state of the battle set wearing a crested mithril helm (its head point is the crown of the helm, `"head": "top"`).
- **The other blades (`hero_<set>_<long_sword|broad_sword|dragon_slayer>`):** every set's four attacks again, from its
  state holding the Long Sword, the Dwarvish Broad Sword (in both hands, as long as he is tall) or the Dragon Slayer
  (silver, a faint blue edge glow, golden winged guard). Each blade sheet holds only the attacks, plus the set's own idle
  as the importer's reference for scale; `PlayerVisual.sheet_for` plays an attack from the worn blade's sheet
  (`BLADE_SHEETS`, `BLADE_CLIPS`), and everything else from the set. The Short Sword is each set's own attacks.
- **Shields, drawn into the block (`hero_<set>_<small|large|magic>_shield`):** each cloaked set from a state holding
  each shield up to guard (the Small Shield a round wooden buckler with an iron boss, the Large Shield a tall kite shield
  with a crimson face and silver rim, the Magic Shield a long leaf of pale sea-green mithril with gold trim), and from it
  a braced block clip that holds on its last frame. `sheet_for("block")` plays it for the worn shield (`SHIELD_SHEETS`);
  the code-drawn shield is held over the block only on a sheet without one (the old hero).
- **The Rune Dagger throw (`throw`, `throw_up`, Sean 2026-10-30):** a quick ninja-star flick of the LEFT hand from a
  low ready crouch, forward at chest height or up over the head, the sword kept in the right hand (so nothing is
  sheathed). Each set has it with the Short Sword, and each blade sheet with its blade (`BLADE_CLIPS`). The takes drew
  a dagger or a streak at the release, so the picks start just after it: the dagger is the game's projectile. A throw
  restarts the flick over the legs' poses and it plays out like a swing's recovery (`PlayerVisual.FINISH`); the old
  hero, with no flick, only squashes as before. The first right-hand, empty-handed flick (PR #343) is replaced.
- **Grey slabs:** PixelLab sometimes leaves a flat dull-grey patch behind a smear or a cloak (one exact grey with a
  faint warm, violet, green or blue cast, plus a few mottled neighbours); `pixellab_sheets.py` erases a connected patch
  of such greys when it is 400 px or more and mostly one colour, so the shaded armor steel is never touched.
- **Cloaks, drawn in (Sean, 2026-10-30):** every set, the bare elf included, is made again from a state wearing a long
  cloak in a chroma-key green with gold trim ("like a green screen"), with every clip and blade (`hero/<set>_cloak/`).
  `shaders/hero_dye.gdshader` recolors the key (a saturated pure green nothing else on the hero uses) to the worn dye,
  keeping its shading; Warden Green is the lit tone `PlayerVisual.WARDEN_KEY`. The sets carry the manifest flags
  `"cloak": true` (the code cloak and hood of 13.4 are not drawn over them) and `"key_cloak": true` (the shader). Where a
  take dropped the cloak to an empty outline it was retaken (the plate set's most often), picked around, or kept where
  the cloak only swings behind the body.
- **Hair (Sean, 2026-10-30):** the elf's violet hair is the only saturated purple on him, so the same shader recolors
  it to the hair color chosen on the Equipment page (a Hair section after the Cloak: Violet, the art's own, Copper,
  Raven, Silver, Gold and Ash; free, any time; `PlayerVisual.HAIR`, saved as `GameState.data.hair`). The armor's
  violet-tinted steel and the outline are too grey or too dark to count. The helmed Battle Suit (`"hair": false`) shows
  no hair, and its crest keeps its purple.
- **Helmet:** with any set but the Battle Suit, the Battle Helmet stays a layer on the head point (Sean, 2026-10-30);
  only the Battle Suit has a helmed set. The layer is cut from that set's art (`tools/art/helmetgen.py`): the helm and
  the face and ear it frames, from the first frame of the helmed idle, at the sets' scale, so it matches the helmed
  Battle Suit (it replaces Sean's pixel helmet, made for the Autosprite hero). `PlayerVisual.HELMET_OFFSET` is what
  helmetgen measures on the bare Battle Suit, whose head lies where the helm's does.
- **Run speed:** each set's run plays at the frame rate its stride needs for the planted foot to keep pace with the
  ground at the run speed (165 px/s, section 6): 25 to 36 fps, from the foot's backward travel per cycle.

## 14. Technical Architecture (Godot)

- **Engine:** Godot 4.7.2 stable (pinned in CI and `tools/godot-version.txt`). GDScript with static typing.
- **Renderer:** Forward+ (2D lights, glow); verify Compatibility renderer as a fallback for low-end machines.
- **Physics:** custom kinematic controller on CharacterBody2D with hand-written movement (no built-in floor snapping surprises), fixed 60 Hz.
- **Structure:**
  - `autoload/` GameState, SaveSystem (JSON, 3 slots, autosave on rest), EventBus, AudioDirector, InputRouter (rebinding, buffering), RoomManager. As built, saving lives in GameState: one JSON file per slot in user://, written safely and read defensively (15.3, pass 109).
  - `scenes/player/`, `scenes/enemies/<family>/`, `scenes/bosses/<boss>/`, `scenes/rooms/<zone>/<room>.tscn`, `scenes/ui/`.
  - `data/` items, enemies, shops, skill tree, dialogue as `.tres` resources or JSON (so balance changes never touch code).
- **Level authoring for an AI team:** rooms are described in a text format (`levels/<zone>/<room>.room`: an ASCII tile grid plus a YAML header for doors, entities and camera). A runtime loader (`scripts/world/room_loader.gd`) builds TileMapLayer nodes and entities from them, so no generated scenes need to be kept in sync. Text levels diff cleanly in pull requests and are easy for agents to write and review. A world graph file (`levels/world.yaml`) lists room connections, which feeds the map screen and a reachability checker.
- **Reachability checker:** a tool that simulates the player's movement envelope (jump heights, dash distance) per ability set and proves every required item is reachable in order and that no soft-lock exists. It runs in CI. Its pickup sweeps cover the finds `prop:` lines lay as well as the grid's pickups (pass 203: until then a Joker Key, Battle Helmet, Pendant or Magical Rod moved out of reach would have passed).
- **Testing:** GUT unit tests for systems; scripted input replays for the movement controller with asserted metrics (jump height, dash distance, coyote window); headless boot of every room; screenshot capture per room under a virtual display (Xvfb) for visual review.
- **Performance budget:** 60 fps locked on a mid-2018 laptop GPU; under 1.5 GB RAM; rooms load in under 100 ms (preload neighbors).
- **Full-screen effects** that snap to world pixels (the Mist's fog) render at one texel per world pixel in their own small viewport and are scaled up: a quarter of the fragments of the 2x scene, and the same look. Their noise comes from a small tileable texture, not per-fragment hashing.
- **Accessibility:** full remapping, screen-shake and flash toggles, game speed slider (70 to 100%; steps of 10), assist options (extra invulnerability, infinite double jump in Guru Trials only off by default), colorblind-safe gate icons, subtitles for all voiced grunts. *Interim (pass 09):* the options menu has shake (full, half, off), flashes (full, reduced, off), rumble, music and sound volume and game speed, and the keyboard can be rebound; gamepad remapping comes with controller glyphs. *The mercy assist (pass 325):* the line above and the open questions ("one tuned difficulty plus assist options") promised assists, and none were built, so a player who found a fight too fast had only Game speed. The Options row "Assist: mercy", off by default and saved with the rest (`Settings.mercy`, under `[assist]`), doubles the invulnerability a hit leaves (0.8 s to 1.6 s, `Settings.MERCY_MULT`, read through `Player.hurt_invuln`), and the blink lasts as long, so a flurry or a boss's follow-up can't take two masks in a breath. The hurt pose still lets go after 0.25 s, so control comes back as soon as ever, and the Elixir's rise keeps twice the hit's grace. It changes no number in 5.3 or 6, which stay the one tuned game. The Guru Trials' infinite double jump is not built: a Trial's miss already costs time, never health. `test_the_mercy_assist_doubles_a_hits_grace`. *Damage numbers (pass 154):* the UI list (12) names "damage numbers (optional toggle)"; they are built as the Options row "Damage numbers", off by default and saved with the rest (`Settings.damage_numbers`). On, every blow that lands shows the damage it actually dealt (after a foe's guard, bark or shell) over what it struck: white for a cut, gold and twice the size for a heavy blow (the finisher, a thrust, a Riposte), and red over the player for the HP a hit took after armor. A number pops up 18 px with an ease-out and a little sideways drift (alternating, so a flurry doesn't stack), holds through the hit-stop and fades over its last 0.25 s of 0.7 s (`DamageNumber`). A blow a shield turns shows none. Foes, bosses (segment bosses through `BossSegment`) and the gym's dummy all show them. **Poison ticks (pass 309):** a poison tick was the one loss of health that showed no number, and since pass 306 it varies with the zone (2 in the Tower, up to 4 deep). Each tick now shows what it took over the hero, in the poisoned masks' green (`GameHud.POISONED`), so the number reads as the poison's and not a blow's. A tick that takes nothing (at the last point, or under an Ointment) shows none (`test_damage_numbers_show_each_poison_tick`).

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
| Combat and enemies | 15 | Telegraph times (every wind-up swept since pass 234), hit-stop, every enemy has full animation set, damage balance sheet within targets |
| World and level design | 15 | Room count, landmarks, save spacing, reachability proof, sequence breaks safe, secrets per zone |
| Art cohesion | 15 | Palette compliance 100%, contrast check pass, no missing animations, parallax per zone, screenshots reviewed |
| Bosses | 10 | Each has 2 to 3 phases, tests its ability, cinematic kill, balanced HP (target fight time 2.5 to 5 min; the health sheet in 5.5, held by `test_the_guardians_last_as_long_as_their_place` since pass 204) |
| Systems | 10 | Save/load round-trip, shop, skill tree, map, fast travel, settings all tested |
| Audio | 5 | Every action has SFX, every zone has music and ambience, mix levels in range |
| Stability and performance | 5 | 60 fps budget, no crashes in a 2-hour soak bot run, load times |
| Faithfulness to Faxanadu | 5 | Checklist: towns, Gurus, ranks, rings, keys, springs, gear and goods, all original bosses, Evil One, spells and relics, the Dragon Slayer as King Grieve's swallowed sword (pass 217), Pakukame's Liliths, three at a time (pass 257), shields that ward a foe's sorcery (pass 225), King Grieve's hall named Fraternal Castle as in the original (pass 241), Mascon's tavern with its bar maid's word (pass 265), and the original's Naga floating over the Tower's ladders (pass 273) and leaving its great loaf when slain (pass 281), and the Myconid's sure bread (pass 289). Held as a whole by `test_the_faithfulness_checklist_is_all_here` since pass 201, the towns' tool and key shops by `test_every_town_keeps_the_originals_shops` since pass 209, and the original's gear and goods (names, a way to get each, and blade, armor and shield ladders that climb) by `test_the_originals_gear_is_all_here` since pass 233 |

**Stability measures (pass 99):** the journey soak (`test_soak.gd`) walks the world twice, door to door with mashing play between. It rests and Continues into a fresh world every 20 rooms and opens the pause and skills screens on the way. The second lap must leave no live objects, orphan nodes or tree nodes behind. No frame of play (room loads aside) may pass 50 ms, save one lone frame a lap under 100 ms (pass 182, below). Anything a room will need mid-play is loaded while the room loads: a boss arena loads its boss's sprite sheet and music (`BossArena.warm`), because a fight starts mid-play. Every sound effect loads with the game (`Sfx.load_all`, about 20 ms once, 2.2 MB), so no first slash or phase break waits on the disk (pass 103). Every boss fight is timed for 15 s of mashing with a phase knocked off every 5 s (`test_every_boss_fight_holds_the_frame_budget`): the average frame must stay under 8 ms and the 99th percentile under 16.6 ms, and nothing may load from disk once the fight has begun.

**Every room, and the trials live (pass 166):** `test_every_room_loads_and_settles_inside_the_budget` enters all of the game's rooms in one world, the trials and the gym included. Each must load behind the fade in under 500 ms, and once it has settled its frames must average under 8 ms. The first room of a zone pays for its tileset, and a boss arena for its warm-up; the worst is about 150 ms here. The trials soak runs each Guru Trial as a live run, with the Hour Glass turned whenever it is ready: hazards set you back instead of hurting, Stillness's water freezes and runs on, and no run is left open after.

**Guardians from the rooms, and beaten for good (pass 174):** the boss frame audit reads its arenas from the rooms' `boss:` headers instead of a hand-kept list, which had missed the Clockwork Alpha and the Bark Captain; every guardian `BossArena` knows must have exactly one arena. `test_every_beaten_guardian_stays_beaten_through_a_save` wins each fight (the Evil One's starts the ending, so it is left to the ending's tests), saves, continues into a fresh world in that room and walks in: the doors stay open, no fight starts, and the prize (rings, keys, health, magic, points, abilities, armor) is neither lost nor given twice. A save's key counts come back as whole numbers, as they went (JSON had turned them to floats).

**After the end (pass 144):** every soak had run on a fresh save, so the post-game world (4.4: the blossom layer, `Music.after_the_end`, every boss arena idle) and Wanderer's Grace (`Player.on_kill` on every death) had never been walked. `test_a_journey_after_the_end_stays_lean` runs the journey on a cleared save: every boss beaten, every spring running, the Wanderer branch learned. Each lap walks 100 doors out of Eolis and 50 out of the dead meteor's Threshold, resting and continuing every 20 rooms (each Continue must still be cleared). The checks:
- the second lap leaves no orphan nodes, no growth in the tree and fewer than 50 live objects behind;
- no two frames of play pass 50 ms, and no lone frame 100 ms (pass 182);
- no sheet or sound is first loaded from disk during play, once a room's first three frames have built it (pass 303);
- no engine or script error is logged (`ErrorCatcher`);
- blossom drifted, Zenis played still and Eolis its festival.

**Dying during a boss win (pass 239):** the edge case of a trade at the killing blow is closed: nothing can hurt the hero while a guardian falls (8, "A won fight stays won").

**One lone frame forgiven (pass 182):** the journeys' 50 ms check failed three times in full runs (58.6 ms in pass 174, 51.2 ms in `zenis/heart_gate` in pass 178, 51.5 ms in `sunken/source_hall` in pass 179), each time a single frame in a room no change had touched, and each passed when run again alone. A frame-by-frame trace of the post-game lap (about 4,000 play frames) found nothing in the game behind it: the entry frame itself costs a median 5 ms (up to 66 ms, a load, not judged), and every judged frame after it a median 0.6 ms and at most 5 ms. A real hitch (a lazy load, a slow room, a leak) comes back every time its room is entered, so it shows as several slow frames; the host pausing the process shows as one. So each lap tracks its worst and second-worst play frames: the second must stay under 50 ms and the worst under 100 ms, and a lone frame over 50 ms is printed. `test_the_journey_frame_budget_forgives_one_lone_frame` checks the tally keeps both across the two halves of a post-game lap.

**A lone frame is not a load (pass 303):** pass 301's full run had one 103.8 ms frame in the Gnawed Stair, play frame 9, on the first journey lap. It passed when run again alone (worst 5.7 ms), and the same seed walks the same path. A probe of both journeys counted the character sheets (`Sheet`) and sounds (`Sfx.loads`) first loaded during play frames, and found none. So the frame was the host, as in pass 182, and the 100 ms limit stays. The probe is now a check on every journey lap, so a future lazy load (a new sheet first fetched mid-room) fails at once instead of waiting to show up as a rare spike.

**A resting drop does its checks once (pass 311):** pass 308's spike check scans every child of the room, and it ran every frame a drop lay still: nine resting drops made 764 scans in 2 s where nine would do. Each scan is cheap (about 2 µs in the Flooded Hall), so no frame showed it, but the cost grew with every drop and every child. A drop now checks once as it settles, and again only after it leaves the floor (a torn leaf drops it, say). Pass 307's door clamp now asks the tiles only for a drop or coin within 40 px of a side edge, so a mid-room coin spray asks none. `test_a_resting_drop_checks_for_spikes_once`.

**A thousand coins (pass 199):** gold came out in coins of 1 and 5, each a small body that falls, bounces and flies to you. The biggest purses had grown (the Dartmoor vault's 5,000 g chest, and since pass 197 boss purses of up to 1,000 g), so opening that chest threw 1,004 coins at once: 0.87 s to spawn them and a 27 ms frame, measured headless. Each coin also chimes when it is picked up. Coins now come in 1, 5, 25 and 100 (`Coin.DENOMINATIONS`), each drawn a little larger than the last. A spray uses the largest coin that leaves at least as much again for smaller ones, so small purses still scatter singles. The same chest is now 61 coins, spawned in 54 ms, with a worst frame of 1.5 ms. `test_a_big_purse_sprays_few_coins` holds every purse up to 5,000 g to at most 64 coins, adding up to the purse exactly, and keeps a purse under 10 g as single coins.

**No silent sounds (pass 207):** `test_every_sound_the_code_plays_exists` reads the scripts for literal names, but some sounds are named at runtime: a helper's choice (`Coin.sound`, `Menus.equipment_sound`, `Player.swing_sound`) or a name built from parts (`"step_" + surface`). A typo there played silence and failed nothing. `Sfx.play` now keeps every name it is asked for that has no file in `Sfx.missing`, and the test runner fails any test that adds to it, so the whole suite, the soaks' journeys included, checks the sounds that actually play. `test_a_sound_with_no_file_is_caught_at_runtime` checks that the list notices one, and that every choice the helpers and the rooms' footsteps can make exists. A misspelled `coin_big` fails the coin test through it.

**The mashing hand holds Attack (pass 151):** the soaks' mashing player pressed Attack but never held it, and none had learned a Blade skill, so Thrust (pass 149), Riposte and Rising Cut had never been soaked. The mashing now holds Attack for spans of 4 to 60 frames, most of them long enough to charge a Thrust, and every zone soak and both journeys learn the whole Blade branch. Each zone soak must see the player thrust (all but the Sunken Spring, which is all water). The first run found a bug that had nothing to do with the Thrust: the Mascon soak climbed into the Scorched Hall, fell back down its floor shaft and met Mascon's spikes before it first landed. Since M3 a floor or ceiling door had left the safe footing as the last room's until the first landing, so the hazard set it back at the Scorched Hall's coordinates, inside Mascon's ground. Every door's arrival is now the first safe spot (3.3, `test_spikes_before_the_first_landing_set_you_back_in_the_new_room`). The journeys now mash on dice of their own, so the doors they pick don't hang on the mashing, and the after-the-end leak check retraces its second lap, since a lap over new ground caches the music, sheets and tiles it meets for the first time.

**The mashing hand throws the dagger (pass 191):** the Rune Dagger (pass 184) had never been thrown in a soak, so every room's walls, doors, gates, planks and water, and every boss fight's `Enemy.take_throw`, had been met by it only in its own tests. The mashing hand now throws it every 25 frames. The timing comes from a counter, not the soak's random stream, so each soak's mashing stays the run it was before. Each zone soak checks that it threw at least once a room (`Player.throws`). The first full soak threw it 778 times across the rooms and in every boss fight with no problem.

**The mashing hand wears a shield too (pass 319):** the soak's hero starts a new game in every room, and a new game has no shield, so the guard, the parry, the Magic Shield's reflect and the ward had never been mashed in a real room. Since Sean's off hand (5.2) a shield and the dagger exclude each other, so one hero can't do both. Every other room of each zone's soak now wears the Magic Shield, and the rest keep the hand free. The soak checks the dagger was thrown at least once per free-handed room and the guard held at least 10 frames per shielded room. The first run guarded 2,085 frames across 62 shielded rooms with no problems, and frame times stayed between 0.57 and 1.11 ms.

**Saves and settings (pass 109):** no file the game reads can crash it or leave it half-loaded.
- **Writing.** Saves and `settings.cfg` are written to a `.tmp` file, read back whole, and only then swapped in, with the previous file kept as `.bak` (`GameState.write_safely`). A write that fails leaves the last good file untouched.
  - **A rest that can't save says so (pass 255).** `write_safely` reported a failed write, but nothing listened: `World.save_at` dropped the result, and the shrine always said "Rested. Progress saved." On a full or read-only disk a player could quit trusting a save that never happened. Now `save_at` returns whether the file was written. A shrine or a Guru that couldn't write still rests you and sets your respawn point, but says "Rested, but the journey could not be saved." (`SaveShrine.NOT_SAVED`), and the Guru names no mantra. Test: `test_a_rest_that_cannot_save_says_so`.
- **Loading.** A damaged file (empty, cut off, not JSON, not a save) falls back to its `.bak`. If neither reads, the load is refused and the game in play is left as it was. The title's Continue then starts a new journey with a note, rather than failing.
- **Sanitizing.** Whatever loads is rebuilt on a new game's data (`GameState.sanitize`):
  - every key is present and has its own type, and a wrong type falls back to the default;
  - lists keep only well-formed entries (skills, rings, pins, Guru stops), and the save point and purse must be whole;
  - numbers are finite and never negative, and health, MP and flasks never fall below a new game's;
  - keys from a newer build are kept.
- **Missing rooms.** A rest in a room this build lacks wakes you at the new-game spot.
- **Settings.** Each option must be the right type and in range, or it takes its default; only a real keycode is bound.
- **Older files (pass 129).** A settings file from an earlier build has no line for the actions added since. It loads with those actions on their default keys and logs nothing. It had logged an engine error for each missing action.
- **Saves naming what a build lacks (pass 138).** A save can name a skill node, blade, ring or dye that this build doesn't have (renamed, or from a newer build). Unlearning skills used to stop at such a node with a script error, after taking the gold and before refunding any points. Now an unknown node refunds nothing and the respec goes through. The save keeps each skill and dye once, as strings, so a skill listed twice can't be refunded twice. An unknown blade falls back to the Short Sword untempered: it had taken the missing blade's temper. An unknown dye leaves the cloak as it is. `test_a_save_naming_things_this_build_lacks_plays_on` runs such a save through loading, dressing, the skill list, the dyer and a respec with `ErrorCatcher` listening. **A slot holds its own kind (pass 191):** a save can now wear a known item in the wrong slot, such as a sword as a helmet or plate as a blade, since the helmet slot and kept gear came in. Such an item comes off when the save is loaded, and an empty blade slot falls back to the Short Sword. The kept gear list is strings, once each, and always holds the Short Sword; the Cloak section lists only dyes the save owns. `test_a_save_with_gear_in_the_wrong_slots_plays_on` runs such a save through the Equipment page (every row chosen), the shops and a dagger throw with `ErrorCatcher` listening.
- **Moved pickups (pass 213).** A pickup's id is its room and cell (`dartmoor/drowned_nave:31,6`), so moving one in a room file would hand a save that had already taken it a second copy at the new cell. `GameState.MOVED_PICKUPS` lists every move (old id to new id) and `sanitize` carries each taken one over. A scan of the level history found two: the Drowned Nave's Mantra Shard (pass 67) and the North Bough's Life Fruit (pass 211, and again in pass 216). Since then: the Sky Steps' purse (pass 219). Moving a pickup means adding a line there. `test_a_moved_pickup_stays_taken` checks the carry-over and that each old cell is empty and each new one holds a pickup.
- **Saves from before the off hand (pass 317).** Sean's off-hand rule (5.2, 2026-10-31) means a worn shield holds the throwing hand. A save from an earlier build that had found the Rune Dagger and wore a shield would load with Throw doing nothing, with nothing to say why: the pickup's banner that explains it had played under the old rule. Such a save is now marked as it loads (`GameState.VERSION` 2; `OFFHAND_VERSION`; the flag `notice:offhand`), and the next Continue shows a banner, "The Off Hand: Your shield now holds the throwing hand. To throw, choose the Rune Dagger under Off Hand (Equipment)." It shows once (`GameState.take_load_notice` clears it). The shield stays on, because which hand to keep is the player's choice. A save with the hand already free, or one written under the rule, is not told. Test: `test_an_old_save_with_shield_and_dagger_is_told_of_the_off_hand`.
- **The Dragon Slayer in the save (pass 221).** It is kept twice: as an ability (`abilities.dragon_slayer`, which the reach checker gates the heart's flesh on and the pass 217 migration reads) and as gear (the Equipment page; the blade in hand is what cuts the flesh). It was the one ability missing from a new game's list (`GameState.fresh`), so `test_every_save_field_survives_a_round_trip` never carried it, a damaged value kept whatever type it had, and a save could hold one half without the other. It is listed now, and `sanitize` makes a save hold both or neither: the sword in the gear grants the ability, and the ability puts the sword in the gear (not in hand). `test_the_dragon_slayer_is_held_as_ability_and_gear_together`.
- **No engine errors (pass 215).** The runner holds an `ErrorCatcher` over every test, and any engine error the test logs fails it, as a missing sound does (pass 207). Warnings are not counted. A test that sets out to provoke one, such as a damaged settings file that Godot's own parser reports, says so with `expect_engine_errors()`. Only the two settings tests do. The first run caught a real one: a test's wait captured a fireball that had already been freed, which Godot logs as an error. Waits now hold such nodes by weak reference. Loading a damaged save had also logged Godot's "Parse JSON failed" error before the game's own plain warning. It now parses with `JSON.new().parse`, which reports by return value, so a player's log shows only "user://save_1.json is not a save".
- **A clean slate for every test (pass 231).** The game keeps some state in statics (the options, stopped time, a trial or rush under way, a forced pose, the drop odds, the feel switches), and a static outlives the test that set it. A probe found the secret-ending test starting the real game, which loads and applies the options; it never put them back, so the six save tests after it ran with rumble on and the options file pointed at a test path. Worse, the suite's own `_restore` pointed the options back at `user://settings.cfg`, the player's file. Now the runner starts every test from one slate (`_clean_slate`: default options pointed at `TestSuite.SETTINGS_PATH`, never the player's file; no hitstop, rumble, sound or random drops; no stopped time, trial, rush or pose), fails any test that leaves one of them changed (`_leaks`), and wipes the slate either way. Test: `test_every_test_starts_from_a_clean_slate`.
- **Every option in the leak check (pass 327).** `_leaks` named each option by hand, so pass 325's mercy assist had to be added to the list, and an option left out would have leaked between tests unseen. Now `Settings.snapshot()` holds every option, and the runner compares it with the snapshot a fresh reset gives. `test_every_option_is_in_the_snapshot` reads the static vars in `settings.gd`, so an option missing from the snapshot fails it. It also flips each option to check it counts as a leak, and loads a file from before `[assist]` and one with a damaged mercy, both of which give mercy off without an engine error.
- **A soak that pushes a phase lands on it (pass 223).** The Hydra soak failed now and then ("the soak reached the flood"). The cause was in the test, not the fight: it pushes the boss's health onto each phase mark, and 99,999 x 0.3 rounds to 30,000, a hair above the mark, so the flood came only if a mashed blow happened to land after the push. Across 30 random seeds, 13 never got there. The soaks now push with `_push_to_mark`, which rounds down, and the Hydra soak checks the flood comes at the push itself. 30 of 30 seeds pass. The game's own marks were fine: a boss turns at or below its mark, and the phase-1 clamp stops above the next one.
- **The Bloom soak tears and broods (pass 263).** The Bloom soak claimed to tear the leaf in phase 2, but its player was put into biting range half a reach from the root, where a bite never tears. So the leaf was never torn in it (0 gaps, and the "never past 3 gaps" check passed on nothing), and pass 257's brood was soaked without a check. In phase 2, while the jaws choose and aim, the soak now holds the player 0.9 of a reach out over the wider side of the leaf, and it runs up to 20 s past its 30 if the leaf is still whole. It must tear the leaf (1 to 3 gaps) and loose the brood (never more than 3 at once). Then it fells the Bloom with a brood in the air, and no Lilith may outlive it.
- **The King Grieve soak calls his guard (pass 271).** Pass 268 gave the King a household guard of Shade Knights called from the throne, but his soak only checked duels, the ward and shard waves, so a guard that piled up, came more than `GUARDS` times, or outlived him under mashing would pass. The soak now counts every knight in the hall each frame. The guard must come at least once (every knight seen is one he called), never more than one stands at a time, and he never calls more than `GUARDS`. Then he falls with a knight still standing (the soak checks one does), and none may be left 4 s later, when the hall must hold no more nodes than it began with, dust and his gold aside. Dust is left out because the fall's slow motion runs on the wall clock, which a headless run outpaces, so its dust can still be in the air (the soak also ends it with `Feel.reset()`). Without `_dismiss_guard()` in his `die()`, the soak fails.
- **Every guardian is soaked (pass 279).** Fight soaks covered the Widow, the Hydra, the Foreman, the Bloom, the Roc, King Grieve, Shadow Eura and the Evil One's three forms. Six guardians had none: Rokusutahn, the Clockwork Alpha, the Bark Knight Captain, the Marsh Hag Matriarch, Zoradohna and the Drowned Warden. A lunge, web, hex, drill or wave that left an effect behind would have passed. `test_every_other_guardian_fight_soak_stays_lean` fights each of them in its arena for 20 s against a mashing hero who can't die. Halfway through it drops the guardian to 15% health, so its later phase is soaked too, and it holds the guardian's health there so the fight never ends. Then it lets go of the controls for 4 s. It checks that the room never grows by 60 nodes or more and settles back within 6 of where it started (leaving out dust and coins). It also checks that a frame averages under the 60 fps budget (0.5 to 0.6 ms on the test machine). Rokusutahn's torn floor is meant to stay, so its spikes are counted apart and must never pass one per torn column (26). With the floor torn twice, the test fails. All six held, so nothing needed fixing.
- **Every foe's spoils stay in its room (pass 287).** Passes 283 and 285 kept drops and coins inside the room (`Drop.keep_in_room`), but only the two Naga rooms were tested. `test_every_foes_spoils_rest_in_its_room` now kills every foe in every room at once: 82 rooms, each foe leaving a loaf and three coins, 1,012 pickups in all. Every one must rest on a floor inside its room within 5 s, and each room must keep its 8 ms frame budget while it all falls. All hold. With the coins' guard removed, 14 coins are lost across twelve rooms, not just the Naga rooms: six in five rooms of the Trunk (the Sapwell Deeps twice, the Sap Tunnel, the Sap Cistern, the Grub Warren, the Mossy Overhang), five in four rooms of the Tower (the Winch Hall twice, the Mine Mouth, the Mine Shaft, the Smelter), two in the Mist (Fog Cut, the Scorched Hall) and one in the Sunken Spring's Source Hall. So pass 285 kept more gold than it measured.
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
