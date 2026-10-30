# Pass 274: the Naga's bite meets a shield

Category: Combat and enemies (last pass 266).

## Audit

I checked the Naga from pass 273 against bible 5.3 and against the foes like it: the Spring Eel, the Clockwork Hound and the Leaf Mantis.
- Its strike was its body's touch (`contact_damage`, 16). The player takes contact as an unparryable blow. Every other telegraphed bite or slash in the game goes through `hit_player_in_rect`, so a parry turns it and staggers the foe (bible 5.3, "Parry: ... enemy staggered"). A Naga was the one tell-then-bite a shield could not meet.
- Testing the parry found a worse bug. Pass 273 grew the Naga's body to 44 px tall when it was drawn at 2x. Level with a hero standing on the floor, its body bottom grazes the floor. The strike ended on any slide collision, so it stopped on its first frame and never reached a hero on the ground. Pass 273's test held the hero in mid-air and missed it.

The Naga's other combat interactions are sound:
- **Knockback** pushes it off its column, and the float pulls it back.
- **Pogo:** it is in the `pogo` group.
- **Rune Dagger:** it takes the dagger through `take_throw`.
- **Stagger:** it ends in `idle`, which the Naga reads as `return`.
- **Hour Glass:** it does not stop foes, only their shots and water (bible A8).
- **Hitstun mid-coil:** the coil keeps drawing its tell, so the strike is never unannounced.

## Fix

`scripts/enemies/naga.gd`:
- The strike now bites through `hit_player_in_rect(bite_rect(), BITE_DAMAGE)`, once per strike and parryable. A parry staggers it for 1 s, then it gathers itself.
- During the strike its touch is off, so the bite alone decides. While floating, its body only scrapes, for 8 (`TOUCH_DAMAGE`, was 16).
- Only a wall ends a strike early (`is_on_wall()`), not the floor.

New test `test_the_nagas_bite_can_be_parried` (test_enemies). The hero stands on the floor, as in the rooms:
- a parried bite does no harm and staggers the serpent, which then gathers itself;
- an unmet bite lands whole (16);
- its body only scrapes.

With the old floor-ends-the-strike check, the unmet bite does nothing and the test fails.

Bible 7: the Naga entry now describes the bite, the parry and the scrape.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the Naga now reaches a grounded hero and answers a parry. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 275 takes World (last pass 267).
