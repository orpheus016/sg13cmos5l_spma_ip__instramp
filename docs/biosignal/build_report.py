#!/usr/bin/env python3
"""Build docs/biosignal/report.html (self-contained, no external requests) from
sim/biosignal/results/{summary.json,*.csv}.   python3 build_report.py"""
import json, os
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "..", "sim", "biosignal", "results")
summary = json.load(open(os.path.join(RES, "summary.json")))

data = {"vcm": summary["vcm"], "vdd": summary["vdd"], "ibias_uA": summary["ibias_uA"], "signals": {}, "runs": summary["runs"]}
for sig, meta in summary["signals"].items():
    cases, t = {}, None
    for r in summary["runs"]:
        if r["signal"] != sig:
            continue
        d = np.loadtxt(os.path.join(RES, r["case"] + ".csv"), delimiter=",", skiprows=1)
        t = d[:, 0]
        cases[r["case"]] = [round(float(v), 4) for v in d[:, 2]]
        x = d[:, 1]
    data["signals"][sig] = dict(label=meta["label"], primary=meta["primary_code"],
                                t=[round(float(v), 5) for v in t],
                                x=[round(float(v) * 1e6, 3) for v in x],   # uV at the electrode
                                cases=cases)

html = open(os.path.join(HERE, "report_template.html")).read()
html = html.replace("/*__DATA__*/null", json.dumps(data, separators=(",", ":")))
open(os.path.join(HERE, "report.html"), "w").write(html)
print("report.html", len(html) // 1024, "KiB")
