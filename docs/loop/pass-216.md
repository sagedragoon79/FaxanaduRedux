# Pass 216: the Stride's gate is a veil, not a distance

Movement's last pass (208) was the oldest apart from Art, so pass 216 takes Movement. I audited movement against bible 6 and passes 209 to 215. That included pass 211's claim that a double jump can't reach the North Bough's warden cache, which I checked by playing the real controller in the real room.

| Check | Finding | Verdict |
| --- | --- | --- |
| Tuning held to bible 6 (200, 208) | Every number in `MovementTuning` is still pinned by a test and has a play test. | fine |
| Hit-stops (208, 210), engine errors (215) | No movement code changed. | fine |
| **The Stride's gate (211)** | A scripted probe ran left off the bough's ledge and jumped at every timing in 2-frame steps. It took the Life Fruit with a plain single jump, no boots: 10 hits in the first two take-off columns alone. The reach checker's jump envelopes are deliberately *under* the real controller (a single jump rises 72 px and carries about 87 px across before it drops back to the cache's height). That makes them sound for "can reach" and unsound for "can't reach". So pass 211's gate, and the gap before it, never held. | **built the bible's stride gate: the elven veil** |
| Height gates | A single jump peaks at 72 px. Feather Hollow's perch is six rows (96 px) up, so it really does need the boots. | fine |

## As built

- **`StrideVeil`** (legend `|`, `scripts/world/stride_veil.gd`):
  - Bible 4.5 called this gate a "mist curtain", but that name had already gone to the Mist's bound fog (`Y`).
  - It sits on its own collision layer, `Player.LAYER_VEIL` (16).
  - The player's mask drops that layer while dashing (`Player.passes_veils`) and keeps it dropped while the body still overlaps a veil, so a dash that ends inside doesn't trap you.
  - Ground and air dashes both pass. The veil flares with the new `veil` sound (a silk rush and two glassy notes a fifth apart).
  - Without the Stride, touching it says "An elven veil. Only a warden's stride passes it."
  - Only the player is stopped.
- **Reach checker:** `|` is solid until the Stride is found.
- **North Bough:**
  - The Life Fruit sits in a sealed alcove at (2,6), under the ceiling, with walls on three sides and a veil column (x4, rows 4 to 6) on the fourth.
  - A three-plank porch outside the veil (x5 to 7, row 7) can be reached by a plain jump from the west shelf.
  - The shelf is back to its original five tiles.
  - `GameState.MOVED_PICKUPS` maps both earlier spots, (8,7) and (9,6), to (2,6).
- **Tests:**
  - `test_an_elven_veil_lets_only_a_dash_through` (new) checks that walking is stopped, a dash without the Stride is stopped, a ground stride passes, walking back is stopped, an air dash passes, and that inside a veil you are let out and it closes again once you're clear.
  - `test_the_warden_cache_needs_the_stride` (new) runs the real room from the porch: walk, jump and dash take the fruit only with the Stride.
  - `STRIDE_SECRETS` points at (2,6), so the reach checker holds it shut with the boots and open with the Stride.
- **Bible:** 4.1 A5 row; a correction on the pass 211 paragraph saying why safe envelopes can't prove a gate; and 4.5 "Mist curtains", as built.
- **README:** the `|` legend row.
- **Screenshot:** `/mnt/project-files/pass-216/north_bough_veil.png`. The veil reads as a teal column with a pale rune between the fruit and the porch. I made the strands and rune stronger after the first shot, where the veil was too faint against the sky.

Follow-up for World: every "out of reach without X" assertion that rests on distance rather than height or a gate tile should be checked the same way, starting with the Sky Steps purse in `BOOT_SECRETS`.

Full suite: 4051 of 4051 checks passed, with no script or engine errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: the Stride now has the gate the bible gave it, and the dash's gating is proved in the physics. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 217 takes Faithfulness (last pass 209, now the oldest).
