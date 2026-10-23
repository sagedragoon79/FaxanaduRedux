#!/usr/bin/env python3
"""Synthesizes placeholder music loops and ambience beds into assets/music/*.ogg.

The design bible (13.1, 13.3) has the real soundtrack coming from Sean's music
library. Until a track is supplied, these stand in: small seeded arrangements
(pads, plucked arpeggios, bass, a lead melody built from a motif, soft drums)
rendered as seamless loops. Drop a real file with the same name (any of .ogg,
.mp3 or .wav) into assets/music/ and the game plays that instead.

Needs numpy and ffmpeg (for Ogg Vorbis). Deterministic: same seed, same files.
Usage: python3 tools/audio/musicgen.py [track ...]
"""
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

RATE = 32000
OUT = Path(__file__).resolve().parents[2] / "assets" / "music"

NOTE = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}
SCALES = {
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "dorian": [0, 2, 3, 5, 7, 9, 10],
    "major": [0, 2, 4, 5, 7, 9, 11],
    "lydian": [0, 2, 4, 6, 7, 9, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
}


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


# --- DSP -----------------------------------------------------------------------------
def fft_filter(x, low=None, high=None, order=4):
    """Smooth low/high-pass in the frequency domain (fast for long buffers)."""
    n = len(x)
    if n == 0:
        return x
    size = 1 << (n - 1).bit_length()
    spec = np.fft.rfft(x, size)
    f = np.fft.rfftfreq(size, 1 / RATE)
    gain = np.ones_like(f)
    if low:
        gain /= np.sqrt(1 + (f / low) ** (2 * order))
    if high:
        gain *= 1 - 1 / np.sqrt(1 + (f / high) ** (2 * order))
    return np.fft.irfft(spec * gain, size)[:n]


def adsr(n, a=0.01, d=0.1, s=0.7, r=0.1):
    e = np.full(n, s)
    na, nd, nr = int(a * RATE), int(d * RATE), int(r * RATE)
    na = min(na, n)
    e[:na] = np.linspace(0, 1, na)
    nd = min(nd, n - na)
    e[na:na + nd] = np.linspace(1, s, nd)
    nr = min(nr, n)
    if nr:
        e[n - nr:] *= np.linspace(1, 0, nr)
    return e


def phase(freq, n, vib=0.0, vib_rate=5.0):
    t = np.arange(n) / RATE
    f = freq * (1 + vib * np.sin(2 * np.pi * vib_rate * t))
    return np.cumsum(f) / RATE % 1.0


def wave_of(shape, ph, duty=0.5):
    if shape == "square":
        return np.where(ph < duty, 1.0, -1.0)
    if shape == "tri":
        return 4.0 * np.abs(ph - 0.5) - 1.0
    if shape == "saw":
        return 2.0 * ph - 1.0
    return np.sin(2 * np.pi * ph)


# --- Instruments (each returns a mono note buffer) --------------------------------
def pad(freq, dur):
    n = int(dur * RATE)
    x = sum(wave_of("saw", phase(freq * d, n)) for d in (0.996, 1.0, 1.004)) / 3
    x += 0.5 * wave_of("sine", phase(freq / 2, n))
    return fft_filter(x, low=900) * adsr(n, 0.6, 0.4, 0.8, 0.8) * 0.35


def pluck(freq, dur, bright=1800):
    n = int(dur * RATE)
    x = wave_of("square", phase(freq, n), 0.3)
    e = np.exp(-np.arange(n) / RATE * 7.0)
    return fft_filter(x * e, low=bright) * adsr(n, 0.003, 0.0, 1.0, 0.03) * 0.28


def bass(freq, dur):
    n = int(dur * RATE)
    x = wave_of("tri", phase(freq, n)) + 0.3 * wave_of("square", phase(freq, n), 0.5)
    return fft_filter(x, low=700) * adsr(n, 0.005, 0.08, 0.75, 0.04) * 0.45


def lead(freq, dur):
    n = int(dur * RATE)
    x = wave_of("square", phase(freq, n, vib=0.006, vib_rate=5.5), 0.25)
    return fft_filter(x, low=2200) * adsr(n, 0.02, 0.15, 0.6, 0.12) * 0.2


def bell(freq, dur):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    mod = np.sin(2 * np.pi * freq * 3.5 * t) * 2.0 * np.exp(-t * 3)
    x = np.sin(2 * np.pi * freq * t + mod)
    return x * np.exp(-t * 2.2) * adsr(n, 0.002, 0.0, 1.0, 0.05) * 0.3


def kick(dur=0.3):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    f = 45 + 110 * np.exp(-t * 30)
    return np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 9) * 0.8


