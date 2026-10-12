#!/usr/bin/env python3
"""Build docs/<cell>/cace/README.md from the latest CACE run.

usage: scripts/make_readme.py [cell=ota_cmos5l] [runs/RUN_xxx]

What CACE already writes (design md, symbol/schematic svg, results table, xy plots) is embedded
as-is. This script only adds what CACE does not provide:
  * PVT worst-case conditions (min/max with corner, vdd, T) and spec fail counts
  * Monte Carlo statistics per corner x temperature (mean, sigma, mean +- 3 sigma)
  * Monte Carlo spread images (CACE's histograms overlay all corners and are not unit-scaled)
Values are read from the raw *.data files (SI base units) and converted with CACE's own
spice_unit_unconvert, so display units match the yaml.
"""
import datetime
import glob
import os
import re
import statistics as st
import subprocess
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import yaml
from cace.common.spiceunits import spice_unit_unconvert

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CELL = sys.argv[1] if len(sys.argv) > 1 else "ota_cmos5l"
RUNS = sorted(glob.glob(f"{ROOT}/runs/RUN_*"))
RUN = sys.argv[2] if len(sys.argv) > 2 else (RUNS[-1] if RUNS else None)
if not RUN:
    sys.exit("no CACE run found in runs/ - run scripts/run_cace.sh first")

DS = yaml.safe_load(open(f"{ROOT}/cace/{CELL}.yaml"))
DOC = os.path.join(ROOT, DS["paths"]["documentation"])
os.makedirs(DOC, exist_ok=True)
TCOL = {-40: "#3b6fb6", 27: "#6a6a6a", 85: "#c0392b"}


_SCALE = {}


def conv(unit, value):
    """SI value -> display unit of the yaml. The factor comes from CACE's own spice_unit_unconvert
    (regex heavy, so it is evaluated once per unit; all supported conversions are linear)."""
    if unit not in _SCALE:
        _SCALE[unit] = float(spice_unit_unconvert((str(unit), 1.0)))
    return value * _SCALE[unit]


def read(d):
    f = glob.glob(d + "/*.data")
    return [float(x) for x in open(f[0]).read().split()] if f else None


def cond(d):
    return yaml.safe_load(open(d + "/conditions.yaml")) or {}


def limit(spec, which):
    v = spec.get(which, {}).get("value", "any")
    return None if v == "any" else float(v)


def tool_of(p):
    t = p.get("tool")
    return t.get("ngspice") if isinstance(t, dict) else None


def fmt(x):
    return f"{x:.4g}"


def known_limits(var):
    """first non-'any' spec limits of a variable name over all parameters (for reference lines in MC plots)"""
    for p in DS["parameters"].values():
        sp = p.get("spec", {}).get(var)
        if sp and tool_of(p) and tool_of(p).get("collate") != "iterations":
            lo, hi = limit(sp, "minimum"), limit(sp, "maximum")
            if lo is not None or hi is not None:
                return lo, hi
    return None, None


# ----------------------------------------------------------------------------- PVT worst case
def pvt_section(pname, p):
    tool, specs = tool_of(p), p["spec"]
    rows = []
    for d in sorted(glob.glob(f"{RUN}/parameters/{pname}/run_*")):
        v = read(d)
        if v is None:
            continue
        c = cond(d)
        rows.append((c.get("corner"), c.get("vdd"), c.get("temperature"), v))
    if not rows:
        return ""
    out = [f"\n### {pname} - {p.get('display', '')}\n", f"{len(rows)} runs.\n",
           "| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec | fails |",
           "|---|---|---|---|---|---|---|"]
    for i, name in enumerate(tool["variables"]):
        if not name or name == "null":
            continue
        u = specs[name]["unit"]
        vals = [conv(u, r[3][i]) for r in rows]
        lo_i, hi_i = vals.index(min(vals)), vals.index(max(vals))
        lo, hi = limit(specs[name], "minimum"), limit(specs[name], "maximum")
        spec = " ".join(s for s in [f">= {lo:g}" if lo is not None else "", f"<= {hi:g}" if hi is not None else ""] if s) or "any"
        bad = sum(1 for x in vals if (lo is not None and x < lo) or (hi is not None and x > hi))
        fails = f"**{bad}/{len(rows)}**" if bad else ("0" if spec != "any" else "-")
        a, b = rows[lo_i], rows[hi_i]
        out.append(f"| {name} [{u}] | {fmt(vals[lo_i])} | {a[0]}, {a[1]} V, {a[2]} C | {fmt(vals[hi_i])} | {b[0]}, {b[1]} V, {b[2]} C | {spec} | {fails} |")
    return "\n".join(out) + "\n"


