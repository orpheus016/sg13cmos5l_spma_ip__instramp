#!/usr/bin/env python3
"""Read the cell registry cells.yaml.

  cellinfo.py <cell> <key>          value of a key (gds/sch/cace/top are printed as absolute paths; lists space separated)
  cellinfo.py --list                all cell names
  cellinfo.py --matrix cace|verify  JSON list of cell names for a GitHub Actions matrix (cells having the stage cace / drc|lvs)
  cellinfo.py <cell> mc-params      names of the CACE parameters that are Monte Carlo runs (for run_cace.sh -sp)
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


def main():
    a = sys.argv[1:]
    cells = load()
    if not a:
        sys.exit(__doc__)
    if a[0] == "--list":
        print("\n".join(cells))
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
