# Pass 499: the Haar Wyrm breathes steam, not fog

## Category

The workbench queue's top item and a Sean note (2026-11-06): **the Haar Wyrm breathes steam, not
fog.** His words for the breath: "a semi slow bellow of steam like you see hissing out of a steam
pipe. It's slow enough to dodge." And the story that gives the zone its weather a cause: the wyrm is
steam and bone; it boiled the Haar Spring's three tanks dry, and the Haar's fog is its steam cooled
over the marsh — so the fog lifting by half when it falls (the event table) now has a reason. A
gameplay-plus-story pass. The guardian's redrawn PixelLab base ("steam and bone") stays with the
gated art loop (art pass 8), which already carries the new look into its prompt.

## What was built

`MistBreath` is now **`SteamBreath`** (`scripts/bosses/haar_breath.gd`), a gout of hot white steam
that vents from the breathing head's jaws:

- **Slow and billowing.** 95 px/s (was 150), and it lives 3.2 s (was 2.4), so it still crosses more
  than a lane. It starts narrow at the mouth (`spread` 0.4) and billows wider as it rolls (to 1.9),
  thinning and cooling as it goes. Its hurt rect widens with the plume but its **height stays capped
  at 44 px** — under a single jump's 72 px apex (`movement_tuning` `jump_height`), so a jump always
  clears it, and standing up on the tank walls or rafts keeps you above it. 12 damage, no parry, as
  before; in phase 3 it still vents along the flood's surface.
- **Hotter and whiter.** Near-white steam (`f4f7f6`) with a warm hot core (`fff1dc`) at the leading
  jaw, cooling toward the tail; the trailing puffs rise, and the whole gout wavers with a heat
  shimmer.

Around it, in `scripts/bosses/haar_wyrm.gd` and friends:

- **The tell** (0.7 s, still never under `Enemy.MIN_TELEGRAPH`): pressure builds — wisps of steam
  leak from the jaws, steam gathers hot and white on the floor below, and a **rising hiss**
  (`steam_hiss`) plays under it, then the bellow.
- **A doused head goes out with a hiss and a last puff.** When a filled tank douses the head over it
  in phase 2, the head now vents a last rising puff of steam (`HydraHead.puff`, `DOUSE_PUFF` 0.6 s)
  as the `douse` splash-and-hiss plays.
- **Dry tanks steam.** While a tank waits for Deluge in phase 2 it gives off a faint rising steam
  (`dry_basin.gd`), the wyrm having boiled it dry — alongside the blue water-shimmer hint, which
  stays.
- **Epithet:** "Three Heads of Fog" is now "Three Heads of Steam".

Sound (`tools/audio/sfxgen.py`, regenerated, checked for level): `haar_breath` is now a pressurized
steam-pipe hiss layered over the throaty breath (peak 0.50, rms 0.11), and a new `steam_hiss` is the
rising tell (peak 0.40, rms 0.12). The `.ogg` music half of `levels.py --check` needs ffmpeg, which
is not on this PC; CI's mix job runs it. The two new `.wav`s were measured directly and sit in line
with their siblings, no clipping.

Story: bible **8.4** (concept, arena, phase 1, phase 2 douse, phase 3, sound, look) rewritten to
steam; the Stillstone lines in A8 now say "steam breath"; the Haar-Spring-restored event row names
the cause (the wyrm's cooled steam); **Ilka** (`haar_keeper`, `haar_keeper_glad`) now tells the
player the fog was the wyrm's breath and has gone cold with it; the three **Haar Spring signs** speak
of the tanks boiled dry and the marsh breathed full of steam.

## Tests

In `tests/test_boss.gd`:

- `test_steam_breath_vents_along_the_floor` (the renamed roll test): a steam head bellows after a
  tell of at least `MIN_TELEGRAPH`, the gout vents along the floor and moves.
- `test_steam_breath_is_slow_and_billows`: ~95 px/s over a second, widens as it rolls, and its run
  (`LIFE * SPEED`) crosses more than a lane.
- `test_steam_breath_is_dodged_by_a_jump_or_the_walls`: fully billowed it is at most 48 px tall,
  under the 72 px jump apex, and a player up on a tank wall is clear of it.
- `test_a_doused_head_goes_out_with_a_puff`: in phase 2 the head over a filled tank is doused and
  leaves a last puff.

`test_combat.gd`'s guardian sheet and `test_boss.gd`'s Stillstone and mist-head checks follow the
rename.

Mutation check: uncapping the gout's height (`lerpf(0.5, 1.9, ...)`) makes it 84 px tall and fails
all three checks of `test_steam_breath_is_dodged_by_a_jump_or_the_walls`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 86.5 | The breath reads as hot steam with depth and a heat shimmer, hotter and whiter than the fog; the guardian's HD base is still deferred to the art loop. |
| Bosses | 10 | 99 | The Haar Wyrm's breath, tell, douse and dry-tank steam are clearer and better telegraphed; held by tests. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | A steam-pipe bellow and a rising tell hiss give the breath its own voice. |
| Stability and performance | 5 | 99 | Unchanged; the gout is a single code-drawn node as before. |
| Story and world | 5 | 99 | The Haar's fog now has a cause — the wyrm's cooled steam — carried through the bible, Ilka and the signs. |

Weighted: 97.075.

## Next

Pass 500: art loop pass 8 — the seven placeholder guardians, the Haar Wyrm first, now drawn as
"steam and bone" per this pass, Sean approves each base before animation (`PIXELLAB_API_KEY` is set;
~193 generations plus 50 USD of credits). Art outranks the rubric rotation when the queue holds no
fresh Sean note. Then the VFX pass (a code effect vs the free VFX tool) and the pass-497 independent
grade's defects (the hero sprite, flat lighting/AO, depth and tile repetition).

For Sean (carried from pass 498, still open): the rain sheet won, so the **Haar marshes** could take
a thin, slow drizzle to suit the fog, and the High Boughs an even fainter mist-rain — say the word
and a pass wires it in.
