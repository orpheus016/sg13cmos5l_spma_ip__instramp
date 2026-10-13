#!/usr/bin/env python3
"""Helpers for the SG13CMOS5L KLayout LVS flow (used by scripts/run_lvs.sh, usable on their own).

  lvs_tools.py netlist-fix <in.spice> <out.spice>
      xschem LVS netlist -> netlist the KLayout reader accepts (.param hoisted into the .subckt, .save dropped)
  lvs_tools.py labels <layout.gds> <topcell> <netlist.spice> [--write <out.gds>]
      check that every subckt port has a label on a text layer the LVS deck reads (<metal>/25);
      with --write also save a scratch copy of the GDS where the missing ones are copied from the pin/drawing layer
  lvs_tools.py report <file.lvsdb>
      human readable result: per device and per net, with layout coordinates; exit 0 only on a full match

Run with `python3 -I` (needs the `klayout` python module, which ships with the KLayout of the tool image).
"""
import argparse
import re
import sys


# ----------------------------------------------------------------------------- netlist
def subckt_ports(text):
    for line in text.splitlines():
        if line.lower().startswith(".subckt"):
            toks = line.split()
            ports = []
            for t in toks[2:]:
                if "=" in t:
                    break
                ports.append(t)
            return toks[1], ports
    return None, []


def cmd_netlist_fix(args):
    text = open(args.inp).read()
    name, _ = subckt_ports(text)
    if name is None:
        sys.exit("netlist-fix: no '.subckt' line. The netlist was not generated with lvs_netlist=1 "
                 "(a simulation netlist has '**.subckt' commented out).")
    out, params, hoisted = [], [], False
    for line in text.splitlines():
        low = line.lower()
        if low.startswith(".param"):
            params.append(line)
            continue
        if low.startswith(".save") or low.startswith(".end") and not low.startswith(".ends"):
            continue
        out.append(line)
        if low.startswith(".subckt") and not hoisted:
            out.append("*PARAMS_HOISTED")
            hoisted = True
    i = out.index("*PARAMS_HOISTED")
    out[i:i + 1] = params
    if not any(l.lower().startswith(".ends") for l in out):
        sys.exit("netlist-fix: no '.ends' line")
    open(args.out, "w").write("\n".join(out) + "\n")
    print(f"netlist-fix: {args.out}  (subckt {name}, {len(params)} .param lines moved inside)")


# ----------------------------------------------------------------------------- labels
# layer -> name; the LVS deck reads net names from (layer, 25); people usually label on (layer, 2) pin or (layer, 0)
TEXT_LAYERS = {8: "Metal1", 10: "Metal2", 30: "Metal3", 50: "Metal4", 67: "Metal5", 126: "TopMetal1", 134: "TopMetal2"}


def cmd_labels(args):
    import klayout.db as db

    _, ports = subckt_ports(open(args.netlist).read())
    if not ports:
        sys.exit("labels: no subckt ports found in " + args.netlist)
    ly = db.Layout()
    ly.read(args.gds)
    top = ly.cell(args.topcell)
    if top is None:
        sys.exit(f"labels: cell '{args.topcell}' not in {args.gds}")

    found = {}  # port -> {(layer, dt): [(x_um, y_um)]}
    for layer in TEXT_LAYERS:
        for dt in (0, 2, 25):
            li = ly.find_layer(layer, dt)
            if li is None:
                continue
            it = db.RecursiveShapeIterator(ly, top, li)
            while not it.at_end():
                sh = it.shape()
                if sh.is_text():
                    p = it.trans() * sh.text.trans.disp
                    found.setdefault(sh.text.string, {}).setdefault((layer, dt), []).append((p.x, p.y))
                it.next()

    ok, missing, add = [], [], []
    for p in ports:
        where = found.get(p, {})
        if any(dt == 25 for (_, dt) in where):
            ok.append(p)
            continue
        missing.append(p)
        src = [(k, v) for k, v in where.items()]
        if src:
            (layer, dt), pts = src[0]
            for x, y in pts:
                add.append((layer, p, x, y))
            print(f"  {p:10s} NOT visible to LVS: label is on {layer}/{dt} ({TEXT_LAYERS[layer]}), needs {layer}/25")
        else:
            near = [k for k in found if k.lower() == p.lower()]
            print(f"  {p:10s} NO label at all" + (f" (found with other case: {near})" if near else ""))
    print(f"labels: {len(ok)}/{len(ports)} ports have a /25 text label"
          + (f"; missing: {', '.join(missing)}" if missing else ""))

    if args.write and add:
        for layer, txt, x, y in add:
            ly.cell(args.topcell).shapes(ly.layer(layer, 25)).insert(db.Text(txt, db.Trans(x, y)))
        ly.write(args.write)
        print(f"labels: wrote scratch copy with {len(add)} added /25 labels -> {args.write}")
    sys.exit(0 if not missing else 3)


