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
| 4 | **Branches (Conflate)** | Conflate | 24 | Sunlit canopy, enormous leaves, wind | Wind currents; bounce-pods | Pakukame |
| 5 | **Branches (Daybreak) and Canopy Spires** | Daybreak | 26 | Sky islands, storms, ruined elf shrines | Lightning conduits; air dash routes | Borabohra |
| 6 | **Dartmoor** | Dartmoor | 28 | Flooded dwarf capital, meteor crystals growing through masonry | Time-stop puzzles; illusory walls | King Grieve, Shadow Eura |
| 7 | **Zenis** | none | 14 | Inside the meteor: organic stone, alien light, gravity wrong | Gauntlet using every ability | The Evil One |
| opt | **Sunken Spring** | none | 8 | Under Dartmoor, the original source of the springs | Underwater swimming (Deluge-drained rooms) | Optional: The Drowned Warden |
| opt | **Guru Trials** | Eolis | 6 | Abstract mantra-space, monochrome | Pure platforming challenges | none |

### 3.3 Room and map rules

- **Room size:** multiples of one screen (640x360 px internal = 40x22.5 tiles of 16 px). Rooms are 1x1 up to 4x3 screens.
- **Camera:** room-bounded; camera locks to room edges; transitions are seamless scrolls (no fade) within a zone and a brief fade between zones. The scroll is a screen push: the old view slides out the way the player went while the new room slides in (0.34 s). Inner doorways (Up to enter) fade, since there is no direction to scroll.
- **Save points:** each town has a Guru (save, respec, rank-up). Plus 2 to 3 **Meditation Shrines** per zone (save only). No room is more than 4 rooms from a save or a shortcut back to one.
- **Fast travel:** unlocked after the first spring: Guru-to-Guru travel through the "Mantra Path" menu.
- **Map:** auto-maps visited rooms. The Cartographer in each town sells the zone outline (empty rooms shown dimmed). Map pins (custom markers) available from the start. Doors, gates and items get icons once seen.
- **Landmarks:** every zone has at least 3 visually unique landmark rooms (a giant statue, a waterfall, a crashed airship-dwarf barge) so players can navigate by memory.

---

## 4. Progression

### 4.1 Abilities (the gates)

Abilities are permanent and listed in acquisition order. Each one opens new routes in every earlier zone.

| # | Ability | Faxanadu root | What it does | Gate it opens | Found in |
|---|---------|---------------|--------------|---------------|----------|
| A0 | **Wanderer's Kit** (start) | (original hero) | Run, jump, variable jump, slash, up-slash, Red Potion flask | none | Start |
| A1 | **Climbing Glove** | Glove | Wall slide and wall jump | Tall shafts, narrow chimneys | Trunk Hollows, mid-zone shrine |
| A2 | **Mattock** | Mattock | Down-strike in the air: **pogo** off enemies, spikes and thorn bulbs; breaks cracked stone | Cracked walls and floors, thorn-bulb chains, spike corridors | Tower of Trunk, after a mini-boss |
| A3 | **Wing Boots** | Wing Boots | **Double jump** (feathers burst), refreshed by pogo and wall touch | Wide gaps, high ledges | The Mist, Victim side |
| A4 | **Deluge** (spell) | Deluge | Water bolt: puts out flame barriers, fills basins (floating platforms rise) | Fire seals, dry basins | The Mist, Mascon side |
| A5 | **Elven Stride** | (new, elven) | **Air dash** with brief invulnerability; passes through mist curtains | Mist curtains, long horizontal gaps, wind walls | Branches, Conflate |
| A6 | **Thunder** (spell) | Thunder | Bolt that arcs to conductors; powers elevators and doors | Dead conduits | Branches, Daybreak |
| A7 | **Black Onyx** | Black Onyx | Passive: illusory walls shimmer; hidden platforms faintly visible | Illusory walls (secrets and one main route in Dartmoor) | Dartmoor, early |
| A8 | **Hour Glass** | Hour Glass | Stops time for 2.5 s (cooldown 8 s): freezes falling water, crushers, platforms, projectiles | Time puzzles, waterfall stairs | Dartmoor, mid-zone |
| A9 | **Elf, Ruby, Dworf and Demon Rings** | Rings | Story keys: the four rings open the gate of Zenis | The Zenis gate | Rokusutahn, Zoradohna, Zorugeriru, King Grieve |
| A10 | **Dragon Slayer** | Dragon Slayer | The only blade that can hurt the Evil One's core | Final boss | Zenis, inside the gate |