# ----------------------------------------------------------------------------- Monte Carlo
def mc_samples(pname, variables):
    """{var: {(corner, T): [values in SI]}} from parameters/<mc>/run_<combo>/run_<iter>"""
    data = {}
    for combo in glob.glob(f"{RUN}/parameters/{pname}/run_*"):
        for it in glob.glob(combo + "/run_*"):
            v = read(it)
            if v is None:
                continue
            c = cond(it)
            key = (c["corner"].replace("_mismatch", ""), int(float(c["temperature"])))
            for name, val in zip(variables, v):
                if name and name != "null":
                    data.setdefault(name, {}).setdefault(key, []).append(val)
    return data


def mc_figure(pname, var, unit, groups, title):
    corners = [c for c in ["tt", "ss", "ff", "sf", "fs"] if any(k[0] == c for k in groups)]
    temps = sorted({k[1] for k in groups})
    fig, (ax, ax2) = plt.subplots(1, 2, figsize=(13, 4.8), gridspec_kw={"width_ratios": [3, 1.3]})
    w = 0.8 / len(temps)
    for ci, c in enumerate(corners):
        for ti, t in enumerate(temps):
            xs = groups.get((c, t))
            if not xs:
                continue
            x0 = ci + (ti - (len(temps) - 1) / 2) * w
            ys = [conv(unit, x) for x in xs]
            col = TCOL.get(t, "#444")
            ax.boxplot(ys, positions=[x0], widths=w * 0.8, showfliers=False,
                       boxprops=dict(color=col), medianprops=dict(color=col), whiskerprops=dict(color=col), capprops=dict(color=col))
            jit = [x0 + (((i * 7919) % 100) / 100 - 0.5) * w * 0.5 for i in range(len(ys))]
            ax.scatter(jit, ys, s=6, color=col, alpha=0.5, zorder=3)
            ax.text(x0, 1.01, f"{st.stdev(ys):.2g}", transform=ax.get_xaxis_transform(), ha="center", fontsize=7, color=col)
    ax.set_xticks(range(len(corners)))
    ax.set_xticklabels(corners)
    ax.set_xlabel("process corner (mismatch on)    [number on top = sigma of that box]")
    ax.set_ylabel(f"{var} [{unit}]")
    lo, hi = known_limits(var)
    for lim in (lo, hi):
        if lim is not None:
            ax.axhline(lim, color="k", ls=":", lw=1)
    for t in temps:
        ax.scatter([], [], color=TCOL.get(t, "#444"), label=f"{t} C")
    ax.legend(title="temperature", loc="upper right", fontsize=8)
    ax.grid(alpha=0.25)
    ax.set_title(title, pad=22)
    for t in temps:
        ys = [conv(unit, x) for (c, tt), xs in groups.items() if tt == t for x in xs]
        ax2.hist(ys, bins=25, histtype="step", color=TCOL.get(t, "#444"), label=f"{t} C: mean {fmt(st.mean(ys))}, sigma {fmt(st.stdev(ys))}")
    for lim in (lo, hi):
        if lim is not None:
            ax2.axvline(lim, color="k", ls=":", lw=1)
    ax2.set_xlabel(f"{var} [{unit}] (all corners pooled)")
    ax2.set_ylabel("samples")
    ax2.legend(fontsize=7)
    ax2.grid(alpha=0.25)
    fig.tight_layout()
    fn = f"{pname}_spread.png"
    fig.savefig(os.path.join(DOC, fn), dpi=130)
    plt.close(fig)
    return fn


