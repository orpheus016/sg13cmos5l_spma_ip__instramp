#!/usr/bin/env python3
"""Static HTML reports for the cells that have no CACE datasheet, and docs/index.html for all cells.

  build_chip_report.py [--cells a,b] [--no-index]

scripts/build_report.sh builds the interactive notebook report (docs/<cell>/report.html) for the cells with a CACE datasheet. Everything
else (pgia_top, slot9_wrapper, output_buffer, ...) gets a self-contained page here from what scripts/flow.sh and scripts/tap_audit.py left behind:
  docs/<cell>/status.json   stages with result, time, detail        docs/<cell>/audit.json   latch-up / tap audit
  docs/<cell>/media/<cell>_{layout,schematic}.png (embedded)         cells.yaml (title, note, files, children)
A red banner says so when the layout or schematic changed after the flow run (sha1 differs). docs/index.html lists every cell with its
report, stage results and the last scripts/build_all.sh summary (docs/build_summary.json). Needs only pyyaml.
"""
import argparse
import base64
import datetime
import hashlib
import html
import json
import os
import sys

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSS = """
:root{--bg:#fff;--fg:#1d2330;--mut:#5b6577;--line:#d9dee8;--card:#f5f7fb;--ok:#0b7a3b;--bad:#b3261e;--warn:#8a5a00;--link:#1a56c4}
@media (prefers-color-scheme:dark){:root{--bg:#10141c;--fg:#e6e9f0;--mut:#9aa4b8;--line:#2a3140;--card:#171c27;--ok:#58c98a;--bad:#ff8a80;--warn:#e3b04b;--link:#8ab4ff}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,sans-serif}
main{max-width:64rem;margin:0 auto;padding:1.2rem 16px 3rem}
h1{font-size:1.5rem;margin:.2rem 0}h2{font-size:1.1rem;margin:1.6rem 0 .5rem}.mut{color:var(--mut)}a{color:var(--link)}
table{border-collapse:collapse;width:100%}th,td{padding:.35rem .6rem;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
td.n{text-align:right;white-space:nowrap}.ok{color:var(--ok)}.bad{color:var(--bad)}.warn{color:var(--warn)}
.banner{background:var(--card);border-left:4px solid var(--bad);padding:.6rem .9rem;margin:1rem 0}
img{max-width:100%;border:1px solid var(--line);background:#fff}code{background:var(--card);padding:0 .25rem;border-radius:3px}
@media (max-width:640px){th,td{padding:.3rem .3rem;font-size:.9rem}}
"""
STATUS_CLS = {"pass": "ok", "fail": "bad", "error": "bad", "blocked": "warn", "skip": "mut", "ok": "ok", "FAIL": "bad", "ERROR": "bad"}


def sha(p):
    return hashlib.sha1(open(p, "rb").read()).hexdigest()[:12] if p and os.path.isfile(p) else None


def jload(p):
    try:
        return json.load(open(p))
    except Exception:
        return None


def img(p):
    if not os.path.isfile(p) or os.path.getsize(p) > 6_000_000:
        return ""
    return f'<img alt="{html.escape(os.path.basename(p))}" src="data:image/png;base64,{base64.b64encode(open(p, "rb").read()).decode()}">'


def page(title, body):
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
            f"<title>{html.escape(title)}</title><style>{CSS}</style></head><body><main>{body}</main></body></html>")