def snare(rng, dur=0.2):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    x = fft_filter(rng.uniform(-1, 1, n), low=6000, high=900) * np.exp(-t * 18)
    return (x + 0.4 * np.sin(2 * np.pi * 190 * t) * np.exp(-t * 25)) * 0.5


def hat(rng, dur=0.05):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    return fft_filter(rng.uniform(-1, 1, n), high=7000) * np.exp(-t * 60) * 0.12


def shaker(rng, dur=0.08):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    return fft_filter(rng.uniform(-1, 1, n), high=4500, low=9000) * np.sin(np.pi * t / dur) * 0.18


# --- Arrangement -------------------------------------------------------------------------
class Song:
    def __init__(self, bpm, bars, beats=4):
        self.beat = 60.0 / bpm
        self.bar = self.beat * beats
        self.beats = beats
        self.length = int(self.bar * bars * RATE)
        # Render a little past the loop; the overflow wraps to the start.
        self.buf = np.zeros((self.length + RATE * 4, 2))

    def add(self, note, at_beats, pan=0.0, gain=1.0):
        i = int(at_beats * self.beat * RATE)
        left, right = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
        end = min(i + len(note), len(self.buf))
        self.buf[i:end, 0] += note[: end - i] * left * gain * 1.414
        self.buf[i:end, 1] += note[: end - i] * right * gain * 1.414

    def render(self, reverb=0.25):
        out = self.buf.copy()
        if reverb > 0:
            rng = np.random.default_rng(3)
            n = int(1.8 * RATE)
            t = np.arange(n) / RATE
            for ch in range(2):
                ir = rng.uniform(-1, 1, n) * np.exp(-t * 3.2)
                ir = fft_filter(ir, low=3500)
                ir[0] = 0
                size = 1 << (len(out) + n).bit_length()
                wet = np.fft.irfft(np.fft.rfft(out[:, ch], size) * np.fft.rfft(ir, size), size)[: len(out)]
                out[:, ch] += wet / (np.sqrt(np.sum(ir ** 2)) + 1e-9) * reverb * 0.6
        loop = out[: self.length].copy()
        tail = out[self.length:]
        loop[: len(tail)] += tail[: self.length]
        peak = np.max(np.abs(loop)) + 1e-9
        return loop / peak * 0.85


def chord_tones(root_midi, scale, degree, count=3):
    """Scale-degree triad (or more) starting at `degree` (0-based)."""
    out = []
    for k in range(count):
        d = degree + 2 * k
        out.append(root_midi + scale[d % 7] + 12 * (d // 7))
    return out


def scale_note(root_midi, scale, degree):
    return root_midi + scale[degree % 7] + 12 * (degree // 7)


def motif(rng, length_beats, chord_degree, density=0.6):
    """A rhythm and contour on scale degrees: [(beat, dur, degree)]."""
    notes = []
    beat = 0.0
    deg = chord_degree + rng.choice([0, 2, 4])
    while beat < length_beats:
        dur = rng.choice([0.5, 0.5, 1.0, 1.0, 1.5, 2.0]) if rng.random() < density else 1.0
        if beat + dur > length_beats:
            dur = length_beats - beat
        rest = rng.random() < 0.18
        if not rest:
            notes.append((beat, dur, deg))
        step = rng.choice([-2, -1, -1, 1, 1, 2, 3, -3])
        deg = max(chord_degree - 3, min(chord_degree + 7, deg + step))
        beat += dur
    return notes


def melody(song, rng, root, scale, prog, inst, start_bar=0, octave=12, pan=0.2, gain=1.0, density=0.6):
    """A-A'-B-A form over the progression, two bars per phrase."""
    bars = len(prog)
    phrase_a = motif(rng, song.beats * 2, prog[0], density)
    phrase_b = motif(rng, song.beats * 2, prog[len(prog) // 2 % len(prog)], density)
    for p in range(start_bar, bars, 2):
        section = (p // 2) % 4
        notes = phrase_b if section == 2 else phrase_a
        shift = prog[p % bars] - prog[0] if section != 2 else 0
        for beat, dur, deg in notes:
            d = deg + (shift if section == 1 else 0)
            m = scale_note(root + octave, scale, d)
            song.add(inst(midi_hz(m), dur * song.beat * 0.95), p * song.beats + beat, pan, gain)


def write_ogg(name, stereo):
    OUT.mkdir(parents=True, exist_ok=True)
    data = (np.clip(stereo, -1, 1) * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / "x.wav"
        with wave.open(str(wav), "wb") as w:
            w.setnchannels(2)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(data.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "4",
                        str(OUT / f"{name}.ogg")], check=True)


# --- Tracks ------------------------------------------------------------------------------
def track_title():
    rng = np.random.default_rng(11)
    s = Song(bpm=68, bars=16)
    root, scale = 50, SCALES["minor"]  # D minor
    prog = [0, 5, 3, 4, 0, 5, 6, 4] * 2
    for b, deg in enumerate(prog):
        for m in chord_tones(root, scale, deg):
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.4, 0.4), 0.8)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.bar * 0.95), b * 4, 0, 0.6)
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=12, pan=0.3, gain=0.9, density=0.3)
    return s.render(reverb=0.5)


def track_eolis():
    rng = np.random.default_rng(23)
    s = Song(bpm=92, bars=16)
    root, scale = 53, SCALES["lydian"]  # F lydian: warm, a little wistful
    prog = [0, 4, 5, 3, 0, 4, 1, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, 0.0, 0.45)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 1.9), b * 4, 0, 0.8)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg + 4)), s.beat * 1.9), b * 4 + 2, 0, 0.6)
        arp = tones + [tones[0] + 12]
        for k in range(8):
            m = arp[[0, 1, 2, 3, 2, 1, 2, 3][k]] + 12
            s.add(pluck(midi_hz(m), s.beat * 0.5), b * 4 + k * 0.5, -0.35, 0.55)
        for k in range(4):
            s.add(shaker(rng), b * 4 + k + 0.5, 0.3, 0.8)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=12, pan=0.15, gain=0.8)
    return s.render(reverb=0.3)


