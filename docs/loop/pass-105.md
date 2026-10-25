# Pass 105: combat against bible 5.3

Combat (94.25) was the lowest category apart from Art. This pass checks bible 5.3 line by line in scripted fights, fixes what was off, and pins it with tests.

## Audit

| Item | Bible | Found | Result |
| --- | --- | --- | --- |
| Ground and air combo, damage, windows, cooldowns, buffer | 3 / 2 hits, 8 / 14, 0.40 s, 0.20 / 0.20 / 0.38 s, 0.15 s | matches | OK (existing tests) |
| Slash recoil | each hit pushes you back 4 px | 2.3 px: `slash_recoil` 90 px/s against 2,600 px/s² of ground deceleration | **Fixed**: 120 px/s gives about 4 px. New test. |
| Up-slash | a hit pops the player up slightly | not built: only Rising Cut's launch of the foe existed | **Built**: see below. |
| Parry window | 0.12 s from the press, 140 ms hit-stop, 1 s stagger, +6 MP | matches | OK. A new test covers both edges: 0.083 s parries, 0.167 s doesn't. It also checks the stagger at 0.9 s and 1.1 s, the MP and the hit-stop. |
| Guard | 50%, 8 MP, 40% speed | matches | OK (existing test) |
| Being hit | 0.8 s i-frames, 0.15 s hit-stop, 160 / 220 px/s knockback, 0.18 s lock | matches | OK. New test. |
| Heavy finisher on foes | (not specified) | 1.8x knockback, but the same 0.18 s hitstun as a light hit | **Changed**: it now holds a foe 1.8x as long (0.32 s). |

## Finisher reactions by enemy

Each foe's own `knockback` decides how far a hit drives it. The heavy finisher multiplies that by 1.8, and the hitstun by 1.8 too:
- **Light foes are thrown back:** Hornet 180, Gear Bat 160, Lantern Ghost, Storm Harpy and Spring Eel 120.
- **Mid-weight foes stagger a step:** Rot Dwarf, Mantis and Hound 60, Shade Knight and Beetle 40.
- **Heavy foes barely move:** Crystal Dwarf 30, Iron Dwarf 25, Meteor Slug 20, Minecart 10.
- **Rooted foes don't move at all:** Bog Myconid, Grub Lump, Sap Spitter and Meteor Seed are 0. They still lose 0.32 s of thinking.

The spread suits each enemy, so it stays. The longer hitstun is the change: the finisher now buys a beat to step back or reposition. It doesn't reset a wind-up, because `state_time` keeps running through hitstun, so a foe that was about to strike still strikes. This is intended: the combo is a reward, not a stun-lock.

## The up-slash pop

In midair, an up-slash that lands on a foe turns a fall into a 150 px/s rise (`CombatTuning.up_slash_pop`), about 7 px:
- It happens once per swing.
- It never adds to a rising jump.
- It doesn't trigger off breakable blocks.

The bible said "launcher-type enemy". It applies to every foe so the rule is easy to learn. Juggling a flier from below now slows your fall, but it can't climb: the 0.2 s swing cooldown lets gravity win each cycle.

No screenshot this pass: the changes are motion and timing (a few pixels of recoil, a 7 px pop, a longer reel), and a still image doesn't show them.

## Tests

`test_combat.gd`:
- `test_a_slash_that_lands_pushes_you_back_a_few_pixels`: 3 to 6 px.
- `test_the_parry_window_is_0_12_s_and_pays_6_mp`
- `test_being_hit_matches_the_bible`
- `test_the_heavy_finisher_drives_a_foe_back_and_holds_it_longer`
- `test_a_midair_up_slash_that_lands_holds_you_up`

Full suite: 1994 checks, all passing.

## Bible

Section 5.3: the slash line now gives the recoil and hitstun numbers, and the up-slash line describes the pop as built.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94.75 | Unchanged. |
| Combat and enemies | 15 | 95 | Every line of 5.3 is verified and tested. The missing up-slash pop is built, the recoil reads, and the finisher has a distinct reaction. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 94.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.125 (up from 94.01; 94.0125 + 0.1125).

## Next

Movement (94.75) and Systems (94.75) are now tied for lowest apart from Art. Pass 106 takes Systems: build one of the unbuilt systems from bible 9 and 10. The completion screen (map %, secrets, time, deaths) comes first, because the ending already exists to hang it on.
