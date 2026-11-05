#!/usr/bin/env python3
"""Generate the layout of central_bias (xschem/central_bias/central_bias.sch) from PDK PCells.

  make_central_bias_layout.py [--out gds/central_bias/central_bias.gds] [--check]

Output: one top cell `central_bias`, flat, pins as text labels (signals on Metal3 /25, supplies on Metal4 /25 like the other cells).

Structure (the schematic has m = 10 / 33 / 11 / 8 NMOS units and 10 / 9 / 9 PMOS units; every transistor is ONE unit device, so m is the number of units):
  * NMOS block: 62 unit transistors W=1u L=2u (PDK pcell `nmos`), PMOS block: 28 units W=2u L=2u (`pmos`). All gates of a block are one net (poly bus with
    gate contacts at the left end), all sources one net (Metal1 bus + taps). The drains of a group (mirror output) go up/down on Metal1 stubs to one Metal2
    track per group. Two rows per block, the second row mirrored and shifted by half a pitch, so the units of a group are spread evenly along the block.
  * NMOS: R (reference, IB_IN, diode: its track is joined to the gate poly), IA, BUF, P (n_pref). PMOS: R (n_pref, diode), G1, G2. n_pref joins the two blocks
    on a Metal2 strap.
  * p-taps (substrate, AVSS) along the NMOS source buses and n-taps in one NWell (AVDD) along the PMOS source buses, one every 12 um.
Not done (documented in xschem/central_bias/README.md): dummy devices at the ends of the rows, exact common-centroid order.
--check: build in memory and compare with the file (exit 1 if different).
"""
import argparse
import os
import sys

import pya

PDK_PY = "/foss/pdks/ihp-sg13cmos5l/libs.tech/klayout/python"
sys.path[:0] = [PDK_PY, PDK_PY + "/pycell4klayout-api/source/python"]

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ACT, POLY, CONT, M1, V1, M2, V2, M3, V3, M4, NWELL = (1, 0), (5, 0), (6, 0), (8, 0), (19, 0), (10, 0), (29, 0), (30, 0), (49, 0), (50, 0), (31, 0)
LAB3, LAB4 = (30, 25), (50, 25)
PITCH = 3000          # nm between unit starts of one row (unit is 2680 wide)
TAP_EVERY = 4         # one tap per this many columns (12 um)

NMOS_GROUPS = [("R", 10), ("IA", 33), ("BUF", 11), ("P", 8)]      # first = reference/diode group
PMOS_GROUPS = [("R", 10), ("G1", 9), ("G2", 9)]
# net of each group's track
NET = {("N", "R"): "IB_IN", ("N", "IA"): "IB_IA", ("N", "BUF"): "IB_BUF", ("N", "P"): "n_pref", ("P", "R"): "n_pref", ("P", "G1"): "IB_G1", ("P", "G2"): "IB_G2"}


def sequence(groups):
    """Evenly spread order of the units (error diffusion): list of group names."""
    n = sum(c for _, c in groups)
    placed = {g: 0 for g, _ in groups}
    out = []
    for j in range(n):
        best = max(groups, key=lambda gc: (gc[1] * (j + 1) / n - placed[gc[0]], gc[1]))
        out.append(best[0])
        placed[best[0]] += 1
    return out


