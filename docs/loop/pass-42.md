# Pass 42: Bog Myconid

Combat was the lowest heavily weighted category at 84. The Mist had only one regular enemy, the Lantern Ghost, so
every Mist room fought the same way.

## What changed

- **Bog Myconid** (`scripts/enemies/bog_myconid.gd`, legend `V`): a squat marsh mushroom rooted in the mud.
  - Come within about five tiles and its cap swells for 0.6 s while its gills glow. During the swell it joins the
    fog's `light` group (radius 34), so the telegraph shows even in the murk.
  - Then it bursts into a **spore cloud** (`scripts/enemies/spore_cloud.gd`). The cloud billows out to 40 px, drifts
    up and thins away in 2.4 s. It stings for 8 on contact and again every 0.7 s, and it can't be parried.
  - Spent, its cap sags open for 1.1 s and takes half again the damage. The answer is to step back out of the cloud's
    reach, then come in and strike.
- **A 2x code-drawn sheet** from `tools/art/castgen.py` (`bog_myconid`, 40x40, origin 20,38) with four animations:
  idle, windup (glowing gills and gold-lit eyes), burst and spent. Other sheets are byte-identical.
- **Two new sounds**, appended at the end of `sfxgen` so the old wavs stay identical: `swell` (a wet rising creak) and
  `spore` (a dusty pop and a hiss).
- **Placed in four Mist rooms:** two in the Fog Cut, one on the Drowned Stair's long landing, one in the Veiled Rise
  and two in the Victim Causeway.
- Bible 7 (Mist enemies) describes it. `levels/README.md` has the `V` legend row.

## Tests

`test_enemies.gd` has a new test, `test_bog_myconid_swells_bursts_spores_and_is_soft_when_spent`. It checks that:

- the swell lasts at least `Enemy.MIN_TELEGRAPH`, and the myconid lights the fog the whole time;
- a cloud bursts and the glow goes out;
- the cloud stings the player two tiles away on arrival and on its tick, not every frame;
- a 10 hit deals 15 while spent and 10 when firm;
- the cloud thins away.

## Screenshots

`/mnt/project-files/pass-42/`: a Fog Cut myconid swelling, then its spore cloud.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 86 | A second Mist enemy that controls space rather than chasing, with a clear punish window. |
| World and level design | 15 | 88 | Unchanged. |
| Art cohesion | 15 | 84 | Unchanged. |
| Bosses | 10 | 84 | Unchanged. |
| Systems | 10 | 84 | Unchanged. |
| Audio | 5 | 84 | Two new sounds. |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | Unchanged. |

Weighted score: 85.70 (up from 85.40).

## Lowest categories and next pass

Stability (83) is the lowest category. Art, Bosses and Systems are tied at 84. Bosses carries more weight than
Stability, and the Mist's second boss, Zorugeriru, is the next big piece. A Stability pass (save and load across the
Mist, and a soak of the new rooms) is a good pick if Zorugeriru needs groundwork first.
