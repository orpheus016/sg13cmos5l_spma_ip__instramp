#!/usr/bin/env python3
"""One-off layout fix: pseudo-resistor n-tap bridges in gds/pgia_top/pgia_top.gds (cell pgia_top).

Four hand-drawn Activ boxes join the p+ source/drain fingers of the 4 pseudo-resistor PMOS (pmos$19) to the n-tap column in the same
Activ island. The LVS deck treats a salicided p+ S/D abutting an n+ tap as shorted (rule psd_ntap_abutt in general_derivations.lvs), so
VINP, CM and VINN were all merged with AVDD. The n-tap itself is fine (n+ is implicit in CMOS5L, no nSD is drawn), only the bridges go.

  fix_pseudores_tap.py [--gds gds/pgia_top/pgia_top.gds] [--check]

Copies the GDS to <dir>/backups/<name>_backup_<timestamp>.gds first, then deletes the boxes (exact match, cell pgia_top only).
Already fixed -> "nothing to do", exit 0. Only some boxes present -> aborts without writing. --check only reports.
Afterwards: reload the file in KLayout and refresh the copy of pgia_top inside gds/slot9_wrapper/slot9_wrapper.gds.
"""
import argparse
import os
import shutil
import sys
import time

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CELL = "pgia_top"
ACTIV = (1, 0)
BRIDGES_UM = [  # (left, bottom, right, top)
    (495.220, 72.425, 496.030, 72.725),
    (495.220, 78.275, 496.030, 78.575),
    (495.220, 79.740, 496.030, 79.940),
    (495.170, 85.600, 496.030, 85.800),
]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gds", default=os.path.join(ROOT, "gds/pgia_top/pgia_top.gds"))
    ap.add_argument("--check", action="store_true", help="only report, write nothing")
    args = ap.parse_args()

    ly = db.Layout()
    ly.read(args.gds)
    top = ly.cell(CELL)
    li = ly.find_layer(*ACTIV)
    if top is None or li is None:
        sys.exit(f"fix_pseudores_tap: no cell '{CELL}' or no Activ layer {ACTIV} in {args.gds}")
    want = [db.Box(*(round(v * 1000) for v in b)) for b in BRIDGES_UM]
    hits = [s for s in top.shapes(li).each() if s.is_box() and s.box in want]
    found = {s.box for s in hits}
    print(f"fix_pseudores_tap: {len(found)}/{len(want)} bridge boxes present in cell {CELL} of {os.path.relpath(args.gds, ROOT)}")
    if not found:
        print("fix_pseudores_tap: nothing to do (already fixed)")
        return
    if len(found) != len(want):
        sys.exit("fix_pseudores_tap: only some of the boxes are there, the layout was edited by hand since; not touching it. "
                 "Missing: " + ", ".join(str(b) for b in want if b not in found))
    if args.check:
        return

    bdir = os.path.join(os.path.dirname(args.gds), "backups")
    os.makedirs(bdir, exist_ok=True)
    name = os.path.splitext(os.path.basename(args.gds))[0]
    backup = os.path.join(bdir, f"{name}_backup_{time.strftime('%Y-%m-%d_%Hh%Mm%S')}_fix_pseudores_tap.gds")
    shutil.copy2(args.gds, backup)
    print(f"fix_pseudores_tap: backup {os.path.relpath(backup, ROOT)}")
    for s in hits:
        s.delete()
    ly.write(args.gds)
    print(f"fix_pseudores_tap: deleted {len(hits)} boxes, wrote {os.path.relpath(args.gds, ROOT)}")
    print("fix_pseudores_tap: reload the file in KLayout and refresh pgia_top inside gds/slot9_wrapper/slot9_wrapper.gds")


if __name__ == "__main__":
    main()
