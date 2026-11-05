# Pass 464: Bloodletting, by the buttons

## Category

Combat (last audited in pass 458).

## Audit

This is the first Combat pass under the Yldenfall names. A scan of every test that drives `Input`
found the Thrust (pass 450), the pogo and the Delver's Pick down-strike (the Foreman's rock and
movement tests), and Fourth Strike, Rising Cut and Riposte (pass 458) proved with the real buttons.
Bloodletting, the last Blade skill before the Thrust, was not. Its test cut a foe staggered by a call
(`dwarf.stagger()`) with a scripted Attack. A player makes the opening with a parry, and the parry's
knock-back and the Riposte's shove both push the foe out of reach, so it was unproven that a player
can cash it in.

## Bug found

None. While writing the test, the cuts first missed: the parry and the Riposte had pushed the dwarf
beyond a blade's reach. That is the game working as designed. The hero has to step in, and the test now
does that with the real Right.

## Fix

`test_bloodletting_answers_the_real_controller` (tests/test_economy.gd) learns the whole Blade branch
up to Bloodletting and fights a Rot Dwarf with real input only:
- A real Block parries his blade, and he reels open (`punishable`).
- Real Right closes in, and two real Attack taps while he reels each heal 2 HP with the `bloodlet`
  sound.
- Once he is back on his feet, the same tap still cuts but heals nothing.

A helper, `_close_in_for_real`, walks the hero to a foe with the real Right. Bible 9 gains
"Bloodletting, by the buttons (pass 464)".

Mutation check:
- Bloodletting that heals on any hit fails 1 check (it healed a foe on his feet).
- Bloodletting that never heals fails 2 checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. Bloodletting is proved with the buttons. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 465: World.
