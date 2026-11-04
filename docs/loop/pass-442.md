# Pass 442: a spell turned by a shield no longer shoves the caster

## Category

Combat and enemies.

## Audit

Pass 386 found the Spell button answered on its frame, but no spell cast through `Input` had been seen to meet a foe. Next Spell had never been followed by a cast, and casting's rules (not while guarding, and a press inside the 0.35 s cooldown casts nothing and is not saved) were only scripted. This pass casts the Deluge for real at a Rot Dwarf across the room.

## Bug found

The bolt met the dwarf's shield, and the shield's push shoved the caster back from 168 px away. `Enemy._on_blocked` set the hero's velocity to 200 px/s away from any turned blow, so this applied to every spell, thrown Rune Dagger and Thunder chain turned by a shield. For a turned slash, the hero's own 120 px/s recoil overwrote the push straight after, so the push was never felt on the one blow it was meant for. On a turned up-slash or down-strike it set the hero's horizontal speed to zero.

## Fix

- The player marks the blade's own blow while it is dealt. A guard that turns it calls `Player.blade_turned`, and the swing then pushes back at `CombatTuning.turned_blade_push` (200 px/s) in place of `slash_recoil`.
- Spells, thrown blades and vertical blows push nothing.
- Bible 5.3 says so: the Slash line, and "Spells by the buttons (pass 442)".
- `test_spells_answer_the_real_controller_at_a_real_foe` checks, all through the real controller:
  - the bolt meets the shield with its thud and the hero stays put;
  - cast as the dwarf raises his axe, the bolt strikes for 12;
  - Next Spell then Spell casts Thunder;
  - a press inside the cooldown casts nothing, then or after;
  - Spell with Block held casts nothing, and once Block is let go the next press casts;
  - a slash the shield turns pushes the hero back at 200 px/s.
- Mutation: restoring the old push fails two checks, the caster moving 6.1 px and the turned slash pushed only at 120 px/s. Letting a cast through the guard fails the guard check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. A turned spell no longer shoves the caster, and a turned blade now clangs back. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 443: World.
