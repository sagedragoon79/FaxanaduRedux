# Pass 355: the builder's notes, made true (World)

Category: World (last pass 347).

## Audit

`levels/README.md` is what a pass reads before it builds a room (CLAUDE.md sends every new room to it): the legend, doors, map placement and the layout rules of thumb. The bible's world rules are held by tests (sizes since pass 331, reachability, doors, secrets since 349), but the README's own claims were not.

- **Room sizes had drifted.** The README said "Rooms are whole screens". Pass 331 corrected the bible: fourteen rooms are a screen and a half wide (60 tiles) and the Heart Gate is 56. A builder who trusted the README would think those rooms were wrong.
- **The safe jumps had never been made.** "A standing jump clears 4 tiles up with 2 across, 3 up with 4 across, or 2 up with 5 across. Leave 3 clear tiles of headroom." Every layout pass leans on these, and no test had jumped them. A change to the movement could leave the README promising jumps the hero can't make, and new rooms built on them would only be caught by the reach checker, whose jumps are shorter still.

## Fix

- README "Rooms and doors": rooms are 1x1 to 4x3 screens, most whole, some a screen and a half (60) and the Heart Gate 56, as bible 3.3 says. It also names the test that holds the bounds.
- README "Safe numbers": names the new test.
- Bible 3.3: "The builder's notes (pass 355)".
- `test_the_readmes_safe_jumps_are_real` (test_movement.gd):
  - reads the three jumps and the headroom from the README text;
  - checks that the 4-rows platform rule is one of them;
  - for each jump, builds a ledge `up` rows high whose near edge is `across` tiles from where you stand, with a ceiling over it at the README's 3 tiles of headroom;
  - jumps from a standstill with the real controller and checks you land on the ledge.

Mutation: with the README changed to "5 tiles up with 2 across" and "2 up with 8 across", the real jumps fall back to the floor and the test fails on both. No room changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score. The room builder's notes are true and held. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 356 takes Bosses (last pass 348).