def track_trunk():
    rng = np.random.default_rng(37)
    s = Song(bpm=100, bars=16)
    root, scale = 45, SCALES["dorian"]  # A dorian: green, mysterious
    prog = [0, 0, 6, 3, 0, 0, 5, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.5, 0.5), 0.4)
        for k in range(8):
            if k in (0, 3, 6):
                s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 0.9), b * 4 + k * 0.5, 0, 0.8)
        for k in range(8):
            m = tones[[0, 2, 1, 2, 0, 2, 1, 2][k]] + 12
            s.add(pluck(midi_hz(m), s.beat * 0.5, bright=1600), b * 4 + k * 0.5, 0.4, 0.45)
        # A hollow hand drum.
        for k, g in [(0, 1.0), (1.5, 0.5), (2.5, 0.7)]:
            s.add(kick(0.25) * 0.5, b * 4 + k, 0, g)
        if b % 2:
            s.add(snare(rng) * 0.4, b * 4 + 3, 0.2)
    melody(s, rng, root, scale, prog, bell, start_bar=8, octave=24, pan=-0.2, gain=0.7, density=0.4)
    return s.render(reverb=0.45)


def anvil(rng, freq=1200.0, dur=0.6):
    """A struck anvil: inharmonic partials that ring and die away."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.zeros(n)
    for ratio, g in [(1.0, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12)]:
        out += np.sin(2 * np.pi * freq * ratio * t) * g * np.exp(-t * (6 + ratio * 2))
    out += fft_filter(rng.uniform(-1, 1, n), high=3000) * np.exp(-t * 60) * 0.4
    return out * 0.3


def track_tower():
    rng = np.random.default_rng(41)
    s = Song(bpm=92, bars=16)
    root, scale = 43, SCALES["phrygian"]  # G phrygian: dark, metal, dwarven
    prog = [0, 0, 1, 0, 0, 6, 1, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones[:2]:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.4, 0.4), 0.35)
        # A plodding bass in fifths, like a hauling chant.
        for k in range(4):
            off = 0 if k % 2 == 0 else 4
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg + off)), s.beat * 0.85), b * 4 + k, 0, 0.8)
        # Hammer on the one and three, an anvil ring on the four.
        s.add(kick(0.3) * 0.7, b * 4, 0, 1.0)
        s.add(kick(0.3) * 0.5, b * 4 + 2, 0, 0.8)
        s.add(anvil(rng, rng.choice([1180.0, 1240.0])), b * 4 + 3, rng.uniform(-0.6, 0.6), 0.5)
        for k in range(8):
            s.add(hat(rng) * 0.5, b * 4 + k * 0.5, 0.3, 0.3 if k % 2 else 0.5)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=12, pan=-0.15, gain=0.55, density=0.5)
    melody(s, rng, root, scale, prog, bell, start_bar=8, octave=24, pan=0.3, gain=0.35, density=0.3)
    return s.render(reverb=0.5)


def track_boss():
    rng = np.random.default_rng(51)
    s = Song(bpm=148, bars=16)
    root, scale = 40, SCALES["phrygian"]  # E phrygian: menace
    prog = [0, 0, 1, 0, 0, 0, 5, 6] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg) + (12 if k % 4 == 3 else 0)), s.beat * 0.45), b * 4 + k * 0.5, 0, 0.9)
        for k in (0, 1.5, 3):
            for m in tones:
                s.add(pluck(midi_hz(m + 12), s.beat * 0.4, bright=2200), b * 4 + k, rng.uniform(-0.3, 0.3), 0.35)
        for k in range(4):
            s.add(kick(), b * 4 + k, 0, 0.9)
            s.add(hat(rng), b * 4 + k + 0.5, 0.3)
        s.add(snare(rng), b * 4 + 1, -0.1)
        s.add(snare(rng), b * 4 + 3, -0.1)
    melody(s, rng, root, scale, prog, lead, start_bar=0, octave=24, pan=0.1, gain=0.9, density=0.8)
    return s.render(reverb=0.2)


def amb_trunk():
    rng = np.random.default_rng(71)
    dur = 24.0
    n = int(dur * RATE)
    out = np.zeros((n + RATE * 3, 2))
    rumble = fft_filter(rng.uniform(-1, 1, len(out)), low=120) * 3.0
    out[:, 0] += rumble
    out[:, 1] += rumble
    # Drips: short sine blips falling in pitch, at random places.
    for _ in range(26):
        i = rng.integers(0, n)
        m = int(0.12 * RATE)
        t = np.arange(m) / RATE
        f = rng.uniform(900, 1700) * np.exp(-t * 6)
        drip = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 30) * rng.uniform(0.2, 0.5)
        pan = rng.uniform(-1, 1)
        out[i:i + m, 0] += drip * (1 - pan) / 2
        out[i:i + m, 1] += drip * (1 + pan) / 2
    # Creaks of the living wood.
    for _ in range(5):
        i = rng.integers(0, n)
        m = int(rng.uniform(0.6, 1.2) * RATE)
        t = np.arange(m) / RATE
        f = rng.uniform(70, 110) + 8 * np.sin(2 * np.pi * 23 * t)
        creak = fft_filter(wave_of("saw", np.cumsum(f) / RATE % 1.0), low=700) * np.sin(np.pi * t / t[-1]) * 0.25
        out[i:i + m, :] += creak[:, None]
    loop = out[:n].copy()
    loop[: len(out) - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.6


def amb_eolis():
    rng = np.random.default_rng(73)
    dur = 20.0
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    wind = fft_filter(rng.uniform(-1, 1, n), low=500, high=80)
    swell = 0.6 + 0.4 * np.sin(2 * np.pi * t / dur) * np.sin(2 * np.pi * 3 * t / dur)
    left = wind * swell
    right = np.roll(wind, RATE // 3) * swell
    out = np.stack([left, right], axis=1)
    return out / (np.max(np.abs(out)) + 1e-9) * 0.5


def amb_tower():
    """Machinery deep in the walls: a low hum, distant hammer strikes, chain rattles."""
    rng = np.random.default_rng(79)
    dur = 22.0
    n = int(dur * RATE)
    t_all = np.arange(n + RATE * 3) / RATE
    out = np.zeros((n + RATE * 3, 2))
    hum = np.sin(2 * np.pi * 55 * t_all) * 0.15 + fft_filter(rng.uniform(-1, 1, len(out)), low=200) * 1.5
    hum *= 0.8 + 0.2 * np.sin(2 * np.pi * t_all / 5.5)
    out[:, 0] += hum
    out[:, 1] += hum
    for _ in range(9):
        i = rng.integers(0, n)
        hit = anvil(rng, rng.uniform(700, 1300), 1.2) * rng.uniform(0.15, 0.35)
        hit = fft_filter(hit, low=2000)
        pan = rng.uniform(-1, 1)
        out[i:i + len(hit), 0] += hit * (1 - pan) / 2
        out[i:i + len(hit), 1] += hit * (1 + pan) / 2
    for _ in range(4):
        i = rng.integers(0, n)
        m = int(0.7 * RATE)
        tt = np.arange(m) / RATE
        rattle = fft_filter(rng.uniform(-1, 1, m), high=2500, low=7000) * (np.sin(2 * np.pi * 18 * tt) > 0.3)
        rattle = rattle * np.sin(np.pi * tt / tt[-1]) * 0.15
        out[i:i + m, :] += rattle[:, None]
    loop = out[:n].copy()
    loop[: len(out) - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.55


TRACKS = {
    "title": track_title,
    "eolis": track_eolis,
    "trunk": track_trunk,
    "tower": track_tower,
    "boss": track_boss,
    "amb_trunk": amb_trunk,
    "amb_eolis": amb_eolis,
    "amb_tower": amb_tower,
}


def main():
    names = sys.argv[1:] or list(TRACKS)
    for name in names:
        write_ogg(name, TRACKS[name]())
        print("wrote", name)


if __name__ == "__main__":
    main()
