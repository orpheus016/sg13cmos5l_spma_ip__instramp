#!/usr/bin/env python3
"""Fetch real EEG / EMG / ECG recordings from PhysioNet and cut short excerpts.

No wfdb dependency: the three formats involved (EDF, WFDB fmt 16, WFDB fmt 212)
are parsed with numpy.  Output: one CSV per signal with columns  t_s, v_V
(volts at the electrode, DC removed, time starting at 0), plus MANIFEST.json
with source URLs, windows and SHA-256 of the raw downloads.

Usage:  python3 fetch_data.py [--cache DIR]     (default cache: ./raw, not committed)
"""
import argparse, hashlib, json, os, sys, urllib.request
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PN = "https://physionet.org/files"

SOURCES = {
    "eeg": dict(
        dataset="EEG Motor Movement/Imagery Dataset (eegmmidb) 1.0.0",
        doi="10.13026/C28G6P", record="S001/S001R02.edf",
        note="subject S001, run 2 = eyes closed baseline, channel Oz (alpha rhythm)",
        url=f"{PN}/eegmmidb/1.0.0/S001/S001R02.edf", out="eeg_oz.csv"),
    "emg": dict(
        dataset="Examples of Electromyograms (emgdb) 1.0.0",
        doi="10.13026/C2K03V", record="emg_healthy",
        note="healthy 44 y male, needle EMG, tibialis anterior, gentle dorsiflexion",
        url=f"{PN}/emgdb/1.0.0/emg_healthy.dat", out="emg_tibialis.csv"),
    "ecg": dict(
        dataset="MIT-BIH Arrhythmia Database 1.0.0",
        doi="10.13026/C2F305", record="100",
        note="record 100, lead MLII",
        url=f"{PN}/mitdb/1.0.0/100.dat", out="ecg_mitdb100.csv"),
}


def get(url, cache):
    os.makedirs(cache, exist_ok=True)
    p = os.path.join(cache, url.rsplit("/", 1)[1])
    if not os.path.exists(p):
        print("download", url, file=sys.stderr)
        with urllib.request.urlopen(url, timeout=60) as r, open(p, "wb") as f:
            f.write(r.read())
    return p, hashlib.sha256(open(p, "rb").read()).hexdigest()


def read_edf_channel(path, label):
    """Return (fs, volts) of the EDF channel whose label starts with `label`."""
    b = open(path, "rb").read()
    ns = int(b[252:256])
    nrec = int(b[236:244]); dur = float(b[244:252])
    off = 256
    def fld(w):
        nonlocal off
        v = [b[off + i * w: off + (i + 1) * w].decode().strip() for i in range(ns)]
        off += ns * w
        return v
    labels = fld(16); fld(80); units = fld(8)
    pmin = [float(x) for x in fld(8)]; pmax = [float(x) for x in fld(8)]
    dmin = [float(x) for x in fld(8)]; dmax = [float(x) for x in fld(8)]
    fld(80); nsamp = [int(x) for x in fld(8)]; fld(32)
    idx = [i for i, l in enumerate(labels) if l.strip(". ").lower().startswith(label.lower())]
    if not idx:
        raise SystemExit(f"channel {label} not in {labels}")
    k = idx[0]
    hdr = 256 * (ns + 1)
    data = np.frombuffer(b[hdr:], dtype="<i2").reshape(nrec, sum(nsamp))
    start = sum(nsamp[:k])
    raw = data[:, start:start + nsamp[k]].reshape(-1).astype(float)
    gain = (pmax[k] - pmin[k]) / (dmax[k] - dmin[k])
    phys = (raw - dmin[k]) * gain + pmin[k]
    scale = {"uV": 1e-6, "mV": 1e-3, "V": 1.0}[units[k]]
    return nsamp[k] / dur, phys * scale


def read_fmt16(path, adc_per_mV, baseline, n_sig=1):
    x = np.fromfile(path, dtype="<i2").reshape(-1, n_sig)[:, 0].astype(float)
    return (x - baseline) / adc_per_mV * 1e-3          # volts


def read_fmt212(path, ch, adc_per_mV, baseline, zero):
    """MIT format 212: two 12-bit signed samples packed in 3 bytes (2 channels)."""
    b = np.fromfile(path, dtype=np.uint8)
    b = b[: len(b) // 3 * 3].reshape(-1, 3).astype(np.int32)
    s0 = b[:, 0] | ((b[:, 1] & 0x0F) << 8)
    s1 = b[:, 2] | ((b[:, 1] & 0xF0) << 4)
    s = (s0, s1)[ch]
    s = np.where(s > 2047, s - 4096, s).astype(float)
    return (s - zero) / adc_per_mV * 1e-3


def window(fs, v, t0, dur):
    i0, n = int(t0 * fs), int(dur * fs)
    w = v[i0:i0 + n]
    return w - w.mean()                                  # remove DC / electrode offset


def write_csv(name, fs, v):
    t = np.arange(len(v)) / fs
    np.savetxt(os.path.join(HERE, name), np.c_[t, v], delimiter=",",
               header="t_s,v_V", comments="", fmt=["%.6f", "%.4e"])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", default=os.path.join(HERE, "raw"))
    a = ap.parse_args()
    man = {}

    p, h = get(SOURCES["eeg"]["url"], a.cache)
    fs, v = read_edf_channel(p, "Oz")
    w = window(fs, v, 10.0, 4.0)
    write_csv(SOURCES["eeg"]["out"], fs, w)
    man["eeg"] = dict(SOURCES["eeg"], sha256=h, fs_hz=fs, t0_s=10.0, dur_s=4.0,
                      pp_V=float(np.ptp(w)))

    p, h = get(SOURCES["emg"]["url"], a.cache)
    fs = 4000.0
    v = read_fmt16(p, 10000.0, 0)                        # header: 10000/mV, baseline 0
    # pick the 1 s window with the strongest activity
    step = int(fs / 4); best = max(range(0, len(v) - int(fs), step),
                                   key=lambda i: v[i:i + int(fs)].std())
    w = window(fs, v, best / fs, 1.0)
    write_csv(SOURCES["emg"]["out"], fs, w)
    man["emg"] = dict(SOURCES["emg"], sha256=h, fs_hz=fs, t0_s=best / fs, dur_s=1.0,
                      pp_V=float(np.ptp(w)))

    p, h = get(SOURCES["ecg"]["url"], a.cache)
    fs = 360.0
    v = read_fmt212(p, 0, 200.0, 1024, 1024)             # header: 200/mV, zero 1024
    w = window(fs, v, 5.0, 4.0)
    write_csv(SOURCES["ecg"]["out"], fs, w)
    man["ecg"] = dict(SOURCES["ecg"], sha256=h, fs_hz=fs, t0_s=5.0, dur_s=4.0,
                      pp_V=float(np.ptp(w)))

    json.dump(man, open(os.path.join(HERE, "MANIFEST.json"), "w"), indent=2)
    for k, m in man.items():
        print(f"{k}: fs={m['fs_hz']:.0f} Hz  window {m['t0_s']:.2f}+{m['dur_s']} s  pp={m['pp_V']*1e3:.3f} mV")


if __name__ == "__main__":
    main()
