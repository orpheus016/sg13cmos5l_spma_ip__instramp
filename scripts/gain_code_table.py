#!/usr/bin/env python3
"""Per-gain-code table of pgia_top: schematic vs post-layout (C and R+C), at tt / 27 C / 1.2 V.

  gain_code_table.py [--cell pgia_top] [--schematic <run>] [--c <run>] [--rc <run>] [-o docs/<cell>/cace/gain_codes.md]

scripts/compare_cace.py compares the min / typ / max of two CACE summaries; for pgia_top the schematic run sweeps gain code, corner, supply and
temperature while the post-layout `typ` profile covers a subset, so the "typ" columns are not the same thing. This table takes the same condition
(corner tt, rcorner typ, 27 C, vdd 1.2 V) of every run and lists the ac_gain results per gain code.
Default runs: newest runs/RUN_* with netlist source schematic, newest runs/pex_cace/<cell>/RUN_* and runs/pex_cace_rc/<cell>/RUN_*.
"""
import argparse
import glob
import os
import re
import sys

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VARS = ["A_CL", "A_ERR", "F3DB", "F0DB", "PH_1K", "R_PSEUDO"]    # order of the echo line of cace/templates/pgia_top/ac_gain.sch


def newest(pattern, want_source=None):
    for d in sorted(glob.glob(os.path.join(ROOT, pattern)), key=os.path.getmtime, reverse=True):
        s = os.path.join(d, "summary.md")
        if not os.path.isfile(s):
            continue
        txt = open(s).read()
        if want_source and f"**netlist source**: {want_source}" not in txt:
            continue
        if "ac_gain" in "".join(os.listdir(os.path.join(d, "parameters"))) and want_source != "schematic" or want_source == "schematic" and "pgia_top" in txt:
            return d
    return None


def collect(run):
    """{gain_code: [values]} of the ac_gain runs at tt / typ resistor corner / 27 C / 1.2 V"""
    out = {}
    for d in glob.glob(os.path.join(run, "parameters", "ac_gain", "run_*")):
        try:
            c = yaml.safe_load(open(os.path.join(d, "conditions.yaml")))
            data = glob.glob(os.path.join(d, "ac_gain_*.data"))
            if not data:
                continue
            if str(c.get("corner")) != "tt" or str(c.get("rcorner", "typ")) != "typ" or float(c["temperature"]) != 27 or abs(float(c["vdd"]) - 1.2) > 1e-6:
                continue
            vals = [float(x) for x in open(data[0]).read().split()]
            out[int(c["gain_code"])] = vals
        except Exception:
            continue
    return out


def fmt(v, i):
    if v is None:
        return "-"
    return {0: "%.2f", 1: "%+.2f", 2: "%.0f", 3: "%.3g", 4: "%.2f", 5: "%.3g"}[i] % (v[i] / 1e3 if i == 2 else v[i] / (1e9 if i == 5 else 1))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cell", default="pgia_top")
    ap.add_argument("--schematic")
    ap.add_argument("--c")
    ap.add_argument("--rc")
    ap.add_argument("-o")
    a = ap.parse_args()
    sch = a.schematic or newest("runs/RUN_*", "schematic")
    c = a.c or (sorted(glob.glob(os.path.join(ROOT, "runs", "pex_cace", a.cell, "RUN_*")), key=os.path.getmtime) or [None])[-1]
    rc = a.rc or (sorted(glob.glob(os.path.join(ROOT, "runs", "pex_cace_rc", a.cell, "RUN_*")), key=os.path.getmtime) or [None])[-1]
    if not sch:
        sys.exit("gain_code_table: no schematic run")
    runs = {"schematic": collect(sch), "C": collect(c) if c else {}, "RC": collect(rc) if rc else {}}
    codes = sorted(set().union(*[set(v) for v in runs.values()]))
    rel = lambda p: os.path.relpath(p, ROOT) if p else "-"
    md = [f"# {a.cell}: gain per code, schematic vs post-layout", "",
          f"Condition: corner tt, resistor corner typ, 27 C, vdd 1.2 V, ibias0 1.0 uA (single bias pin, central_bias on chip). Differential input 1 V ac, ac gain at 1 kHz.", "",
          f"* schematic: `{rel(sch)}`", f"* post-layout C (kpex wire capacitance): `{rel(c)}`", f"* post-layout RC (Magic wire R + C): `{rel(rc)}`", "",
          "| Code | Target dB | A_CL schematic | A_CL C | A_CL RC | Δ C | Δ RC | F3DB schematic kHz | F3DB C kHz | F3DB RC kHz | R_pseudo schematic / C / RC GOhm |",
          "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
    for k in codes:
        s, cc, r = runs["schematic"].get(k), runs["C"].get(k), runs["RC"].get(k)
        d = lambda x: "-" if x is None or s is None else "%+.2f" % (x[0] - s[0])
        tgt = "%.2f" % (18.0618 + 6.0206 * k) if k <= 10 else "clamped"
        md.append(f"| {k} | {tgt} | {fmt(s,0)} | {fmt(cc,0)} | {fmt(r,0)} | {d(cc)} | {d(r)} | {fmt(s,2)} | {fmt(cc,2)} | {fmt(r,2)} | {fmt(s,5)} / {fmt(cc,5)} / {fmt(r,5)} |")
    out = a.o or os.path.join(ROOT, "docs", a.cell, "cace", "gain_codes.md")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "w").write("\n".join(md) + "\n")
    print("\n".join(md))
    print(f"\ngain_code_table: wrote {os.path.relpath(out, ROOT)}")


if __name__ == "__main__":
    main()
