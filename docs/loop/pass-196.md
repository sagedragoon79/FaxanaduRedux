# Pass 196: guardians as deep as their zones

Bosses' last pass (188) was the oldest apart from Art, so pass 196 takes Bosses. Pass 194 left boss arenas at threat 1 so each boss would stay tuned on its own. I drew up the guardians' damage sheet to check that choice, and audited bosses against the rubric (15.3: two or three phases, a test of the ability it guards, a cinematic kill, balanced health).

| Check | Finding | Verdict |
| --- | --- | --- |
| **Guardians' damage against their zone** | Bosses' raw damage is flat from the Trunk to Zenis, like the foes' was before pass 194. At threat 1, each guardian's hardest blow through its zone's par armor was: Rokusutahn 17, Zoradohna 20, Ripasheiku 14, Pakukame 17, Borabohra 15, King Grieve 12, the Drowned Warden ("the hardest fight in the game") 12, the Evil One's avatar 11 and its heart 9. Since pass 194 a Shade Knight in Dartmoor's halls lands 20, so the deep guardians were softer than the corridors leading to them. | **fixed: arenas take their zone's threat; a test holds the guardians' sheet** |
| Phases, ability tests, kills | Unchanged since pass 188. Every boss's phase and telegraph tests pass. | fine |
| Health | It is unchanged, and the blade side of the sheet stays as it was. Par slashes run from about 17 (Shadow Eura) to 37 (the Drowned Warden), plus Rokusutahn's 600 spread over his parts. | fine |
| The boss rush | It runs in the same arenas, so it takes the same threat, against the endgame kit a 100% save carries (a 100% save owns the Battle Suit and Helmet, which together let 36% of each blow through). | fine |

## As built

- `Room.threat()` has no boss exception: an arena takes its zone's threat.
- `Player._threatened` scales a boss's blows and shots like any foe's. Only world hazards (fire seals) are left out.
- Zorugeriru's rising flood (`HydraFlood`, through `take_damage`) wears you down as a hazard does and stays unscaled. `zorugeriru.gd` is untouched.
- The guardians now hit, through their zone's par armor:
  - Rokusutahn 17;
  - Zoradohna 20 and the Foreman 19;
  - Ripasheiku 20, Zorugeriru 15 and the Matriarch 12;
  - Pakukame 25 and the Bark Knight Captain 21;
  - Borabohra 25;
  - King Grieve 24, the Clockwork Alpha 22 and Shadow Eura 22;
  - the Drowned Warden 24;
  - the Evil One's avatar 22, and its veins and heart 18.
- `test_combat.gd`:
  - `test_the_guardians_hit_as_hard_as_their_zone` (new) reads each boss's and its shots' `*DAMAGE` and `*CONTACT` constants. It holds every guardian's hardest blow to 0.5 to 1.5 masks through par armor, and each zone's guardians to at least 0.75 masks.
  - `test_a_foe_hits_as_hard_as_its_zone_is_deep` now expects a Dartmoor arena's threat to be 2.
- Bible 5.5: a guardians' sheet, and the arena rule changed (it supersedes the pass-194 line).

Full suite: 3816 of 3816 checks passed, with no script errors. No boss test needed changing beyond the one arena-threat check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: no guardian is now softer than its zone's foes, and a test keeps it so. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 197 takes Systems (last pass 189, now the oldest).
