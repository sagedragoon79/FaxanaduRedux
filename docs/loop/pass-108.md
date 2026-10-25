# Pass 108: the Drowned Dwarf

Combat (95) was tied for lowest with Stability, apart from Art. Stability already has fuzzed-input soaks for every zone, so this pass took Combat.

Bible 7 asks for 4 to 5 enemy families per zone, and it still listed foes that were never built. The Mist was the thinnest zone, with only the Lantern Ghost and the Bog Myconid. This pass builds the Drowned Dwarf, which the bible lists for the Mist as "rises from water".

## The Drowned Dwarf

The Mist has no deep water. Its "water" is the drowned marsh floor, so the dwarf rises out of the mire instead. He is one of the Victim miners the marsh took, risen with the anchor he was drowned on.

| State | What happens |
| --- | --- |
| Sunk | Only his helm's crest, a ring of mud and a trickle of bubbles show. He can't be hit and does no harm: his collision layer is off. |
| Rise | You come within about five tiles, level with him: he hauls himself out over 0.7 s with a splash. Half out of the mud, he takes half again the damage. |
| Walk | He shambles after you at 26 px/s, stopping at walls and ledges. Contact deals 10. |
| Heave (the telegraph) | You are close in front: he heaves the anchor overhead for 0.6 s, with a white pulse and the low `tell_heavy` groan. |
| Slam | He brings it down in front of him for 18 (a 38x30 box). It can be parried, which staggers him. |
| Mired | The anchor buries itself in the mud with a splat, some dust and a little shake. For 0.8 s every blow lands at half again. |
| Sink | Out of sight for 3 s (more than 10 tiles off, or off his level), he sinks back into the mire to wait. |

His stats: 46 HP, 7 to 11 gold, 18 XP, knockback 30. He is waterlogged and barely moves when hit.

What he adds to the Mist:
- **An ambush you can read.** He lies in wait on the floors you walk through the fog, but the crest and bubbles give him away.
- **Two punish windows.** Strike him as he climbs out, or once the anchor is buried.
- **A parry.** The slam can be parried.

The Myconid is a zoning foe and the Ghost a hunter; the dwarf is a heavy melee brute, which the Mist didn't have.

**Placement** (legend `p`): five Mist rooms, each on a solid floor away from the room's other foes:
- Marsh Road
- Victim Causeway
- Drowned Stair (the bottom floor)
- Veiled Rise
- Feather Hollow

Reachability still passes. I first put one in Fog Cut, but the screenshot showed him next to a Bog Myconid, whose spore cloud hid his whole heave, so I moved him to Feather Hollow.

**Sheet**: `drowned_dwarf`, drawn in code by `castgen.py` at 2x (no Autosprite). It has 8 animations:
- sunk, rise, sink, walk, heave, slam, mired, stagger;
- a `depth` sinks the body below the ground line and clips it there, with a ring of churned mud;
- rotted mail and a rusted pauldron, skin gone blue-white, a weed-matted beard, pale eyes, and a big rusted anchor.

Screenshots are in `/mnt/project-files/pass-108/`:
- `sunk.png`: the crest and bubbles in the fog;
- `rise.png`: climbing out;
- `heave.png`: the anchor overhead, flashing white.

## Tests

`test_enemies.gd`:
- `test_drowned_dwarf_lies_sunk_then_rises_when_you_come_near`:
  - sunk, he can't be hit and does no harm;
  - he rises over 0.7 s, during which a 10 hit deals 15;
  - risen, he is hittable and hurts to touch, and he shambles toward you.
- `test_drowned_dwarf_heaves_then_slams_and_the_slam_can_be_parried`:
  - the heave lasts at least `Enemy.MIN_TELEGRAPH` and flashes;
  - the slam catches a player standing still;
  - mired, he takes 15 from a 10 hit;
  - a parried slam does no damage and staggers him.
- `test_drowned_dwarf_sinks_back_once_he_loses_you`: only after 3 s, and he is out of reach again.
- The attack-sound scan covers him: the heave, slam, rise and mire all play sounds. `sunk` joins the scan's calm states.

Full suite: 2076 checks, all passing.

## Bible

Bible 7:
- The Mist row describes the Drowned Dwarf as built.
- A new row sorts the foes that are still unbuilt:
  - **planned**, in order: Bark Knight, Seed Bomber, Marsh Hag, Spire Sentinel;
  - **cut**: the Mist Wisp (the Lantern Ghost is the Mist's wisp), the Wind Imp (the Storm Harpy holds Daybreak's air) and the Sky Ray (the wind currents make the open sky the challenge there).

The legend in `levels/README.md` gains `p`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 95.5 | Unchanged. |
| Combat and enemies | 15 | 95.5 | A new Mist family with a distinct role (ambush brute), a parryable slam and two punish windows; the bible's roster is now sorted into built, planned and cut. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.45 (up from 94.375).

## Next

Stability (95) is now the lowest apart from Art. Pass 109 takes it:
- a save-file robustness pass: a corrupt, truncated or older-version save must load safely or fall back to a fresh game, never crash;
- the settings file gets the same treatment;
- each case gets a test.
