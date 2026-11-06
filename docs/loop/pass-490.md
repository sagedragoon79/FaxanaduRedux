# Pass 490: The spell guardians at the slowest speed

## Category

Bosses.

## Audit

Leads: the guardians whose fights need a spell (the Haar Wyrm's tanks filled with Deluge, Skyrend's roost
conduits woken with Tempest Lance) won with the real Spell button at 70% Game speed; a guardian's death
blow (`Feel.boss_kill`) at 70%, the game returning to 70% afterwards.

- The tanks and conduits were filled and woken by the real button only at full speed, or with a scripted
  `spell_pressed`, or by calling `douse` and `power` directly.
- `Feel.boss_kill` was tested only at full speed and only by reading its ramp (`_ramped_scale`), never by
  watching `Engine.time_scale` in real time with hit-stop on.

## Bug found

None. A proof. The first draft of the test cast again 20 frames after a tank filled and nothing came out:
that is the cast's 0.35 s cooldown (0.5 s at 70%), and a press inside it casting nothing is the bible's
own rule (5.3, pass 442), not a bug.

## Fix

`test_the_spell_guardians_fall_to_the_buttons_at_the_slowest_game_speed` (test_boss) plays both fights at
70%. The real Spell button fills each of the Haar Wyrm's three tanks with Deluge in phase 2, and the
fourth head comes out; it wakes each of the roost's three conduits with Tempest Lance, and Skyrend comes
down. Each death blow, with hit-stop on and timed in real time (pass 488), freezes the game, slows it to
0.3 of 70%, never runs it faster than 70%, and leaves it at 70%. Bible 8 gains "The spell guardians at the
slowest speed (pass 490)".

Mutation check: with the kill's slow motion easing back to full speed instead of the Game speed
(`Feel._ramped_scale`), the test fails (2 checks, 1.00 seen).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Score unchanged. The spell guardians and the death blow are proved at 70%. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 491: Systems.
