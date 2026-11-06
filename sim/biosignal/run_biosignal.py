#!/usr/bin/env python3
"""Run the biosignal transient matrix through ngspice and analyse it.

  python3 run_biosignal.py [--jobs N] [--only SUBSTR] [--no-run]

For every case (signal, netlist, offset, gain code) it
  1. writes work/<case>.cir with gen_tb.make_deck, runs ngspice (skipped if work/<case>.txt exists),
  2. resamples the output on the source's own time grid and stores results/<case>.csv  (t_s, vin_V, vout_V),
  3. computes fidelity metrics and writes results/summary.json.

Offsets: "none" = vin_off 0 (chip as built);  "null" = the intentional input offset that cancels the
systematic input-referred offset of that netlist (-334.7 uV schematic, -903.7 uV extracted layout).
"""
import argparse, json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
import numpy as np
import gen_tb

HERE = os.path.dirname(os.path.abspath(__file__))
WORK = os.path.join(HERE, "work")
RES = os.path.join(HERE, "results")
SIGNALS = {  # key: (csv, primary gain code, max internal step, label)
    "eeg": ("eeg_oz.csv", 8, 500e-6, "EEG (Oz, eyes closed)"),
    "emg": ("emg_tibialis.csv", 5, 100e-6, "EMG (tibialis anterior)"),
    "ecg": ("ecg_mitdb100.csv", 5, 200e-6, "ECG (MIT-BIH 100, MLII)"),
}
NETS = ["schematic", "pex_c", "pex_rc"]
SWEEP_CODES = [0, 2, 4, 6, 8, 10]          # schematic, nulled: how the output scales with gain code
EXTRA = {"emg": [6], "ecg": [6]}           # one code higher on all netlists: shows output compression at the top of the swing
VOUT_LO, VOUT_HI = 0.05, 0.98              # V, output considered clipped outside this range (VOUT saturates near 0.99 V)
SETTLE = 0.05                              # s, excluded from the metrics


OFFSETS = ("null",)      # ideal input-offset null only (add "none" with --with-none for the full study)


def cases():
    out = []
    for sig, (_, code, _, _) in SIGNALS.items():
        for net in NETS:
            for off in OFFSETS:
                out.append((sig, net, off, code))
        for net in NETS:
            for off in OFFSETS:
                for c in EXTRA.get(sig, []):
                    out.append((sig, net, off, c))
        for c in SWEEP_CODES:
            if c != code and c not in EXTRA.get(sig, []):
                out.append((sig, "schematic", "null", c))
    return out


def name(c):
    sig, net, off, code = c
    return f"{sig}_{net}_{off}_c{code}"


def run_case(c):
    sig, net, off, code = c
    csv, _, tmax, _ = SIGNALS[sig]
    txt = os.path.join(WORK, name(c) + ".txt")
    if os.path.exists(txt):
        return c
    vin_off = gen_tb.VIN_OFF_NULL[net] if off == "null" else 0.0
    deck = gen_tb.make_deck(csv, code, net, vin_off, txt, tmax=tmax)
    cir = os.path.join(WORK, name(c) + ".cir")
    open(cir, "w").write(deck)
    r = subprocess.run(["ngspice", "-b", cir], capture_output=True, text=True, env=dict(os.environ, PDK="ihp-sg13cmos5l", PDK_ROOT="/foss/pdks", OMP_NUM_THREADS="1"))
    open(os.path.join(WORK, name(c) + ".log"), "w").write(r.stdout[-4000:] + r.stderr[-2000:])
    if not os.path.exists(txt):
        print("FAILED", name(c), file=sys.stderr)
    else:
        print("done", name(c), flush=True)
    return c


def analyse(c):
    sig, net, off, code = c
    txt = os.path.join(WORK, name(c) + ".txt")
    if not os.path.exists(txt):
        return None
    d = np.loadtxt(txt)
    ts, vout, idd = d[:, 0], d[:, 1], d[:, 5]
    t, x = gen_tb.load_signal(SIGNALS[sig][0])
    if ts[-1] < 0.98 * t[-1]:               # ngspice aborted (timestep too small) - input driven far into overdrive
        print(f"ABORTED at {ts[-1]:.3f} s of {t[-1]:.1f} s: {name(c)} (skipped)", file=sys.stderr)
        return None
    y = np.interp(t, ts, vout)
    idd_uA = float(-np.interp(t, ts, idd).mean() * 1e6)
    m = t >= SETTLE
    xm, ym = x[m] - x[m].mean(), y[m] - y[m].mean()
    g = float(np.dot(xm, ym) / np.dot(xm, xm))                    # least-squares gain
    ideal = 8.0 * 2 ** code
    res = ym - g * xm
    corr = float(np.corrcoef(xm, ym)[0, 1])
    clipped = float(np.mean((y[m] < VOUT_LO) | (y[m] > VOUT_HI)))
    rec = dict(case=name(c), signal=sig, net=net, offset=off, code=code,
               vin_off_uV=(gen_tb.VIN_OFF_NULL[net] * 1e6 if off == "null" else 0.0),
               gain_ideal=ideal, gain_eff=g, gain_err_dB=float(20 * np.log10(abs(g) / ideal)) if g else None,
               corr=corr, nrmse=float(np.sqrt(np.mean(res ** 2)) / np.sqrt(np.mean((g * xm) ** 2))),
               vout_mean=float(y[m].mean()), vout_min=float(y[m].min()), vout_max=float(y[m].max()),
               vin_pp_uV=float(np.ptp(x) * 1e6), vout_pp_mV=float(np.ptp(y[m]) * 1e3),
               clipped_frac=clipped, idd_uA=idd_uA)
    os.makedirs(RES, exist_ok=True)
    np.savetxt(os.path.join(RES, name(c) + ".csv"), np.c_[t, x, y], delimiter=",",
               header="t_s,vin_V,vout_V", comments="", fmt=["%.5f", "%.4e", "%.5f"])
    return rec


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--jobs", type=int, default=14, help="parallel ngspice processes (each is single-threaded)")
    ap.add_argument("--only", default="")
    ap.add_argument("--no-run", action="store_true")
    ap.add_argument("--with-none", action="store_true", help="also run the unnulled (vin_off = 0) cases")
    a = ap.parse_args()
    global OFFSETS
    if a.with_none:
        OFFSETS = ("none", "null")
    os.makedirs(WORK, exist_ok=True)
    todo = [c for c in cases() if a.only in name(c)]
    # slowest (RC) first so they overlap with everything else
    todo.sort(key=lambda c: {"pex_rc": 0, "pex_c": 1, "schematic": 2}[c[1]])
    if not a.no_run:
        with ThreadPoolExecutor(a.jobs) as ex:
            list(ex.map(run_case, todo))
    recs = [r for r in (analyse(c) for c in cases()) if r]
    json.dump(dict(vcm=gen_tb.VCM, vdd=gen_tb.VDD, ibias_uA=gen_tb.IB * 1e6,
                   signals={k: dict(file=v[0], primary_code=v[1], label=v[3]) for k, v in SIGNALS.items()},
                   runs=recs), open(os.path.join(RES, "summary.json"), "w"), indent=1)
    for r in recs:
        print(f"{r['case']:28s} g={r['gain_eff']:8.1f} ({r['gain_err_dB']:+5.1f} dB) corr={r['corr']:.3f} "
              f"nrmse={r['nrmse']:.3f} vout=[{r['vout_min']:.2f},{r['vout_max']:.2f}] clip={r['clipped_frac']*100:4.1f}%")


if __name__ == "__main__":
    main()
