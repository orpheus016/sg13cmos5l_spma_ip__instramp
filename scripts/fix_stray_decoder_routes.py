#!/usr/bin/env python3
"""One-off layout fix: stray decoder -> gain stage routes in gds/pgia_top/pgia_top.gds (cell pgia_top).

When gain_network was replaced by gain_stage, two routes of the old topology were left behind: decoder s1_b[0] -> stage 1 and
decoder s2_b[0] -> stage 2 (Metal2 / Metal3 / Via2 drawn directly in pgia_top). In the schematic those decoder outputs are unconnected
(gain_stage builds S0 internally), so the routes short the decoder buffers into the stages' S0 nets (LVS: AND2 / inverter / OUTPUT10/20 mismatches).

  fix_stray_decoder_routes.py [--gds gds/pgia_top/pgia_top.gds] [--check]

Copies the GDS to <dir>/backups/ first, then deletes the shapes (exact bbox match, cell pgia_top only). None present -> "nothing to do".
Only some present -> aborts without writing (the layout was edited since). --check only reports.
"""
import argparse
import os
import shutil
import sys
import time

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CELL = "pgia_top"
LAYERS = {"M2": (10, 0), "M3": (30, 0), "V2": (29, 0)}
# (layer, left, bottom, right, top) in um
ROUTES = {
    "s1_b[0] -> stage 1": [
        ("M3", 89.80, 74.55, 115.50, 74.85), ("M3", 115.25, 74.45, 115.75, 74.95), ("M3", 115.35, 74.55, 115.65, 74.85),
        ("M2", 115.25, 74.45, 115.75, 74.95), ("M2", 115.35, 74.70, 115.65, 104.50), ("M2", 115.25, 104.25, 115.75, 104.75),
        ("M2", 115.35, 104.35, 115.65, 104.65),
        ("V2", 115.41, 74.61, 115.59, 74.80), ("V2", 115.41, 104.41, 115.59, 104.59),
        ("M3", 115.25, 104.25, 115.75, 104.75), ("M3", 115.50, 104.35, 323.50, 104.65), ("M3", 323.25, 104.25, 323.75, 104.75),
        ("M3", 323.35, 104.35, 323.65, 104.65),
        ("M2", 323.35, 86.94, 323.65, 104.50), ("M2", 323.25, 86.69, 323.75, 87.19), ("M2", 323.35, 86.80, 323.65, 87.09),
        ("M2", 323.25, 104.25, 323.75, 104.75),
        ("V2", 323.40, 104.41, 323.60, 104.59), ("V2", 323.40, 86.85, 323.60, 87.04),
        ("M3", 316.88, 86.80, 317.18, 87.09), ("M3", 315.36, 86.80, 316.88, 87.09), ("M3", 317.03, 86.80, 323.50, 87.09),
        ("M3", 323.25, 86.69, 323.75, 87.19),
    ],
    "s2_b[0] -> stage 2": [
        ("M2", 97.25, 91.25, 97.75, 91.75), ("M2", 97.35, 91.50, 97.65, 221.94), ("M2", 97.25, 221.69, 97.75, 222.19),
        ("M2", 97.35, 221.79, 97.65, 222.09),
        ("V2", 97.41, 91.41, 97.59, 91.59), ("V2", 97.41, 221.85, 97.59, 222.04),
        ("M3", 97.25, 91.25, 97.75, 91.75), ("M3", 89.80, 91.35, 97.50, 91.65), ("M3", 97.35, 91.35, 97.65, 91.65),
        ("M3", 97.25, 221.69, 97.75, 222.19), ("M3", 97.50, 221.79, 220.42, 222.09), ("M3", 220.27, 221.79, 221.25, 222.09),
    ],
}
TOL = 6  # dbu


def box_um(t):
    return db.Box(*(round(v * 1000) for v in t[1:]))


def same(a, b):
    return all(abs(x - y) <= TOL for x, y in ((a.left, b.left), (a.bottom, b.bottom), (a.right, b.right), (a.top, b.top)))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gds", default=os.path.join(ROOT, "gds/pgia_top/pgia_top.gds"))
    ap.add_argument("--check", action="store_true", help="only report, write nothing")
    args = ap.parse_args()

    ly = db.Layout()
    ly.read(args.gds)
    top = ly.cell(CELL)
    if top is None:
        sys.exit(f"fix_stray_decoder_routes: no cell '{CELL}' in {args.gds}")
    hits, missing = [], []
    for route, items in ROUTES.items():
        found = 0
        for t in items:
            li = ly.find_layer(*LAYERS[t[0]])
            want = box_um(t)
            m = [s for s in top.shapes(li).each() if same(s.bbox(), want)] if li is not None else []
            if m:
                hits.append(m[0])
                found += 1
            else:
                missing.append((route, t))
        print(f"fix_stray_decoder_routes: {route}: {found}/{len(items)} shapes present")
    if not hits:
        print("fix_stray_decoder_routes: nothing to do (already fixed)")
        return
    if missing:
        sys.exit("fix_stray_decoder_routes: only part of the routes is there, the layout was edited by hand since; not touching it. Missing: "
                 + "; ".join(f"{r} {t[0]} ({t[1]},{t[2]})-({t[3]},{t[4]})" for r, t in missing))
    if args.check:
        return

    bdir = os.path.join(os.path.dirname(args.gds), "backups")
    os.makedirs(bdir, exist_ok=True)
    name = os.path.splitext(os.path.basename(args.gds))[0]
    backup = os.path.join(bdir, f"{name}_backup_{time.strftime('%Y-%m-%d_%Hh%Mm%S')}_fix_stray_decoder_routes.gds")
    shutil.copy2(args.gds, backup)
    print(f"fix_stray_decoder_routes: backup {os.path.relpath(backup, ROOT)}")
    for s in hits:
        s.delete()
    ly.write(args.gds)
    print(f"fix_stray_decoder_routes: deleted {len(hits)} shapes, wrote {os.path.relpath(args.gds, ROOT)}")
    print("fix_stray_decoder_routes: reload the file in KLayout and refresh pgia_top inside gds/slot9_wrapper/slot9_wrapper.gds")


if __name__ == "__main__":
    main()