Supporting spells (optional, combat-focused, found or bought): **Fire** (arcing fireball, burns bramble walls for secrets), **Tilte** (homing spirit orb), **Death** (screen-wide, very expensive, late secret).

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
- A wall-jump route skips most of the Tower of Trunk after Zoradohna is beaten.
- Hour Glass can be reached before Black Onyx with precise dashes.
All story triggers check items, not route order.

### 4.4 World-state changes

| Trigger | Change |
|---------|--------|
| Spring of Trunk restored | Sap pools in Trunk Hollows harden into walkable amber; new route to a secret; Apolune NPCs return; Eolis fountain 1/3 |
| Zoradohna defeated | Forepaw dwarves freed; elevator to Eolis; dwarf smith opens (weapon upgrades) |
| Spring of Mist restored | Fog lifts by half in the Mist (vision radius grows); drowned boardwalks resurface; fountain 2/3 |
| Spring of Sky restored | Wind currents reverse in Branches (new routes); Eolis festival, fountain full, final shop tier |
| King Grieve defeated | Dartmoor drains; Sunken Spring entrance opens |
| Evil One defeated | Post-game: Tree blooms, palette shift to spring colors, all enemies respawn as "remnants" for 100% cleanup |

### 4.5 Gate visual language

Every gate has a consistent, readable look so players remember it:
- **Cracked stone:** pale crack lines, small pebbles fall when you are near (Mattock).
- **Thorn bulbs:** red glowing pods on spike vines (pogo targets).
- **Mist curtains:** shimmering vertical fog with a faint elven rune (Elven Stride).
- **Fire seals:** red runic flames (Deluge).
- **Dry basins:** cracked mud basins with a water-line stain (Deluge).
- **Dead conduits:** copper coils with a dim blue spark (Thunder).
- **Illusory walls:** a 1-pixel seam visible only with Black Onyx.
- **Time-locked water:** waterfalls with clock-glyph droplets (Hour Glass).
- **Key doors:** Jack, Queen, King, Ace and Joker doors with a card-suit glyph.
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
| Blade | Hand Dagger (start, fast, short) | Long Sword (400 g) | Giant Blade (2,800 g, slow, huge arc) | Dragon Slayer (found) |
| Armor | Leather (200 g) | Studded Mail (1,100 g) | Full Plate (4,200 g) | Battle Suit (secret) |
| Shield | Small Shield (150 g) | Large Shield (900 g) | Magic Shield (3,600 g, reflects small projectiles on parry) | Battle Helmet (secret, +1 mask) |

Each blade has its own swing speed and reach, so a weapon change is a play-style change, not just a number. The dwarf smith in Forepaw upgrades each blade twice (+15% each) for gold plus Meteor Shards.

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

- **Slash:** 3-hit ground combo, 2-hit air combo. Each hit pushes the player back 4 px (knockback against enemy on hit).
- **Up-slash:** hits above; a hit on a launcher-type enemy pops the player up slightly.
- **Down-strike (Mattock):** see pogo in 6.6.
- **Parry (shield):** tap Block within 0.12 s of a hit: no damage, 140 ms hit-stop, enemy staggered. Holding Block reduces damage by the shield's percent but drains MP.
- **Spells:** one equipped spell on the Spell button, cycle with shoulder buttons. MP regenerates slowly and on melee hits.
- **Damage taken:** 0.8 s invulnerability, 0.15 s hit-stop, knockback, screen flash.

**Starting combat values** (in `scripts/player/combat_tuning.gd`, asserted by tests):

