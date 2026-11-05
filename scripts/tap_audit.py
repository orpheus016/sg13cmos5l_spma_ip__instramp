#!/usr/bin/env python3
"""Latch-up / tap audit of a layout (what LVS and the PDK DRC deck do not check).

  tap_audit.py <cell> | --gds <file> --top <cell>   [--limit 20] [--json docs/<cell>/audit.json] [--strict] [--baseline f] [--accept-abut]

Layer logic is the one of the PDK LVS deck (rule_decks/general_derivations.lvs): n+ is implicit in SG13CMOS5L,
  pactiv = Activ & pSD        nactiv = Activ - pSD        (no nSD is drawn)
  n-tie  = nactiv in NWell, not under GatPoly, with a Cont        p-tie = pactiv outside NWell, not under GatPoly, with a Cont
Checks (limit in um, default 20 = the IHP latch-up guideline, `LU_b` in sg13cmos5l_tech_default.json):
  LU.a  every p+ Activ inside an NWell is within <limit> of an n-tie          (the PDK deck implements this one; repeated as a cross-check)
  LU.b  every n+ Activ outside NWells (NMOS source/drain) is within <limit> of a p-tie
        (the PDK deck names LU.b, prints "Executing rule LU.b" and checks nothing: this audit is the only check of it)
  WELL  every NWell polygon that contains p+ Activ also contains an n-tie
  ABUT  p+ and n+ Activ sharing an edge outside standard cells: with salicide that is a short (the LVS deck merges them, rule
        psd_ntap_abutt). Legitimate as a deliberate abutted tie (source tied to the well/substrate: the analog cells have dozens), a bug
        otherwise - the pseudo-resistor n-tap bug of pgia_top looked exactly like this. Without a baseline the sites are only listed
        (warning). With a baseline (docs/<cell>/audit_baseline.json, written by --accept-abut after a person has looked at the list)
        every abutment that is not in the baseline is a violation.
Distances are measured with a sized() (octagonal) region, which is slightly generous at corners (<= 8 %).
Exit: 0 clean (warnings allowed unless --strict), 1 violations, 2 setup problem.
"""
import argparse
import json
import os
import subprocess
import sys

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L = dict(activ=(1, 0), gatpoly=(5, 0), cont=(6, 0), psd=(14, 0), nwell=(31, 0))
STD_PREFIX = "sg13cmos5l_"


def region(ly, top, key, exclude=()):
    """Merged flat Region of one layer below `top`; cells whose index is in `exclude` (and what is only reachable through them) are skipped."""
    li = ly.find_layer(*L[key])
    if li is None:
        return db.Region()
    it = db.RecursiveShapeIterator(ly, top, li)
    if exclude:
        it.unselect_cells(list(exclude))
    r = db.Region(it)
    r.merge()
    return r


