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

    # The Forepaw smith's hammer on the anvil: a bright, inharmonic ring.
    d = 0.5
    partials = [(880, 1.0, 2.0), (2380, 0.5, 3.0), (3960, 0.3, 4.0), (5470, 0.15, 5.0)]
    ring = mix(*[osc(np.full(int(RATE * d), float(f)), "sine") * env(int(RATE * d), 0.001, k) * g for f, g, k in partials])
    tick = highpass(noise(0.02), 2500) * env(int(RATE * 0.02), 0.0005) * 0.9
    save("anvil", mix(ring, tick), 0.5)

    # The Minecart Rider's brake: iron on iron, a wavering high shriek.
    d = 0.22
    n = int(RATE * d)
    wobble = 1900 + 120 * np.sin(np.linspace(0, 2 * np.pi * 9, n))
    screech = mix(osc(wobble, "square", 0.2) * 0.5, osc(wobble * 1.51, "sine") * 0.4)
    grit = highpass(noise(d), 3000) * 0.5
    save("brake", lowpass(mix(screech, grit), 7000) * env(n, 0.01, 0.8), 0.4)

    # A cart wheel over a rail joint: two quick clacks and a rumble.
    d = 0.14
    n = int(RATE * d)
    clack = np.zeros(n)
    for start in (0, int(RATE * 0.05)):
        k = int(RATE * 0.025)
        clack[start:start + k] += lowpass(noise(0.025), 1800)[:k] * env(k, 0.0005, 2.5)
    rumble = lowpass(osc(np.full(n, 70.0), "square", 0.5), 400) * env(n, 0.005, 1.0) * 0.5
    save("cart", mix(clack, rumble), 0.6)

    # Footsteps per surface (design bible 11): the player plays step_<surface> for
    # the ground underfoot. Each is short, quiet and differs in body and grain.
    d = 0.07
    n = int(RATE * d)
    grit = highpass(noise(d), 2500) * env(n, 0.0005, 4.0) * 0.6
    thump = lowpass(noise(d), 700) * env(n, 0.001, 2.5)
    save("step_stone", mix(thump, grit), 0.5)

    d = 0.09
    n = int(RATE * d)
    save("step_moss", lowpass(noise(d), slide(700, 250, d)) * env(n, 0.012, 2.0), 0.45)

    d = 0.09
    n = int(RATE * d)
    knock = osc(slide(210, 150, d), "tri") * env(n, 0.001, 3.0)
    scuff = lowpass(noise(d), 1600) * env(n, 0.001, 4.0) * 0.5
    save("step_plank", mix(knock, scuff), 0.5)

    d = 0.12
    n = int(RATE * d)
    ring = mix(osc(np.full(n, 1180.0), "sine"), osc(np.full(n, 1730.0), "sine") * 0.6,
               osc(np.full(n, 2610.0), "sine") * 0.3) * env(n, 0.0005, 3.5) * 0.35
    clank = lowpass(noise(0.03), 2200) * env(int(RATE * 0.03), 0.0005, 2.5)
    save("step_iron", mix(clank, ring), 0.45)

    d = 0.12
    n = int(RATE * d)
    save("step_sap", lowpass(noise(d), slide(250, 1400, d, 0.7)) * env(n, 0.02, 1.5), 0.45)

    # A Lantern Ghost's wail before it lunges: a breathy falling moan with a
    # wavering second voice.
    d = 0.55
    n = int(RATE * d)
    vib = 1 + 0.03 * np.sin(2 * np.pi * 6 * t_axis(d))
    moan = osc(slide(620, 380, d, 0.8) * vib, "sine") + osc(slide(930, 560, d, 0.8) * vib * 1.01, "tri") * 0.3
    breath = lowpass(highpass(noise(d), 900), 3000) * 0.35
    save("wail", mix(moan, breath) * env(n, 0.12, 1.2), 0.45)

    # Ripasheiku (bible 8.3). A web strand shot from the vault: an elastic zip
    # that rises and snaps tight.
    d = 0.28
    n = int(RATE * d)
    zip_ = osc(slide(300, 1800, d, 0.4), "tri") * 0.5
    hiss = highpass(lowpass(noise(d), slide(2000, 7000, d, 0.5)), 1200) * 0.6
    save("web_shoot", mix(zip_, hiss) * env(n, 0.01, 1.6), 0.5)

    # The strand catching you: a wet, sticky slap with a low twang.
    d = 0.22
    n = int(RATE * d)
    slap = lowpass(noise(d), 1400) * env(n, 0.001, 3.0)
    twang = osc(slide(190, 150, d) * (1 + 0.04 * np.sin(2 * np.pi * 18 * t_axis(d))), "tri") * env(n, 0.002, 1.5) * 0.7
    save("web_catch", mix(slap, twang), 0.6)

    # Reeling in: the strand creaks under tension, a ratchet of ticks over a
    # rising strain.
    d = 0.9
    n = int(RATE * d)
    ticks = np.zeros(n)
    tick = highpass(noise(0.012), 1800) * env(int(RATE * 0.012), 0.0005, 2.0)
    for k in range(14):
        i = int(k / 14 * (n - len(tick)))
        ticks[i:i + len(tick)] += tick * (0.6 + 0.4 * (k % 2))
    strain = osc(slide(140, 260, d, 0.7), "saw") * 0.18
    save("reel", mix(ticks, lowpass(strain, 900)) * env(n, 0.03, 0.6), 0.5)

    # Many legs on stone: a quick patter of dry clicks, for her climb and the
    # shiver before she drops.
    d = 0.45
    n = int(RATE * d)
    rng = np.random.default_rng(83)
    pat = np.zeros(n)
    click = lowpass(highpass(noise(0.008), 1500), 6000) * env(int(RATE * 0.008), 0.0003, 2.0)
    for k in range(16):
        i = int((k + rng.uniform(-0.3, 0.3)) / 16 * (n - len(click)))
        i = max(0, min(n - len(click), i))
        pat[i:i + len(click)] += click * rng.uniform(0.5, 1.0)
    save("skitter", pat * env(n, 0.02, 0.8), 0.5)

    # A soul-lantern breaking: thin glass and a bright tinkle that rings away.
    d = 0.5
    n = int(RATE * d)
    crack = highpass(noise(0.04), 3000) * env(int(RATE * 0.04), 0.0005, 2.0)
    tinkle = mix(osc(np.full(n, 2350.0), "sine"), osc(np.full(n, 3120.0), "sine") * 0.7,
                 osc(np.full(n, 4410.0), "sine") * 0.4) * env(n, 0.001, 2.5) * 0.35
    save("lantern_break", mix(crack, tinkle), 0.5)

    # Bound fog parting before the Lantern Key: a breathy rising shimmer, like
    # a held breath let go, with a soft bell at its crest.
    d = 0.9
    n = int(RATE * d)
    breath = lowpass(highpass(noise(d), 500), slide(900, 4200, d, 0.6)) * 0.6
    shimmer = mix(osc(slide(660, 990, d, 0.5), "sine"), osc(slide(990, 1485, d, 0.5), "sine") * 0.5) * 0.25
    save("curtain", mix(breath, shimmer) * env(n, 0.25, 1.4), 0.5)


    # A Bog Myconid swelling: a wet, rising creak, like a bladder filling.
    d = 0.55
    n = int(RATE * d)
    creak = lowpass(osc(slide(90, 210, d, 0.7), "square", 0.3), 900) * 0.5
    wet = lowpass(noise(d), slide(300, 1400, d, 0.8)) * 0.4
    save("swell", mix(creak, wet) * env(n, 0.3, 0.6), 0.45)

    # Its burst: a soft, dusty pop and a long hiss of spores settling.
    d = 0.8
    n = int(RATE * d)
    pop = lowpass(noise(0.06), 700) * env(int(RATE * 0.06), 0.001, 2.0)
    hiss = lowpass(highpass(noise(d), 1800), 6000) * env(n, 0.02, 1.6) * 0.5
    save("spore", mix(pop, hiss), 0.55)

    # A fire seal doused by Deluge: a sharp splash and a long hiss of steam.
    d = 0.9
    n = int(RATE * d)
    slap = lowpass(noise(0.05), 2500) * env(int(RATE * 0.05), 0.001, 2.0)
    steam = highpass(lowpass(noise(d), slide(7000, 2500, d, 0.7)), 1200) * env(n, 0.03, 1.2) * 0.6
    save("douse", mix(slap, steam), 0.55)

    # Zorugeriru's bite: a deep growl that snaps shut on a hard bone clack.
    d = 0.45
    n = int(RATE * d)
    growl = lowpass(osc(slide(70, 120, d, 0.5), "square", 0.4), 600) * env(n, 0.05, 1.2) * 0.6
    clack = highpass(noise(0.03), 1500) * env(int(RATE * 0.03), 0.0005, 2.5)
    save("hydra_bite", mix(growl, clack), 0.6)

    # A head breathing mist: a long throaty exhale, darker than the spores.
    d = 1.0
    n = int(RATE * d)
    exhale = lowpass(highpass(noise(d), 200), slide(2400, 700, d, 0.6)) * 0.7
    throat = lowpass(osc(np.full(n, 55.0), "square", 0.5), 300) * 0.25
    save("mist_breath", mix(exhale, throat) * env(n, 0.15, 1.1), 0.5)

    # The coil bursting and the arena flooding: a rushing roar of water.
    d = 1.6
    n = int(RATE * d)
    rush = lowpass(noise(d), slide(500, 2600, d, 0.4)) * 0.8
    rumble = lowpass(noise(d), 160) * 0.8
    save("flood", mix(rush, rumble) * env(n, 0.2, 1.3), 0.6)

    # The hydra's roar (a phase change): three throats, a fifth apart, falling.
    d = 1.1
    n = int(RATE * d)
    roar = mix(*[lowpass(osc(slide(f, f * 0.7, d, 0.6), "saw" if i else "square", 0.3), 1400) * 0.4
                 for i, f in enumerate([98.0, 147.0, 196.0])])
    breath = lowpass(highpass(noise(d), 300), 2500) * 0.35
    save("hydra_roar", mix(roar, breath) * env(n, 0.08, 1.0), 0.65)

    # A bounce-pod throwing you up: a rubbery squelch and a rising, wobbling boing.
    d = 0.45
    n = int(RATE * d)
    squelch = lowpass(noise(0.05), 900) * env(int(RATE * 0.05), 0.001, 2.0)
    t = np.arange(n) / RATE
    boing = osc(slide(180, 520, d, 0.5) * (1 + 0.06 * np.sin(2 * np.pi * 22 * t)), "sine") * env(n, 0.005, 1.4) * 0.6
    save("pod", mix(squelch, boing), 0.55)

    # A Thunder Beetle charging: static crackling louder and faster over a rising buzz.
    d = 0.6
    n = int(RATE * d)
    t = np.arange(n) / RATE
    crackle = highpass(noise(d), 2500) * (np.random.default_rng(55).random(n) < (0.02 + 0.25 * t / d)) * 1.6
    buzz = lowpass(osc(slide(110, 240, d, 0.8), "saw"), 1800) * 0.25 * (t / d)
    save("static", mix(crackle, buzz) * env(n, 0.4, 0.4), 0.45)

    # Its discharge: a hard electric snap and a short sizzling tail.
    d = 0.5
    n = int(RATE * d)
    snap = highpass(noise(0.04), 900) * env(int(RATE * 0.04), 0.0005, 2.0) * 1.2
    sizzle = highpass(lowpass(noise(d), 7000), 1500) * (np.sign(np.sin(2 * np.pi * 60 * np.arange(n) / RATE)) * 0.5 + 0.5)
    hum = osc(np.full(n, 120.0), "square", 0.5) * 0.25
    save("zap", mix(snap, sizzle * 0.5 * env(n, 0.005, 1.6), hum * env(n, 0.005, 2.5)), 0.6)

    # A fireball bursting: a soft whump and a spray of crackling embers.
    d = 0.55
    n = int(RATE * d)
    whump = lowpass(noise(d), slide(1800, 200, d, 0.5)) * env(n, 0.003, 1.8) * 1.1
    pops = highpass(noise(d), 3000) * (np.random.default_rng(57).random(n) < 0.03) * env(n, 0.01, 1.2) * 1.4
    thud = osc(slide(110, 50, d, 0.7), "sine") * env(n, 0.002, 2.2) * 0.5
    save("fire_burst", mix(whump, pops, thud), 0.6)

    # Dry bramble catching: a rush of flame and quick snapping twigs.
    d = 0.7
    n = int(RATE * d)
    rush = lowpass(highpass(noise(d), 400), 3000) * env(n, 0.08, 1.2) * 0.7
    snaps = highpass(noise(d), 2000) * (np.random.default_rng(58).random(n) < 0.05) * 1.5 * env(n, 0.02, 0.8)
    save("crackle", mix(rush, snaps), 0.5)

    # A conduit waking: a rising electric whine that settles into a steady hum.
    d = 0.8
    n = int(RATE * d)
    whine = lowpass(osc(slide(180, 720, d, 0.35), "saw"), 2400) * env(n, 0.01, 1.4) * 0.5
    hum = osc(np.full(n, 120.0), "square", 0.3) * 0.2 * (1 - env(n, 0.3, 1.0))
    crack = highpass(noise(0.05), 1500) * env(int(RATE * 0.05), 0.0005, 2.0)
    save("spark_up", mix(crack, whine, hum), 0.55)

    # A Storm Harpy rearing back: a raw, rising screech with a raspy edge.
    d = 0.5
    n = int(RATE * d)
    t = np.arange(n) / RATE
    cry = osc(slide(900, 1700, d, 0.6) * (1 + 0.03 * np.sin(2 * np.pi * 31 * t)), "saw") * 0.35
    rasp = highpass(lowpass(noise(d), 5000), 1800) * 0.4
    save("screech", lowpass(mix(cry, rasp), 4200) * env(n, 0.06, 1.2), 0.45)

    # Her feathers flung: three quick whips of air.
    d = 0.35
    n = int(RATE * d)
    whip = np.zeros(n)
    for k in range(3):
        m = int(RATE * 0.09)
        start = int(RATE * 0.06 * k)
        part = highpass(lowpass(noise(0.09), slide(5000, 1500, 0.09, 0.5)), 900) * env(m, 0.002, 2.0)
        whip[start:start + m] += part[: n - start]
    save("feather", whip, 0.5)

if __name__ == "__main__":
    main()