| Value | Setting |
|-------|---------|
| Light hit / heavy third hit | 8 / 14 damage (Hand Dagger) |
| Combo window, cooldowns | 0.40 s to chain; 0.20 s, 0.20 s, 0.38 s after hits 1 to 3 |
| Attack buffer | 0.15 s |
| Parry window | 0.12 s from the Block press; 140 ms hit-stop, enemy staggered 1 s, +6 MP |
| Guard (Small Shield) | 50% less damage, 8 MP per blocked hit, 40% walk speed |
| Knockback when hit | 160 px/s back, 220 px/s up, 0.18 s control lock |
| MP | 60 max, +2/s, +4 per melee hit on an enemy |
| Red Potion | 2 charges, +40 HP, 0.7 s to drink, cancelled (charge kept) if hit |
| Deluge | 15 MP, 12 damage, 300 px/s |
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
| Slope handling | snap to slopes up to 45°, no speed loss going up |

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
| Coyote time | 0.10 s |
| Jump buffer | 0.12 s (works on ground, wall and double jump) |
| Corner correction | nudge up to 6 px horizontally on head bump; 4 px vertically on ledge clip |
| Minimum jump height | about 18 px (tap) |

### 6.3 Wall slide and wall jump (Climbing Glove)

| Parameter | Value |
|-----------|-------|
| Wall slide speed | max 90 px/s (falls slowly with dust particles) |
| Wall stick | 0.08 s before pushing away detaches |
| Wall jump velocity | 220 px/s outward, 380 px/s up (pushing away from the wall) |
| Climb jump velocity | 120 px/s outward, 380 px/s up (neutral or toward the wall; lock 0.06 s) |
| Input lock after wall jump | 0.10 s, then control blends back over 0.10 s |
| Same-wall climb | allowed (neutral wall jump goes up and slightly out, Hollow Knight style) |
| Wall coyote | 0.08 s after leaving a wall |

### 6.4 Double jump (Wing Boots)

| Parameter | Value |
|-----------|-------|
| Height | 48 px (3 tiles), velocity 326 px/s |
| Count | 1, refreshed by ground, wall touch, pogo, and dash-reset orbs |
| Feel | feather burst, small upward squash, wing whoosh |

### 6.5 Air dash (Elven Stride)

| Parameter | Value |
|-----------|-------|
| Speed and duration | 380 px/s for 0.15 s (about 57 px) |
| Gravity during dash | none; exits with vy = 0 |
| Invulnerability | first 0.10 s |
| Charges | 1 in air (2 with skill node), refreshed like double jump |
| Ground dash | yes, same values, 0.25 s cooldown |
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

### 6.7 Juice checklist (all required before the movement milestone closes)

- **Squash and stretch:** jump 0.85x1.2 for 3 frames; land 1.25x0.8 scaled by fall speed; wall jump stretch toward direction.
- **Dust:** on run start, turnaround, land, wall slide (every 0.06 s), wall jump.
- **Hit-stop:** 50 ms normal hit, 90 ms heavy, 140 ms parry, 200 ms boss stagger, 350 ms boss kill (with slow-mo ramp).
- **Screen shake:** trauma model (shake = trauma²), decays 1.5/s. Light hit 0.15, heavy 0.3, boss slam 0.6. Option to reduce or turn it off.
- **Flash:** enemy flashes white for 2 frames on hit; player flashes red and blinks during invulnerability.
- **Camera:** look-ahead 48 px in facing direction (eased over 0.4 s); vertical look-down when holding down for 0.4 s; lerp smoothing with deadzone 16x24 px.
- **Rumble:** on gamepads, light for hits, strong for damage and boss slams.
- **Sound:** layered footsteps per surface; distinct jump, double jump, wall jump, dash, pogo and land sounds.
- **Particles:** spark burst on hit, gold coins that bounce and magnet to the player after 0.4 s.
- **Input:** every action responds on the same frame it is pressed. 60 fps physics, fixed timestep; rendering uncapped with interpolation.

---

## 7. Enemies

About 4 to 5 enemy families per zone plus variants (recolors with new behavior). Names reuse the original's monster names where they exist.

