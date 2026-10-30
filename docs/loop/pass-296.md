# Pass 296: a set-back is a fresh start

Category: Movement feel (last pass 288).

## Audit

I checked the spike set-back (bible 6.13) as passes 292 to 295 left it.

**Where it lands you:**
- **Spots on slopes, one-way planks and ladder tops.** These are tiles of the room, so the gone-tile check reads them as footing. Pass 295's walk through five zones' rooms found no floor contact misread once ledge corners were fixed.
- **Door edges.** A safe spot is kept only while you stand on the floor. Standing in a door's zone takes you through the door, so a kept spot is never inside one. A room's entry spot is set by the World as you arrive.

**What carries across the set-back:**
- **Facing and momentum.** `teleport` zeroes velocity and leaves facing alone.
- **Ledge grace and the jump buffer.** Neither was cleared. In practice the hurt and its hitstop outlast the 0.12 s jump buffer, so a jump pressed on the way down did not fire. The test holds that.
- **The dash buffer.** **A dash pressed as you fell onto the spikes did fire.** The set-back refills your air dashes (`teleport` calls `_refresh_air_moves`), so the buffered dash went off on arrival. It carried you 64 px off the safe spot with no press of your own, often back toward the spikes.

## Fix

- New `Player.set_back()`: teleports you to the safe spot, then drops every buffered press (jump, dash, swing, throw) and the ledge's and the wall's grace.
- It is used by both hazard paths in `take_damage`, and by the World's rescue when you fall below a room.
- A plain `teleport` (doors, lifts, the mantra path) is unchanged, so a press made through a door still counts.

Test: `test_a_set_back_drops_the_presses_buffered_on_the_way_down` (`test_combat.gd`). The player drops onto spikes, pressing jump and then dash just before they bite. After the set-back the player must not rise or move for 30 frames, and must still face the same way. Without the fix, the dash case moves 63.7 px.

Bible 6.13: a paragraph after pass 295's.

No screenshot: the change is in timing, which the test checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: a set-back no longer fires a dash you pressed before it. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 297 takes Faithfulness (last pass 289).
