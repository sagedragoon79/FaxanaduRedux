# Pass 386: every combat button answers on its frame (Combat)

Category: Combat and enemies (last pass 378).

## Audit

Passes 379 to 385 changed no combat number or code. Bible 5.3's table is still held row by row, and every foe's wind-up still clears `Enemy.MIN_TELEGRAPH`. Pass 384 found that every move test scripted the player's intent, and timed the moves through the real controller. The fight's own buttons were left out of that: Block, Spell, Next Spell, Red Potion, the Hour Glass, Throw, and the Thrust's held Attack. All of them were still only ever scripted. A poll that read any of them a step late, or a Thrust that waited on a release it had already seen, would have passed every test. 6.7's promise ("every action responds on the same frame it is pressed") covers them too.

## Fix

- No game code changed: the probe found every button already answers on time.
- The real-controller helpers from pass 384 move from test_movement into `TestSuite` (`press_for_real`, `release_for_real`), so every suite can use them.
- `test_every_combat_button_answers_on_its_frame` (test_combat) presses each button through `Input` and checks that it answers in the first physics step that sees it:
  - Block raises the guard and opens the 0.12 s parry window;
  - Spell spends the Deluge's MP and puts its bolt out;
  - Next Spell turns from Deluge to Thunder;
  - Red Potion starts the drink;
  - the Hour Glass stops time;
  - Throw lets the Rune Dagger fly.
- The Thrust is a release, not a press. Attack is held through the real controller past its 0.4 s charge, and nothing lunges until it is let go. The lunge then comes in the very step the button comes up, because a held button is read as held or not, rather than as just pressed.
- Bible 5.3 gains a note that names the test and gives the Thrust's timing.

Mutation check: a `PlayerInput.poll` that hands every press and the held Attack over one step late fails all 7 buttons.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. Every combat button is timed through the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 387: World.
