# Pass 285: gold stays in the room

Category: Systems (last pass 277).

## Audit

I read bible 9 to 11 against what passes 278 to 284 touched:
- **Fine as they are:**
  - The tell cues, guardian soaks, ladder rules and the tell test's driven tells change no system: skills, shops, ranks or saves.
  - The great loaf (pass 281) heals 40 and settles poison as bread does. It is a drop, not an item, so the inventory and the save never hold it.
  - The 5.3 rows for spikes and the cast cooldown (pass 282) match the skill tree. No node changes either: Light Step was dropped, and Thrift changes cost, not the wait.
- **The gap is in the economy (10.1).** Pass 283 kept every drop inside its room. Coins are a separate pickup (`Coin`) and were left out. A coin falls until something stops it. If you are more than the magnet's 100 px away, gold from a foe slain over a floor gap is lost, and that is just how you fight a Naga from its ladder with a Rune Dagger or a spell. I placed coins at every kill point along the Naga's swing and strike, as pass 283 did for loaves. **18 of 72 in the Tower Foot and 13 of 72 in the Mine Shaft fell out of the room.** Section 10.1's gold sheet counts a pass of foes at full value, so that gold was promised and never paid.

## Fix

- `Drop.keep_in_room(body)`: pass 283's room guard, now a static helper used by drops and coins alike.
  - A body past a side edge stops at it.
  - One that falls through a gap rests on the floor at the gap's nearer edge.
  - If there is no floor to rest on, it is freed.
- `Coin` calls it after it moves. A coin flying to you under the magnet moves straight to you and is not held.
- Test: `test_a_nagas_gold_lands_where_you_can_reach_it` (`test_rooms.gd`).
  - In both Naga rooms, 72 coins must each come to rest on a floor inside the room.
  - The hero waits out of magnet range and takes none of them.
  - Mutation check: without the coin's call, it fails, with 18 and 13 lost.
- Bible 10.1: a paragraph under the gold sheet.
- No screenshot: this changes where a coin rests, not how it is drawn, and the test checks the position.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the gold a foe drops can no longer fall out of the room. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 286 takes Audio (last pass 278).
