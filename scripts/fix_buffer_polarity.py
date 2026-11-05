#!/usr/bin/env python3
"""Layout fix: output buffer polarity (input on the OTA's non-inverting pin, VOUT fed back to the inverting pin).

  fix_buffer_polarity.py [--gds f ...] [--check]        (default: the three layouts that contain the buffer)

The buffer (xschem/output_buffer, one ota_cmos5l) had the input on the OTA's inverting pin VINN and VOUT on the non-inverting pin VINP:
positive feedback, the output latches at the supply (chip simulation: VOUT 1.15 V, gain -100 dB). LVS cannot see that, the layout matched the
schematic. Schematic: input -> VINP, VOUT -> VINN. Layout: the two OTA input pads are adjacent M3 strips (VINN upper y 20.32..20.565, VINP lower
y 19.40..19.64); the OTA cell itself is not touched (instramp uses the same cell), only the shapes of the buffer's top cell and one pad of pgia_top:

  cell output_buffer (um)
    - M3 (0.000,20.320)-(0.670,20.565)  upper stub  -> M3 (0.000,20.320)-(0.240,20.565) + M3 (0.000,19.640)-(0.240,20.320): the upper stub (the
                                                       pin where pgia_top connects) is now tied down to the lower stub = OTA VINP pad = input
    - M3 (0.000,0.880)-(0.240,19.400)   feedback strap -> M3 (0.000,0.880)-(0.240,18.950) + M3 pad (-0.15,18.45)-(0.35,18.95) + Via3 + Metal4 jumper
                                                       over the input stub (L shape) + Via3 + M3 landing pad (0.85,20.32)-(1.45,21.15) on the OTA VINN pad
  cell pgia_top: M3 pad (379.72,225.04)-(380.52,225.84) -> right edge 380.40 (the input wire pad was joined to the old upper stub; it must stay
                 0.2 um away from the OTA's upper pad now that they are different nets)

Each layout is copied to <dir>/backups/ first, exact shapes are required (same guard as fix_pseudores_tap.py), idempotent. --check only reports.
Afterwards: scripts/export_slot_gds.py (slot_9.gds), LVS output_buffer / pgia_top / slot9_wrapper, DRC.
Exit: 0 done / already fixed, 1 nothing written (layout differs from what the script expects), 2 file problem.
"""
import argparse
import os
import shutil
import sys
import time

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT = ["gds/pgia_top/output_buffer.gds", "gds/pgia_top/pgia_top.gds", "gds/slot9_wrapper/slot9_wrapper.gds"]
M3, V3, M4 = (30, 0), (49, 0), (50, 0)
TOL = 6

BUF_DELETE = [(M3, (0.000, 20.320, 0.670, 20.565)), (M3, (0.000, 0.880, 0.240, 19.400))]
BUF_ADD = [
    (M3, (0.000, 20.320, 0.240, 20.565)),     # upper stub, shortened
    (M3, (0.000, 19.640, 0.240, 20.320)),     # ties the upper stub down to the lower stub (input -> OTA VINP)
    (M3, (0.000, 0.880, 0.240, 18.950)),      # feedback strap, cut below the lower stub
    (M3, (-0.150, 18.450, 0.350, 18.950)),    # pad for the via at the strap end
    (V3, (0.005, 18.605, 0.195, 18.795)),
    (M4, (-0.150, 18.550, 0.350, 21.250)),    # jumper over the input stub: vertical ...
    (M4, (-0.150, 20.750, 1.450, 21.250)),    # ... and horizontal part
    (V3, (1.005, 20.880, 1.195, 21.070)),
    (M3, (0.850, 20.320, 1.450, 21.150)),     # landing pad on the OTA VINN pad
]
TOP_PAD_OLD = (M3, (379.720, 225.040, 380.520, 225.840))
TOP_PAD_NEW = (M3, (379.720, 225.040, 380.400, 225.840))


def box(t):
    return db.Box(*(round(v * 1000) for v in t))


def same(a, b):
    return all(abs(x - y) <= TOL for x, y in ((a.left, b.left), (a.bottom, b.bottom), (a.right, b.right), (a.top, b.top)))


def find(ly, cell, layer, want):
    li = ly.find_layer(*layer)
    if li is None:
        return []
    w = box(want)
    return [s for s in cell.shapes(li).each() if same(s.bbox(), w)]


def state(ly, buf, top):
    """'old' | 'new' | 'mixed' | 'unknown' for the buffer cell, plus the pgia_top pad state."""
    old = [bool(find(ly, buf, l, b)) for l, b in BUF_DELETE]
    new = [bool(find(ly, buf, l, b)) for l, b in BUF_ADD]
    if all(old) and not any(new):
        s = "old"
    elif not any(old) and all(new):
        s = "new"
    else:
        s = "mixed"
    pad = "n/a"
    if top is not None:
        po, pn = bool(find(ly, top, *TOP_PAD_OLD)), bool(find(ly, top, *TOP_PAD_NEW))
        pad = "old" if po and not pn else "new" if pn and not po else "mixed"
    return s, pad


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gds", nargs="*", help="layouts to patch (default: the three that contain the buffer)")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    files = [os.path.join(ROOT, f) for f in (a.gds or DEFAULT)]
    plans, rc = [], 0
    for f in files:
        rel = os.path.relpath(f, ROOT)
        if not os.path.isfile(f):
            print(f"fix_buffer_polarity: {rel} not found", file=sys.stderr)
            return 2
        ly = db.Layout()
        ly.read(f)
        buf, top = ly.cell("output_buffer"), ly.cell("pgia_top")
        if buf is None:
            print(f"fix_buffer_polarity: {rel}: no cell output_buffer")
            continue
        s, pad = state(ly, buf, top)
        print(f"fix_buffer_polarity: {rel}: buffer {s}, pgia_top pad {pad}")
        if s == "new" and pad in ("new", "n/a"):
            continue
        if s == "old" and pad in ("old", "n/a"):
            plans.append((f, ly, buf, top))
        else:
            print(f"fix_buffer_polarity: {rel}: layout differs from what the script expects (edited by hand since?); not touching it", file=sys.stderr)
            rc = 1
    if rc or a.check or not plans:
        if not plans and not rc:
            print("fix_buffer_polarity: nothing to do (already fixed)")
        return rc
    stamp = time.strftime("%Y-%m-%d_%Hh%Mm%S")
    for f, ly, buf, top in plans:
        bdir = os.path.join(os.path.dirname(f), "backups")
        os.makedirs(bdir, exist_ok=True)
        name = os.path.splitext(os.path.basename(f))[0]
        bk = os.path.join(bdir, f"{name}_backup_{stamp}_fix_buffer_polarity.gds")
        shutil.copy2(f, bk)
        for layer, b in BUF_DELETE:
            for s in find(ly, buf, layer, b)[:1]:
                s.delete()
        for layer, b in BUF_ADD:
            buf.shapes(ly.layer(*layer)).insert(box(b))
        if top is not None:
            for s in find(ly, top, *TOP_PAD_OLD)[:1]:
                s.delete()
            top.shapes(ly.layer(*TOP_PAD_NEW[0])).insert(box(TOP_PAD_NEW[1]))
        ly.write(f)
        print(f"fix_buffer_polarity: patched {os.path.relpath(f, ROOT)} (backup {os.path.relpath(bk, ROOT)})")
    print("fix_buffer_polarity: next: scripts/export_slot_gds.py, LVS output_buffer / pgia_top / slot9_wrapper, DRC")
    return 0


if __name__ == "__main__":
    sys.exit(main())
