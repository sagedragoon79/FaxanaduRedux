#!/usr/bin/env python3
"""Synthesizes the prototype sound effects into assets/sfx/*.wav.

Small sfxr-style recipes: oscillators with pitch slides, filtered noise and
envelopes. Deterministic (fixed seed), so re-running gives identical files.
Usage: python3 tools/audio/sfxgen.py
"""
import wave
from pathlib import Path

import numpy as np

RATE = 22050
OUT = Path(__file__).resolve().parents[2] / "assets" / "sfx"
rng = np.random.default_rng(1987)


def t_axis(dur):
    return np.arange(int(RATE * dur)) / RATE


def slide(f0, f1, dur, curve=1.0):
    t = t_axis(dur)
    k = (t / dur) ** curve
    return f0 + (f1 - f0) * k


def osc(freqs, shape="square", duty=0.5):
    phase = np.cumsum(freqs) / RATE % 1.0
    if shape == "square":
        return np.where(phase < duty, 1.0, -1.0)
    if shape == "tri":
        return 4.0 * np.abs(phase - 0.5) - 1.0
    if shape == "saw":
        return 2.0 * phase - 1.0
    return np.sin(2 * np.pi * phase)


def noise(dur):
    return rng.uniform(-1, 1, int(RATE * dur))


def lowpass(x, cutoff):
    # One-pole filter; cutoff may be an array to sweep.
    cutoff = np.broadcast_to(np.asarray(cutoff, dtype=float), x.shape)
    a = 1.0 - np.exp(-2 * np.pi * cutoff / RATE)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a[i] * (x[i] - acc)
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def env(n, attack=0.005, decay_pow=1.5):
    t = np.linspace(0, 1, n)
    a = max(1, int(RATE * attack))
    e = (1 - t) ** decay_pow
    e[:a] *= np.linspace(0, 1, a)
    return e


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def save(name, x, gain=0.8):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    data = (x * 32767).astype(np.int16)
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())


def main():
    d = 0.11
    save("jump", lowpass(osc(slide(260, 520, d, 0.6), "square", 0.25), 5000) * env(int(RATE * d)), 0.55)

    d = 0.2
    whoosh = highpass(noise(d), 1500) * env(int(RATE * d), 0.03, 2.0) * 0.5
    chirp = osc(slide(520, 1040, d, 0.5), "tri") * env(int(RATE * d), 0.002, 2.5)
    save("double_jump", mix(chirp, whoosh), 0.6)

    d = 0.12
    click = highpass(noise(0.03), 2000) * env(int(RATE * 0.03))
    tone = osc(slide(330, 560, d, 0.5), "square", 0.3) * env(int(RATE * d))
    save("wall_jump", mix(lowpass(tone, 4000), click * 0.6), 0.55)

    d = 0.1
    save("land", lowpass(noise(d), slide(1200, 200, d)) * env(int(RATE * d), 0.001, 2.0), 0.7)

    d = 0.06
    save("step", lowpass(noise(d), 900) * env(int(RATE * d), 0.001, 3.0), 0.5)

    d = 0.2
    save("dash", lowpass(highpass(noise(d), 400), slide(800, 5000, d, 0.5)) * env(int(RATE * d), 0.01, 1.2), 0.7)

    d = 0.1
    save("slash", highpass(lowpass(noise(d), slide(7000, 1500, d)), 800) * env(int(RATE * d), 0.004, 1.5), 0.6)

    d = 0.09
    body = osc(slide(180, 70, d), "square", 0.4) * env(int(RATE * d), 0.001, 1.2)
    crunch = lowpass(noise(d), 3000) * env(int(RATE * d), 0.001, 3.0)
    save("hit", mix(lowpass(body, 2500), crunch * 0.8), 0.8)

    d = 0.12
    save("pogo", mix(osc(slide(620, 940, d, 0.3), "tri") * env(int(RATE * d), 0.001, 2.0),
                     highpass(noise(0.03), 3000) * env(int(RATE * 0.03)) * 0.4), 0.6)

    d = 0.08
    save("thorn", lowpass(osc(slide(300, 200, d), "square", 0.2), 2000) * env(int(RATE * d)), 0.5)

    d = 0.35
    rumble = lowpass(noise(d), slide(1500, 150, d)) * env(int(RATE * d), 0.002, 1.3)
    save("break", mix(rumble, lowpass(osc(slide(120, 50, d), "square"), 800) * env(int(RATE * d)) * 0.5), 0.85)

    d = 0.25
    save("hurt", lowpass(osc(slide(420, 140, d, 0.7), "square", 0.5), 3000) * env(int(RATE * d), 0.002, 1.0), 0.6)


if __name__ == "__main__":
    main()
