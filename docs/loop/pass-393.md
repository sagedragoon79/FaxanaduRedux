# Pass 393: the original's foes on the rename list (Faithfulness)

Category: Faithfulness (last pass 385).

## Audit

- Passes 386 to 392 added no original name. The Windloft veil (388) and the zone chain of 3.1 (387) carry their deviations in the bible.
- Pass 385's rename list (`data/original_names.json`) held places, people, guardians, things, spells and ranks, but no foes. The game still names four of the original's foes, and their scripts say so: the Monodron, the Bog Myconid, the Naga (its "the original's serpent") and Pakukame's Liliths ("as in the original"). A rename for a public release going down the list would have missed all four. The Monodron's own script did not say it was the original's.
- The remake's other foes (the Hornet, the Rot Dwarf, the Leaf Mantis and the rest) are new names and need no rename.

## Fix

- The list gains a `foes` group: Monodron, Myconid, Naga, Lilith (78 names, in 183 files).
- The Monodron's script calls it the original's.
- `test_the_rename_list_finds_every_name_it_keeps` now reads every script in `scripts/enemies/`. A foe whose script says it is the original's must have its name on the list, and every listed foe must be a foe there.
- Bible 1, IP note: the counts, a "The foes (pass 393)" note, and the test's reach.

Mutation check: with Naga taken off the list, the test fails 2 checks (Naga is the original's and unlisted; the count is 77).

Full suite: 7089 checks passed, soaks 50.5 minutes, every sound heard.

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
| Faithfulness | 5 | 99 | Unchanged score. The original's foes are on the rename list, and a foe that calls itself the original's must be. |

Weighted: 96.8625.

## Next

Pass 394: Combat.
