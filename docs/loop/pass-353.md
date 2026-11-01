# Pass 353: the original's spent tools, kept for good (Faithfulness)

Category: Faithfulness (last pass 345).

## Audit

The faithfulness passes so far have set the manual's items beside the remake's: the Red Potion (321), the spells' power (329), the Hour Glass (337) and the Elixir (345), with the Poison and the Ointment (305) and the Pendant (201). Each deviation is written in the bible with what the original did, and the checklist test (`test_the_faithfulness_checklist_is_all_here`) holds the text.

Two of the original's best-known tools had no such line. In the original, the Wing Boots and the Mattock were used up. The Boots let you fly for a time that was shorter the higher your rank, and then they were gone; each Mattock broke one blocked passage. The remake makes both permanent abilities (A2 double jump and pogo, A3 double jump). The ability table names them as their Faxanadu roots, but nothing said that the originals were spent, or why the remake keeps them. A reader of the bible could take the double jump for the original's Boots.

## Fix

- Bible 4, after the spells' power: "The original's spent tools, kept for good (deviation, pass 353)". It says what each did in the original (timed flight shrinking with rank, one passage per Mattock), and why the remake keeps them: every gate stays a gate after the first crossing, section 4's backtracking needs the tool kept, a timed flight would outrun the reach checker's measured gaps, and a flight that shrank with rank would turn rank into a loss. It also says what each tool keeps of the original's job.
- `test_the_faithfulness_checklist_is_all_here` now checks:
  - the note is in the bible;
  - a save keeps the Boots and the Mattock as yes-or-no;
  - no item in `data/items.json` is named for either;
  - in play, two leaps with the Boots each lift a second time in the air, and after each landing the Boots are still worn and their lift is back.

Mutation: with the Boots spent on their first lift, the play checks fail; with the note's wording changed, the text check fails. No behaviour changed.

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
| Faithfulness | 5 | 99 | Unchanged score. The Boots and the Mattock now say what the original's were. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 354 takes Combat (last pass 346).
