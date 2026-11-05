# Pass 479: Thane Vorrund weeps

## Category

Story and world.

## Audit

Lead: each turn of bible 2 shown in the game. The Story and world row of the rubric (15.3) names them:
the Reeve's doubt, the Ringreader's reading of the glass leaf, the miner's confession in Amberlee,
Carillon's record of the Withering, Vorrund's surrender of Severance and the Leaffall ending. Only the
glass leaf had a test (pass 463). The audit read each one where the game speaks it:

- Reeve Aldous, in his hall: "a stranger is one more mouth." Shown.
- Dwarf Orrin, in Amberlee: "We did. The Hollin. Our Thane gave the word." Shown.
- Mayor Halloran, in Carillon: the oldest bell names "the year of the Withering" and "Thane Vorrund,
  who planted the flower." Shown.
- The ending's farewell names the Leaffall festival. Shown.
- Thane Vorrund: bible 2 has him beaten, weeping at last as he gives up Severance. **Not shown.**

## Bug found

The game showed the giving but not the weeping. His banner said "His grafting blade, the one edge that
can part the bloom from the tree. With it, the Frost Seed.", and the Kennels' sign to his throne said
after the fight "The king waits for no one now." Only Kettleforge's elder said he wept, at second hand,
after the end. The one turn of Act III that is his own did not happen on screen.

## Fix

- The banner: "Thane Vorrund weeps at last, and gives up his grafting blade. With it, the Frost Seed."
  (450 px at size 10, inside the 640 px screen like every other banner).
- The Kennels' sign after him: "The king wept there at last, for his queen."
- `test_every_turn_of_the_story_is_told_in_the_game` (test_world) holds each turn to the words the game
  speaks and to the room the person stands in. `test_thane_vorrund_defeat_gives_the_frost_seed_and_the_severance`
  now checks the banner says he weeps when he really falls.
- Bible 8.7 (the grafting blade) gains "He weeps (pass 479)".

Mutation check: with the old banner text, the new test fails on Vorrund (1 check).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Up from 97. Every turn of bible 2 is now shown in the game and held by a test; Vorrund's weeping was the one missing. |

Weighted: 96.8125.

## Next

Pass 480: Combat.
