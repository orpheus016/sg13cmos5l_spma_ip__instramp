#!/usr/bin/env python3
"""Make a PEX copy of a GDS: strip the internals of MoM capacitors.

  pex_prepare_gds.py <in.gds> <out.gds> --top <cell> [--min-width 0.4] [--no-flatten]

Why: cap_cmomi/cap_cmomf are simulated with their compact model. Their drawn fingers (hundreds of 0.2 um
polygons per metal plus ~10k vias per cap) are plain metal/via shapes to a parasitic extractor, which then
(a) takes forever (kpex 2.5D: >15 min, >4 GB for the OTA) and (b) would count the capacitance twice.
Kept inside every cap cell: the recognition marker (so LVS still finds the device), the pin shapes, text, and the
wide Metal4 bus bars (>= --min-width, the terminals the top level wires connect to). Removed: all other
Metal1-4 shapes and all Via1-3 shapes in cells whose name starts with cap_cmomi / cap_cmomf. The original GDS
is not modified.

Flattening (default): kpex runs a hierarchical (deep) LVS, and then extracts parasitics only for nets visible at the top
level (an OTA instance would contain devices but none of its internal parasitics). The copy is therefore flattened into
--top. Net labels (text on <metal>/25) in sub-cells are removed first: every OTA instance carries its own VINN/VOUT/...
labels, which would give several different nets the same name after flattening and confuse the extractor. Only the
labels of the top cell name nets; everything else becomes $N. Text on other layers in sub-cells (annotations such as
"Source", "Drain Bias" on Metal1) is removed as well: Magic treats it as a net label and would short repeated instances.

Sidecar <out>.caps (flattened copies only): one line "x1 y1 x2 y2" (um) per MoM cap marker = a point on each of its two
Metal4 terminal bars. scripts/pex_magic.tcl asks Magic which net is under each point, so the compact-model caps can be
put back on the right nets of a Magic RC netlist.
"""
import argparse
import sys

import klayout.db as db

METALS = {(8, 0): "Metal1", (10, 0): "Metal2", (30, 0): "Metal3", (50, 0): "Metal4"}
VIAS = {(19, 0), (29, 0), (49, 0)}
MARK = (99, 39), (99, 40)  # recog_mom, recog_momf


def write_caps(ly, top, path):
    """one point on each of the two Metal4 terminal bars of every MoM cap marker (um)"""
    m4 = db.Region(top.begin_shapes_rec(ly.layer(50, 0)))
    marks = db.Region()
    for l in MARK:
        li = ly.find_layer(*l)
        if li is not None:
            marks += db.Region(top.begin_shapes_rec(li))
    lines = []
    for mk in marks.merged().each():
        bars = sorted((m4 & db.Region(mk.bbox())).merged().each(), key=lambda p: -p.area())[:2]
        if len(bars) < 2:
            print(f"pex_prepare_gds: WARNING cap marker at {mk.bbox()} has {len(bars)} Metal4 bar(s), skipped")
            continue
        pts = [(b.bbox().center().x * ly.dbu, b.bbox().center().y * ly.dbu) for b in bars]
        lines.append(" ".join(f"{v:.3f}" for p in pts for v in p))
    with open(path, "w") as f:
        f.write("\n".join(lines) + ("\n" if lines else ""))
    print(f"pex_prepare_gds: {len(lines)} cap terminal pair(s) -> {path}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("inp")
    ap.add_argument("out")
    ap.add_argument("--top", help="top cell (needed for flattening)")
    ap.add_argument("--no-flatten", action="store_true", help="keep the hierarchy")
    ap.add_argument("--min-width", type=float, default=0.4, help="um; Metal4 shapes at least this wide are kept")
    a = ap.parse_args()

    ly = db.Layout()
    ly.read(a.inp)
    keep_w = int(round(a.min_width / ly.dbu))
    ncells = nrem = nkeep = 0
    for cell in ly.each_cell():
        if not cell.name.lower().startswith(("cap_cmomi", "cap_cmomf")):
            continue
        ncells += 1
        for (l, d), name in list(METALS.items()) + [(v, "Via") for v in VIAS]:
            li = ly.find_layer(l, d)
            if li is None:
                continue
            for s in list(cell.shapes(li).each()):
                if (l, d) == (50, 0):
                    b = s.bbox()
                    if min(b.width(), b.height()) >= keep_w:
                        nkeep += 1
                        continue
                cell.shapes(li).erase(s)
                nrem += 1
    if ncells == 0:
        print("pex_prepare_gds: no cap_cmomi/cap_cmomf cells found")
    if not a.no_flatten:
        top = ly.cell(a.top) if a.top else None
        if top is None:
            sys.exit("pex_prepare_gds: --top <cell> is required (or --no-flatten)")
        nlab = 0
        for cell in ly.each_cell():
            if cell.cell_index() == top.cell_index():
                continue
            for li in ly.layer_indexes():
                for s in list(cell.shapes(li).each()):
                    if s.is_text():
                        cell.shapes(li).erase(s)
                        nlab += 1
        top.flatten(True)
        ly.prune_subcells(top.cell_index(), -1)
        print(f"pex_prepare_gds: flattened into {a.top}, removed {nlab} texts in sub-cells")
        write_caps(ly, top, a.out + ".caps")
    ly.write(a.out)
    print(f"pex_prepare_gds: {ncells} cap cell(s): removed {nrem} shapes, kept {nkeep} Metal4 bars -> {a.out}")


if __name__ == "__main__":
    main()
