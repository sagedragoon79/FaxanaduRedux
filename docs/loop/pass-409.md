# Pass 409: the King and the Guru, by the buttons

## Category

Faithfulness (last pass 401).

## Audit

- Tests cover the original's signature beats. Most are played through the game:
  - the King's purse;
  - the Guru's titles and mantra;
  - the key-and-door economy;
  - the Wingboots timer;
  - the Hour Glass;
  - the meteor and the springs;
  - the Evil One's last rooms.
- Every faithfulness promise in bible 1, 2 and 11 names a test.
- The gap is the two first meetings a player of the original makes. Tests met the King by setting a scripted `up_pressed`, and passes 401 and 406 rested with the Guru by calling `guru.rest` directly. Nothing had ever pressed Up at the Guru and chosen "Rest and save" from his menu with Jump. If his menu wired "Rest and save" to the wrong row, every Guru test would still pass, and the one place the original's password survives would be lost in play.

## Fix

`test_the_king_and_the_guru_answer_the_real_controller` (test_economy.gd) plays both meetings with `Input` alone:

- Up at the King takes his 1,500 gold, and Up again gives no more.
- Up at the Guru opens his menu and pauses the game.
- Jump on "Rest and save" closes the menu. It rests, saves to test slot 9 with the chime, and recites "Rested. Your mantra is: " with the journey's mantra.

Bible 11's Easter eggs line gains "By the buttons (pass 409)".

Mutation check: when the Guru's menu does not rest on its first row, the new test fails, and every other Guru test (151 checks) still passes.

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
| Faithfulness | 5 | 99 | Score unchanged. The King's purse and the Guru's rest and mantra answer the real controller. |

Weighted: 96.8625.

## Next

Pass 410: Combat.
