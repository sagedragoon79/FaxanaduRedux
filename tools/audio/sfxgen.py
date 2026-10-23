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

    d = 0.14
    body = lowpass(osc(slide(140, 55, d), "square", 0.45), 2000) * env(int(RATE * d), 0.001, 1.0)
    swish = highpass(lowpass(noise(d), slide(6000, 900, d)), 500) * env(int(RATE * d), 0.004, 1.2)
    save("heavy", mix(swish, body * 0.7), 0.75)

    d = 0.3
    ring = mix(osc(slide(1320, 1250, d), "sine") * env(int(RATE * d), 0.001, 2.2),
               osc(slide(1980, 1900, d), "sine") * env(int(RATE * d), 0.001, 3.0) * 0.5)
    save("parry", mix(ring, highpass(noise(0.04), 3000) * env(int(RATE * 0.04)) * 0.8), 0.7)

    d = 0.12
    save("guard", mix(lowpass(osc(slide(420, 380, d), "square", 0.3), 2500) * env(int(RATE * d), 0.001, 2.0),
                      lowpass(noise(d), 2500) * env(int(RATE * d), 0.001, 3.0) * 0.6), 0.6)

    d = 0.12
    save("coin", mix(osc(np.where(t_axis(d) < 0.04, 1320.0, 1760.0), "square", 0.5) * env(int(RATE * d), 0.001, 1.5)), 0.4)

    d = 0.25
    bubble = osc(slide(300, 900, d, 0.4) + 80 * np.sin(2 * np.pi * 30 * t_axis(d)), "sine") * env(int(RATE * d), 0.01, 1.2)
    save("cast", mix(bubble, lowpass(noise(d), 1800) * env(int(RATE * d), 0.02, 1.0) * 0.4), 0.6)

    d = 0.2
    save("splash", lowpass(highpass(noise(d), 600), slide(5000, 1200, d)) * env(int(RATE * d), 0.002, 1.6), 0.6)

    d = 0.3
    pop = lowpass(osc(slide(240, 60, d, 0.5), "square", 0.5), 1800) * env(int(RATE * d), 0.001, 1.3)
    save("enemy_die", mix(pop, lowpass(noise(d), slide(3000, 300, d)) * env(int(RATE * d), 0.001, 1.6)), 0.75)

    d = 0.4
    buzz = osc(np.full(int(RATE * d), 170.0) + 12 * np.sin(2 * np.pi * 9 * t_axis(d)), "saw")
    save("buzz", lowpass(buzz, 1400) * env(int(RATE * d), 0.05, 0.6), 0.45)

    d = 0.5
    sparkle = sum(osc(np.full(int(RATE * d), f), "sine") * env(int(RATE * d), 0.002 + i * 0.05, 2.0)
                  for i, f in enumerate([880, 1108, 1318, 1760]))
    save("heal", sparkle, 0.5)

    d = 0.3
    save("drink", lowpass(noise(d), 700 + 400 * np.sin(2 * np.pi * 8 * t_axis(d)) ** 2) * env(int(RATE * d), 0.02, 0.8), 0.45)

    d = 0.9
    save("death", lowpass(osc(slide(330, 55, d, 0.6), "square", 0.5), slide(3000, 400, d)) * env(int(RATE * d), 0.005, 0.9), 0.7)

    d = 0.12
    save("fizzle", highpass(lowpass(noise(d), 2500), 800) * env(int(RATE * d), 0.002, 2.0), 0.35)

    d = 0.1
    save("hop", lowpass(osc(slide(180, 320, d), "square", 0.4), 2000) * env(int(RATE * d)), 0.45)

    d = 0.25
    save("hurt", lowpass(osc(slide(420, 140, d, 0.7), "square", 0.5), 3000) * env(int(RATE * d), 0.002, 1.0), 0.6)


    # --- World and UI (M3) ---
    def arpeggio(notes, step, shape="square", duty=0.5, tail=0.25):
        dur = step * len(notes) + tail
        n = int(RATE * dur)
        out = np.zeros(n)
        for i, f in enumerate(notes):
            start = int(RATE * i * step)
            seg = n - start
            out[start:] += osc(np.full(seg, float(f)), shape, duty) * env(seg, 0.002, 2.2)
        return out

    save("item", lowpass(arpeggio([523, 659, 784, 1047, 1319], 0.07, "square", 0.25, 0.5), 5000), 0.5)
    save("secret", lowpass(arpeggio([392, 494, 587, 740, 988], 0.06, "tri", 0.5, 0.4), 6000), 0.55)
    save("save", arpeggio([523, 784, 1047, 1568], 0.09, "sine", 0.5, 0.7), 0.5)

    d = 0.3
    creak = lowpass(osc(slide(90, 70, d) + 6 * np.sin(2 * np.pi * 23 * t_axis(d)), "saw"), 900) * env(int(RATE * d), 0.03, 1.2)
    save("door", mix(creak, lowpass(noise(d), 600) * env(int(RATE * d), 0.01, 2.0) * 0.5), 0.55)

    d = 0.35
    thunk = lowpass(osc(slide(160, 90, 0.12), "square", 0.4), 1500) * env(int(RATE * 0.12), 0.001, 1.5)
    save("chest", mix(thunk, np.concatenate([np.zeros(int(RATE * 0.1)), arpeggio([784, 1047, 1319], 0.05, "square", 0.5, 0.1) * 0.5])), 0.55)

    save("rank", lowpass(arpeggio([392, 523, 659, 784, 1047, 784, 1047], 0.08, "square", 0.5, 0.6), 4500), 0.5)

    # --- Bosses (M3) ---
    d = 1.3
    growl = osc(slide(95, 48, d, 0.8) + 9 * np.sin(2 * np.pi * 31 * t_axis(d)), "saw")
    rasp = lowpass(noise(d), 900 + 500 * np.sin(2 * np.pi * 4 * t_axis(d)) ** 2)
    save("roar", mix(lowpass(growl, 1100), rasp * 0.7) * env(int(RATE * d), 0.08, 0.7), 0.8)

    d = 0.9
    save("rumble", lowpass(noise(d), 180) * env(int(RATE * d), 0.15, 0.6) * 3.0, 0.7)

    d = 0.22
    save("splat", lowpass(noise(d), slide(2400, 300, d)) * env(int(RATE * d), 0.002, 1.8), 0.6)

    d = 0.5
    grains = noise(d) * (np.random.default_rng(7).random(int(RATE * d)) > 0.9)
    save("crumble", mix(lowpass(grains, 2500), lowpass(noise(d), 300) * 0.8) * env(int(RATE * d), 0.003, 1.2), 0.7)

    d = 0.03
    save("blip", lowpass(osc(np.full(int(RATE * d), 880.0), "square", 0.5), 3000) * env(int(RATE * d), 0.001, 1.0), 0.3)

    # A gear spinning up: a ratcheting saw that climbs in pitch and clicks faster.
    d = 0.5
    t = t_axis(d)
    ratchet = (np.sin(2 * np.pi * np.cumsum(slide(14, 60, d)) / RATE) > 0.6).astype(float)
    spin = osc(slide(140, 620, d, 0.7), "saw") * (0.5 + 0.5 * ratchet)
    save("whir", lowpass(spin, slide(900, 3200, d)) * np.minimum(1.0, t / 0.35), 0.4)


    # The Guru names your title: a short heraldic fanfare, square lead over a
    # triangle bass, ending on a held major chord (Faxanadu's rank-up jingle).
    beat = 0.11
    lead = [(523, 1), (523, 1), (523, 1), (659, 3), (587, 1), (659, 1), (784, 6)]
    bass = [(131, 3), (165, 3), (196, 6)]
    def line(notes, shape, duty, decay):
        n = int(RATE * beat * sum(b for _, b in notes)) + int(RATE * 0.5)
        out = np.zeros(n)
        pos = 0
        for f, b in notes:
            seg = n - pos
            out[pos:] += osc(np.full(seg, float(f)), shape, duty) * env(seg, 0.004, decay) * (1.0 if b < 6 else 1.3)
            pos += int(RATE * beat * b)
        return out
    a = line(lead, "square", 0.25, 1.6)
    b = line(bass, "tri", 0.5, 0.9)
    m = max(len(a), len(b))
    a = np.pad(a, (0, m - len(a)))
    b = np.pad(b, (0, m - len(b)))
    chord_start = int(RATE * beat * 9)
    chord = np.zeros(m)
    seg = m - chord_start
    for f in (392, 523, 659):
        chord[chord_start:] += osc(np.full(seg, float(f)), "square", 0.5) * env(seg, 0.01, 1.2) * 0.3
    save("title", lowpass(mix(a, b * 0.8, chord), 5000), 0.55)

if __name__ == "__main__":
    main()
