# Pass 459: the King's gold to the Jack door, by the buttons

## Category

World (last audited in pass 451).

## Audit

The scheduled leads were mostly proved already. A card door was walked into with the real Right
(pass 417), a shop was bought from with the real buttons (pass 413), an inner door was entered with the
real Jump and Attack (test_rooms), and ladders and drops were climbed through the real controller
(test_movement). The King's purse had been taken with the real Up on its own (pass 409; corrected in pass 460, which first said only a scripted Up had). The original's opening was never
played as a new player meets it, one step after another: the King's gold, then the Merchant's Jack
Key, then the Jack door. That run crosses a dialog, a shop menu and a door, each of which takes and
gives back the controls.

## Bug found

None.

## Fix

`test_the_kings_gold_buys_the_key_that_opens_the_door` (tests/test_economy.gd) starts a new game in a
town with the King, the Eolis Merchant and a Jack door, and uses only real input:
- Up at the King gives his 1,500 gold with a clink and opens his words. Jump turns his pages and puts
  them away.
- Held Right walks to the Merchant, and Up opens his shop. Down finds the Jack Key, Jump buys it for
  150 of the King's gold, and Dash leaves.
- Held Right into the Jack door turns the key with no rattle and walks through, and the key is spent.

Bible 4.5 gains "The King's gold to the Jack door, by the buttons (pass 459)".

Mutation check: a shop that takes the gold but gives no key fails 4 checks (the door rattles and stays
shut).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The opening's gold, key and door are proved with the buttons. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 460: Bosses.
