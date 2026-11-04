#!/usr/bin/env python3
"""Write the file the Chipalooza harness looks for: gds/slot_9.gds with the top cell `slot_9`.

  export_slot_gds.py [--src gds/slot9_wrapper/slot9_wrapper.gds] [--out gds/slot_9.gds] [--cell slot_9]
                     [--golden <harness>/gds/slot9_wrapper.gds] [--sanitize] [--check]

The harness (sg13cmos5l_ocd_chipalooza/scripts/get_project_gds.sh) clones this repository as dependencies/slot_9 and takes
slot_<N>.gds from final/gds/ or gds/ (error if missing, if .gds and .gds.gz both exist, or if there are several candidates
outside those folders). It aborts unless the file contains a cell named slot_9, reads it read-only with Magic and puts it over the
wrapper location. Our layout work is done in gds/slot9_wrapper/slot9_wrapper.gds (the golden frame plus the project), so this
script only renames the top cell; no geometry is touched.

Checks, all of them also with --check (which writes nothing and exits 1 when gds/slot_9.gds is missing or stale):
  - the source has one top cell, dbu 0.001, and the harness frame size (537.15 x 273.00 um)
  - golden frame (when the harness repo is next to this one, or --golden): every golden polygon is still in the top cell and every golden
    text label is at the same place
  - the output has one top cell named slot_9, same geometry (XOR per layer, flattened) and same labels as the source
  - exactly one slot_9.gds* exists in the repository (the harness refuses candidates it cannot rank)
--sanitize replaces `$` in cell names (KLayout pcell names such as pmos$14) by `_`; off by default, see scripts/harness_trial.sh
for the check that Magic reads the names as they are. Exit: 0 ok, 1 check failed / stale, 2 cannot run.
"""
import argparse
import os
import sys

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRAME_UM = (537.15, 273.0)
DEFAULT_SRC = "gds/slot9_wrapper/slot9_wrapper.gds"
DEFAULT_OUT = "gds/slot_9.gds"
DEFAULT_GOLDEN = os.path.join(os.path.dirname(ROOT), "sg13cmos5l_ocd_chipalooza", "gds", "slot9_wrapper.gds")


def load(path):
    ly = db.Layout()
    ly.read(path)
    return ly


def top_of(ly, what):
    tops = list(ly.top_cells())
    if len(tops) != 1:
        raise ValueError(f"{what}: {len(tops)} top cells ({', '.join(c.name for c in tops)}), need exactly 1")
    return tops[0]


def labels(ly, top):
    """{(layer, datatype, text, x_dbu, y_dbu)} of the text shapes drawn directly in the top cell."""
    out = set()
    for li in ly.layer_indices():
        info = ly.get_info(li)
        for s in top.shapes(li).each():
            if s.is_text():
                out.add((info.layer, info.datatype, s.text.string, s.text.trans.disp.x, s.text.trans.disp.y))
    return out


def layer_regions(ly, top):
    """{(layer, datatype): merged flat Region} of all non-empty layers."""
    out = {}
    for li in ly.layer_indices():
        info = ly.get_info(li)
        r = db.Region(top.begin_shapes_rec(li))
        if not r.is_empty():
            r.merge()
            out[(info.layer, info.datatype)] = r
    return out


def xor_differences(a, b):
    """Layers where two {layer: Region} dicts differ -> {layer: area_um2 of the XOR}."""
    diff = {}
    for k in set(a) | set(b):
        x = (a.get(k) or db.Region()) ^ (b.get(k) or db.Region())
        if not x.is_empty():
            diff[k] = round(x.area() / 1e6, 4)
    return diff


def check_source(ly, top, golden_path, problems):
    if abs(ly.dbu - 0.001) > 1e-12:
        problems.append(f"source dbu is {ly.dbu}, the harness frame uses 0.001")
    bb = top.bbox()
    got = (round(bb.width() * ly.dbu, 3), round(bb.height() * ly.dbu, 3))
    if got != FRAME_UM:
        problems.append(f"source bounding box is {got[0]} x {got[1]} um, the harness slot wrapper is {FRAME_UM[0]} x {FRAME_UM[1]} um")
    if golden_path and os.path.isfile(golden_path):
        g = load(golden_path)
        gt = top_of(g, "golden")
        missing_lbl = sorted(t[2] for t in labels(g, gt) - labels(ly, top))
        if missing_lbl:
            problems.append(f"golden frame labels missing or moved: {', '.join(missing_lbl[:8])}{' ...' if len(missing_lbl) > 8 else ''}")
        lost = {}
        for li in g.layer_indices():
            info = g.get_info(li)
            rg = db.Region(gt.begin_shapes_rec(li))
            rg.merge()
            lo = ly.find_layer(info.layer, info.datatype)
            ro = db.Region(top.shapes(lo)) if lo is not None else db.Region()
            ro.merge()
            m = rg - ro
            if not m.is_empty():
                lost[(info.layer, info.datatype)] = round(m.area() / 1e6, 3)
        if lost:
            problems.append("golden frame polygons missing or changed (layer/datatype: um2): " + ", ".join(f"{k[0]}/{k[1]}: {v}" for k, v in sorted(lost.items())))
        return True
    return False


