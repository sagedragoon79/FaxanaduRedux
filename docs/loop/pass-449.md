# Pass 449: raised at the Guru, by the buttons

## Category

Faithfulness (last audited in pass 441).

## Audit

The original starts you again at the last Guru's House you visited (bible 5.4). Ours restarts you
where you last rested, and a Guru's "Rest and save" is one of those places, but the death tests set it
up by calls: `test_death_respawns_at_last_shrine_and_purse_persists` used `use_door` and
`take_damage(9999)`, and the Guru test (`test_the_king_and_the_guru_answer_the_real_controller`)
stopped at the rest. Nothing walked the whole loop with the buttons: rest with a Guru, die to a real
hazard, rise at his side and walk back to the purse.

## Bug found

None.

## Fix

`test_a_death_raises_you_at_the_guru_you_rested_with` (tests/test_economy.gd): in a town with the
room's start three tiles from the Guru, the real Up and Jump rest and save at the Guru; the real Right
walks the hero, at one heart, into floor spikes. He falls with 60 of his 100 gold in a purse on the
safe ground short of the spikes, rises at the Guru's side (not the room's start), made whole, and the
real Right walks him back to take the 60 again without touching the spikes. Bible 5.4 gains "Raised at
the Guru, by the buttons (pass 449)".

Mutation check: respawning at the room's start instead of the saved spot fails the test ("at the
Guru's side (56, Guru 136)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Score unchanged. The Guru's restart is proved with the buttons. |

Weighted: 96.8625.

## Next

Pass 450: Combat.
