# Pass 204: the guardians' health sheet

Bosses' last pass (196) was the oldest apart from Art, so pass 204 takes Bosses. I audited bosses against the rubric (15.3: two or three phases, a test of the ability each guards, a cinematic kill, balanced health) and passes 197 to 203.

| Check | Finding | Verdict |
| --- | --- | --- |
| Boss purses at zone threat (197) | Purses go through `Enemy.die`, and the gold sheet test leaves boss gold out, so the economy holds without it. | fine |
| The Pendant in the Matriarch's arena (201) | It lies in the corner away from the door, and picking it up mid-fight gives the usual banner and a 0.12 s hit-stop, like any find. The arena's fight, phases and tests are unchanged. | fine |
| The Pendant and the Magical Rod against bosses (201) | The Pendant is 10% off every boss's slashes, and the Rod makes Deluge 18. Both only shorten fights. No boss script treats Deluge specially. | fine |
| Phases, ability tests, kills | Every boss has two or three phases (`PHASES`), its ability test, and `Feel.boss_kill`. All their tests pass. | fine |
| **Balanced health** | The rubric's last boss item had no measure at all. Pass 196 gave the guardians a sheet for the blows they deal, but none for their health. | **built: the guardians' health sheet, and a test** |

## The sheet

In slashes of the zone's par blade:

| Zone | Guardians |
| --- | --- |
| Tower | Zoradohna 33, the Foreman 20 |
| Mist | Zorugeriru 24, Ripasheiku 20, the Matriarch 18 |
| Branches | Pakukame 20, the Bark Captain 19 |
| Daybreak | Borabohra 23 |
| Dartmoor | King Grieve 23, the Clockwork Alpha 19, Shadow Eura 18 |
| Sunken Spring | the Drowned Warden 38 (optional) |
| Zenis | the Evil One: avatar 20, heart 17 (37) |

Rokusutahn is left off: his 600 HP is spread over a plated body that takes a quarter of each blow and a soft tail. The Evil One's veins are left off too, because they are a climb rather than a health bar.

What the sheet shows:

- Every guardian falls in 18 to 38 slashes.
- Each mini-boss is shorter than its zone's guardian.
- The finale is the longest required fight, and only the optional Warden runs longer.
- Zoradohna (33) is long for the Tower. She is inside the band, so I left her as she is and noted it for a later Bosses pass.

## As built

- `test_combat.gd`, `test_the_guardians_last_as_long_as_their_place` (new), which reads each boss's `max_hp` and checks:
  - every guardian falls in 15 to 40 par slashes;
  - a mini-boss falls in 25 or fewer and never outlasts its zone's guardians;
  - the Evil One's avatar and heart together outlast every other required guardian.
- Bible 5.5: "The guardians' health" table and rules. Bible 15.3: the Bosses row names the test.
- No boss health changed.

Full suite: 3976 of 3976 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the rubric's balanced-health item is now measured and held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 205 takes Systems (last pass 197, now the oldest).
