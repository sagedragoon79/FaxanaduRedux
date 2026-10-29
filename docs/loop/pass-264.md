# Pass 264: what the feet kick up

Category: Movement (last pass 256).

## Audit

I read bible 6 against `movement_tuning.gd`, and the numbers match (the movement tests assert them). Then I looked at how recent ground types meet the juice checklist (6.7):
- pass 181's marsh mud;
- pass 248's sap;
- pass 259's standing water.

Their steps sound right: `step_mud`, `step_sap`, and `step_wade` since pass 262. But every puff the feet throw was the same pale dust whatever the ground:
- the run's kick;
- the jump;
- the landing;
- the dash along the floor.

A landing in Dartmoor's water raised a dry dust cloud under the surface. A sprint through the Mist's marsh kicked up dust from mud. What you see and what you hear disagreed on every step.

The other items checked hold:
- the Lilith's dive knocks you back like any blow;
- the water is no SwimWater, so jump, coyote time and buffering are unchanged in it;
- ladders and one-way planks are as before.

## Fix

- `Dust.setup` takes the ground. The four ground puffs (`Dust.GROUND`: run, dash, jump, land) take its look from `Dust.GROUND_TINT`:
  - marsh mud flings dark brown clods;
  - sap flings amber gobbets;
  - standing water throws pale blue spray.

  All three are heavy, so they fall back rather than drift. Stone, moss, plank and iron keep the pale dust.
- Spray leaps up from the water's surface rather than from the floor a tile below it. It has three more drops than the dust, thrown higher, so it reads above the water.
- `Player._ground()` is shared by the footstep and the puffs.
- Test: `test_what_the_feet_kick_up_takes_the_ground_s_look` (`test_movement.gd`). It drops the player for real and checks five things:
  - a landing on stone puffs dust;
  - a landing in the marsh flings mud, and so does the run;
  - a landing in the Flooded Hall's water throws spray, every drop thrown upward and falling back;
  - in the same hall drained, the landing puffs dust again.
- Screenshot, looked at: `/mnt/project-files/pass-264/splash_24.png` shows spray at the hero's hips as she lands in the Flooded Hall. My first cut threw it from the floor, under the water, where it barely showed. I moved it to the surface.
- Bible 6.7, the Dust line.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: the feet's puffs agree with the ground's sound. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 265 takes Faithfulness (last pass 257).