# ----------------------------------------------------------------------------- report
def cmd_report(args):
    import klayout.db as db

    X = db.NetlistCrossReference
    names = {getattr(X, n): n for n in ("Match", "NoMatch", "Mismatch", "Skipped", "MatchWithWarning") if hasattr(X, n)}
    st = lambda s: names.get(s, "None")
    good = {X.Match}

    l = db.LayoutVsSchematic()
    l.read(args.lvsdb)
    x = l.xref()
    all_ok = True

    def loc(d):
        try:
            t = d.trans
            return f"({t.disp.x:.2f},{t.disp.y:.2f}) um"
        except Exception:
            return ""

    for cp in x.each_circuit_pair():
        lay, sch = cp.first(), cp.second()
        print(f"circuit  layout={lay.name if lay else None}  schematic={sch.name if sch else None}  -> {st(cp.status())}")
        if not (lay and sch):
            print("  one side has no counterpart: top cell name differs from the schematic .subckt name")
            all_ok = False
            continue
        if cp.status() not in good:
            all_ok = False
        lp = [p.name() for p in lay.each_pin()]
        sp = [p.name() for p in sch.each_pin()]
        print(f"  ports layout   : {' '.join(lp) or '(none: no label on a /25 text layer?)'}")
        print(f"  ports schematic: {' '.join(sp)}")
        print("  devices (layout <-> schematic):")
        for dp in x.each_device_pair(cp):
            a, b = dp.first(), dp.second()
            tag = "ok " if dp.status() in good else "!! "
            cls = (a or b).device_class().name
            print(f"   {tag}{(a.expanded_name() if a else '-'):6s} {cls:14s} <-> {(b.expanded_name() if b else '-'):6s} {st(dp.status()):16s} {loc(a) if a else ''}")
        bad_nets = []
        for n in x.each_net_pair(cp):
            a, b = n.first(), n.second()
            if n.status() not in good:
                bad_nets.append((a.expanded_name() if a else None, b.expanded_name() if b else None, st(n.status())))
        if bad_nets:
            print("  nets that do not match (layout <-> schematic):")
            for a, b, s in bad_nets:
                hint = ""
                if a is None:
                    hint = "  <- only in schematic: merged with another net (short) or open in layout"
                elif b is None:
                    hint = "  <- only in layout: extra/unlabelled net (open in layout?)"
                print(f"   !! {str(a):10s} <-> {str(b):10s} {s}{hint}")
    print("RESULT:", "MATCH" if all_ok else "MISMATCH")
    sys.exit(0 if all_ok else 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("netlist-fix"); p.add_argument("inp"); p.add_argument("out"); p.set_defaults(f=cmd_netlist_fix)
    p = sub.add_parser("labels"); p.add_argument("gds"); p.add_argument("topcell"); p.add_argument("netlist")
    p.add_argument("--write"); p.set_defaults(f=cmd_labels)
    p = sub.add_parser("report"); p.add_argument("lvsdb"); p.set_defaults(f=cmd_report)
    a = ap.parse_args()
    a.f(a)


if __name__ == "__main__":
    main()
