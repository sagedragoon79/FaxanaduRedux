# Pass 242: the guard breaks

Combat's last pass (234) was the oldest apart from Art, so pass 242 takes Combat.

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs | Every wind-up in the game is held at or above `Enemy.MIN_TELEGRAPH` (pass 234). | holds |
| Starting values | `test_the_starting_combat_values_match_bible_5_3` passes. | holds |
| Parry, Riposte, Rune Dagger, spells | Each has its own tests (5.2, 5.3, 9). | holds |
| Enemy variety | Every zone has its families, and Zenis remixes them (pass 161). | holds |
| **Guard with too little MP** | `receive_attack` guards only when `mp >= guard_mp_cost` (8). With less, it fell through to a plain hit in silence. The shield stayed up in the guard pose at 40% walk speed, the blow landed whole with only the hurt yelp, and nothing said the guard had failed. A player holding Block in a long fight (their MP drained by guarding) could not tell a guard from a wasted one. | **fixed** |

## As built

- `tools/audio/sfxgen.py`: new `guard_break`, a dry crack of splitting wood over a falling knock with splinters after it (0.28 s, peak -4.4 dB, rms -17.5 dB, next to `guard`'s -13.6). The wav files the generator rewrote were restored; only the new file was kept.
- `Player.receive_attack`: a frontal blow on a guard that can't be paid for breaks it. The guard break sound plays, guard dust bursts, the screen shakes, and the blow lands whole. `Player.guard_broken` keeps the shield down until Block is let go (in `_update_block`).
- `test_a_guard_with_no_mp_breaks_and_drops` (`test_combat.gd`, new). Against a Rot Dwarf's swing with 7 MP, the blow lands whole and `guard_break` plays instead of `guard`. The shield drops and stays down while Block is held, then comes back once Block is let go and pressed again.
- Mutation check: with the break disabled, the test fails three checks (no break sound, the shield stays up).
- Bible 5.3 (a Guard break bullet and the Guard row).
- No lasting visual change (a one-frame dust burst), so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: a failed guard now reads as one. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 243 takes World (last pass 235, now the oldest).