def cell_report(cell, v):
    d = os.path.join(ROOT, "docs", cell)
    st, au = jload(os.path.join(d, "status.json")), jload(os.path.join(d, "audit.json"))
    gds = os.path.join(ROOT, v["gds"]) if v.get("gds") else None
    sch = os.path.join(ROOT, v["sch"]) if v.get("sch") else None
    b = [f"<h1>{html.escape(v.get('title') or cell)} <span class='mut'>({cell})</span></h1>", f"<p class='mut'>{html.escape(v.get('note', ''))}</p>"]
    if st:
        stale = [n for n, cur, old in (("layout", sha(gds), (st.get("gds") or {}).get("sha1")), ("schematic", sha(sch), (st.get("schematic") or {}).get("sha1")))
                 if cur and old and cur != old]
        if stale:
            b.append(f"<div class='banner'><b>{' and '.join(stale)} changed after the last flow run</b> ({html.escape(st.get('generated', ''))}): "
                     f"the results below are out of date. Run <code>scripts/flow.sh {cell}</code> or <code>scripts/build_all.sh</code>.</div>")
        b.append(f"<h2>Flow stages</h2><p class='mut'>scripts/flow.sh, {html.escape(st.get('generated', ''))}, commit {html.escape(str(st.get('commit')))}, "
                 f"layout sha1 {html.escape(str((st.get('gds') or {}).get('sha1')))}, schematic sha1 {html.escape(str((st.get('schematic') or {}).get('sha1')))}</p>"
                 "<table><tr><th>Stage</th><th>Result</th><th>Time</th><th>Detail</th></tr>")
        for s in st.get("stages", []):
            b.append(f"<tr><td>{html.escape(s['name'])}</td><td class='{STATUS_CLS.get(s['status'], '')}'>{html.escape(s['status'])}</td>"
                     f"<td class='n'>{s['seconds']} s</td><td>{html.escape(s.get('detail', ''))}</td></tr>")
        b.append("</table>")
    else:
        b.append("<p class='bad'>No flow run yet for this cell (<code>scripts/flow.sh " + cell + "</code>).</p>")
    if au:
        b.append(f"<h2>Latch-up / tap audit</h2><p class='mut'>scripts/tap_audit.py, limit {au['limit_um']:g} µm, {au['counts']['ntie']} n-tie / "
                 f"{au['counts']['ptie']} p-tie polygons, {au['counts']['p_activ_in_nwell']} p+ and {au['counts']['n_activ_in_substrate']} n+ device Activ polygons.</p>")
        if not au["violations"] and not au["warnings"]:
            b.append(f"<p class='ok'>Clean: every device Activ within the tie distance, every NWell tied; {au.get('abut_total_sites', 0)} accepted abutted-tie site(s).</p>")
        for k, x in {**au["violations"], **au["warnings"]}.items():
            cls = "bad" if k in au["violations"] else "warn"
            b.append(f"<p class='{cls}'>{html.escape(k)}: {x['count']} spot(s); first at {html.escape(str(x['where'][:3]))}</p>")
    if cell == "slot9_wrapper" and v.get("harness_gds"):
        h = os.path.join(ROOT, v["harness_gds"])
        b.append("<h2>Harness deliverable</h2><p>The Chipalooza harness clones this repository and reads <code>" + html.escape(v["harness_gds"]) + "</code> "
                 f"(top cell <code>{html.escape(v.get('harness_top', ''))}</code>): " + (f"{os.path.getsize(h) / 1e6:.2f} MB, sha1 {sha(h)}." if os.path.isfile(h) else "<span class='bad'>missing</span>.") + "</p>")
    pics = "".join(img(os.path.join(d, "media", f"{cell}_{k}.png")) for k in ("layout", "schematic"))
    if pics:
        b.append("<h2>Layout and schematic</h2>" + pics)
    if v.get("children"):
        b.append("<h2>Contains</h2><p>" + ", ".join(f"<a href='../{c}/report.html'>{c}</a>" for c in v["children"]) + "</p>")
    out = os.path.join(d, "report.html")
    os.makedirs(d, exist_ok=True)
    open(out, "w").write(page(f"{cell} report", "".join(b) + f"<p class='mut'>generated {datetime.datetime.now().isoformat(timespec='seconds')} by scripts/build_chip_report.py</p>"))
    return out


def index(reg):
    bs = jload(os.path.join(ROOT, "docs", "build_summary.json"))
    rows = []
    for cell, v in reg.items():
        if not (v.get("gds") or v.get("sch")):
            continue
        has = os.path.isfile(os.path.join(ROOT, "docs", cell, "report.html"))
        st = jload(os.path.join(ROOT, "docs", cell, "status.json"))
        stages = " ".join(f"<span class='{STATUS_CLS.get(s['status'], '')}'>{html.escape(s['name'])}</span>" for s in (st or {}).get("stages", [])) or "<span class='mut'>no flow run</span>"
        link = f"<a href='{cell}/report.html'>{cell}</a>" if has else cell
        rows.append(f"<tr><td>{link}</td><td class='mut'>{html.escape(v.get('note', ''))}</td><td>{stages}</td><td class='mut'>{html.escape((st or {}).get('generated', ''))}</td></tr>")
    b = ["<h1>Cell reports</h1><p class='mut'>PGIA IP, SG13CMOS5L. Stage colours: green passed, red failed.</p>"]
    if bs:
        b.append(f"<h2>Last build</h2><p class='mut'>scripts/build_all.sh ({bs['mode']}), {html.escape(bs['generated'])}, branch {html.escape(bs['branch'])} {html.escape(bs['commit'])}, {bs['seconds']} s</p>"
                 "<table><tr><th>Step</th><th>Result</th><th>Time</th></tr>")
        for s in bs["steps"]:
            b.append(f"<tr><td>{html.escape(s['name'])}</td><td class='{STATUS_CLS.get(s['status'], '')}'>{html.escape(s['status'])}</td><td class='n'>{s['seconds']} s</td></tr>")
        b.append("</table>")
    b.append("<h2>Cells</h2><table><tr><th>Cell</th><th>What</th><th>Stages</th><th>Flow run</th></tr>" + "".join(rows) + "</table>")
    open(os.path.join(ROOT, "docs", "index.html"), "w").write(page("Cell reports", "".join(b)))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cells")
    ap.add_argument("--no-index", action="store_true")
    a = ap.parse_args()
    reg = yaml.safe_load(open(os.path.join(ROOT, "cells.yaml")))
    want = a.cells.split(",") if a.cells else None
    n = 0
    for cell, v in reg.items():
        if want and cell not in want:
            continue
        if not (v.get("gds") or v.get("sch")) or v.get("cace"):
            continue  # CACE cells: scripts/build_report.sh (notebook)
        print("chip report:", os.path.relpath(cell_report(cell, v), ROOT))
        n += 1
    if not a.no_index:
        index(reg)
        print("chip report: docs/index.html")
    return 0


if __name__ == "__main__":
    sys.exit(main())
