# Pass 447: the off hand changes while the dagger flies

## Category

Stability and performance.

## Audit

Sean's off-hand rule says the off hand holds a shield or the Rune Dagger. Only scripts had ever made that swap, and never with a dagger already thrown. A player can throw, open the pause menu before the dagger lands, and strap a shield on. This pass checked whether that leaves a stray or doubled dagger, keeps the dagger from coming home, or lets Throw get past the shield.

## Bug found

None.
- The dagger in the air is its own node. It finishes its flight and comes home.
- `dagger_ready` waits for it.
- `_try_throw` checks the off hand on every press, so Throw does nothing while the shield is on the arm.

Two other leads were already covered:
- A swing turned by two guards at once is heard once, because `Sfx.play` drops a second start of the same sound in one physics frame.
- A dash through a door goes on only for the time it had left (pass 443), so it cannot stack.

## Fix

- `test_the_off_hand_changes_while_the_dagger_flies` (test_systems) plays the whole game through the real controller:
  - it throws the dagger, opens the Equipment page by the buttons and straps on the Small Shield while the dagger is still in the air;
  - the dagger finishes its flight alone and comes home;
  - Throw then does nothing, and Block guards;
  - the dagger goes back in the off hand from the page and throws again.
- Bible 5.2 (the off hand) gains "Changed while the dagger flies (pass 447)".
- Mutation: removing the off-hand check from `_try_throw` fails the "Throw does nothing" check. The check after it, "Throw lets it fly again", fails too, because the stray throw from that failure is still in the air.

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
| Stability and performance | 5 | 99 | Score unchanged. The off-hand swap mid-throw is proved through the real controller. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 448: Movement.
