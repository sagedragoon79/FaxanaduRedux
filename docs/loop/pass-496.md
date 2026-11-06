# Pass 496: The Delver's Pick, named on every stone

## Category

Story and world (the next rubric category in the rotation). A text fix that needs no art generations: the
prose a player reads on signs and labels. (This pass was cut off by an app restart and finished by a
resume run. `PIXELLAB_API_KEY` has since been set in the user scope, so the art loop is no longer blocked;
it is the next pass's work, not this one's — see "Next".)

## Audit

Lead: the prose a player reads on signs and labels, after pass 487 did the same for the spells. The
tablets read their text verbatim — `LoreTablet.interact` passes it straight to `GameState.say`, with no
id→name step — so whatever a room file writes is what the player sees.

Scanned every `sign:` and `label:` line across the 10 zone folders for tokens that should never reach
the player. Most underscore tokens in those lines are legitimate `[boss:…]`, `[spring:…]` and
`[conduits:…]` flag blocks, which the tablet strips before reading. One id had leaked into the prose
itself: `delvers_pick`, the internal id of the Delver's Pick ability.

## Bug found

Five Tower signs wrote the ability's raw id, `delvers_pick`, in the sentence a player reads, where its
name "Delver's Pick" belongs:

- `tower/foreman_gate` (two variants): "its `delvers_pick` is yours" and "the foreman's `delvers_pick`".
- `tower/kettleforge_stair`: "those who carry a `delvers_pick`".
- `tower/ore_vault`: "A `delvers_pick` will open it."
- `tower/rail_gallery`: "Dwarves walk the rails with a `delvers_pick` in hand."

The name was already written in full everywhere else it is spoken — the gym's tutorial label
("Delver's Pick: break cracked stone"), the Amberlee miner in `data/npcs.json` ("Bring a Delver's Pick
if you go"), the boss-arena title, and the skill name — so these five were plainly a leak, not a style.

## Fix

The five signs now read "Delver's Pick". No tablet logic changed; only the room text.

## Test

`test_no_sign_shows_a_raw_ability_id` (in `tests/test_rooms.gd`): walks every room's `sign:` and `label:`
lines, drops the `x, y` cell and any leading `[flags]` block, and fails on any `lowercase_with_underscore`
token left in the prose. English prose carries no underscores, so such a token is always a leaked id, and
the one test guards the whole class, not just this ability. It reads 150+ lines, so it cannot pass by
scanning nothing. Mutation check: putting `delvers_pick` back into the Ore Vault sign fails the test,
which names the offender (`tower/ore_vault: delvers_pick`). Bible 4.1 gains the "Told, not labelled with
an id (pass 496)" note beside the spell-names notes, and names this test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 85.25 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Score held. Five Tower signs name the Delver's Pick instead of its id. |

Weighted: 96.8875.

## Next

Pass 497: the queue now leads with Sean's approved items (2026-11-06) — Lithic Fracture (a new supporting
spell) at the top, then the Carillon rain trial — so the next pass takes the top queue item ahead of the
rubric rotation. `PIXELLAB_API_KEY` is now set, so the art loop pass 8 (the seven placeholder guardians,
Haar Wyrm first) is unblocked and follows the Sean items.
