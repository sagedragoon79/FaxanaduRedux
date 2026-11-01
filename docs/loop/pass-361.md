# Pass 361: the Ointment lasts as long at every rank (Faithfulness)

Category: Faithfulness (last pass 353).

## Audit

Passes 354 to 360 changed no item, rank, town or guardian. The faithfulness checklist (`test_the_faithfulness_checklist_is_all_here`) and the gear test (`test_the_originals_gear_is_all_here`) still hold the towns, Gurus, ranks, rings, keys, springs, bosses, spells, relics and gear.

The original's mechanics were then checked against a source the bible had not used: the Speed Demos Archive knowledge base, *Faxanadu: Game Mechanics and Glitches*. It confirms two things the bible already says. Pass 353 covers the Wing Boots' flight shrinking with title. Bible 5.4 covers "you do start with more golds after death … when you have a higher experience level".

It also names one rule the bible never mentions. The Ointment's timer, like the Boots', "shortens at higher titles", and the page notes that "higher titles from experience tend to be a net negative in this game". The remake's Ointment lasts a flat 10 s at every rank. That was a silent deviation: no note said what the original did or why the remake changed it, and no test held the Ointment's length against rank.

## Fix

- Bible 4: a note "The Ointment lasts as long at every rank (deviation, pass 361)". It says what the original did, gives the source, and gives the remake's reason, the same one pass 353 gave for the Boots: rank is the reward and should never take something away.
- The faithfulness checklist now:
  - checks the note is there;
  - rubs an Ointment on at the first rank and at Lord, and lets each wear off after 10 s;
  - drops one onto a full pouch at both ranks, so it goes straight on;
  - checks that all four last the same `Player.OINTMENT_TIME`.

Mutation: with an Ointment that shrinks by 4% a rank, the check fails (10 s at Novice, 4 s at Lord).

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
| Faithfulness | 5 | 99 | Unchanged score. One silent deviation is now written down and held. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 362 takes Combat (last pass 354).
