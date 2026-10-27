# Room files

A room is a text file: `key: value` header lines, a line with `---`, then the tile grid.
One character is one 16x16 tile. The room's size is the grid's size.

```
name: Movement Gym
zone: gym
map: 0, 0          (the room's top-left on the map, in screens)
door: 1, trunk/hollow_02, 3   (door 1 here leads to door 3 of that room)
label: 3, 33, Some text placed at tile (3, 33)
sign: 8, 19, First page|Second page   (a lore tablet at tile (8, 19); | splits pages)
npc: 12, 19, guru  (a person from data/npcs.json standing on tile (12, 19); an optional
                   fourth field shows them only once a flag is set, or with !flag until then;
                   several conditions, space-separated, must all hold)
secret: 57, 5, 62, 7   (covers tiles 57,5 to 62,7 with fake wall so a hidden room's
                        contents can't be seen until the player walks in)
enemy_respawn: 5   (optional: seconds until defeated enemies return; 0 = never)
corrupted: true    (optional: foes are grown through with meteor crystal; default true in zone zenis)
chest_gold: 100    (optional: gold in each chest in this room)
chest: 2, 19, 900   (optional, repeatable: the chest on tile (2, 19) holds 900 gold instead)
lock: 4, 19, queen   (optional, repeatable: the `J` on tile (4, 19) is a queen, king, ace or joker door)
prop: 40, 19, fountain   (a set piece standing on tile (40, 19): fountain, spring_trunk, spring_mist (clears only after boss:zorugeriru), house, lamp (a lamp post whose lantern lights the fog), taproot, lift, forge, winch, crucible, trial_goal (the bell at the end of a Guru Trial), joker_key (the one Joker Key), battle_helmet (the found helmet, in its own slot since pass 185))
boss: rokusutahn   (a boss arena: doors seal until the boss is beaten)
music: title       (optional: a track other than the zone's, from assets/music/)
ambience: heights  (optional: an ambience bed other than the zone's; plays assets/music/amb_heights)
fog: 0.5           (optional: the Mist's fog density over this room, 0 for none; the zone's otherwise)
surface: stone     (optional: the ground's footstep sound if not the zone's: stone, moss, mud, plank, iron, sap)
retro: true        (optional: the world is drawn through the NES filter, RetroFilter: chunky pixels in a 4:3 frame, NES palette only. Eolis of Old)
calm: boss:king_grieve   (optional: once this world flag is set the room spawns no foes; a town woken again. The Drowned Market)
camera: wide       (optional: the camera eases out to show 25% more each way, for big arenas and sky rooms; never past the room's edges, so make the room at least 50x29 tiles to get all of it)
---
##########
#P.......#
##########
```

