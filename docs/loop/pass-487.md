# Pass 487: The spells in their names' words

## Category

Story and world.

## Audit

Leads: after the spell rename (#540), every line a player reads about the spells, and whether each
scroll is foreshadowed before it is found.

- Foreshadowing holds: the Marsh Road's sign tells of the drowned scribe and his scroll before Deluge;
  the Spires' signs and the shrine speak of the elves' lightning before Tempest Lance; a Carillon
  villager points to Ysolde's Emberfall; the scroll shops sell Emberfall and Wisplight.
- The words did not follow the names. The pickup, scroll and Inventory lines had been written for the
  plain names: Deluge was "a bolt of water", Tempest Lance "a bolt of lightning", Emberfall "a
  fireball" and Witherbloom "a ring of black light". Two Arcana skills had become "Deluge Pierce" and
  "Deep Witherbloom", spell names worn whole.

## Bug found

The lines a player reads about four spells described the old plain names, not the new ones Sean chose,
and two skill names read awkwardly.

## Fix

Deluge is "a surging flood of water", Tempest Lance "a lance of lightning", Emberfall "an ember thrown
in an arc", Witherbloom "blight blooms out in a ring". The skills are now **Undertow** (water bolts
pierce) and **Deep Blight** (Witherbloom at half cost); their ids stay. `test_each_spell_is_told_in_the_words_of_its_name`
(test_systems) checks each spell's name, its pickup or Inventory line and its scroll for its name's
picture, and that no skill wears a whole spell's name. Bible 4.1's spell-names note gains "Told in their
names' words (pass 487)".

Mutation check: with Deluge's old line back ("A bolt of water"), the test fails.

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
| Story and world | 5 | 98 | Score unchanged. The spells are told in the words of their new names. |

Weighted: 96.8125.

## Next

Pass 488: Combat.
