# Pass 488: A blow at every game speed

## Category

Combat.

## Audit

Leads: a parry or block pressed inside hitstop with the real controller, the hurt knockback at every game
speed, and Undertow and Forked Storm cast for real.

- Undertow (`test_torrent_pierce_strikes_every_foe_in_line`) and Forked Storm
  (`test_chain_thunder_leaps_to_two_more_foes`) are cast through the player's own spell path; the Spell
  button itself answers on its frame for every spell (pass 386), and pass 486 proved presses inside a
  freeze are read, so a block or parry pressed in hitstop is read the same way.
- The hurt knockback had only been measured at full speed, and always with hitstop off (the runner
  turns it off), so never through the 0.15 s freeze that every blow starts.

## Bug found

None. A proof.

## Fix

`test_a_blow_throws_you_as_far_at_every_game_speed` (test_combat) turns hitstop on and takes a blow at
100, 85 and 70% Game speed: the game freezes, then the hero lands 39.6, 40.3 and 41.3 px back after
rising 20.0, 20.3 and 20.5 px, within a step of each other. Bible 5.3 gains "A blow at every game speed
(pass 488)".

Mutation check: with the knockback scaled by the Game speed (`Player.take_damage`), the test fails at
70% (32 px back, 14 up).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The knockback is proved through its freeze at every speed. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 489: World.