| Zone | Enemies |
|------|---------|
| Trunk Hollows | Monodron (one-eyed hopper), Hornet (swooper), Rot Dwarf (shield-bearing walker), Grub Lump (crawls over floors, walls and ceilings; from a ceiling it shivers for 0.45 s, then drops on you), Sap Spitter (turret; lobs sap globs that leave a slowing puddle for 4 s) |
| Tower of Trunk | Iron Dwarf (plated walker: raises a hammer for 0.65 s, slams, and sends a shockwave along the floor that a hop clears; his plate halves blows except from above or while the hammer is stuck in the floor for about 1 s), Minecart Rider, Gear Bat, Rock Golem (mini-boss: the Foreman) |
| The Mist | Lantern Ghost (only visible near light), Bog Myconid (spore cloud), Marsh Hag, Drowned Dwarf (rises from water), Mist Wisp |
| Branches (Conflate) | Leaf Mantis, Sky Ray (gliding), Seed Bomber, Bark Knight |
| Branches (Daybreak) | Storm Harpy, Thunder Beetle (pogo-able shell), Spire Sentinel, Wind Imp |
| Dartmoor | Crystal Dwarf (meteor-fused), Shade Knight (parry-heavy), Clockwork Hound, Meteor Slug |
| Zenis | Remixes of every family, corrupted with meteor crystal |

