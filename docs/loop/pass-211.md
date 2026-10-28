# Pass 211: the Stride's first secret needs the Stride

World's last pass (203) was the oldest apart from Art, so pass 211 takes World. I audited the ability-gated secrets in `tests/test_reachability.gd` against bible 4.1 and `levels/README.md`. For each secret, I asked the reach checker whether the abilities the player always holds by then already open it.

| Check | Finding | Verdict |
| --- | --- | --- |
| Critical path, pickups and soft-locks | Every reachability test passes at each ability step. | fine |
| Boots secrets (A3) | Feather Hollow's perch is shut without the boots and open with them. | fine |
| **The Stride's secret (A5)** | The test checked the North Bough cache from a set *without* the Wing Boots. The boots always come first, and with them a double jump reached the cache: it was five tiles across at a five-row rise from the bough's ledge. So the Stride gated no pickup at all, only the sky-island rooms. | **moved; the test now starts with the boots** |
| Sky Steps purse | It was listed as a Stride secret, but it is a double jump up from the island below. | **relisted with the boots' secrets** |
| Backtracking rewards | A probe found that the boots open only Feather Hollow, the North Bough and Sky Steps pickups. No earlier zone holds anything for the boots, the Stride, the Onyx, the Hour Glass, Thunder or Fire beyond their own zones' rooms. | noted for a later World pass |

## As built

- `north_bough.room`:
  - The Life Fruit moves to (9,6), on a one-tile plank at row 7.
  - The west shelf under it ends a tile sooner (x0 to 3).
  - From the ledge the fruit is seven tiles across at a four-row rise; from the shelf it is six across at a five-row rise. Both are one tile past a double jump and inside a double jump with a dash.
  - The cracked-stone Mana Dew pocket below the shelf stays sealed.
- `test_elven_stride_crosses_the_gap_to_the_warden_cache` starts with the Wing Boots. `BOOT_SECRETS` gains the Sky Steps purse, and `STRIDE_SECRETS` keeps only the North Bough cache.
- Mutation check: putting the shelf back to five tiles lets the boots reach the cache, and the test fails.
- Bible 4.1: the A5 row notes the move, and a new paragraph says each secret must hold against the abilities found before it.
- Screenshot: `/mnt/project-files/pass-211/north_bough.png`. The perch reads clearly over the gap, between the shortened shelf and the bough ledge.

Full suite: 4024 of 4024 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the Stride now gates a pickup as the bible says, and the test holds it against the boots. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 212 takes Bosses (last pass 204, now the oldest).