def boxes_of(r, n=8):
    out = []
    for p in list(r.each())[:n]:
        b = p.bbox()
        out.append([round(b.left / 1000, 2), round(b.bottom / 1000, 2), round(b.right / 1000, 2), round(b.top / 1000, 2)])
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cell", nargs="?", help="registry cell (cells.yaml): gds and top cell are taken from there")
    ap.add_argument("--gds")
    ap.add_argument("--top")
    ap.add_argument("--limit", type=float, default=20.0, help="max distance to a tie in um")
    ap.add_argument("--json", help="write the result here (default docs/<cell>/audit.json for a registry cell)")
    ap.add_argument("--strict", action="store_true", help="warnings (ABUT without baseline) also fail")
    ap.add_argument("--baseline", help="accepted abutment sites (default docs/<cell>/audit_baseline.json for a registry cell)")
    ap.add_argument("--accept-abut", action="store_true", help="write the current abutment sites as the new baseline (review the list first!)")
    a = ap.parse_args()

    gds, top = a.gds, a.top
    if a.cell:
        info = lambda k: subprocess.run([sys.executable, "-I", os.path.join(ROOT, "scripts/cellinfo.py"), a.cell, k], capture_output=True, text=True)
        if not gds:
            r = info("gds")
            gds = r.stdout.strip() if r.returncode == 0 else None
        if not top:
            r = info("top")
            top = r.stdout.strip() if r.returncode == 0 else a.cell
    if not gds or not os.path.isfile(gds):
        print(f"tap_audit: no layout ({gds or 'none given'}); pass a registry cell or --gds", file=sys.stderr)
        return 2
    ly = db.Layout()
    ly.read(gds)
    topc = ly.cell(top or "")
    if topc is None:
        print(f"tap_audit: cell '{top}' not in {gds} (top cells: {', '.join(c.name for c in ly.top_cells())})", file=sys.stderr)
        return 2

    um = 1000  # dbu per um (dbu 0.001)
    lim = round(a.limit * um)
    activ, gate, cont, psd, nwell = (region(ly, topc, k) for k in ("activ", "gatpoly", "cont", "psd", "nwell"))
    pactiv = activ & psd
    nactiv = activ - psd
    ntie = ((nactiv & nwell) - gate).interacting(cont)
    ptie = ((pactiv - nwell) - gate).interacting(cont)
    p_in_well = pactiv & nwell
    n_in_sub = nactiv - nwell

    res = dict(layout=os.path.relpath(gds, ROOT) if gds.startswith(ROOT) else gds, top=top, limit_um=a.limit, violations={}, warnings={},
               counts=dict(ntie=ntie.count(), ptie=ptie.count(), p_activ_in_nwell=p_in_well.count(), n_activ_in_substrate=n_in_sub.count(), nwell=nwell.count()))

    # LU.a / LU.b: portions of the device Activ farther than <limit> from a tie
    far = {
        "LU.a (p+ Activ in NWell to n-tie)": p_in_well - ntie.sized(lim, lim, 2),
        "LU.b (n+ Activ in substrate to p-tie)": n_in_sub - ptie.sized(lim, lim, 2),
    }
    for name, r in far.items():
        if not r.is_empty():
            res["violations"][name] = dict(count=r.count(), area_um2=round(r.area() / 1e6, 2), where=boxes_of(r))
    # WELL: nwell polygon with p+ but no tie
    bad = db.Region()
    for poly in nwell.each():
        pr = db.Region(poly)
        if not (p_in_well & pr).is_empty() and (ntie & pr).is_empty():
            bad.insert(poly)
    if not bad.is_empty():
        res["violations"]["WELL (NWell with p+ Activ and no n-tie)"] = dict(count=bad.count(), where=boxes_of(bad))
    # ABUT: shared edges p+/n+ Activ, outside standard cells (their abutted ties are by design)
    std = [c.cell_index() for c in ly.each_cell() if c.name.startswith(STD_PREFIX)]
    if std:
        act_ns, psd_ns = region(ly, topc, "activ", std), region(ly, topc, "psd", std)
        p_ns, n_ns = act_ns & psd_ns, act_ns - psd_ns
    else:
        p_ns, n_ns = pactiv, nactiv
    shared = p_ns.edges() & n_ns.edges()
    sites = sorted({(round(e.bbox().center().x / um), round(e.bbox().center().y / um)) for e in shared.each()})
    res["abut_sites"] = [list(t) for t in sites]
    bpath = a.baseline or (os.path.join(ROOT, "docs", a.cell, "audit_baseline.json") if a.cell else None)
    if a.accept_abut:
        if not bpath:
            print("tap_audit: --accept-abut needs a registry cell or --baseline <file>", file=sys.stderr)
            return 2
        os.makedirs(os.path.dirname(bpath), exist_ok=True)
        json.dump(dict(layout=res["layout"], top=top, abut_sites=res["abut_sites"], note="accepted p+/n+ Activ abutments (deliberate abutted ties); written by scripts/tap_audit.py --accept-abut"), open(bpath, "w"), indent=1)
        print(f"tap_audit: baseline with {len(sites)} abutment site(s) written to {os.path.relpath(bpath, ROOT)}")
        known = set(map(tuple, res["abut_sites"]))
        have_base = True
    else:
        have_base = bool(bpath) and os.path.isfile(bpath)
        known = set(map(tuple, json.load(open(bpath))["abut_sites"])) if have_base else set()
    near = lambda p: any((p[0] + dx, p[1] + dy) in known for dx in (-1, 0, 1) for dy in (-1, 0, 1))
    new_sites = [t for t in sites if not near(t)] if have_base else sites
    if new_sites:
        sel = [e for e in shared.each() if (round(e.bbox().center().x / um), round(e.bbox().center().y / um)) in set(new_sites)]
        where = [dict(x=round(e.bbox().center().x / um, 2), y=round(e.bbox().center().y / um, 2), length_um=round(e.length() / um, 2)) for e in sel[:10]]
        key = "ABUT (p+ and n+ Activ share an edge outside standard cells" + (", NOT in the accepted baseline)" if have_base else ")")
        entry = dict(count=len(sel), length_um=round(sum(e.length() for e in sel) / um, 2), where=where)
        (res["violations"] if have_base else res["warnings"])[key] = entry
    res["abut_total_sites"], res["abut_baseline"] = len(sites), (os.path.relpath(bpath, ROOT) if have_base else None)

    print(f"tap audit of {res['layout']} top {top}: {res['counts']['ntie']} n-tie, {res['counts']['ptie']} p-tie polygons, "
          f"{res['counts']['p_activ_in_nwell']} p+ / {res['counts']['n_activ_in_substrate']} n+ device Activ polygons, limit {a.limit:g} um")
    for k, v in res["violations"].items():
        print(f"  FAIL {k}: {v['count']} spot(s){', ' + str(v['area_um2']) + ' um2' if 'area_um2' in v else ''}; first at (um) {v['where'][:3]}")
    for k, v in res["warnings"].items():
        print(f"  WARN {k}: {v['count']} edge piece(s), {v['length_um']} um in total; first at {v['where'][:3]}")
    if not res["violations"] and not res["warnings"]:
        print("  all device Activ within the tie distance, every NWell tied; " + (f"{len(sites)} p+/n+ abutment site(s), all in the accepted baseline" if sites else "no p+/n+ abutment outside standard cells"))
    out = a.json or (os.path.join(ROOT, "docs", a.cell, "audit.json") if a.cell else None)
    if out:
        os.makedirs(os.path.dirname(out), exist_ok=True)
        json.dump(res, open(out, "w"), indent=1)
    return 1 if res["violations"] or (a.strict and res["warnings"]) else 0


if __name__ == "__main__":
    sys.exit(main())
