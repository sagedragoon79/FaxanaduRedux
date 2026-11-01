# Pass 370: how far a spell carries (Combat)

Category: Combat (last pass 362).

## Audit

Passes 363 to 369 changed no blow, foe or spell. Pass 368's stick angle reaches combat: an up-slash and a pogo need the stick within 55 degrees of vertical. Its test covers that.

Pass 362 wrote down how far a swing reaches. The spells were the same gap. Each of the five spells has a row in 5.3 giving its cost, its damage and, for the bolts, its speed. No line said how far any of them carries. Those numbers lived only as constants in the projectile classes:

- a bolt's life (`DelugeBolt.LIFE` 1.2 s, `ThunderBolt.LIFE` 0.7 s);
- Fire's burst and life;
- Tilte's life, speed and seek;
- Death's ring and roll time;
- the Rune Dagger's range and speed.

So a reader of 5.3 would take Thunder, the faster bolt at 380 px/s against Deluge's 300, to reach farther. It reaches only about 260 px against Deluge's 355. Foes are placed and tuned against how far a spell carries, and nothing held it.

## Fix

- Bible 5.3 has a new row, "Spell reach (pass 370)", that gives each spell's reach, measured over open ground and cast standing:
  - **Deluge:** 1.2 s, about 355 px (22 tiles).
  - **Thunder:** 0.7 s, about 260 px (16 tiles), the price of its speed. It leaps 72 px to a dead conduit.
  - **Fire:** bursts where it lands, about 113 px ahead on flat floor, striking everything within 20 px. In the air it bursts after 1.6 s.
  - **Tilte:** lives 2.2 s at 230 px/s and locks on the nearest foe within 240 px.
  - **Death:** its ring rolls out to 300 px over 0.45 s.
  - **Rune Dagger:** flies 160 px at 420 px/s.
- `test_every_spell_carries_as_far_as_5_3_says` has the real player cast Deluge, Thunder, Fire and Tilte across an empty 58-tile hall, then checks:
  - each projectile's flight is measured against the row: distance within 8 px, life within 0.05 s;
  - Thunder must pay for its speed in reach;
  - every constant above must be written in the row.

Mutation: with Thunder's life at 1.0 s, the test fails 2 checks (the distance and the time).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. How far every spell carries is written and measured. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 371: World.
