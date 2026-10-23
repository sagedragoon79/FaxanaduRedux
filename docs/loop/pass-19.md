# Pass 19: the Gear Bat, and the climb toward the Foreman

Date: 2026-10-23. Scope: Combat (78) and World (73). The tower gets its second enemy of its
own and three rooms on the way to the Foreman.

## What was built

- **Gear Bat** (`scripts/enemies/gear_bat.gd`, legend `B`): a clockwork bat of riveted iron
  with a brass gear on its back.
  - It **roosts** upside down under a ceiling. It wakes when you pass within about 7 tiles
    across and 10 tiles below it, or when you hit it.
  - Awake, it hangs off to one side of you and above you, on whichever side it is already
    on, and stays within 200 px of its roost.
  - **Telegraph:** it stops, and the gear glows and whirs for 0.5 s (a new rising, ratcheting
    `whir` sound). The bat jitters and pulses white.
  - **Attack:** it flings the gear at you (**GearBlade**, `scripts/enemies/gear_blade.gd`).
    The gear spins out at 300 px/s, slows to a stop over 0.6 s and homes back to the bat, so it
    can catch you twice if you stand in its path. A wall turns it back early. While the gear
    is out, the bat flies bare and slower, and can't throw.
  - **Parry:** parry the gear and it is knocked home at 380 px/s. It hits the bat for 16 and
    staggers it, which sets up a free combo.
  - If the bat dies with its gear out, the gear drops harmlessly and breaks.
- **2x sheet** for the bat (`gear_bat`, cell 56x40, Canvas scale 2): roost, fly, windup,
  bare and stagger. The thrown gear is drawn in code in the same gold and at the same size.
- **Three tower rooms** (6 of the zone's 26 so far):
  - **Gear Shaft** (15,-5): a two-screen climb up scaffolds from a new ceiling shaft in the
    Winch Hall. Three bats roost under a girder, the door ledge and the ceiling. It has a chest
    and a Potion Shard at the top.
  - **Bat Belfry** (16,-5): a two-screen hall under the old shift bell. Three bats roost under
    the bell housing above a spike pit with stepping platforms. Two Iron Dwarves and two more
    bats are in the hall, and a Mantra Shard sits on a perch.
  - **Foreman's Gate** (18,-5): a shrine to save at before the Foreman. The gate is barred
    for now; the next pass opens it into the arena.
  - The Winch Hall gets a ceiling shaft and a platform chain up to it.
- Bible 7 records the Gear Bat. `levels/README.md` lists `B`.

## Automated verification

New tests:
- the bat stays roosted while you are far off;
- once you are near, the whir lasts at least `Enemy.MIN_TELEGRAPH`;
- the thrown gear cuts the player and comes back to the bat;
- a parried gear hits its bat for `REFLECT_DAMAGE`, staggers it and is caught;
- a gear thrown at a wall turns back without passing into it;
- the sheet has all five animations.

Reachability: every new pickup, chest and the shrine are reachable, and there are no
soft-locks. The checker's jumps are at most 4 rows up, so platform chains step by 4 at most.

Screenshots reviewed: the sheet at 4x; the Belfry with bats roosting and one awake; a thrown
gear with the bare bat; the Gear Shaft ledge with a bat under it; the Foreman's Gate shrine.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 80 | A flier with a returning projectile and a parry that pays off. |
| World and level design | 15 | 74 | The tower climbs: 6 rooms, a bat belfry over spikes, a shrine before the mini-boss. |
| Art cohesion | 15 | 72 | A second 2x code sheet. The Foreman's gate is still plain stone. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 64 | One new sound. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 75 (74.85, up from 74.40).

## Lowest categories and next pass

1. **Bosses (68)**: the Foreman (Rock Golem mini-boss) behind the gate, who drops the Mattock.
2. **Faithfulness (60)**, **Stability (63)** and **Audio (64)**: lightly weighted.
3. **Art (72)**: a gate set piece; the older code sheets at 2x.
