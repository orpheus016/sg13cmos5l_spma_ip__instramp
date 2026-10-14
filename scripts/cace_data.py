"""Read CACE results into pandas (used by tools/report.ipynb; usable from any notebook).

  import sys; sys.path.insert(0, "scripts"); import cace_data as cd
  ref  = cd.find_run("ota_cmos5l", "schematic")     # newest schematic run with the most evaluated rows
  df   = cd.load_run(ref, "ota_cmos5l")             # one row per (parameter, variable, run): value in the unit of the datasheet
  cd.summary(ref)                                   # the Pass/Fail table of summary.md as a DataFrame

Conventions: values in the display unit of cace/<cell>.yaml (CACE's own spice_unit_unconvert), condition columns as in the run's
conditions.yaml (corner, vdd, temperature, ...), `kind` is "pvt" for the sweep runs and "mc" for Monte Carlo iterations.
"""
import glob
import json
import os
import re

import pandas as pd
import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_SCALE = {}


def _conv(unit, value):
    from cace.common.spiceunits import spice_unit_unconvert
    if unit not in _SCALE:
        _SCALE[unit] = float(spice_unit_unconvert((str(unit), 1.0)))
    return value * _SCALE[unit]


def datasheet(cell):
    return yaml.safe_load(open(os.path.join(ROOT, "cace", f"{cell}.yaml")))


def _rows(summary_path):
    out = []
    for line in open(summary_path):
        if not line.startswith("|") or "---" in line or "Parameter" in line:
            continue
        c = [x.strip().replace("​", "") for x in line.strip().strip("|").split("|")]
        if len(c) >= 10:
            out.append(c)
    return out


def summary(run):
    """summary.md of a CACE run as a DataFrame (strings as printed by CACE plus numeric value columns)"""
    rows = _rows(os.path.join(run, "summary.md"))
    df = pd.DataFrame(rows, columns=["parameter", "tool", "variable", "min_limit", "min_value", "typ_target", "typ_value",
                                     "max_limit", "max_value", "status"][:len(rows[0])] if rows else None)
    for c in ("min_value", "typ_value", "max_value"):
        df[c + "_num"] = df[c].str.extract(r"^\s*([-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?)")[0].astype(float)
    df["unit"] = df["typ_value"].str.extract(r"^\s*\S+\s+(\S+)")[0]
    df["status"] = df["status"].str.replace(r"[^A-Za-z]", "", regex=True)
    return df


def netlist_source(run):
    m = re.search(r"\*\*netlist source\*\*:\s*(\S+)", open(os.path.join(run, "summary.md")).read())
    return m.group(1) if m else None


def find_run(cell, source="schematic", variant="c"):
    """newest run of a cell with the most evaluated rows. source: schematic (runs/RUN_*), pex (variant c: runs/pex_cace,
    rc: runs/pex_cace_rc)"""
    pats = {"schematic": "runs/RUN_*", "pex": {"c": f"runs/pex_cace/{cell}/RUN_*", "rc": f"runs/pex_cace_rc/{cell}/RUN_*"}[variant]}
    best, best_n = None, -1
    for d in sorted(glob.glob(os.path.join(ROOT, pats[source if source == "schematic" else "pex"])), reverse=True):
        s = os.path.join(d, "summary.md")
        if not os.path.isfile(s):
            continue
        txt = open(s).read()
        if f"CACE Summary for {cell}\n" not in txt + "\n" or f"netlist source**: {source}" not in txt:
            continue
        n = len(re.findall(r"\|\s*(Pass|Fail)", txt))
        if n > best_n:
            best, best_n = d, n
    return best


def load_run(run, cell):
    """long DataFrame of all raw results of a run"""
    ds = datasheet(cell)
    recs = []
    for pname, p in ds["parameters"].items():
        tool = p.get("tool", {}).get("ngspice") if isinstance(p.get("tool"), dict) else None
        if not tool:
            continue
        names = tool["variables"]
        spec = p.get("spec", {})
        for data in glob.glob(os.path.join(run, "parameters", pname, "**", "*.data"), recursive=True):
            d = os.path.dirname(data)
            cf = os.path.join(d, "conditions.yaml")
            if not os.path.isfile(cf):
                continue
            c = yaml.safe_load(open(cf)) or {}
            vals = open(data).read().split()
            nested = os.path.basename(os.path.dirname(d)).startswith("run_") and os.path.dirname(d) != os.path.join(run, "parameters", pname)
            for name, v in zip(names, vals):
                if not name or name == "null":
                    continue
                unit = spec.get(name, {}).get("unit", "")
                try:
                    x = _conv(unit, float(v))
                except ValueError:
                    continue
                recs.append(dict(parameter=pname, variable=name, value=x, unit=unit, kind="mc" if nested or "iterations" in tool.get("collate", "") else "pvt",
                                 corner=str(c.get("corner", "")).replace("_mismatch", ""), vdd=float(c.get("vdd", float("nan"))),
                                 temperature=float(c.get("temperature", float("nan"))), run=os.path.relpath(d, run)))
    return pd.DataFrame(recs)


def limits(cell):
    """{variable: (min, max, unit, display)} from the datasheet; None for `any`"""
    out = {}
    for p in datasheet(cell)["parameters"].values():
        for v, s in p.get("spec", {}).items():
            def lim(w):
                x = s.get(w, {}).get("value", "any") if isinstance(s.get(w), dict) else s.get(w, "any")
                return None if x in ("any", None) else float(x)
            lo, hi = lim("minimum"), lim("maximum")
            if v not in out or (out[v][0] is None and out[v][1] is None):
                out[v] = (lo, hi, s.get("unit", ""), s.get("display", v))
    return out


def status(cell):
    f = os.path.join(ROOT, "docs", cell, "status.json")
    return json.load(open(f)) if os.path.isfile(f) else None


def postlayout(cell, variant="c"):
    f = os.path.join(ROOT, "docs", cell, "cace", "postlayout" + ("_rc" if variant == "rc" else "") + ".json")
    return json.load(open(f)) if os.path.isfile(f) else None


def stale(cell):
    """list of reasons why docs/<cell>/status.json no longer matches the sources (empty = up to date)"""
    import hashlib
    st = status(cell)
    if not st:
        return ["no flow run yet (scripts/flow.sh " + cell + ")"]
    out = []
    for key, label in (("gds", "layout"), ("schematic", "schematic")):
        p = st.get(key, {}).get("path")
        if p and os.path.isfile(os.path.join(ROOT, p)):
            h = hashlib.sha1(open(os.path.join(ROOT, p), "rb").read()).hexdigest()[:12]
            if h != st[key]["sha1"]:
                out.append(f"{label} {p} changed since the flow run")
    return out
