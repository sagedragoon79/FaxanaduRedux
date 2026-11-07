#!/usr/bin/env python3
"""Guards for the backdrop gradient (design bible 12.6).

These cover the pure gradient helpers in tilegen that shape every far layer's
sky, so the moire dot-grid the independent grade flagged (pass 497/500/501) stays
fixed. The game test suite is Godot-only and CI does not run Python unit tests;
run this guard with `python tools/art/test_tilegen.py` after touching the
gradient. Exit code is non-zero on the first failure, so it mutation-checks by a
plain re-run.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import tilegen as tg  # noqa: E402


def _nearest(name):
    """The palette name nearest in RGB to `name` (identity for a palette name)."""
    target = tg.c(name)[:3]
    return min(tg.PAL, key=lambda n: sum((tg.PAL[n][i] - target[i]) ** 2 for i in range(3)))


def test_ramp_is_palette_locked():
    ramp = tg.gradient_ramp("night-0", "crystal-1")
    assert ramp, "ramp is non-empty"
    for name in ramp:
        assert name in tg.PAL, f"{name} is a master-palette colour"


def test_ramp_has_several_steps_between_far_apart_ends():
    # The whole point: far-apart endpoints get intermediate palette steps, not a
    # two-colour field. (Mutating gradient_ramp back to [top, bottom] fails here.)
    for top, bottom in [("night-0", "sky-2"), ("night-1", "crystal-2"), ("sky-5", "sky-7")]:
        ramp = tg.gradient_ramp(top, bottom)
        assert len(ramp) >= 3, f"{top}->{bottom} ramps through >=3 palette steps, got {ramp}"


def test_ramp_ends_sit_on_the_endpoints():
    ramp = tg.gradient_ramp("night-0", "sky-2")
    assert ramp[0] == _nearest("night-0"), f"ramp starts at the top colour, got {ramp[0]}"
    assert ramp[-1] == _nearest("sky-2"), f"ramp ends at the bottom colour, got {ramp[-1]}"


def test_ramp_has_no_repeated_neighbours():
    ramp = tg.gradient_ramp("night-0", "stone-1")
    assert all(a != b for a, b in zip(ramp, ramp[1:])), f"adjacent ramp steps differ, got {ramp}"


def test_a_solid_band_is_fully_solid():
    # At the very top the gradient is one flat colour (no stray dither pixels).
    ramp = ["night-0", "stone-0", "sky-2"]
    row = {tg.gradient_pixel(ramp, x, 0, 300) for x in range(400)}
    assert row == {ramp[0]}, f"the top row is solid, got {row}"


def test_a_seam_dithers_between_adjacent_steps_only():
    ramp = ["night-0", "stone-0", "sky-2"]
    # p = y/(h-1)*(n-1); pick y so the seam between ramp[0] and ramp[1] is active.
    h = 300
    y = round((0.5 / (len(ramp) - 1)) * (h - 1))  # frac ~ 0.5 in the first seam
    row = [tg.gradient_pixel(ramp, x, y, h) for x in range(600)]
    assert set(row) == {ramp[0], ramp[1]}, f"a seam mixes only its two neighbours, got {set(row)}"


def test_the_dither_is_noise_not_a_rigid_grid():
    # The moire signature is a fixed small period in x (the old ordered dither
    # repeated every 4 px). Value-noise dither has no such period. Mutating
    # gradient_pixel back to an ordered grid pushes a shift's match rate to ~1.0.
    ramp = ["night-0", "stone-0", "sky-2"]
    h = 300
    y = round((0.5 / (len(ramp) - 1)) * (h - 1))
    row = [tg.gradient_pixel(ramp, x, y, h) for x in range(2000)]
    for shift in (1, 2, 4, 8):
        matches = sum(1 for x in range(len(row) - shift) if row[x] == row[x + shift])
        rate = matches / (len(row) - shift)
        assert rate < 0.9, f"shift {shift}: {rate:.2f} of pixels repeat — reads as a grid, not grain"


def main():
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_") and callable(v)]
    for t in tests:
        t()
        print(f"ok  {t.__name__}")
    print(f"\n{len(tests)} checks passed")


if __name__ == "__main__":
    main()
