# Pass 251: the signs remember

World's last pass (243) was the oldest apart from Art, so pass 251 takes World.

| Check | Finding | Verdict |
| --- | --- | --- |
| Critical path, soft-locks, rest spacing, doors | `test_reachability.gd`, `test_no_room_is_far_from_a_rest` and the door pairing tests pass. | holds |
| Find counts, gated finds, hidden rooms | Held by passes 131, 219, 235 and 243. | holds |
| **Signs against world state** | I read all 142 signs. A sign had one text forever, so 16 of them went on describing a world that had changed. The Eolis fountain stayed "Dry for a season now" while it filled, and Amber Falls still said "When the spring runs again". The Spring of Trunk still said "Clear the spout" once it was clear. The Scorched Hall and the Victim Causeway still promised boardwalks that had already risen. Rokusutahn, Zoradohna, Borabohra, the Drowned Warden, King Grieve, the Bloom and the Clockwork Alpha were each still "waiting", "drilling" or "nested" after they were beaten. The Spire Foot's gate stayed "cold" once it stood open. People already change with flags (the townsfolk and the keepers), but tablets never did. | **fixed** |

## As built

- `LoreTablet.variants`, `add_variant` and `current_text`. A sign line may open with bracketed world flags, the same as a person's fourth field (`Room.flags_hold`). Lines on one cell make one tablet. When it is read, it shows the first line whose flags hold, and a plain line always holds. It picks the line at read time, so a spring cleared in its own room changes the sign at once.
- 16 rooms gain a line for afterwards (bible 11, "The signs remember"). The fountain has three states: dry, partly fed and full. The Springs of Mist and Sky each read one way before their boss falls, another once it is beaten, and a third once the spring is clear.
- Tests:
  - `test_a_tablet_reads_what_the_world_has_become` (`test_rooms.gd`): three lines on one cell make one tablet, and it reads Before, After and Both as the flags are set, without the player leaving the room.
  - `test_every_world_change_rewrites_its_sign`: every bracketed flag names a real boss, spring or room of conduits, every cell ends on a plain line, and each of the 15 foretold changes has its line.
- Mutation check: with the flags ignored (`if true:`), the first test fails.
- The legend in `levels/README.md`, and bible 11.
- No screenshot, because a tablet looks the same and only its words change.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the signs now keep up with the springs and the bosses. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 252 takes Bosses (last pass 244, now the oldest).