def other_candidates(out_path):
    found = []
    for d, dirs, files in os.walk(ROOT):
        dirs[:] = [x for x in dirs if x not in (".git", "runs", "__pycache__")]
        for f in files:
            if f in ("slot_9.gds", "slot_9.gds.gz") and os.path.abspath(os.path.join(d, f)) != os.path.abspath(out_path):
                found.append(os.path.relpath(os.path.join(d, f), ROOT))
    return found


def sanitized_names(ly):
    used = {c.name for c in ly.each_cell()}
    ren = {}
    for c in ly.each_cell():
        if "$" in c.name:
            new = c.name.replace("$", "_")
            while new in used:
                new += "_"
            used.add(new)
            ren[c.cell_index()] = new
    return ren


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--src", default=os.path.join(ROOT, DEFAULT_SRC))
    ap.add_argument("--out", default=os.path.join(ROOT, DEFAULT_OUT))
    ap.add_argument("--cell", default="slot_9", help="top cell name the harness expects")
    ap.add_argument("--golden", default=DEFAULT_GOLDEN, help="harness gds/slot9_wrapper.gds (frame check; skipped when absent)")
    ap.add_argument("--sanitize", action="store_true", help="replace $ in cell names by _")
    ap.add_argument("--check", action="store_true", help="write nothing; exit 1 if the output is missing or differs from the source")
    args = ap.parse_args()

    rel = lambda p: os.path.relpath(p, ROOT)
    if not os.path.isfile(args.src):
        print(f"export_slot_gds: source {rel(args.src)} not found", file=sys.stderr)
        return 2
    problems = []
    try:
        src = load(args.src)
        st = top_of(src, rel(args.src))
    except Exception as e:  # noqa: BLE001
        print(f"export_slot_gds: {e}", file=sys.stderr)
        return 2
    had_golden = check_source(src, st, args.golden, problems)
    print(f"export_slot_gds: source {rel(args.src)}: top '{st.name}', {src.cells()} cells, frame check "
          f"{'against ' + os.path.basename(os.path.dirname(os.path.dirname(args.golden))) if had_golden else 'skipped (harness repo not found)'}")

    ren = sanitized_names(src) if args.sanitize else {}
    src_regions = layer_regions(src, st)
    src_labels = labels(src, st)

    if args.check:
        if not os.path.isfile(args.out):
            problems.append(f"{rel(args.out)} does not exist (run scripts/export_slot_gds.py)")
        else:
            try:
                out = load(args.out)
                ot = top_of(out, rel(args.out))
                if ot.name != args.cell:
                    problems.append(f"top cell of {rel(args.out)} is '{ot.name}', the harness needs '{args.cell}'")
                d = xor_differences(src_regions, layer_regions(out, ot))
                if d:
                    problems.append(f"{rel(args.out)} is stale: geometry differs from the source on " + ", ".join(f"{k[0]}/{k[1]} ({v} um2)" for k, v in sorted(d.items())[:6]))
                if src_labels != labels(out, ot):
                    problems.append(f"{rel(args.out)} is stale: text labels differ from the source")
            except Exception as e:  # noqa: BLE001
                problems.append(str(e))
    else:
        if problems:
            print("export_slot_gds: refusing to write, the source has problems:", file=sys.stderr)
            for p in problems:
                print("  - " + p, file=sys.stderr)
            return 1
        # KLayout stamps the write date into the GDS header: rewriting an unchanged file would put a 4 MB binary diff into every commit
        if os.path.isfile(args.out) and not ren:
            try:
                cur = load(args.out)
                ct = top_of(cur, rel(args.out))
                if ct.name == args.cell and not xor_differences(src_regions, layer_regions(cur, ct)) and src_labels == labels(cur, ct):
                    print(f"export_slot_gds: {rel(args.out)} is already current, not rewritten")
                    extra = other_candidates(args.out)
                    if extra:
                        print("export_slot_gds: FAILED - more than one slot_9.gds* in the repository: " + ", ".join(extra), file=sys.stderr)
                        return 1
                    print("export_slot_gds: OK")
                    return 0
            except Exception:  # noqa: BLE001
                pass  # unreadable output: write it again
        st.name = args.cell
        for ci, new in ren.items():
            src.rename_cell(ci, new)
        os.makedirs(os.path.dirname(args.out), exist_ok=True)
        src.write(args.out)
        print(f"export_slot_gds: wrote {rel(args.out)} (top cell renamed '{st.name}'{', ' + str(len(ren)) + ' cell names sanitized' if ren else ''})")
        # read it back: what is on disk must equal the source
        out = load(args.out)
        ot = top_of(out, rel(args.out))
        d = xor_differences(src_regions, layer_regions(out, ot))
        if d or src_labels != labels(out, ot) or ot.name != args.cell:
            problems.append("the written file does not read back identical to the source")

    extra = other_candidates(args.out)
    if extra:
        problems.append("more than one slot_9.gds* in the repository, the harness would not know which one to use: " + ", ".join(extra))
    if os.path.isfile(args.out) and os.path.isfile(args.out + ".gz"):
        problems.append(f"both {rel(args.out)} and {rel(args.out)}.gz exist (the harness stops on that)")

    if problems:
        print("export_slot_gds: FAILED" if not args.check else "export_slot_gds: CHECK FAILED", file=sys.stderr)
        for p in problems:
            print("  - " + p, file=sys.stderr)
        return 1
    print("export_slot_gds: OK" + (" (up to date)" if args.check else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
