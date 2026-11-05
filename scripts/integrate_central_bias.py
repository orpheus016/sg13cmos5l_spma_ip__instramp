#!/usr/bin/env python3
"""Layout: put central_bias into pgia_top and split the shared bias net into the four block nets.

  integrate_central_bias.py [--gds f ...] [--check] [--dx-dy x y]

Before: one net (the harness bias pin IBIAS at the west edge) fans out as a tree to the four blocks: M3 trunk y=124 (x 4.5 .. 336) -> stage 2 branch at x=212,
stage 1 column at x=336 (down) and the M4 line y=162 (x 336 .. 495) with the buffer branch at x=376 and the instrumentation amplifier at x=495.
After: central_bias sits in the free band above stage 1 (x 218..318, y 110..138); the tree is cut into
    IB_IN   trunk (pin -> x 211.3)                 <- central_bias IB_IN        (left of the cell)
    IB_G2   stage 2 branch (column x=212)          <- IB_G2                     (left)
    IB_G1   stage 1 column (x=336, y < 117.5)      <- IB_G1                     (right)
    IB_IA   column x=336 (y 124..162) + M4 line + instrumentation amplifier  <- IB_IA   (right)
    IB_BUF  buffer branch (column x=376, M4 via cut) <- IB_BUF                  (right)
and AVSS / AVDD of the cell are tied to the TopMetal1 AVSS landing (300, 141) and the AVDD M4 line (x 311..313).
The connections are made by a small maze router on Metal2..4 (grid 0.8 um, wire 0.4 / 0.5 um) around everything that is there.
Applied to the cell `pgia_top` of gds/pgia_top/pgia_top.gds and gds/slot9_wrapper/slot9_wrapper.gds (identical routes), with timestamped backups and an exact-shape
guard (like fix_buffer_polarity.py). Afterwards: scripts/export_slot_gds.py, LVS pgia_top / slot9_wrapper (the schematic must contain x_bias), DRC.
Exit: 0 done / already integrated, 1 layout differs from what the script expects (nothing written), 2 file problem or no route found.
"""
import argparse
import heapq
import os
import shutil
import sys
import time

import klayout.db as db

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT = ["gds/pgia_top/pgia_top.gds", "gds/slot9_wrapper/slot9_wrapper.gds"]
CB_GDS = "gds/central_bias/central_bias.gds"
DX, DY = 215300, 110500          # placement of the central_bias cell (nm)
L = {"M2": (10, 0), "V2": (29, 0), "M3": (30, 0), "V3": (49, 0), "M4": (50, 0)}
TOL = 6
GRID = 800                        # nm
WIDTH = {"M2": 380, "M3": 380, "M4": 500}      # 380: two wires leaving the pins of the cell (0.6 um pitch) keep 0.22 um spacing
MARGIN = {"M2": 520, "M3": 520, "M4": 620}     # keep-out from foreign metal measured from the wire centre line (spacing 0.21 + half width + slack)

# exact shapes of the bias tree that are cut (layer, (x1, y1, x2, y2) um) -> replaced
CUT = [
    ("M3", (4.50, 123.83, 336.00, 124.17), [("M3", (4.50, 123.83, 211.30, 124.17))]),                   # trunk -> west part only (IB_IN)
    ("M2", (335.82, 42.80, 336.18, 124.00), [("M2", (335.82, 42.80, 336.18, 117.50))]),                 # stage 1 column: lower part = IB_G1
    ("V3", (375.90, 161.91, 376.10, 162.09), []),                                                       # buffer branch leaves the M4 line
]
# added metal that is not a routed wire: the supply ties
ADD = [
    ("M4", (299.70, 111.40, 300.30, 141.60)),                      # AVSS: pad stack of the NMOS block -> M4 landing of the TopMetal1 AVSS rail
]
# targets (layer, rect um): the pieces of the old tree each net is joined to
TARGET = {
    "IB_IN": [("M3", (4.50, 123.83, 211.30, 124.17))],
    "IB_G2": [("M2", (211.82, 124.00, 212.18, 177.81))],
    "IB_G1": [("M2", (335.82, 42.80, 336.18, 117.50))],
    "IB_IA": [("M2", (335.82, 124.00, 336.18, 162.00))],
    "IB_BUF": [("M3", (375.75, 161.75, 376.25, 162.25)), ("M2", (375.75, 161.75, 376.25, 162.25))],
}
ORDER = ["IB_IN", "IB_G2", "IB_G1", "IB_IA", "IB_BUF"]
WINDOW = (200.0, 100.0, 400.0, 240.0)    # um: routing area


