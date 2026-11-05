# Pass 463: the glass leaf, read

## Category

Story and world (new in pass 461; this is its first scored pass).

## Audit

The 15.3 row asks that each beat of section 2 shows in the game. I searched the data, scripts and rooms
for each one:
- The Reeve's doubt: Reeve Aldous ("a stranger is one more mouth"). Present.
- The miner's confession in Amberlee: the Amberlee miner ("You want to know who did this? We did."). Present.
- Carillon's record of the Withering and the planter's name: the Spires mayor and the Kettleforge
  elder. Present.
- Vorrund's surrender of Severance: his arena's reward. Present.
- The Leaffall ending: the ending card and the Leaffall lines. Present.
- The Ringreader's reading of the glass leaf: **missing.** The words "glass leaf" appear nowhere in the
  game. The Ringreader greeted every visit with the same rest line, so Act I's first beat was never
  shown: the stranger's leaf turned to glass, and its grain shows the Heartwood Spring dammed with
  stillglass.

## Bug found

A story beat the bible names was not in the game.

## Fix

- `data/npcs.json`: the Ringreader gains `greeting_leaf`.
- `scripts/world/npc.gd`: `Npc.ringreader_greeting` gives that reading over the menu the first time any
  Ringreader is met, and sets the flag `leaf_read` (`Npc.LEAF_READ`, kept in the save). After that,
  the usual greeting.
- `scripts/game.gd`: the `--open=ringreader` screenshot option uses it too.

`test_the_first_ringreader_reads_the_glass_leaf` (tests/test_economy.gd) checks it with the real
controller. On a new journey, Up at the Ringreader shows the reading, which names the glass leaf, the
Heartwood Spring and the stillglass. The flag is set, and the save keeps it. After Dash, Up again shows
the usual greeting.

Two other tests change:
- The Boss Rush test takes its "nothing changed" snapshot of the flags after the Ringreader has spoken.
- The cast-line length scan now reads every `greeting*` key.

Bible 2 gains "The glass leaf, read (pass 463)". Screenshot: `/mnt/project-files/pass-463/leaf.png`. The
three lines fit above the rows.

Mutation check: a Ringreader who never reads the leaf fails 3 checks.

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
| Story and world | 5 | 97 | First score. Every beat of section 2 now shows. Still open: the card-suit symbols left on the key doors, and no test yet holds every guardian to lore before and after its fight. |

Weighted: 96.7625.

## Next

Pass 464: Combat (the old order, with Story and world in Faithfulness's place). A later Story and world
pass should replace the key doors' card suits and add a guardian-lore test.
