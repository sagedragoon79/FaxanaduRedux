# Pass 110: the Bark Knight

Combat (95.5) and Movement (95.5) were tied for lowest apart from Art. Pass 107 had just pinned every movement number, so this pass took Combat and built the next planned foe from bible 7. The Branches had only the Leaf Mantis of their own, which made them the thinnest zone.

## The Bark Knight

He is a knight the World Tree grew for itself, armored in living bark, carrying a lance of green bough. He had to play differently from the zone's other knights and dwarves:
- The Rot Dwarf rushes you.
- The Shade Knight blocks in front.
- The Leaf Mantis ambushes and lunges.

The Bark Knight holds a line at long reach, and his armor wears down.

| State | What happens |
| --- | --- |
| Walk | He paces the branch roads at 22 px/s, turning at walls and bough ends. Contact deals 10. |
| Brace (the telegraph) | When you are level with him and within about five tiles in front, he draws the lance back and his eyes light, for 0.6 s. He pulses white and plays the `tell_charge` sound. |
| Thrust | The lance drives out to its full reach, from 10 to 72 px in front of him, for 16 with a whoosh. That is about four tiles, well past any other melee foe. The thrust can be parried, which staggers him. |
| Rooted | His feet sink into the branch for 1.1 s and the lance stays out, stiff as a bough. It becomes a one-way ledge in the "pogo" group, so you can stand on it or pogo off it to get over him. |
| Uproot | He pulls free, one bark plate grows back, and he walks again with a 0.8 s pause before he can brace again. |

**The bark guard.** He wears three plates of bark.
- Each blow on the bark deals a quarter of its damage, rounded up, knocks off one plate, and throws debris with a `crumble` sound.
- With all three plates gone he is bare, pale heartwood (the sheet's `bare_` animations) and takes full damage.
- While he is rooted the bark doesn't guard him at all. But a plate grows back each time he uproots.

That gives two ways to fight him:
- Strip him fast: three quick blows, then he's open.
- Wait out the thrust: parry it or step back, then punish him while he is rooted.

Chip him slowly and he grows the bark back.

His stats: 54 HP, 8 to 12 gold, 20 XP, knockback 40.

**Placement** (legend `!`, the last free symbol used for foes):
- Sunlit Bough, on the lower floor past the pillar.
- Thicket Road, on the floor between the trunk and the spike pit.
- Canopy Bridge, on the bridge over the thorn pit. Here his rooted lance is a ledge over the pit.

Reachability still passes.

**Sheet**: `bark_knight`, drawn in code by `castgen.py` at 2x (no Autosprite). It has walk, brace, thrust, rooted and stagger animations, each in a barked version and a `bare_` heartwood version. The design:
- dark bark plates with moss on the shoulders;
- a crown of leaves;
- amber eyes that light during the brace;
- a budding bough lance with a pale thorn tip;
- roots spread from his feet while rooted.

The first draft clipped the lance's thorn at the frame edge, so the canvas is now 112 px wide. The first heartwood was so pale it read as skin, so it is now a step darker.

Screenshots are in `/mnt/project-files/pass-110/`, all on Canopy Bridge:
- `brace.png`: lit, lance drawn back;
- `thrust.png`: the lance out across the bridge, catching the player;
- `rooted.png`: roots out, the lance held as a ledge.

## Tests

All in `test_enemies.gd`:
- `test_bark_knight_braces_then_thrusts_his_lance_and_the_thrust_can_be_parried`:
  - the brace lasts at least `Enemy.MIN_TELEGRAPH` and flashes;
  - the thrust catches a player 3.5 tiles away;
  - a parried thrust does no damage and staggers him.
- `test_bark_knight_bark_guards_until_stripped_and_regrows_as_he_uproots`:
  - a 10 hit on bark deals 3 and takes a plate;
  - three blows strip him, and then a 10 hit deals 10;
  - rooted, a 10 hit deals 10 and takes no plate;
  - a plate grows back as he pulls free.
- `test_bark_knight_rooted_lance_is_a_ledge`:
  - the lance is no ledge while he walks;
  - rooted, the player lands and stands on it;
  - it goes when he uproots, and the player drops to the floor.
- The attack-sound scan covers him: the brace, thrust and rooting each play a sound.

## Bible

Bible 7:
- The Branches row describes the Bark Knight as built.
- The "Not yet built" row now plans, in order: Seed Bomber, Marsh Hag, Spire Sentinel.

The legend in `levels/README.md` gains `!`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 95.5 | Unchanged. |
| Combat and enemies | 15 | 96 | A second Branches family with its own role: a long-reach line holder with armor you strip, a parryable thrust, a punish window, and a lance that becomes terrain. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2133 checks, all passing.

Weighted score: 94.6 (up from 94.525).

## Next

Movement (95.5) is now the lowest category apart from Art, so pass 111 takes it.
