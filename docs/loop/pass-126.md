# Pass 126: foes dissolve when they die

Combat (97, weight 15) was the heaviest of the lowest categories apart from Art. I audited combat against bible 5 and 7 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| A hit on a ladder | knocks you off (pass 124); the foes near the Tower ladders (Hornets, an Iron Dwarf, a Grub Lump, Gear Bats) all telegraph, so a climb is never an ambush | fine |
| Spire Sentinel | a blow on the stone clinks with the guard spark and sound, and a pogo still bounces | fine |
| Marsh Hag, card vaults, late game | covered by passes 117 to 123 and their tests | fine |
| **Death** | Bible 7: "every enemy has a death animation with a dissolve". As built, a foe vanished the frame it died, leaving a puff of debris and its coins. The kill, the moment every fight builds to, had no animation at all. | **fixed** |

## As built

- **`Enemy.die`:** the body no longer disappears.
  - For 0.45 s (`Enemy.DISSOLVE`) it stays where it fell, under `shaders/dissolve.gdshader`.
  - It flashes white, then breaks up into motes, one world pixel (two art pixels) at a time, the top a little first. Each mote glows pale gold as it goes.
  - Then it is hidden, and freed unless it respawns. A respawn mid-dissolve resets it.
- **Untouchable:** the dying body has no collision. It can't be struck, it does no contact damage, and every homing spell and aim already skips `dead` foes.
- **Unchanged:** the coins, drops, XP, hit-stop, shake and death sound still come at once.
- **Bosses:** they keep their own deaths and go at once when they reach `Enemy.die`, as before. Every other foe dissolves.
  - My first full run caught this: Ripasheiku frees her lanterns as she dies, and while her body lingered, her own process still touched them ("previously freed" errors in the log).
  - The second run has no script errors.
- **Screenshots:** a `--shot-kill=FRAME` game option strikes down every foe in the room on that frame, to catch the dissolve.

## Screenshots

In `/mnt/project-files/pass-126/`:
- `dissolve.png`: the Rot Dwarf Hall, 7 frames after its foes fall. The Rot Dwarf flashes white and starts to break up, with its coins in the air.
- `dissolve_late.png`: 15 frames after, the bodies are scattered motes glowing gold.

## Tests

In `test_enemies.gd`:
- `test_a_defeated_enemy_dissolves_then_is_gone`:
  - the body stays with the dissolve shader;
  - it has no collision;
  - it is partway through after 0.2 s;
  - it is gone after 0.45 s;
  - it never hurt anyone.
- `test_enemies_respawn_when_configured` now checks that the body dissolves, then is gone, then respawns whole.

## Bible

Section 7: "The dissolve (pass 126)".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Every kill now has its moment: a white flash and a body that breaks up into light, as bible 7 asks. |
| World and level design | 15 | 97.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 97 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2450 checks, all passing, with no script errors in the log.

Weighted score: 95.4875 (up from 95.4125). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio and Stability are tied at 97, and Systems weighs the most. Pass 127 takes Systems.