Every enemy has: a readable telegraph (minimum 0.35 s wind-up with a pose and a flash), a hurt reaction, a death animation with a dissolve, and drops (gold, MP orbs, rare items). Besides gold, about 1 kill in 12 leaves **bread** (heals 15, the original's staple) and 1 in 10 a **mana orb** (+12 MP); both wait on the floor for 10 s.

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
- **Concept:** A dwarf champion fused with a mining engine, piloting a walking siege drill. The dwarf inside is still conscious and begging to be stopped.
- **Arena:** a vertical elevator shaft that keeps rising during the fight.
- **Tests:** pogo (the drill's exhaust vents are pogo-able and the only way to reach the cockpit).
- **Phase 1:** drill charges and shockwave slams on a single platform.
- **Phase 2:** the elevator rises; falling debris must be pogoed; the drill climbs the shaft walls.
- **Phase 3:** cockpit opens; down-strike the dwarf's crystal harness to free him.
- **Reward:** Ruby Ring, frees Forepaw, unlocks the dwarf smith.

### 8.3 Ripasheiku, the Lantern Widow (The Mist)
- **Concept:** A spider-wraith that carries the souls of the drowned as lanterns on her legs. She is invisible except where her lanterns glow.
- **Arena:** a sunken chapel in heavy fog.
- **Tests:** reading by light; double jump.
- **Phase 1:** she stalks in the dark; each lantern you break makes more of her visible.
- **Phase 2:** she hangs from the ceiling and drops web lines that pull you toward her.
- **Phase 3:** all lanterns broken; she is fully visible, fast, and desperate.
- **Reward:** Lantern Key (opens the path to Zorugeriru), Mana Dew.

### 8.4 Zorugeriru, the Mist Hydra (The Mist)
- **Concept:** A three-headed serpent made of fog and bone, coiled around the Spring of Mist. Only the head that is solid at the moment can be hurt.
- **Arena:** the spring basin; the water level changes across phases.
- **Tests:** Deluge (filling the basin raises platforms to reach the high head) and air control.
- **Phase 1:** heads take turns becoming solid; mist breath sweeps.
- **Phase 2:** use Deluge on the three basins to float platforms up to the hidden fourth head.
- **Phase 3:** the body uncoils and the arena floods; fight on floating debris.
- **Reward:** Dworf Ring, restores the Spring of Mist.

### 8.5 Pakukame, the Devouring Bloom (Branches, Conflate)
- **Concept:** A carnivorous flower the size of a house, rooted in a leaf, with a turtle-shell bulb that snaps shut. Pakukame "chomps" (paku-paku).
- **Arena:** a giant curved leaf over open sky, edged with bounce-pods.
- **Tests:** air dash through its vine lashes and over the gaps it bites in the leaf.
- **Phase 1:** vine whips and seed spit; its mouth opens after each bite (weak point).
- **Phase 2:** it bites chunks out of the arena; you dash across gaps and bounce on pods.
- **Phase 3:** it uproots and chases you along a falling leaf (short chase sequence).
- **Reward:** skill point, large gold drop, the Conflate gate opens.

### 8.6 Borabohra, the Storm Roc (Branches, Daybreak)
- **Concept:** A titanic thunderbird nesting on the highest spire, its feathers made of rain clouds.
- **Arena:** three floating islands; the camera pulls out wide.
- **Tests:** Thunder (charge the conduits on each island to ground the bird) and everything in the air.
- **Phase 1:** dive bombs and feather volleys; ground it by powering conduits.
- **Phase 2:** a storm; lightning hits the tallest point, so stay low or use it.
- **Phase 3:** aerial duel: you ride its updraft and pogo its head.
- **Reward:** Sky Key, restores the Spring of Sky.

### 8.7 King Grieve, the Drowned Sovereign (Dartmoor)
- **Concept:** The dwarf king who bargained with the meteor. Tragic, regal, half crystal. He fights with a great-axe and royal guards he summons.
- **Arena:** a flooded throne room; the water clock on the wall drains during the fight.
- **Tests:** Hour Glass (freeze his crystal shards in the air and use them as platforms) and parrying.
- **Phase 1:** honorable duel; heavy axe combos with clear parry windows.
- **Phase 2:** summons crystal guards; shards fly; time-stop them into stepping stones to reach his crown.
- **Phase 3:** the meteor takes control; his body cracks; frantic, faster, corrupted patterns.
- **Reward:** Demon Ring; the dwarves of Dartmoor are freed; Dartmoor drains.

### 8.8 Shadow Eura, the Mirror (Dartmoor, Zenis gate)
- **Concept:** A shadow copy of the player, made from every fight the meteor has watched. Uses your abilities and your equipped spell.
- **Arena:** a mirrored hall with a reflective floor; the player's reflection is the boss.
- **Tests:** mastery of all movement.
- **Phase 1:** mirrors your inputs with a delay.
- **Phase 2:** acts on its own, using your highest-level skill tree branch against you.
- **Phase 3:** splits into two; one is real (only the real one shows in the floor reflection).
- **Reward:** the Zenis gate opens.

### 8.9 The Evil One (Zenis)
- **Concept:** Not a demon king but a parasite: a vast eye-flower of meteor crystal rooted into the Tree's crown, feeding through veins of light.
- **Arena:** the heart of the meteor; three arenas in sequence.
- **Phase 1 (The Throne):** a humanoid avatar in armor duels you; standard boss.
- **Phase 2 (The Veins):** the avatar shatters; you climb a vertical chamber cutting light-veins while the core fires beams (uses wall jump, dash, pogo, Hour Glass).
- **Phase 3 (The Core):** only the Dragon Slayer can hurt the core; each strike restores a spring's light and the Tree fights alongside you (roots lash the core).
- **Reward:** ending; credits climb up the Tree from Eolis to the crown.

### 8.10 Optional boss
- **The Drowned Warden (Sunken Spring):** an ancient guardian of the spring source; the hardest fight in the game; drops the Battle Suit.

Mini-bosses (about one per zone): The Foreman (rock golem), Marsh Hag Matriarch, Bark Knight Captain, Clockwork Alpha.

---

## 9. Skill Tree

The **Guru** in each town teaches skills. Points come from:
- **Ranks:** XP from kills raises your title, using the original's 16 ranks (Novice, Aspirant, Battler, Fighter, Adept, Chevalier, Veteran, Warrior, Swordman, Hero, Soldier, Myrmidon, Champion, Superhero, Paladin, Lord). Each rank after Novice = 1 point (15 total).
- **Bosses:** 1 point each from the 9 main bosses (9 total).
- **Mantra Shards:** hidden secrets; 3 shards = 1 point (15 shards, 5 points).

That is **29 points** available against a tree that costs **54** in total, so players must choose. Respec at any Guru for gold (200 g, then 400 g, 600 g and so on, capped at 2,000 g).

Rank XP thresholds (in `GameState.RANK_XP`): 0, 40, 100, 180, 300, 460, 660, 900, 1,200, 1,560, 2,000, 2,500, 3,100, 3,800, 4,600, 5,500. Starting enemies give 5 XP (Rot Dwarf 12), so the Trunk Hollows take a careful player to about Fighter. Ranks rise the moment you pass a threshold and give the point right away; the Guru is where you spend it.

Three branches, 12 nodes each. Costs in brackets. Nodes deeper in a branch need the one before.

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
| Key master | Eolis, Victim, Dartmoor | Jack (150 g), Queen (400 g), King (900 g), Ace (1,800 g) keys; the Joker key is found |
| Cartographer | every town | zone map outlines (200 to 800 g), map pins |
| Spell scrolls | Mascon, Daybreak | Fire (1,200 g), Tilte (2,500 g) |
| Guru | every town | save, skill tree, respec, rank-up |

**Gold sinks:** respecs, Ointments and Elixirs, keys for optional doors (each guards a reward), smith upgrades, cosmetics (cloak dyes, 6 total, purely visual).

---

## 11. Secrets

Target: **at least 3 secrets per zone room-cluster**, about 70 total.

| Type | Count | How it's hidden | Reward |
|------|-------|-----------------|--------|
| Breakable walls (Mattock) | 18 | Cracked stone, sometimes faint | Gold, Life Fruit |
| Illusory walls (Black Onyx) | 10 | Seam visible only with Onyx | Mantra Shards, lore |
| Key doors | 12 | Visible, need a card key | Equipment, spells, shortcuts |
| Life Fruit | 14 | Mix | +HP |
| Mana Dew | 9 | Mix | +MP |
| Potion Shards | 9 | Mix | +flask |
| Mantra Shards | 15 | Mostly hard platforming | Skill points |
| Meteor Shards | 10 | Elite drops, hard rooms | Smith upgrades |
| Guru Trials | 6 | Unlock as springs are restored | Cosmetics, a Mantra Shard each |
| Lore tablets | 12 | Dwarf ruins | Story, map hints |

**Easter eggs:** a hidden room in Eolis rendered in authentic 8-bit NES palette and resolution, with the original's music style; the Guru recites the old password mantra as a joke ("Your mantra is..."): resting with him shows a 16-letter mantra made from your progress (`GameState.mantra()`); it is never typed back in. A secret ending if you reach the Evil One with no deaths and the Battle Suit.

**Completion screen:** shows % with category ticks; 100% unlocks a boss rush and a "Lord" title glow on the cloak.

---

## 12. Art Style Guide (HD Pixel Art)

### 12.1 Resolution and scale

- **World resolution:** 640x360 world pixels. All gameplay numbers (movement, hitboxes, rooms, tiles) are in world pixels.
- **Render density 2x (changed 2026-10-23):** the world renders at 1280x720, two render pixels per world pixel
  (`GameCamera.DETAIL`). Sean's reference for the hero is high-detail pixel art about 200 px tall; at one pixel per
  world pixel a 48 px hero loses the face and armor detail. Character sheets marked `"density": 2` are drawn at double
  detail in the same world size. Older 1x art still draws correctly (each pixel becomes 2x2) and moves to 2x over the
  polish passes: hero first, then enemies and bosses, then NPCs, tiles and decor. Done so far (2026-10-23): the
  hero, the Monodron, Hornet and Rot Dwarf (re-imported free from their clips), Rokusutahn, the Iron Dwarf and the
  zone tiles.
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

Balance after the hooded hero's set, Rokusutahn's parts and the Iron Dwarf: 101 credits, about 10 pro clips. The redesign (concepts, the new base and its
leg fix, a trial clip and the full set) cost 145 and came out of the NPC and reserve lines.

| Use | Clips | Credits | Share |
|-----|-------|---------|-------|
| Tests (turbo idle, turbo vs pro run), spent | 3 | 20 | 4% |
| Player, first design (retired), spent | 13 | 113 | 23% |
| Player redesign, spent: concepts, base and leg fix, trial idle + run, full set of 10 pro clips and 2 sword moves | 14 | 145 | 30% |
| Enemies in the game now (Monodron, Hornet, Rot Dwarf): HD pose + move + attack each | 6 | 69 | 14% |
| NPCs: only if credits are topped up (they stay code-drawn) | 0 | 0 | 0% |
| Bosses, Rokusutahn spent: three pro stills (head, plate, tail) | 3 | 9 | 2% |
| Bosses still to come: stills or key clips for their rigged parts | 3 | 31 | 6% |
| Tower enemies, Iron Dwarf spent: base, walk clip, a rejected slam clip, five poses | 2 | 38 | 8% |
| Reserve for later enemies, fixes and regeneration | | 65 | 13% |
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
HP masks, MP bar, flask icons, boss bar with phase ticks, gold counter, minimap, full map tiles and icons, pause menu, inventory grid, skill tree screen (node icons: 36), shop screen, dialogue box with portrait frame, title screen (BL key art + CODE logo), settings menus, controller glyphs (Xbox, PlayStation, Switch, keyboard), damage numbers (optional toggle). Font: a free pixel font with an open license (for example m5x7/m6x11 by Daniel Linssen, license checked at import) plus a custom title font made by CODE.

#### Item icons (CODE, APP touch-up)
All weapons, armor, shields, rings, keys, spells, consumables, shards, abilities: about 60 icons at 24x24.

#### Audio
- **Music (SEAN, curated by Claude):** title, Eolis (and festival variant), Guru/shrine, each zone (7 + 2 optional), mini-boss, boss (3 themes: early, mid, late), Evil One (3 phases), ending, credits. About 22 tracks. Each zone track gets a "restored" variant (filter/arrangement change) when its spring returns.
- **SFX (CODE synth + CC0 packs):** about 180 effects across movement, combat, UI, ambience, bosses.
- **Ambience:** one bed per zone (wind, drips, creaking wood, storm).

---

## 14. Technical Architecture (Godot)

- **Engine:** Godot 4.7.2 stable (pinned in CI and `tools/godot-version.txt`). GDScript with static typing.
- **Renderer:** Forward+ (2D lights, glow); verify Compatibility renderer as a fallback for low-end machines.
- **Physics:** custom kinematic controller on CharacterBody2D with hand-written movement (no built-in floor snapping surprises), fixed 60 Hz.
- **Structure:**
  - `autoload/` GameState, SaveSystem (JSON, 3 slots, autosave on rest), EventBus, AudioDirector, InputRouter (rebinding, buffering), RoomManager.
  - `scenes/player/`, `scenes/enemies/<family>/`, `scenes/bosses/<boss>/`, `scenes/rooms/<zone>/<room>.tscn`, `scenes/ui/`.
  - `data/` items, enemies, shops, skill tree, dialogue as `.tres` resources or JSON (so balance changes never touch code).
- **Level authoring for an AI team:** rooms are described in a text format (`levels/<zone>/<room>.room`: an ASCII tile grid plus a YAML header for doors, entities and camera). A runtime loader (`scripts/world/room_loader.gd`) builds TileMapLayer nodes and entities from them, so no generated scenes need to be kept in sync. Text levels diff cleanly in pull requests and are easy for agents to write and review. A world graph file (`levels/world.yaml`) lists room connections, which feeds the map screen and a reachability checker.
- **Reachability checker:** a tool that simulates the player's movement envelope (jump heights, dash distance) per ability set and proves every required item is reachable in order and that no soft-lock exists. It runs in CI.
- **Testing:** GUT unit tests for systems; scripted input replays for the movement controller with asserted metrics (jump height, dash distance, coyote window); headless boot of every room; screenshot capture per room under a virtual display (Xvfb) for visual review.
- **Performance budget:** 60 fps locked on a mid-2018 laptop GPU; under 1.5 GB RAM; rooms load in under 100 ms (preload neighbors).
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
