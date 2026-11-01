# Pass 372: every guardian's reveal, held (Bosses)

Category: Bosses (last pass 364).

## Audit

Passes 365 to 371 changed no guardian; their tables and tests still hold.

Bible 8 opens with what every boss has: "a pre-fight arena reveal, 2 or 3 phases, an ability it tests, a stagger window, a cinematic kill, and a reward." Phases, openings, the kill and the rewards each have a test that sweeps every guardian. The reveal had none. Three guardians' own tests glanced at their `intro` state, and the rest only waited it out. Nothing held that each guardian shows its name card, how long the reveal lasts, or that it is a safe moment to look: a guardian that could be cut down during its reveal, or whose reveal shrank to nothing, would have passed every test.

A probe of all 16 arenas found the reveal sound everywhere: each shows its card once, runs 1.2 to 2.4 s, and takes no blow. (Struck directly, Pakukame's body loses health, but its body is not on the enemy layer; its head, its only hitbox, wakes when the reveal ends. The test strikes what a blade could reach.)

## Fix

- Bible 8: a note "The reveal, held (pass 372)" says what each reveal is: the card, the sound and shake, and a length from 1.2 s (Shadow Eura) to 2.4 s (Rokusutahn: 0.5 s out of the wall, 1.3 s of roar, 0.6 s back). During the reveal the guardian strikes no one, and no blow lands on it.
- `test_every_guardian_opens_with_its_reveal` (test_boss) starts every arena. For each guardian it checks:
  - the fight opens on `intro`;
  - the name card shows once, with the script's `DISPLAY_NAME` and `EPITHET`;
  - the reveal's length falls inside the bible's range;
  - a blow every third of a second on the guardian, or on its segments where those are its only hitbox, does nothing;
  - the hero at the door is untouched.

  The shortest and longest reveals must be the bible's 1.2 and 2.4 s.

Mutations, each caught:
- The Foreman takes damage during its intro.
- Rokusutahn's segments take hits during his.
- Shadow Eura's reveal is cut to 1.0 s; this fails the range check and the shortest-reveal check.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. Every guardian's reveal is written and held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 373: Systems.
