# Pass 357: the flasks told apart by shape (Systems)

Category: Systems (last pass 349).

## Audit

Bible 14's Accessibility line promises "colorblind-safe gate icons, subtitles for all voiced grunts". Its interim notes cover the options built since (shake, flashes, rumble, volumes, speed, mercy, damage numbers), but nothing said what became of these two promises, and no test held them.

- **The gates** are told apart by shape already. Each card door bears its suit (`KeyDoor`: spade, heart, club, diamond, star), the Sky gate a bolt, and the other gates each have a look of their own.
- **Voiced grunts** don't exist. Every line is text, and the hero's grunts are sounds, not words.
- **The title's three flasks** (Sean's save slots, pass 343 to 350) were the gap. Bible 14 said they "are told apart by color alone": amber, pale green and pale blue, with no number or letter by Sean's wish. Amber against pale green, and pale green against pale blue, are the pairs colorblind players confuse most. With the shelf focused on one flask, a colorblind player could not tell which of the other two held which journey without moving onto each.

## Fix

- Each flask bears its spring's mark on its glass, full or empty: a leaf for the Trunk, three ripples of mist for the Mist, Borabohra's bolt for the Sky (`SlotPicker.MARKS`, `SlotPicker.mark`). The marks are pictures in keeping with the flask metaphor, never a number or a letter, as Sean asked. Screenshot: `/mnt/project-files/save-slots/flasks-marked.png`.
- Bible 14 (saves): "Told apart by shape as well as color (pass 357)". Bible 14 (Accessibility): an as-built note on the gate icons and on the voiced grunts.
- `test_the_flasks_are_told_apart_by_shape` checks:
  - three marks for three flasks;
  - each is drawn, big enough to read and inside the flask's body;
  - each differs in shape from the others;
  - the bible says so.

Mutation: with two flasks given the same mark, the test fails.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score. The flasks no longer rely on color alone. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 358 takes Audio (last pass 350).
