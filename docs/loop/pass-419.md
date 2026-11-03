# Pass 419: the lift by the buttons

## Category

World and level design (last pass 411).

## Audit

Doors between rooms answer the real controller (411), and so do drops, ladders and the Mantra trials' wind and climbs (408 and earlier). The trunk's lift, bible 3's elevator shortcut home, was only ever run by the test calling the cage's `interact` and the menu's `confirm`: no test pressed Up in a cage or picked a stop with the buttons. The rooms still pass the reachability rules (`test_reachability.gd` is green).

## Fix

- `test_the_lift_answers_the_real_controller` (test_economy.gd), in the East Gate of Eolis:
  - Up in the cage while Zoradohna holds Forepaw: the cage hangs still and no menu opens.
  - Once she falls, Up opens "Forepaw Lift" and pauses the game, on Forepaw first.
  - Down moves to the Tower Foot, and Jump rides there onto open floor, the menu closed and the game running.
- Bible 4.4's Zoradohna row gains "The lift by the buttons (pass 419)".

Mutation: riding the first stop whatever row is chosen fails the new test (it arrives at Forepaw) and the scripted trunk test's last step.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The lift answers the real controller. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 420: Bosses.
