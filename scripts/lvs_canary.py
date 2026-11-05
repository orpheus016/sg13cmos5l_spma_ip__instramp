#!/usr/bin/env python3
"""LVS canary: proves the LVS setup of a cell still catches real errors.

  lvs_canary.py [<cell>=pgia_top] [--keep]

Takes the layout and the LVS netlist of the cell (netlist/<cell>/lvs/<cell>.spice, written by scripts/run_lvs.sh), makes copies in
runs/lvs_canary/<cell>/ and runs the PDK LVS (the same options as scripts/run_lvs.sh: lvs_args of cells.yaml) on
  control   the unchanged copy                                  must MATCH   (else the canary itself is invalid -> exit 2)
  width     W of the first MOS with a numeric W scaled by 1.5   must FAIL
  length    L of the first resistor with a numeric L +10 %      must FAIL
  tap       the contacts of every n-tie of the smallest NWell
            that holds p+ Activ removed (well bulk floats)       must FAIL
  short     two different port labels joined by Metal wires      must FAIL
A mutation that LVS does not notice means the setup got weaker (an option like --ignore_top_ports_mismatch gone too far, a deck update,
a broken netlist step) - that is what this guards against. Nothing in the repository is modified.
Exit: 0 all mutations detected, 1 a mutation was NOT detected, 2 cannot run (no layout / netlist, control does not match).
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDK, PDK_ROOT = "ihp-sg13cmos5l", os.environ.get("PDK_ROOT", "/foss/pdks")
LVS_PY = os.path.join(PDK_ROOT, PDK, "libs.tech/klayout/tech/lvs/run_lvs.py")
LABEL_TO_METAL = {(8, 25): (8, 0), (10, 25): (10, 0), (30, 25): (30, 0), (50, 25): (50, 0), (126, 25): (126, 0)}


def cellinfo(cell, key):
    r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "scripts/cellinfo.py"), cell, key], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def run_lvs(gds, netlist, top, rundir, extra):
    shutil.rmtree(rundir, ignore_errors=True)
    os.makedirs(rundir)
    env = dict(os.environ, PDK=PDK, PDK_ROOT=PDK_ROOT)
    r = subprocess.run([sys.executable, LVS_PY, f"--layout={gds}", f"--netlist={netlist}", f"--topcell={top}", f"--run_dir={rundir}", *extra],
                       capture_output=True, text=True, env=env)
    txt = r.stdout + r.stderr
    return ("Comparison mode: PASS" in txt), txt


# ---- mutations -------------------------------------------------------------------------------------------------------------------------
def mut_width(netlist_text):
    out, done = [], None
    for line in netlist_text.splitlines():
        m = re.match(r"^(M\S*\s.*\bsg13_lv_\w+\s.*\bw=)([0-9.]+(?:e-?\d+)?)([unmpf]?)(\b.*)$", line, re.I) if done is None else None
        if m:
            done = line.split()[0]
            line = f"{m.group(1)}{float(m.group(2)) * 1.5:.6g}{m.group(3)}{m.group(4)}"
        out.append(line)
    return "\n".join(out) + "\n", done


def mut_length(netlist_text):
    out, done = [], None
    for line in netlist_text.splitlines():
        m = re.match(r"^(R\S*\s.*\bl=)([0-9.*e\-]+)(\s.*|)$", line, re.I) if done is None else None
        if m and not m.group(2).startswith("{"):
            done = line.split()[0]
            line = f"{m.group(1)}1.1*{m.group(2)}{m.group(3)}"
        out.append(line)
    return "\n".join(out) + "\n", done


def mut_tap(gds, top, out_gds):
    ly = db.Layout()
    ly.read(gds)
    topc = ly.cell(top)
    topc.flatten(True)
    reg = lambda a, b: db.Region(topc.shapes(ly.find_layer(a, b))) if ly.find_layer(a, b) is not None else db.Region()
    activ, gate, cont, psd, nwell = reg(1, 0), reg(5, 0), reg(6, 0), reg(14, 0), reg(31, 0)
    nwell.merge()
    nactiv, pactiv = activ - psd, activ & psd
    ntie = ((nactiv & nwell) - gate).interacting(cont)
    best = None
    for w in nwell.each():
        wr = db.Region(w)
        if (pactiv & wr).is_empty() or (ntie & wr).is_empty():
            continue
        if best is None or w.area() < best.area():
            best = w
    if best is None:
        return None
    victims = cont.interacting(ntie & db.Region(best))
    li = ly.find_layer(6, 0)
    topc.shapes(li).clear()
    topc.shapes(li).insert(cont - victims)
    ly.write(out_gds)
    bb = best.bbox()
    return f"{victims.count()} contact(s) of n-ties in the NWell at ({bb.center().x / 1000:.0f},{bb.center().y / 1000:.0f}) um"


def mut_short(gds, top, out_gds):
    ly = db.Layout()
    ly.read(gds)
    topc = ly.cell(top)
    labs = []
    for (lt, dt), metal in LABEL_TO_METAL.items():
        li = ly.find_layer(lt, dt)
        if li is None:
            continue
        for s in topc.shapes(li).each():
            if s.is_text():
                labs.append((lt, s.text.string, s.text.trans.disp.x, s.text.trans.disp.y))
    pairs = [(abs(a[2] - b[2]) + abs(a[3] - b[3]), a, b) for i, a in enumerate(labs) for b in labs[i + 1:] if a[0] == b[0] and a[1] != b[1]]
    if not pairs:
        return None
    _, a, b = min(pairs)
    metal = LABEL_TO_METAL[(a[0], 25)]
    li = ly.layer(*metal)
    h = 250  # 0.5 um wide L-shaped wire from label a to label b
    topc.shapes(li).insert(db.Box(min(a[2], b[2]) - h, a[3] - h, max(a[2], b[2]) + h, a[3] + h))
    topc.shapes(li).insert(db.Box(b[2] - h, min(a[3], b[3]) - h, b[2] + h, max(a[3], b[3]) + h))
    ly.write(out_gds)
    return f"{a[1]} and {b[1]} joined on Metal layer {metal[0]}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cell", nargs="?", default="pgia_top")
    ap.add_argument("--keep", action="store_true", help="keep the scratch copies and LVS databases")
    a = ap.parse_args()
    cell = a.cell
    gds, top = cellinfo(cell, "gds"), cellinfo(cell, "top") or cell
    extra = (cellinfo(cell, "lvs_args") or "").split()
    netlist = os.path.join(ROOT, "netlist", cell, "lvs", f"{cell}.spice")
    if not gds or not os.path.isfile(gds):
        print(f"lvs_canary: no layout for {cell} in cells.yaml", file=sys.stderr)
        return 2
    if not os.path.isfile(netlist):
        print(f"lvs_canary: {os.path.relpath(netlist, ROOT)} missing - run scripts/run_lvs.sh {cell} first", file=sys.stderr)
        return 2
    if not os.path.isfile(LVS_PY):
        print(f"lvs_canary: {LVS_PY} not found", file=sys.stderr)
        return 2
    work = os.path.join(ROOT, "runs", "lvs_canary", cell)
    shutil.rmtree(work, ignore_errors=True)
    os.makedirs(work)
    text = open(netlist).read()

    ok, txt = run_lvs(gds, netlist, top, os.path.join(work, "control"), extra)
    print(f"lvs_canary {cell}: control (unchanged copy) -> {'MATCH' if ok else 'MISMATCH'}")
    if not ok:
        print("lvs_canary: the unchanged layout does not match, the canary is not meaningful. Fix LVS first.", file=sys.stderr)
        return 2

    results = []

    def attempt(name, what, gds_in, netlist_in):
        if what is None:
            results.append((name, None, "no suitable place found in this layout, skipped"))
            print(f"  {name:7s} skipped (no suitable place)")
            return
        ok, _ = run_lvs(gds_in, netlist_in, top, os.path.join(work, name), extra)
        results.append((name, not ok, what))
        print(f"  {name:7s} {'detected' if not ok else 'NOT DETECTED  <-----'}  ({what})")

    t, what = mut_width(text)
    p = os.path.join(work, "width.spice"); open(p, "w").write(t)
    attempt("width", f"W of {what} x1.5" if what else None, gds, p)
    t, what = mut_length(text)
    p = os.path.join(work, "length.spice"); open(p, "w").write(t)
    attempt("length", f"L of {what} +10 %" if what else None, gds, p)
    g = os.path.join(work, "tap.gds"); what = mut_tap(gds, top, g)
    attempt("tap", what, g, netlist)
    g = os.path.join(work, "short.gds"); what = mut_short(gds, top, g)
    attempt("short", what, g, netlist)

    missed = [n for n, det, _ in results if det is False]
    ran = [n for n, det, _ in results if det is not None]
    if not a.keep:
        shutil.rmtree(work, ignore_errors=True)
    if missed:
        print(f"lvs_canary: WEAK - LVS did not notice: {', '.join(missed)}", file=sys.stderr)
        return 1
    print(f"lvs_canary: OK, {len(ran)}/{len(ran)} mutations detected" + (f" ({len(results) - len(ran)} skipped)" if len(ran) != len(results) else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
