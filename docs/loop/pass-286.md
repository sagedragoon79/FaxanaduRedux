# Pass 286: an empty flask is heard

Category: Audio (last pass 278).

## Audit

I read bible 13.3's sound entries against what passes 279 to 285 touched:
- **What those passes touched sounds right:**
  - The guardian soaks and the ladder rules add no sounds.
  - The tell test now hears every tell a guardian names (pass 284).
  - The great loaf's heal plays at -3 dB, against bread's -6, so the bigger meal sounds bigger.
  - Coins kept in the room (pass 285) still bounce silently and ring as you take them, as they did before.
- **The cast cooldown (pass 282) raised a question:** what does a press that does nothing sound like? I listed every refusal in `player.gd`:
  - A spell short of MP fizzles.
  - An Hour Glass still running back fizzles.
  - Next Spell with no spell owned fizzles.
  - A press inside the cast cooldown is silent, which is right: the cast you just made is still sounding.
  - **An empty Red Potion flask was silent.** That is the press made most often, and in the worst moment: low on health, mid-fight, mashing Heal, with nothing to say the flask is dry except a glance at the HUD.

  None of the refusals had a test.

## Fix

- New sound `flask_empty` (`tools/audio/sfxgen.py`): a dry cork pop, then two small, high glass rings, with no swallow after them. It is a flask's sound, not the spell `fizzle`, for the same reason pass 122 gave the locked doors their own sound.
  - Only `flask_empty.wav` was added. The other generated files were checked out unchanged.
  - `levels.py --check` passes.
- `Player._update_drink` plays it once for each press of Heal with no charges left.
- Test: `test_a_refused_drink_cast_or_glass_is_heard_once` (`test_combat.gd`). It covers the drink, cast and glass refusals:
  - An empty flask clinks once and nothing is drunk.
  - A press at full health is quiet and spends nothing.
  - A spell short of MP fizzles once and spends nothing.
  - A press inside the cast cooldown is silent.
  - A glass turned while it runs back fizzles once.
- Mutation check: without the clink, the test fails ("an empty flask clinks, once ([])").
- Bible 13.3: a "Refusals" entry after "Locks".
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: an empty flask is heard, and the drink, cast and glass refusals are tested. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 287 takes Stability (last pass 279).