| Char | Meaning |
| --- | --- |
| `#` | Solid ground (top-exposed tiles get a moss edge) |
| `-` | One-way platform (jump up through, Down + Jump to drop) |
| `"` | Ladder (bible 6.11): a column of these; Up/Down climb, Jump leaves. The top cell is also a one-way plank you can stand on |
| `/` `\` | 45° slope, solid below the diagonal: `/` rises to the east, `\` to the west. Put ground under it and on its high side; the reachability checker counts it as a whole block |
| `^` | Floor spikes (hazard, pogo-able) |
| `o` | Thorn bulb (hazard, pogo target) |
| `C` | Cracked stone (Mattock breaks it) |
| `E` | Training dummy |
| `M` | Monodron (hopper) |
| `H` | Hornet (flier; placed at the tile center) |
| `D` | Rot Dwarf (shielded walker) |
| `T` | Sap Spitter (turret; lobs sap that leaves a slowing puddle) |
| `U` | Grub Lump (crawls on floors, walls and ceilings; clings to the floor first, else the ceiling, else a wall) |
| `I` | Iron Dwarf (armored; slams a hammer that sends a shockwave along the floor; hit him while it is stuck) |
| `B` | Gear Bat (roosts upside down; place it just under a ceiling. Flings a returning gear; parry it back at the bat) |
| `K` | Minecart Rider (rolls the floor; revs, then charges to a wall or the floor's end and tips over: hit him then) |
| `A` | Lantern Ghost (drifts through walls; out in the Mist's fog it shows only near light. Eyes flare, then it lunges) |
| `V` | Bog Myconid (rooted; its gills glow as it swells, then it bursts into a lingering spore cloud. Soft while spent) |
| `p` | Drowned Dwarf (the Mist: lies sunk in the mire, unhittable, a crest and bubbles showing; rises when you come near, heaves his anchor, then slams it down in front of him (parryable). Soft while rising and while the anchor is buried; sinks again once he loses you) |
| `m` | Leaf Mantis (hides folded on a bough; unfolds, lunges with its scythes, stops at ledges. Parryable; soft while overreached) |
| `!` | Bark Knight (the Branches: paces in living bark, braces, then thrusts a bough lance about four tiles (parryable) and roots with it out, so the lance is a ledge you can stand on or pogo off. Each blow on his bark only chips one of three plates; bare or rooted he takes full damage, and one plate grows back as he pulls free) |
| `;` | Seed Bomber (the Branches: a pod-bellied bird that keeps about five tiles over your head; squeezes its glowing husk, then drops a seed that sputters and bursts in thorns. Strike the seed back up to knock the bird down. Placed at the tile center; give it open air above the road) |
| `?` | Marsh Hag (the Mist): keeps her distance and hexes the mire under your feet; strike her mid-hex to break it |
| `t` | Thunder Beetle (Daybreak: trundles the floor; its shell turns side blows but not a pogo. Near it, its wing cases crackle, then it discharges a ring of lightning (unparryable, above too); spent, it takes full damage) |
| `y` | Storm Harpy (Daybreak: hangs above and beside you; rears and spreads her wings with a screech, then flings a fan of three parryable feathers (a parried one flies back at her); winded, she sags into reach) |
| `]` | Spire Sentinel (Daybreak: a stone knight that moves only while your back is turned and turns every blow; raises its halberd, then slams in front of it, parryable; cracked open after a parry or a miss) |
| `q` | Crystal Dwarf (Dartmoor: trudges toward you; raises his crystal fist, then drives it into the floor and a chain of crystal spikes erupts toward you (unparryable: jump them); his crystal back turns blows from behind except from above; rooted after, he takes every blow) |
| `R` | Root-gate tile (solid roots; a column of three is usual) |
| `Z` | Fire seal tile (red runic flames: solid, burns on touch; one Deluge bolt douses every seal in the room for good. Wall it in above, or it can be jumped) |
| `c` | Dead conduit (a copper coil, not solid; a Thunder bolt passing within 72 px wakes it for good) |
| `k` | Conduit gate tile (solid; slides open for good once every conduit in the room is awake) |
| `h` | The Thunder scroll |
| `w` | Bramble wall tile (dry thorn-vine: solid; a Fire spell burns the whole knot to ash for good. Fire is optional, so hide only secrets behind it) |
| `u` | Dry basin mud bed (solid ground, cracked) |
| `=` | Dry basin water-line stain: a run of these across a tank above its `u` bed. A Deluge bolt across the tank fills it and the run becomes a one-way raft for good |
| `b` | Drowned boardwalk (the Mist): nothing until the Spring of Mist flows (`spring:mist`), then a one-way platform. Lay it over a spiked dip |
| `@` | Bounce-pod (Branches): stands on the floor of its cell; land on it and it throws you about nine tiles up. Not solid |
| `r` | Stride seed (bible 6.4): floats at the cell's center; touched in the air with a double jump or dash spent, it bursts and gives both back, and grows again after 2.5 s. Seeds only help: the checker ignores them, so never make one the only way to a pickup or exit |
| `>` `<` | Wind current (Branches): a band of wind blowing east (`>`) or west (`<`) that carries an airborne player and bears up a fall; holding Down drops out. Once the Spring of Sky is restored every current blows the other way. Draw them as whole rectangles over open sky
| `Q` | Flue damper tile (iron louvers, solid until Zoradohna falls and the winch turns; a row of three is usual) |
| `N` | Root Heart: strike it and every root-gate in the room opens for good |
| `Y` | Bound fog (the Mist): solid until the player brings the Lantern Key near, then every curtain in the room parts for good (a row of three is usual) |
| `P` | Player spawn (feet at the bottom of the tile) |
| `1`-`9` | Door cells (see below) |
| `%` | Fake wall: looks solid, walk through it (a secret). With the Black Onyx a thin violet seam shimmers around it |
| `i` | Hidden plank: a one-way platform that is always there but unseen; the Black Onyx shows it faintly |
| `n` | Black Onyx (passive ability pickup) |
| `f` | Time-locked water: a block of falling water that bears you down; frozen by the Hour Glass, it has a foothold every 3 rows up from its bottom. Fill a shaft wall to wall so nothing climbs past it |
| `v` | Wrong gravity (Zenis): a block where the player keeps 40% of their weight, so a jump rises about 11 tiles and a fall drifts. The checker allows a 9-tile rise from a spot inside one when the column up to the landing is drift too |
| `a` | Deep water (the Sunken Spring): the player swims while the middle of the body is in it (floats up, sinks holding Down, jump strokes up, and with the head out jumps clear). Not solid. Draw pools as whole blocks; the checker swims through water cells and jumps out from the surface |
| `l` | Spring Eel (the Sunken Spring), in a cell of water: it never leaves the water; it coils, then darts and bites |
| `+` | Heart seal (Zenis): living flesh across a passage, a wall to every blade but the Dragon Slayer, which tears it open for good |
| `{` | The Death scroll (spell pickup, bible 4.1): a late secret |
| `&` | The Dragon Slayer (bible A10): found, it goes straight into your hand |
| `}` | The Rune Dagger (bible 5.2): the Throw button hurls it; it reforms at your hip. In the Trunk's Hornet Gallery |
| `z` | Hour Glass (ability pickup) |
| `e` | Shade Knight (Dartmoor: tower shield turns frontal blows; parry his thrust or cut) |
| `j` | Clockwork Hound (Dartmoor: winds up and pounces; parry flips it; the Hour Glass stops it) |
| `s` | Meteor Slug (Dartmoor: lobs three burning globs; shell turns pogos; the Hour Glass holds the globs) |
| `~` | Sap pool: halves run speed and weakens jumps (Trunk Hollows) |
| `S` | Meditation Shrine (save, refill, respawn point) |
| `J` | Jack door, 3 tiles tall from this cell up (opens with a Jack Key). A `lock:` header line makes it a Queen, King, Ace or Joker door |
| `g` | Dartmoor's upper gate, 3 tiles tall from this cell up (opens with the Sky Key, Borabohra's reward) |
| `$` | Treasure chest (gold, opens once) |
| `G` | Climbing Glove (ability pickup) |
| `X` | Wing Boots (ability pickup: double jump; glows in the fog) |
| `O` | Deluge scroll (spell pickup; glows in the fog) |
| `d` | Elven Stride (a warden's feather; grants the dash) |
| `L` | Life Fruit (+1 mask) |
| `W` | Mana Dew (+10 max MP) |
| `F` | Potion Shard (3 = +1 flask charge) |
| `*` | Mantra Shard (3 = +1 skill point) |
| `(` | Meteor Shard (Temper Blade II at the Forepaw smith costs one) |
| `.` | Empty |

## Rooms and doors

A room's id is its path under `levels/` without `.room`, e.g. `eolis/gate`. The file's
directory is its zone folder; set `zone:` to match (it picks the map color and the area name).

Rooms are whole screens: 40 tiles wide and 23 tall per screen (two screens tall is 45).
`map: x, y` places the room's top-left corner on the map grid, counted in screens.

Mark a door with a digit, repeated over every cell of the opening, and add a `door:` line.
- A door touching the left or right edge is walked through. Put floor right under it; the
  player arrives standing just inside the matching door.
- A door on the top or bottom edge is a shaft. Coming up through a floor door, the player
  pops up with a small boost, so put a ledge beside the shaft's top.
- A door away from the edges is an inner doorway, used by pressing Up.

Every door must lead to a door that leads back (`tests/test_rooms.gd` checks this).
Pickups, chests and cracked walls remember being taken or broken (by room id and tile), so
moving one in a room file makes it collectable again.

## Design rules the tests enforce

`tests/test_reachability.gd` runs the reachability checker (`scripts/world/reach.gd`) on
every room: from the new game spawn, with no abilities, the Climbing Glove must be reachable
and the boss must not be; with the glove (and keys) every room, pickup, chest and shrine must
be reachable; and no reachable spot may be a soft-lock (unable to get back to a save, or on
to the glove). It also boots every room and checks the player lands safely.

A pickup meant to open only after the Spring of Trunk (sap hardens into amber) goes in
`AMBER_SECRETS` in `tests/test_reachability.gd`; the test then proves it is gated.

Sap with open air beside it and more sap below draws as a pouring falls (Amber Falls).

Safe numbers for layouts (a little under the real movement): a standing jump clears 4 tiles
up with 2 across, 3 up with 4 across, or 2 up with 5 across. Leave 3 clear tiles of headroom
for the body. Platforms that should be reachable from the floor go 4 rows above it.
A slope (`/`, `\`) starts on open floor at its low side and meets ground at its high side;
stack them diagonally for a taller ramp, with ground under each. Walkers turn at a ramp.