class Builder:
    def __init__(self):
        self.ly = pya.Layout()
        self.ly.dbu = 0.001
        self.top = self.ly.create_cell("central_bias")
        import sg13cmos5l_pycell_lib  # noqa: F401  (registers the SG13_dev library)
        self.lib = pya.Library.library_by_name("SG13_dev", "sg13cmos5l")
        self.libly = self.lib.layout()
        self.pins = []

    def rect(self, layer, x1, y1, x2, y2):
        self.top.shapes(self.ly.layer(*layer)).insert(pya.Box(min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)))

    def label(self, layer, text, x, y):
        self.top.shapes(self.ly.layer(*layer)).insert(pya.Text(text, x, y))

    def pcell(self, name, params, x, y, mirror):
        ci = self.ly.add_pcell_variant(self.lib, self.libly.pcell_id(name), params)
        self.top.insert(pya.CellInstArray(ci, pya.Trans(0, mirror, x, y)))

    def via_stack_pad(self, x, y, up_to, label=None):
        """Metal2 -> Metal3 (-> Metal4) pad at (x, y) (centre), no Metal1/Metal2 below (callers put those)."""
        self.rect(V2, x - 95, y - 95, x + 95, y + 95)
        h = 190 if up_to == 3 else 250        # signal pads sit on the 600 nm track pitch: keep 220 nm to the next pad
        self.rect(M3, x - h, y - h, x + h, y + h)
        if up_to == 4:
            self.rect(V3, x - 95, y - 95, x + 95, y + 95)
            self.rect(M4, x - 300, y - 300, x + 300, y + 300)

    def block(self, kind, groups, y0, x0):
        """kind 'N' | 'P'. Returns dict with track ys, x extents, strap/pin positions."""
        H = 1000 if kind == "N" else 2000
        T = len(groups)
        seq = sequence(groups)
        names = [g for g, _ in groups]
        tr_y = {g: y0 + H + 800 + k * 600 for k, g in enumerate(names)}
        tracks_top = y0 + H + 800 + (T - 1) * 600
        Yb = tracks_top + 800 + H                     # row B mirror line: y_abs = Yb - u
        n = len(seq)
        ox = lambda j: x0 + j * (PITCH // 2)          # even j: row A, odd j: row B (shifted half pitch)
        rows = {0: [j for j in range(n) if j % 2 == 0], 1: [j for j in range(n) if j % 2 == 1]}
        xend = ox(n - 1) + 2680
        gx = x0 - 800                                 # gate contact column
        for r in (0, 1):
            f = (lambda u: y0 + u) if r == 0 else (lambda u: Yb - u)
            def R(layer, x1, u1, x2, u2):
                self.rect(layer, x1, f(u1), x2, f(u2))
            js = rows[r]
            xa, xb = ox(js[0]), ox(js[-1])
            for j in js:
                if kind == "N":
                    self.pcell("nmos", {"w": "1u", "l": "2u", "ng": "1", "m": "1"}, ox(j), f(0), r == 1)
                else:
                    self.pcell("pmos", {"w": "2u", "l": "2u", "ng": "1", "m": "1"}, ox(j), f(0), r == 1)
                # source strip down to the source bus
                R(M1, ox(j) + 70, -1550, ox(j) + 230, 0)
                # drain stub up to the track of its group, via1 + pad
                ty = tr_y[seq[j]]
                u_t = (ty - y0) if r == 0 else (Yb - ty)
                R(M1, ox(j) + 2450, H, ox(j) + 2610, u_t + 150)
                R(M1, ox(j) + 2380, u_t - 150, ox(j) + 2680, u_t + 150)
                R(V1, ox(j) + 2435, u_t - 95, ox(j) + 2625, u_t + 95)
            # source bus (M1), poly gate bus, gate contact + pad
            R(M1, xa + 70, -1900, xb + 230, -1550)
            R(POLY, gx - 100, -620, xb + 2340, -180)
            R(CONT, gx, -520, gx + 160, -360)
            R(M1, gx - 50, -570, gx + 210, -310)
            # taps on the source bus
            for k in range(0, len(js), TAP_EVERY):
                tx = ox(js[k]) + 70
                self.pcell("ptap1" if kind == "N" else "ntap1", {"w": "0.78u", "l": "0.78u"}, tx, f(-2115) if r == 0 else f(-2115) - 780, False)
        # gate M1 strip joins both rows' gate contacts (same net) and goes to the R track via1
        ry = tr_y["R"]
        u_lo, u_hi = y0 - 570, Yb + 570
        self.rect(M1, gx, u_lo, gx + 160, u_hi)
        self.rect(M1, gx - 50, ry - 150, gx + 210, ry + 150)
        self.rect(V1, gx - 15, ry - 95, gx + 175, ry + 95)
        # tracks (Metal2): from the gate strip (R) / first unit to the pin column
        pinx = xend + 2200
        info = {"tracks": {}, "xend": xend, "x0": x0, "y0": y0, "Yb": Yb, "gx": gx, "pinx": pinx}
        for g in names:
            ty = tr_y[g]
            xl = gx - 50 if g == "R" else x0 + 2400
            self.rect(M2, xl, ty - 150, pinx + 250, ty + 150)
            info["tracks"][g] = ty
            net = NET[(kind, g)]
            if net != "n_pref":
                self.via_stack_pad(pinx, ty, 3)
                self.label(LAB3, net, pinx, ty)
        # right strap on Metal1 joining the source buses of both rows, with a supply pad stack at the bottom
        sx = xend + 600
        self.rect(M1, sx, y0 - 1900, sx + 160, Yb + 1900)
        for rr, xs in ((0, ox(rows[0][-1])), (1, ox(rows[1][-1]))):
            yb_ = (y0 - 1900, y0 - 1550) if rr == 0 else (Yb + 1550, Yb + 1900)
            self.rect(M1, xs + 70, yb_[0], sx + 160, yb_[1])
        py = y0 - 1725
        self.rect(M1, sx - 120, py - 250, sx + 280, py + 250)
        self.rect(V1, sx + 80 - 95, py - 95, sx + 80 + 95, py + 95)
        self.rect(M2, sx + 80 - 250, py - 250, sx + 80 + 250, py + 250)
        self.via_stack_pad(sx + 80, py, 4)
        supply = "AVSS" if kind == "N" else "AVDD"
        self.label(LAB4, supply, sx + 80, py)
        info["sx"] = sx
        info["ymax"] = Yb + 2200
        return info


def build():
    b = Builder()
    x0 = 3000
    nb = b.block("N", NMOS_GROUPS, 3000, x0)
    gap = 5000
    py0 = nb["ymax"] + gap + 2300
    pb = b.block("P", PMOS_GROUPS, py0, x0)
    # n_pref: M2 strap on the left joins the NMOS P track and the PMOS R track
    sx = x0 - 2400
    b.rect(M2, sx, nb["tracks"]["P"] - 150, nb["x0"] + 2400, nb["tracks"]["P"] + 150)
    b.rect(M2, sx, pb["tracks"]["R"] - 150, pb["gx"] + 210, pb["tracks"]["R"] + 150)
    b.rect(M2, sx, nb["tracks"]["P"] - 150, sx + 300, pb["tracks"]["R"] + 150)
    # one NWell over the whole PMOS block (rows, buses, taps, strap)
    b.rect(NWELL, pb["gx"] - 400, pb["y0"] - 2500, pb["sx"] + 700, pb["Yb"] + 2500)
    top = b.top
    top.flatten(True)
    # drop the pcell marker texts
    for lay in ((63, 0), (51, 0), (31, 0), (40, 0)):
        li = b.ly.find_layer(*lay)
        if li is not None:
            for s in list(top.shapes(li).each()):
                if s.is_text():
                    s.delete()
    return b.ly, b.top


def same_layout(ly, top, path):
    """True if the file at path holds the same shapes (all layers) and the same texts as the layout in memory."""
    if not os.path.isfile(path):
        return False
    old = pya.Layout()
    old.read(path)
    ot = old.top_cell()
    if ot.name != top.name:
        return False
    for li in ly.layer_indices():
        info = ly.get_info(li)
        oi = old.find_layer(info.layer, info.datatype)
        r1 = pya.Region(top.begin_shapes_rec(li))
        r2 = pya.Region(ot.begin_shapes_rec(oi)) if oi is not None else pya.Region()
        if not (r1 ^ r2).is_empty():
            return False
        t1 = sorted((s.text.string, s.text.x, s.text.y) for s in top.shapes(li).each() if s.is_text())
        t2 = sorted((s.text.string, s.text.x, s.text.y) for s in ot.shapes(oi).each() if s.is_text()) if oi is not None else []
        if t1 != t2:
            return False
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=os.path.join(ROOT, "gds", "central_bias", "central_bias.gds"))
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    ly, top = build()
    rel = os.path.relpath(a.out, ROOT)
    print("central_bias layout: %.1f x %.1f um" % (top.bbox().width() / 1000, top.bbox().height() / 1000))
    cur = same_layout(ly, top, a.out)
    if a.check:
        print("make_central_bias_layout: %s %s" % (rel, "is up to date" if cur else "differs from the generator output (or is missing)"))
        return 0 if cur else 1
    if cur:
        print("make_central_bias_layout: %s unchanged" % rel)
        return 0
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    ly.write(a.out)
    print("make_central_bias_layout: wrote", rel)
    return 0


if __name__ == "__main__":
    sys.exit(main())
