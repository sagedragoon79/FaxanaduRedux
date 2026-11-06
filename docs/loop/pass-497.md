# Pass 497: Lithic Fracture, the floor splits before you

## Category

Sean's approved item (2026-11-06), at the top of the workbench queue, ahead of the rubric
rotation: a new supporting spell, **Lithic Fracture**. One code-and-free-VFX pass, no PixelLab
generations. It reaches combat (a new foe status), systems (the spell and its gate) and the world
(an optional cache seal across several zones).

## What was built

A cascade of six stone columns erupts one after another along the floor in front of the hero,
about 32 px apart and 0.08 s apart, each bursting as it rises. 24 MP, 6 damage per column (light).
It is the fourth entry on the Next Spell cycle, between Emberfall and Wisplight.

- **The wave** (`scripts/combat/lithic_wave.gd`, `LithicWave`). `plan_columns` lays the columns in
  tiles from the caster's feet, reading only the world collision at each candidate cell: it follows
  the floor down a ledge (up to 48 px), stops at a wall across the floor, and stops at the edge of a
  pit. The column that reaches a cracked stone seal shatters it and the wave ends there. Each foe the
  wave strikes is struck once per cast (`_struck`): 6 damage, a 3 s slow, and — unless it is a boss —
  a stagger. Bosses take the hit and the slow but never a stagger.
- **Each column** (`scripts/combat/stone_column.gd`, `StoneColumn`) thrusts up, bursts once at 40 %
  of its rise (striking foes in its span and shattering a seal), then sinks. Drawn in code as a
  jagged slab with a cracked crown and a shear of dust, consistent with every other spell; the burst
  uses the existing `debris` dust. (Sean's note offered the free VFX tool for the burst; the
  code-drawn burst keeps the spell consistent with the rest and adds no asset pipeline. The VFX-tool
  burst is left as later polish.)
- **A new slow on `Enemy`** (`slow`, `is_slowed`, `SLOW_FACTOR` 0.5, `SLOW_TIME` 3 s). While it
  holds, the foe's clock, its thinking and its movement all run at half time, counted down in real
  time. Because it can only ever stretch a telegraph, never shrink one, no tell drops below
  `Enemy.MIN_TELEGRAPH`. It applies to bosses too.
- **The spell** (`Spells.DATA`/`ORDER`/`cast`), the scroll (`ItemPickup` kind `fracture`, legend
  `:`, a stone-grey scroll icon; `data/items.json` `fracture_scroll`), the Inventory listing
  (`Menus.INVENTORY_GROUPS`), and two sounds (`lithic_cast`, `lithic_hit`, `tools/audio/sfxgen.py`).
  The HUD magic-bar gem shows the spell's colour through `Spells.color`, as the others do.
- **Cracked stone seals** (`scripts/world/stone_seal.gd`, `StoneSeal`, legend `[`): rune-bound dark
  stone that blocks like a wall and yields to nothing but a Lithic Fracture cast. A column that
  reaches one shatters every seal of the run in the room for good, and it stays broken
  (`persist_id`). The reach checker (`Reach._solid_char`) treats `[` as solid until `fracture` is
  found, as it does bramble under `fire`. Lithic Fracture is itself an optional find, so a seal only
  ever hides an optional cache, never the way on.
- **The world.** The scroll lies off the main path, up on the Kettleforge lift gallery
  (`tower/kettleforge`, legend `:` at 54,15). Four optional gold caches sit behind seals, carved into
  solid rock in dead-end pockets so nothing else opens: `hearthroot/west_gate` (24,19),
  `heartwood/dwarf_larder` (6,19), `tower/ore_vault` (20,20) and `tower/old_flue` (35,39) — three
  zones. Each pocket is three tiles tall (the hero is 40 px) with a three-tile seal column and the
  chest behind it, the first wave column landing on the seal.

## Tests

In `tests/test_combat.gd`: `test_lithic_fracture_cascades_along_the_floor` (six columns 32 px apart
over flat floor, a wall stop, a pit stop, and a two-tile step down a ledge, all through
`plan_columns`); `test_a_lithic_wave_staggers_and_slows_what_it_strikes` (a real cast costs 24 MP,
strikes a foe for 6 once, staggers and slows it, and leaves a foe behind the caster untouched);
`test_a_boss_is_slowed_by_lithic_fracture_but_not_staggered`;
`test_a_slowed_foes_tell_never_drops_below_the_floor` (a slowed foe's clock runs at half, so a tell
at the 0.35 s floor only stretches); `test_cracked_stone_seals_open_only_to_lithic_fracture` (a
Deluge bolt leaves a seal whole; a Lithic Fracture column shatters it). In
`tests/test_reachability.gd`: `test_fracture_caches_need_the_fracture_spell` (each cache is out of
reach without the spell and opens with it, and the scroll is reachable without it); the three
"everything reachable" tests now exclude `FRACTURE_SECRETS`. The combat-number, inventory,
spell-cycle, told-in-its-name and README-legend invariants all still hold with the new spell.

Mutation check: dropping the `if not foe.is_in_group("boss")` guard in `LithicWave.strike` fails
`test_a_boss_is_slowed_by_lithic_fracture_but_not_staggered`; making `Reach._solid_char` return
`false` for `[` unconditionally fails `test_fracture_caches_need_the_fracture_spell`.

Bible: section 4.1 gains the Lithic Fracture supporting-spell paragraph, 4.5 the cracked stone seal
gate, and 5.3 its combat row; `levels/README.md` the `[` and `:` legend rows.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | A new foe status (the slow) and a new supporting spell; the telegraph floor holds while slowed. |
| World and level design | 15 | 99 | Four optional caches behind cracked stone seals across three zones, none on the critical path. |
| Art cohesion | 15 | 85.25 | Unchanged (deferred to the art loop). The spell's columns, seal and scroll are code-drawn in the house style. |
| Bosses | 10 | 99 | Unchanged. Bosses take the slow but not the stagger. |
| Systems | 10 | 99 | The spell, its scroll, its gate and its slow are held by tests and the bible. |
| Audio | 5 | 99 | Two new sounds (`lithic_cast`, `lithic_hit`). |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8875.

## Next

Pass 498: the queue's next item is Sean's Carillon rain trial (PixelLab's free rain preset vs the
code-drawn rain), then the art loop pass 8 (the seven placeholder guardians, Haar Wyrm first;
`PIXELLAB_API_KEY` is set). Art outranks the rubric rotation when the queue holds no fresh Sean note.
