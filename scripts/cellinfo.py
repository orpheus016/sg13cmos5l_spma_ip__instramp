#!/usr/bin/env python3
"""Read the cell registry cells.yaml.

  cellinfo.py <cell> <key>          value of a key (gds/sch/cace/top are printed as absolute paths; lists space separated)
  cellinfo.py --list                all cell names
  cellinfo.py --matrix cace|verify  JSON list of cell names for a GitHub Actions matrix (cells having the stage cace / drc|lvs)
  cellinfo.py <cell> mc-params      names of the CACE parameters that are Monte Carlo runs (for run_cace.sh -sp)
  cellinfo.py --check [cell]        validate the registry: gds / sch exist, `top` is a top-level cell of the gds and equals the
                                    schematic name (= .subckt name). One cell, or all cells. Exit 2 + message on stderr if not.
                                    (a cell that is not in the registry passes silently: the scripts then use their own defaults)
  cellinfo.py --order               all cell names, children (`children:`) before their parents: leaves -> chip
Exit 1 if the cell or key does not exist (scripts then fall back to their own defaults).
"""
import json
import os
import sys

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PATHS = ("gds", "sch", "cace")


def load():
    return yaml.safe_load(open(os.path.join(ROOT, "cells.yaml")))


def gds_top_cells(path):
    """Names of the top-level cells of a GDS, or None if klayout.db is not importable (then only the static checks run)."""
    try:
        import klayout.db as db
    except ImportError:
        return None
    ly = db.Layout()
    ly.read(path)
    return [c.name for c in ly.top_cells()]


def check_cell(name, v):
    """List of problems (strings) of one registry entry."""
    gds = v.get("gds")
    if not gds:
        return []  # schematic-only cell, nothing to compare
    top = v.get("top", name)
    path = os.path.join(ROOT, gds)
    if not os.path.isfile(path):  # flow.sh reports such a stage as SKIP ("no layout"), the scripts exit 2 on their own: not an error here
        print(f"cellinfo: note: {name}: gds {gds} does not exist yet", file=sys.stderr)
        return []
    errs = []
    tops = gds_top_cells(path)
    if tops is None:
        print("cellinfo: note: klayout.db not importable, top cell of the gds not checked", file=sys.stderr)
    if tops is not None and top not in tops:
        errs.append(f"{name}: top cell '{top}' is not a top-level cell of {gds} (top cells there: {', '.join(tops) or 'none'}); "
                    f"fix `top:` in cells.yaml or use the GDS that really holds '{top}'")
    sch = v.get("sch")
    if sch:
        if not os.path.isfile(os.path.join(ROOT, sch)):
            print(f"cellinfo: note: {name}: sch {sch} does not exist yet", file=sys.stderr)
        elif os.path.splitext(os.path.basename(sch))[0] != top:
            errs.append(f"{name}: layout top '{top}' differs from the schematic {sch} (.subckt {os.path.splitext(os.path.basename(sch))[0]}); "
                        f"LVS compares those two, they must have the same name")
    return errs


def order(cells):
    """Cell names, children before parents (depth-first, registry order otherwise); children not in the registry are ignored."""
    done, active, out = set(), [], []

    def visit(n):
        if n in done:
            return
        if n in active:
            sys.exit(f"cellinfo: cycle in `children:` ({' -> '.join(active + [n])})")
        active.append(n)
        for c in cells[n].get("children") or []:
            if c in cells:
                visit(c)
        active.pop()
        done.add(n)
        out.append(n)

    for n in cells:
        visit(n)
    return out


def main():
    a = sys.argv[1:]
    cells = load()
    if not a:
        sys.exit(__doc__)
    if a[0] == "--list":
        print("\n".join(cells))
        return
    if a[0] == "--order":
        print("\n".join(order(cells)))
        return
    if a[0] == "--check":
        names = [a[1]] if len(a) > 1 else list(cells)
        errs = [e for n in names if n in cells for e in check_cell(n, cells[n])]
        for n in names:
            for c in (cells.get(n) or {}).get("children") or []:
                if c not in cells:
                    print(f"cellinfo: note: {n}: child '{c}' is not in cells.yaml", file=sys.stderr)
        if errs:
            print("cellinfo: registry check FAILED:\n  " + "\n  ".join(errs), file=sys.stderr)
            sys.exit(2)
        return
    if a[0] == "--matrix":
        want = {"cace": ("cace",), "verify": ("drc", "lvs")}[a[1]]
        print(json.dumps([c for c, v in cells.items() if any(s in (v.get("stages") or []) for s in want)]))
        return
    cell, key = a[0], a[1]
    v = cells.get(cell)
    if v is None:
        sys.exit(1)
    if key == "mc-params":
        y = yaml.safe_load(open(os.path.join(ROOT, v["cace"])))
        print(" ".join(n for n, p in y["parameters"].items() if "iterations" in p.get("conditions", {})))
        return
    if key == "top":
        print(v.get("top", cell))
        return
    val = v.get(key)
    if val is None:
        sys.exit(1)
    if key in PATHS:
        val = os.path.join(ROOT, val)
    print(" ".join(map(str, val)) if isinstance(val, list) else val)


if __name__ == "__main__":
    main()