def box(t):
    return db.Box(*(round(v * 1000) for v in t))


def same(a, b):
    return all(abs(x - y) <= TOL for x, y in ((a.left, b.left), (a.bottom, b.bottom), (a.right, b.right), (a.top, b.top)))


def find(cell, ly, layer, rect):
    li = ly.find_layer(*L[layer])
    if li is None:
        return []
    w = box(rect)
    return [s for s in cell.shapes(li).each() if same(s.bbox(), w)]


def ins(cell, ly, layer, rect):
    cell.shapes(ly.layer(*L[layer])).insert(box(rect) if isinstance(rect, tuple) else rect)


def state(ly, top):
    if ly.cell("central_bias") is not None:
        return "done"
    ok = all(find(top, ly, l, r) for l, r, _ in CUT)
    return "old" if ok else "unknown"


def pin_positions(cb):
    pins = {}
    for li in cb.layout().layer_indices():
        for s in cb.shapes(li).each():
            if s.is_text() and cb.layout().get_info(li).layer == 30 and cb.layout().get_info(li).datatype == 25:
                pins[s.text.string] = (s.text.x + DX, s.text.y + DY)
    return pins


# ---------------------------------------------------------------- router
class Router:
    def __init__(self, ly, top, net, start, targets):
        self.ly, self.top, self.net, self.start, self.targets = ly, top, net, start, targets
        x1, y1, x2, y2 = (round(v * 1000) for v in WINDOW)
        self.x1, self.y1 = x1, y1
        self.ox, self.oy = start
        self.nx0 = -((self.ox - x1) // GRID)
        self.nx1 = (x2 - self.ox) // GRID
        self.ny0 = -((self.oy - y1) // GRID)
        self.ny1 = (y2 - self.oy) // GRID
        self.layers = ["M2", "M3", "M4"]

    def pos(self, i, j):
        return self.ox + i * GRID, self.oy + j * GRID

    def blocked(self):
        """per layer: set of blocked (i, j) nodes."""
        win = db.Region(db.Box(round(WINDOW[0] * 1000) - 2000, round(WINDOW[1] * 1000) - 2000, round(WINDOW[2] * 1000) + 2000, round(WINDOW[3] * 1000) + 2000))
        nodes = db.Region()
        idx = {}
        for i in range(self.nx0, self.nx1 + 1):
            for j in range(self.ny0, self.ny1 + 1):
                x, y = self.pos(i, j)
                b = db.Box(x - 1, y - 1, x + 1, y + 1)
                nodes.insert(b)
                idx[(b.left, b.bottom)] = (i, j)
        out = {}
        for lay in self.layers:
            li = self.ly.find_layer(*L[lay])
            reg = db.Region(self.top.begin_shapes_rec(li)) & win if li is not None else db.Region()
            # the own-net targets are not obstacles
            own = db.Region()
            for tl, tr in self.targets:
                if tl == lay:
                    own.insert(box(tr))
            if not own.is_empty():
                reg = reg - own.sized(10)
            hit = nodes.interacting(reg.sized(MARGIN[lay]))
            out[lay] = {idx[(p.bbox().left, p.bbox().bottom)] for p in hit.each()}
        return out

    def route(self):
        blocked = self.blocked()
        # the start pad lies on M3 and is its own obstacle
        si = (0, 0)
        for lay in self.layers:
            blocked[lay].discard(si)
        tnodes = set()
        for tl, tr in self.targets:
            bx = box(tr).enlarged(450, 450)
            for i in range(self.nx0, self.nx1 + 1):
                for j in range(self.ny0, self.ny1 + 1):
                    x, y = self.pos(i, j)
                    if bx.contains(db.Point(x, y)) and (i, j) not in blocked[tl]:
                        tnodes.add((tl, i, j))
        if not tnodes:
            return None
        start = ("M3", 0, 0)
        dist = {start: 0}
        prev = {}
        pq = [(0, start)]
        goal = None
        while pq:
            d, n = heapq.heappop(pq)
            if d > dist.get(n, 1 << 60):
                continue
            if n in tnodes:
                goal = n
                break
            lay, i, j = n
            nbrs = [((lay, i + 1, j), 1), ((lay, i - 1, j), 1), ((lay, i, j + 1), 1), ((lay, i, j - 1), 1)]
            k = self.layers.index(lay)
            for k2 in (k - 1, k + 1):
                if 0 <= k2 < 3:
                    nbrs.append(((self.layers[k2], i, j), 6))
            for (l2, i2, j2), c in nbrs:
                if not (self.nx0 <= i2 <= self.nx1 and self.ny0 <= j2 <= self.ny1):
                    continue
                if (i2, j2) in blocked[l2]:
                    continue
                nd = d + c
                if nd < dist.get((l2, i2, j2), 1 << 60):
                    dist[(l2, i2, j2)] = nd
                    prev[(l2, i2, j2)] = n
                    heapq.heappush(pq, (nd, (l2, i2, j2)))
        if goal is None:
            return None
        path = [goal]
        while path[-1] != start:
            path.append(prev[path[-1]])
        return path[::-1]

    def shapes(self, path):
        """list of (layer, Box) for wires, vias, pads and the stub to the target."""
        out = []
        def seg(lay, p, q):
            w = WIDTH[lay] // 2
            x1, y1, x2, y2 = min(p[0], q[0]), min(p[1], q[1]), max(p[0], q[0]), max(p[1], q[1])
            out.append((lay, db.Box(x1 - w, y1 - w, x2 + w, y2 + w)))
        pts = [(n[0],) + self.pos(n[1], n[2]) for n in path]
        # wires: one segment per run of straight steps on the same layer (a turn starts a new segment)
        a = 0
        while a < len(pts) - 1:
            b = a
            if pts[a + 1][0] == pts[a][0]:
                dx, dy = pts[a + 1][1] - pts[a][1], pts[a + 1][2] - pts[a][2]
                while b + 1 < len(pts) and pts[b + 1][0] == pts[a][0] and (pts[b + 1][1] - pts[b][1], pts[b + 1][2] - pts[b][2]) == (dx, dy):
                    b += 1
                seg(pts[a][0], pts[a][1:], pts[b][1:])
            a = max(b, a + 1)
        for p, q in zip(pts, pts[1:]):
            if p[0] != q[0]:
                lo = "V2" if {p[0], q[0]} == {"M2", "M3"} else "V3"
                x, y = p[1], p[2]
                out.append((lo, db.Box(x - 95, y - 95, x + 95, y + 95)))
                for lay in (p[0], q[0]):
                    out.append((lay, db.Box(x - 190, y - 190, x + 190, y + 190)))
        # stub from the last node to the target rectangle, same layer
        lay, x, y = pts[-1]
        tl = None
        for l2, tr in self.targets:
            if l2 == lay:
                t = box(tr)
                cx = min(max(x, t.left), t.right)
                cy = min(max(y, t.bottom), t.top)
                if tl is None or abs(cx - x) + abs(cy - y) < tl[0]:
                    tl = (abs(cx - x) + abs(cy - y), cx, cy)
        if tl and tl[0] > 0:
            x2, y2 = tl[1], tl[2]
            # L-shaped stub: x first then y
            seg(lay, (x, y), (x2, y))
            seg(lay, (x2, y), (x2, y2))
        # the start: via stack is not needed, the path starts on the M3 pad of the cell
        return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gds", nargs="*")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    files = [os.path.join(ROOT, f) for f in (a.gds or DEFAULT)]
    plans, rc = [], 0
    for f in files:
        rel = os.path.relpath(f, ROOT)
        if not os.path.isfile(f):
            print(f"integrate_central_bias: {rel} not found", file=sys.stderr)
            return 2
        ly = db.Layout()
        ly.read(f)
        top = ly.cell("pgia_top")
        if top is None:
            print(f"integrate_central_bias: {rel}: no cell pgia_top", file=sys.stderr)
            return 2
        st = state(ly, top)
        print(f"integrate_central_bias: {rel}: {st}")
        if st == "old":
            plans.append((f, ly, top))
        elif st == "unknown":
            print(f"integrate_central_bias: {rel}: the bias tree is not what the script expects (edited since?); not touching it", file=sys.stderr)
            rc = 1
    if rc or a.check or not plans:
        if not plans and not rc:
            print("integrate_central_bias: nothing to do (already integrated)")
        return rc
    cbf = os.path.join(ROOT, CB_GDS)
    cbl = db.Layout()
    cbl.read(cbf)
    cbtop = cbl.top_cell()
    # route once on the first layout, then apply the same shapes to every file
    f0, ly0, top0 = plans[0]
    def apply_base(ly, top):
        cb = ly.create_cell("central_bias")
        for li in cbl.layer_indices():
            info = cbl.get_info(li)
            cb.shapes(ly.layer(info.layer, info.datatype)).insert(cbtop.shapes(li))
        top.insert(db.CellInstArray(cb.cell_index(), db.Trans(DX, DY)))
        for layer, rect, new in CUT:
            for s in find(top, ly, layer, rect)[:1]:
                s.delete()
            for nl, nr in new:
                ins(top, ly, nl, nr)
        for layer, rect in ADD:
            ins(top, ly, layer, rect)
        return cb
    apply_base(ly0, top0)
    pins = pin_positions(cbtop)
    added = []
    for net in ORDER:
        if net not in pins:
            print(f"integrate_central_bias: central_bias has no pin {net}", file=sys.stderr)
            return 2
        r = Router(ly0, top0, net, pins[net], TARGET[net])
        path = r.route()
        if path is None:
            print(f"integrate_central_bias: no route for {net} from {pins[net]}", file=sys.stderr)
            return 2
        shp = r.shapes(path)
        for lay, b in shp:
            ins(top0, ly0, lay, b)
        added += shp
        print(f"integrate_central_bias: {net}: {len(path)} nodes, {sum(1 for p, q in zip(path, path[1:]) if p[0] != q[0])} vias")
    stamp = time.strftime("%Y-%m-%d_%Hh%Mm%S")
    for idx, (f, ly, top) in enumerate(plans):
        bdir = os.path.join(os.path.dirname(f), "backups")
        os.makedirs(bdir, exist_ok=True)
        name = os.path.splitext(os.path.basename(f))[0]
        bk = os.path.join(bdir, f"{name}_backup_{stamp}_integrate_central_bias.gds")
        shutil.copy2(f, bk)
        if idx > 0:
            apply_base(ly, top)
            for lay, b in added:
                ins(top, ly, lay, b)
        ly.write(f)
        print(f"integrate_central_bias: patched {os.path.relpath(f, ROOT)} (backup {os.path.relpath(bk, ROOT)})")
    print("integrate_central_bias: next: scripts/export_slot_gds.py, LVS pgia_top / slot9_wrapper, DRC")
    return 0


if __name__ == "__main__":
    sys.exit(main())