def mc_section(pname, p):
    tool = tool_of(p)
    data = mc_samples(pname, tool["variables"])
    if not data:
        return ""
    out = [f"\n### {pname} - {p.get('display', '')}\n", p.get("description", "") + "\n"]
    for var, groups in data.items():
        unit = p["spec"][var]["unit"]
        n = sum(len(v) for v in groups.values())
        fn = mc_figure(pname, var, unit, groups, f"{p.get('display', pname)}: {var} spread")
        out.append(f"**{var} [{unit}]** - {n} samples\n\n![{pname} spread]({fn})\n")
        out.append("| corner | T [C] | N | mean | sigma | min | max | mean-3sigma | mean+3sigma |\n|---|---|---|---|---|---|---|---|---|")
        for (c, t) in sorted(groups, key=lambda k: (["tt", "ss", "ff", "sf", "fs"].index(k[0]), k[1])):
            ys = [conv(unit, x) for x in groups[(c, t)]]
            m, sd = st.mean(ys), (st.stdev(ys) if len(ys) > 1 else 0.0)
            out.append(f"| {c} | {t} | {len(ys)} | {fmt(m)} | {fmt(sd)} | {fmt(min(ys))} | {fmt(max(ys))} | {fmt(m - 3 * sd)} | {fmt(m + 3 * sd)} |")
        ys = [conv(unit, x) for v in groups.values() for x in v]
        m, sd = st.mean(ys), st.stdev(ys)
        lo, hi = known_limits(var)
        inside = ""
        if lo is not None or hi is not None:
            ok = sum(1 for y in ys if (lo is None or y >= lo) and (hi is None or y <= hi))
            inside = f" - {100 * ok / len(ys):.0f} % of all samples inside [{'-inf' if lo is None else fmt(lo)}, {'+inf' if hi is None else fmt(hi)}] {unit}"
        out.append(f"| **all** | | {len(ys)} | {fmt(m)} | {fmt(sd)} | {fmt(min(ys))} | {fmt(max(ys))} | {fmt(m - 3 * sd)} | {fmt(m + 3 * sd)} |\n\n_pooled sigma {fmt(sd)} {unit}{inside}_\n")
    return "\n".join(out)


# ----------------------------------------------------------------------------- assemble
def cace_file(name):
    f = os.path.join(DOC, name)
    return open(f).read() if os.path.isfile(f) else None


def git(*a):
    try:
        return subprocess.check_output(["git", "-C", ROOT, *a], text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return "unknown"


def main():
    src = "schematic"
    res_md = cace_file(f"{CELL}_{src}.md")
    design_md = cace_file(f"{CELL}.md")
    out = [f"# {CELL} - CACE characterisation\n",
           f"- Generated: {datetime.datetime.now():%Y-%m-%d %H:%M} by `scripts/make_readme.py` from `{os.path.relpath(RUN, ROOT)}`",
           f"- Commit: `{git('rev-parse', '--short', 'HEAD')}`{' (working tree dirty)' if git('status', '--porcelain') else ''}",
           f"- Netlist source: {src}; datasheet: `cace/{CELL}.yaml`; reproduce with `scripts/run_cace.sh {CELL}`",
           "- Sections marked *(CACE)* are written by CACE itself, the rest by this script (CACE has no per-corner MC statistics, worst-case conditions or unit-scaled spread plots).\n"]
    if design_md:
        body = re.sub(r"^# .*\n", "", design_md, count=1)
        out.append("## Design *(CACE)*\n" + body.replace("\n## ", "\n### "))
    if res_md:
        table = res_md.split("## Plots")[0]
        table = re.sub(r"^# CACE Summary.*\n", "", table, count=1, flags=re.M).replace("​", "")
        out.append("## Results summary *(CACE)*\n\nmin / typ / max over all conditions of a parameter; Monte Carlo parameters (`mc_*`) are min/max over all samples.\n" + table)
        plots = res_md.split("## Plots")[1] if "## Plots" in res_md else ""
        # CACE's own MC histograms are not unit-scaled and overlay all corners -> replaced by the spread images below
        plots = re.sub(r"\n## mc_\w+_hist\n\n!\[[^\]]*\]\([^)]*\)\n", "\n", plots)
        if plots.strip():
            out.append("### Plots *(CACE)*\n" + plots.replace("\n## ", "\n#### "))
    out.append("## PVT worst-case conditions\n\nCorners tt/ss/ff/sf/fs, supply and temperature as in the yaml. Values in the display unit of the yaml.\n")
    for pname, p in DS["parameters"].items():
        t = tool_of(p)
        if t and t.get("collate") != "iterations":
            out.append(pvt_section(pname, p))
    out.append("\n## Monte Carlo (local mismatch)\n\nMismatch models only (`mos_<corner>_mismatch`, `res_typ_mismatch`; `cap_cmomi` has no characterised spread), one seed per iteration (`seed = 12345 + iteration`, **the same 50 mismatch draws are reused at every corner and temperature**, so boxes are paired comparisons and the pooled counts overstate the number of independent samples: 50, not 50 x 15). Box = interquartile range, dots = individual samples, dotted lines = spec (if any).\n")
    for pname, p in DS["parameters"].items():
        t = tool_of(p)
        if t and t.get("collate") == "iterations":
            out.append(mc_section(pname, p))
    with open(os.path.join(DOC, "README.md"), "w") as f:
        f.write("\n".join(out) + "\n")
    print("wrote", os.path.relpath(os.path.join(DOC, "README.md"), ROOT))


main()
