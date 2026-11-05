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


def collect(run, param="ac_gain"):
    """{(vin_off in uV, gain_code): [values]} of the runs of one parameter at tt / typ resistor corner / 27 C / 1.2 V"""
    out = {}
    for d in glob.glob(os.path.join(run, "parameters", param, "run_*")):
        try:
            c = yaml.safe_load(open(os.path.join(d, "conditions.yaml")))
            data = glob.glob(os.path.join(d, f"{param}_*.data"))
            if not data:
                continue
            if str(c.get("corner")) != "tt" or str(c.get("rcorner", "typ")) != "typ" or float(c["temperature"]) != 27 or abs(float(c["vdd"]) - 1.2) > 1e-6:
                continue
            vals = [float(x) for x in open(data[0]).read().split()]
            out[(round(float(c.get("vin_off", 0)) * 1e6, 1) + 0.0, int(c["gain_code"]))] = vals
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
    dcs = {"schematic": collect(sch, "dc_op"), "C": collect(c, "dc_op") if c else {}, "RC": collect(rc, "dc_op") if rc else {}}
    offs = sorted(set(k[0] for v in runs.values() for k in v), reverse=True)
    rel = lambda p: os.path.relpath(p, ROOT) if p else "-"
    md = [f"# {a.cell}: gain per code, schematic vs post-layout, without and with the intentional input offset", "",
          "Condition: corner tt, resistor corner typ, 27 C, vdd 1.2 V, ibias0 1.0 uA (single bias pin, central_bias on chip), ac gain at 1 kHz, 1 V differential ac input.", "",
          "The chip has a systematic input-referred offset of about 0.33 mV. Without compensation it is amplified into the output (x2000 .. x8192 at codes 8 to 10) and stage 2 sits at the rail.",
          "`vin_off` is a DC offset on VINP relative to VCM: **0 = chip as built**, **-334.7 uV = intentional offset that nulls the schematic (the value of tb_pgia_top)**, **-903.7 uV = intentional offset that nulls the extracted layout** (found by bisection on code 10, identical for the C and the RC netlist).", "",
          f"* schematic: `{rel(sch)}`", f"* post-layout C (kpex wire capacitance): `{rel(c)}`", f"* post-layout RC (Magic wire R + C): `{rel(rc)}`", ""]
    for off in offs:
        label = {0.0: "as built (vin_off = 0)", -334.7: "schematic null: intentional input offset vin_off = -334.7 uV (value of tb_pgia_top)",
                 -903.7: "extracted-layout null: intentional input offset vin_off = -903.7 uV"}.get(off, f"vin_off = {off:g} uV")
        md += [f"## {label}", "",
               "| Code | Target dB | A_CL schematic | A_CL C | A_CL RC | Δ C | Δ RC | VOUT dc schematic V | F3DB sch / C / RC kHz |", "|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
        for k in sorted(set(k[1] for v in runs.values() for k in v if k[0] == off)):
            s_, c_, r_ = (runs[n].get((off, k)) for n in ("schematic", "C", "RC"))
            d = lambda x: "-" if x is None or s_ is None else "%+.2f" % (x[0] - s_[0])
            tgt = "%.2f" % (18.0618 + 6.0206 * k) if k <= 10 else "clamped"
            vo = lambda n: (lambda v: "-" if v is None else "%.3f" % v[4])(dcs[n].get((off, k)))
            md.append(f"| {k} | {tgt} | {fmt(s_,0)} | {fmt(c_,0)} | {fmt(r_,0)} | {d(c_)} | {d(r_)} | {vo('schematic')} | {fmt(s_,2)} / {fmt(c_,2)} / {fmt(r_,2)} |")
        md.append("")
    out = a.o or os.path.join(ROOT, "docs", a.cell, "cace", "gain_codes.md")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "w").write("\n".join(md) + "\n")
    print("\n".join(md))
    print(f"\ngain_code_table: wrote {os.path.relpath(out, ROOT)}")


if __name__ == "__main__":
    main()
