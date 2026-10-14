#!/usr/bin/env python3
"""Compare two CACE runs (typically schematic vs post-layout) from their summary.md.

  compare_cace.py <schematic_run_dir> <postlayout_run_dir> [-o out.md] [--threshold 5]

Writes a markdown table (typ / min / max of both runs, delta, delta %, status change) and a bar chart of the typical-value
deltas (PNG next to the markdown). Rows whose delta exceeds --threshold percent, or whose status changes from Pass to
Fail, are flagged. Parameters present in only one run are listed as such.
"""
import argparse
import json
import os
import re
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def num(cell):
    m = re.match(r"^\s*([-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?)\s*(\S*)\s*$", cell.replace("​", ""))
    return (float(m.group(1)), m.group(2)) if m else (None, "")


def read_summary(run):
    path = os.path.join(run, "summary.md")
    if not os.path.isfile(path):
        sys.exit(f"compare_cace: {path} not found")
    src = None
    rows = {}
    for line in open(path):
        m = re.search(r"\*\*netlist source\*\*:\s*(\S+)", line)
        if m:
            src = m.group(1)
        if not line.startswith("|") or "---" in line or "Parameter" in line:
            continue
        c = [x.strip() for x in line.strip().strip("|").split("|")]
        if len(c) < 10:
            continue
        var = c[2]
        status = re.sub(r"[^A-Za-z]", "", c[9])
        if status == "Skip":
            continue
        # the same variable can occur in several parameters (e.g. VOS in dc_op and in the Monte Carlo run):
        # rows are keyed by (variable, occurrence) so the first one is compared with the first one
        k = 0
        while (var, k) in rows:
            k += 1
        rows[(var, k)] = dict(name=c[0], min=num(c[4]), typ=num(c[6]), max=num(c[8]), status=status)
    return src, rows


def fmt(v):
    return "-" if v[0] is None else f"{v[0]:.5g}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("schematic")
    ap.add_argument("postlayout")
    ap.add_argument("-o", "--out", default="postlayout.md")
    ap.add_argument("--threshold", type=float, default=5.0, help="percent, flag bigger typical deltas")
    a = ap.parse_args()

    s_src, s = read_summary(a.schematic)
    p_src, p = read_summary(a.postlayout)
    lines = [f"# Schematic vs post-layout\n",
             f"* schematic run: `{a.schematic}` (netlist source: {s_src})",
             f"* post-layout run: `{a.postlayout}` (netlist source: {p_src})",
             f"* flag threshold: {a.threshold:g} % on the typical value; units as in the CACE summary\n",
             "| Parameter | Var | Unit | Schematic min / typ / max | Post-layout min / typ / max | Δ typ | Δ typ % | Status | Flag |",
             "|---|---|---|---|---|---:|---:|---|---|"]
    bars = []
    jrows = []
    nflag = 0
    for key, r in p.items():
        var = key[0] + (f"#{key[1] + 1}" if key[1] else "")
        q = s.get(key)
        if q is None or r["typ"][0] is None:
            if q is None and r["typ"][0] is not None:
                lines.append(f"| {r['name']} | {var} | {r['typ'][1]} | - | {fmt(r['min'])} / {fmt(r['typ'])} / {fmt(r['max'])} | | | only post-layout | |")
            continue
        if q["typ"][0] is None:
            continue
        d = r["typ"][0] - q["typ"][0]
        pct = 100.0 * d / abs(q["typ"][0]) if q["typ"][0] else None   # typical of 0: no percentage
        flag = ""
        if pct is not None and abs(pct) > a.threshold:
            flag = "Δ"
        if q["status"] == "Pass" and r["status"] == "Fail":
            flag += " NEW FAIL"
        nflag += bool(flag)
        jrows.append(dict(var=var, name=r["name"], unit=r["typ"][1],
                          schematic=dict(min=q["min"][0], typ=q["typ"][0], max=q["max"][0], status=q["status"]),
                          postlayout=dict(min=r["min"][0], typ=r["typ"][0], max=r["max"][0], status=r["status"]),
                          delta=d, delta_pct=pct, flag=flag))
        lines.append(f"| {r['name']} | {var} | {r['typ'][1]} | {fmt(q['min'])} / {fmt(q['typ'])} / {fmt(q['max'])} | "
                     f"{fmt(r['min'])} / {fmt(r['typ'])} / {fmt(r['max'])} | {d:+.4g} | {"n/a" if pct is None else format(pct, "+.2f")} | "
                     f"{q['status']} → {r['status']} | {flag} |")
        if pct is not None:
            bars.append((var, pct))
    for key in s:
        if key not in p and not key[1]:
            lines.append(f"| {s[key]['name']} | {key[0]} | | present | missing | | | only schematic | |")
    lines.append(f"\n{nflag} row(s) flagged.")
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    png = os.path.splitext(a.out)[0] + ".png"
    if bars:
        bars.sort(key=lambda b: abs(b[1]))
        fig, ax = plt.subplots(figsize=(7, 0.3 * len(bars) + 1.2))
        ax.barh([b[0] for b in bars], [b[1] for b in bars],
                color=["#c0392b" if abs(b[1]) > a.threshold else "#2e86c1" for b in bars])
        ax.axvline(0, color="k", lw=0.6)
        ax.set_xlabel("post-layout vs schematic, typical value [%]")
        ax.set_title("Post-layout deltas")
        ax.grid(axis="x", alpha=0.3)
        fig.tight_layout()
        fig.savefig(png, dpi=130)
        lines.append(f"\n![deltas]({os.path.basename(png)})")
    open(a.out, "w").write("\n".join(lines) + "\n")
    json.dump(dict(schematic_run=a.schematic, postlayout_run=a.postlayout, schematic_source=s_src, postlayout_source=p_src,
                   threshold_pct=a.threshold, rows=jrows), open(os.path.splitext(a.out)[0] + ".json", "w"), indent=1)
    print(f"compare_cace: {len(bars)} parameters with a % delta, {nflag} flagged -> {a.out}")


if __name__ == "__main__":
    main()
