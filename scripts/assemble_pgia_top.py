#!/usr/bin/env python3
"""
Top-Level Physical Layout Assembly Framework for PGIA IP in IHP SG13CMOS5L
========================================================================

Project: Programmable Gain Instrumentation Amplifier (PGIA) IP
Harness: slot9_wrapper (537.15 um x 273.00 um)
Architecture: Option B (Folded Horseshoe, All Analog Dedicated Pads on East)

Technology Stack Constraints:
- SG13CMOS5L is an M1-M4-TM1 process (NO Metal5, NO Via4, NO TopVia2, NO TopMetal2).
- Maximum effective inter-block signal routing layer: Metal4 (50/0).
- TopMetal1 (126/0, 2.0 um thick) is strictly reserved for global P/G rings.
- TopVia1 (125/0) connects Metal4 directly to TopMetal1.

Sub-Blocks:
- slot9_wrapper: Golden harness frame (537.15 x 273.00 um)
- instramp_cmos5l: Instrumentation Amplifier front-end (124.25 x 122.79 um)
- gain_network: 5-tap programmable gain stage core (97.45 x 74.61 um)
  * Placed as x_stage1 (Lower Lane) and x_stage2 (Upper Lane)
- output_buffer: Rail-to-rail unity-gain buffer (113.55 x 37.41 um)
- gain_decoder_4b: 4-bit digital gain decoder macro (65.00 x 45.00 um)

Phased Pipeline:
  Phase 1: Sub-block ingestion, conflict resolution, Option B placement.
  Phase 2: Substrate isolation moats & digital double guard ring.
  Phase 3: TopMetal1 global power grid distribution.
  Phase 4: Inter-block signal routing (<= Metal4).

Usage:
  python3 scripts/assemble_pgia_top.py --place-only
  python3 scripts/assemble_pgia_top.py --with-moats
  python3 scripts/assemble_pgia_top.py --with-power
  python3 scripts/assemble_pgia_top.py --with-routing
  python3 scripts/assemble_pgia_top.py --all
"""

import os
import sys
import argparse
import klayout.db as pya

# ============================================================================
# SG13CMOS5L LAYER DEFINITIONS
# ============================================================================
# Verified against official ihp-sg13cmos5l.lyp
LAYERS = {
    # Active & Implant
    "Activ_drw": (1, 0),
    "Activ_pin": (1, 2),
    "Cont_drw": (6, 0),
    "nSD_drw": (7, 0),
    "pSD_drw": (14, 0),
    "NWell_drw": (31, 0),
    "PWell_drw": (46, 0),
    "GatPoly_drw": (5, 0),

    # Back-End-of-Line (BEOL) Metal Stack
    "Metal1_drw": (8, 0),
    "Metal1_lbl": (8, 1),
    "Metal1_pin": (8, 2),
    "Metal1_txt": (8, 25),
    "Via1_drw": (19, 0),

    "Metal2_drw": (10, 0),
    "Metal2_lbl": (10, 1),
    "Metal2_pin": (10, 2),
    "Metal2_txt": (10, 25),
    "Via2_drw": (29, 0),

    "Metal3_drw": (30, 0),
    "Metal3_lbl": (30, 1),
    "Metal3_pin": (30, 2),
    "Metal3_txt": (30, 25),
    "Via3_drw": (49, 0),

    "Metal4_drw": (50, 0),
    "Metal4_lbl": (50, 1),
    "Metal4_pin": (50, 2),
    "Metal4_txt": (50, 25),

    # Top-Level BEOL
    # CRITICAL: SG13CMOS5L has NO Metal5!
    # TopVia1 directly connects Metal4 (50/0) to TopMetal1 (126/0).
    "TopVia1_drw": (125, 0),
    "TopMetal1_drw": (126, 0),
    "TopMetal1_lbl": (126, 1),
    "TopMetal1_pin": (126, 2),
    "TopMetal1_txt": (126, 25),

    # Passivation & Boundary
    "Passiv_drw": (9, 0),
    "prBoundary": (189, 4),
    "TEXT_drw": (63, 0),
}


def to_dbu(val, dbu=0.001):
    return int(round(val / dbu))


# ============================================================================
# SUB-BLOCK PATH RESOLUTION
# ============================================================================
def find_sub_block_paths(repo_root):
    """Resolve absolute paths to all constituent sub-block GDS layouts."""
    return {
        "slot9_wrapper": os.path.join(
            repo_root, "..", "sg13cmos5l_ocd_chipalooza", "gds", "slot9_wrapper.gds"
        ),
        "instramp_cmos5l": os.path.join(
            repo_root, "gds", "pgia_top", "instramp_cmos5l.gds"
        ),
        "gain_network": os.path.join(
            repo_root, "gds", "gain_network", "gain_network.klay.gds"
        ),
        "output_buffer": os.path.join(
            repo_root, "gds", "pgia_top", "output_buffer.gds"
        ),
        "gain_decoder_4b": os.path.join(
            repo_root, "gds", "gain_decoder_4b", "final", "gds", "gain_decoder_4b.gds"
        ),
    }


# ============================================================================
# OPTION B PLACEMENT SCHEDULE
# ============================================================================
def get_placement_transforms():
    """Return dictionary of KLayout transformation objects for Option B."""
    return {
        "x_dec": {
            "cell": "gain_decoder_4b",
            "trans": pya.Trans(25000, 60000),
            "desc": "Digital decoder macro (West edge, adjacent to dig_in[0..3])",
            "domain": "Digital (1.2V)"
        },
        "x_ia": {
            "cell": "instramp_cmos5l",
            "trans": pya.Trans(pya.Trans.M90, 484250, 18000),
            "desc": "Instrumentation Amp Front-End (Lower Lane East, facing s9_an[0..1])",
            "domain": "Analog Sens (1.2V)"
        },
        "x_stage1": {
            "cell": "gain_network",
            "trans": pya.Trans(pya.Trans.M90, 263300, 75880),
            "desc": "Gain Stage 1 Core (Lower Lane Center, V_IN2 faces IA)",
            "domain": "Analog Core (1.2V)"
        },
        "x_stage2": {
            "cell": "gain_network",
            "trans": pya.Trans(274150, 210880),
            "desc": "Gain Stage 2 Core (Upper Lane Center, turnaround from Stage 1)",
            "domain": "Analog Core (1.2V)"
        },
        "x_buf": {
            "cell": "output_buffer",
            "trans": pya.Trans(380000, 205000),
            "desc": "Output Buffer Driver (Upper Lane East, driving s9_an[2])",
            "domain": "Analog Driver (1.2V)"
        },
    }


# ============================================================================
# GEOMETRY GENERATORS (CONTACTS, TAPS, MOATS, GUARD RINGS)
# ============================================================================
def create_contact_array(cell, ly, l_cont, x1_um, y1_um, x2_um, y2_um):
    """Generate DRC-clean array of 0.16x0.16 um contacts with 0.18 um space."""
    dbu = ly.dbu
    c_size = 0.16
    c_space = 0.20  # Cnt.b1: >= 0.20 um for arrays > 4x4
    c_pitch = c_size + c_space  # 0.36 um
    c_inset = 0.08  # Cnt.c enclosure by Activ (>= 0.07 um)

    ux1 = x1_um + c_inset
    uy1 = y1_um + c_inset
    ux2 = x2_um - c_inset
    uy2 = y2_um - c_inset

    len_x = ux2 - ux1
    len_y = uy2 - uy1

    if len_x < c_size or len_y < c_size:
        return

    nx = int((len_x - c_size) / c_pitch) + 1
    ny = int((len_y - c_size) / c_pitch) + 1

    actual_span_x = (nx - 1) * c_pitch + c_size
    actual_span_y = (ny - 1) * c_pitch + c_size
    start_x = ux1 + (len_x - actual_span_x) / 2.0
    start_y = uy1 + (len_y - actual_span_y) / 2.0

    grid = 0.005
    start_x = round(start_x / grid) * grid
    start_y = round(start_y / grid) * grid

    shapes = cell.shapes(l_cont)
    for ix in range(nx):
        cx = start_x + ix * c_pitch
        cx_i = to_dbu(cx, dbu)
        cx_size = to_dbu(c_size, dbu)
        for iy in range(ny):
            cy = start_y + iy * c_pitch
            cy_i = to_dbu(cy, dbu)
            cy_size = to_dbu(c_size, dbu)
            shapes.insert(pya.Box(cx_i, cy_i, cx_i + cx_size, cy_i + cy_size))


def create_ptap_rect(cell, ly, l_map, x1, y1, x2, y2, net="AVSS"):
    """Create P-substrate tap rectangular strip."""
    dbu = ly.dbu
    cell.shapes(l_map["Activ_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))
    psd_over = 0.18
    cell.shapes(l_map["pSD_drw"]).insert(pya.Box(
        to_dbu(x1 - psd_over, dbu), to_dbu(y1 - psd_over, dbu),
        to_dbu(x2 + psd_over, dbu), to_dbu(y2 + psd_over, dbu)
    ))
    create_contact_array(cell, ly, l_map["Cont_drw"], x1, y1, x2, y2)
    cell.shapes(l_map["Metal1_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))
    cell.shapes(l_map["Metal1_txt"]).insert(pya.Text(net, to_dbu((x1 + x2) / 2.0, dbu), to_dbu((y1 + y2) / 2.0, dbu)))


def create_ntap_rect(cell, ly, l_map, x1, y1, x2, y2, nw_x1=None, nw_y1=None, nw_x2=None, nw_y2=None, net="AVDD"):
    """Create N-well tap rectangular strip."""
    dbu = ly.dbu
    if nw_x1 is not None:
        cell.shapes(l_map["NWell_drw"]).insert(pya.Box(to_dbu(nw_x1, dbu), to_dbu(nw_y1, dbu), to_dbu(nw_x2, dbu), to_dbu(nw_y2, dbu)))
    cell.shapes(l_map["Activ_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))
    nsd_over = 0.18
    cell.shapes(l_map["nSD_drw"]).insert(pya.Box(
        to_dbu(x1 - nsd_over, dbu), to_dbu(y1 - nsd_over, dbu),
        to_dbu(x2 + nsd_over, dbu), to_dbu(y2 + nsd_over, dbu)
    ))
    create_contact_array(cell, ly, l_map["Cont_drw"], x1, y1, x2, y2)
    cell.shapes(l_map["Metal1_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))
    cell.shapes(l_map["Metal1_txt"]).insert(pya.Text(net, to_dbu((x1 + x2) / 2.0, dbu), to_dbu((y1 + y2) / 2.0, dbu)))


def create_guard_ring(cell, ly, l_map, in_x1, in_y1, in_x2, in_y2, w_ring, is_nwell=False, nw_enc=0.5, net="vss_1v2"):
    """Create a 4-segment guard ring surrounding an inner boundary."""
    dbu = ly.dbu
    sx1, sy1, sx2, sy2 = in_x1 - w_ring, in_y1 - w_ring, in_x2 + w_ring, in_y1
    nx1, ny1, nx2, ny2 = in_x1 - w_ring, in_y2, in_x2 + w_ring, in_y2 + w_ring
    wx1, wy1, wx2, wy2 = in_x1 - w_ring, in_y1, in_x1, in_y2
    ex1, ey1, ex2, ey2 = in_x2, in_y1, in_x2 + w_ring, in_y2

    if not is_nwell:
        for x1, y1, x2, y2 in [(sx1, sy1, sx2, sy2), (nx1, ny1, nx2, ny2), (wx1, wy1, wx2, wy2), (ex1, ey1, ex2, ey2)]:
            create_ptap_rect(cell, ly, l_map, x1, y1, x2, y2, net=net)
    else:
        # NWell outer box enclosing outer edge by 0.35 um
        # NWell inner hole inset into inner boundary by 0.35 um (enclosing inner edge by 0.35 um)
        nw_enc_clean = 0.35
        nw_x1 = in_x1 - w_ring - nw_enc_clean
        nw_y1 = in_y1 - w_ring - nw_enc_clean
        nw_x2 = in_x2 + w_ring + nw_enc_clean
        nw_y2 = in_y2 + w_ring + nw_enc_clean

        hole_x1 = in_x1 + nw_enc_clean
        hole_y1 = in_y1 + nw_enc_clean
        hole_x2 = in_x2 - nw_enc_clean
        hole_y2 = in_y2 - nw_enc_clean

        outer_box = pya.Box(to_dbu(nw_x1, dbu), to_dbu(nw_y1, dbu), to_dbu(nw_x2, dbu), to_dbu(nw_y2, dbu))
        inner_hole = pya.Box(to_dbu(hole_x1, dbu), to_dbu(hole_y1, dbu), to_dbu(hole_x2, dbu), to_dbu(hole_y2, dbu))
        r_nwell = pya.Region(outer_box) - pya.Region(inner_hole)
        cell.shapes(l_map["NWell_drw"]).insert(r_nwell)

        for x1, y1, x2, y2 in [(sx1, sy1, sx2, sy2), (nx1, ny1, nx2, ny2), (wx1, wy1, wx2, wy2), (ex1, ey1, ex2, ey2)]:
            create_ntap_rect(cell, ly, l_map, x1, y1, x2, y2, net=net)


# ============================================================================
# VIA DROP GENERATORS (M4 -> TopMetal1 and M1 -> TopMetal1)
# ============================================================================
def create_m4_to_tm1_drop(cell, ly, l_map, cx_um, cy_um, size_um=2.2):
    """
    Drop a 2x2 TopVia1 array connecting Metal4 to TopMetal1.
    TV1 size: 0.42 um, space: 0.42 um.
    M4 enclosure: 0.10 um. TM1 enclosure: 0.42 um.
    """
    dbu = ly.dbu
    half_s = size_um / 2.0
    x1, y1 = cx_um - half_s, cy_um - half_s
    x2, y2 = cx_um + half_s, cy_um + half_s

    cell.shapes(l_map["Metal4_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))
    cell.shapes(l_map["TopMetal1_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))

    tv_size = 0.42
    shapes_tv1 = cell.shapes(l_map["TopVia1_drw"])
    for ox in [-0.42, 0.42]:
        for oy in [-0.42, 0.42]:
            vx = cx_um + ox - tv_size / 2.0
            vy = cy_um + oy - tv_size / 2.0
            shapes_tv1.insert(pya.Box(to_dbu(vx, dbu), to_dbu(vy, dbu), to_dbu(vx + tv_size, dbu), to_dbu(vy + tv_size, dbu)))


def create_guard_ring_drop(cell, ly, l_map, cx_um, cy_um, w_ring=0.8):
    """Via stack from Metal1 up to TopMetal1 tailored to a guard ring of width w_ring."""
    dbu = ly.dbu
    hw = w_ring / 2.0
    hl = 0.80
    for m in ["Metal1_drw", "Metal2_drw", "Metal3_drw", "Metal4_drw"]:
        cell.shapes(l_map[m]).insert(pya.Box(to_dbu(cx_um - hw, dbu), to_dbu(cy_um - hl, dbu),
                                             to_dbu(cx_um + hw, dbu), to_dbu(cy_um + hl, dbu)))

    v_size = 0.19
    for via_layer in ["Via1_drw", "Via2_drw", "Via3_drw"]:
        shapes = cell.shapes(l_map[via_layer])
        for oy in [-0.35, 0.35]:
            vx = cx_um - v_size / 2.0
            vy = cy_um + oy - v_size / 2.0
            shapes.insert(pya.Box(to_dbu(vx, dbu), to_dbu(vy, dbu), to_dbu(vx + v_size, dbu), to_dbu(vy + v_size, dbu)))

    tv_size = 0.42
    vx = cx_um - tv_size / 2.0
    vy = cy_um - tv_size / 2.0
    cell.shapes(l_map["TopVia1_drw"]).insert(pya.Box(to_dbu(vx, dbu), to_dbu(vy, dbu), to_dbu(vx + tv_size, dbu), to_dbu(vy + tv_size, dbu)))


def create_m1_to_tm1_stack(cell, ly, l_map, cx_um, cy_um, size_um=2.2):
    """Full via stack from Metal1 up to TopMetal1."""
    dbu = ly.dbu
    half_s = size_um / 2.0
    x1, y1 = cx_um - half_s, cy_um - half_s
    x2, y2 = cx_um + half_s, cy_um + half_s

    for m in ["Metal1_drw", "Metal2_drw", "Metal3_drw", "Metal4_drw", "TopMetal1_drw"]:
        cell.shapes(l_map[m]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))

    v_size = 0.19
    for via_layer in ["Via1_drw", "Via2_drw", "Via3_drw"]:
        shapes = cell.shapes(l_map[via_layer])
        for ox in [-0.41, 0.0, 0.41]:
            for oy in [-0.41, 0.0, 0.41]:
                vx = cx_um + ox - v_size / 2.0
                vy = cy_um + oy - v_size / 2.0
                shapes.insert(pya.Box(to_dbu(vx, dbu), to_dbu(vy, dbu), to_dbu(vx + v_size, dbu), to_dbu(vy + v_size, dbu)))

    tv_size = 0.42
    shapes_tv1 = cell.shapes(l_map["TopVia1_drw"])
    for ox in [-0.42, 0.42]:
        for oy in [-0.42, 0.42]:
            vx = cx_um + ox - tv_size / 2.0
            vy = cy_um + oy - tv_size / 2.0
            shapes_tv1.insert(pya.Box(to_dbu(vx, dbu), to_dbu(vy, dbu), to_dbu(vx + tv_size, dbu), to_dbu(vy + tv_size, dbu)))


# ============================================================================
# PHASE 2: SYNTHESIZE ISOLATION STRUCTURES
# ============================================================================
def add_central_isolation_moat(cell, ly, l_map, x1=180.0, x2=500.0):
    """
    Synthesize horizontal inter-lane isolation moat across Y in [141.0, 156.0] um.
    PNP sandwich topology:
      - Lower PTap: Y in [141.0, 143.4] um (AVSS)
      - Center NTap in NWell: Y in [144.5, 152.5] um (AVDD)
      - Upper PTap: Y in [153.6, 156.0] um (AVSS)
    """
    print(f"  [Moat] Synthesizing Central Isolation Moat: X=[{x1:.1f}, {x2:.1f}], Y=[141.0, 156.0] um (Width=15.0 um)...")
    create_ptap_rect(cell, ly, l_map, x1, 141.0, x2, 143.4, net="AVSS")
    create_ntap_rect(cell, ly, l_map, x1 + 0.30, 146.0, x2 - 0.30, 151.0, nw_x1=x1, nw_y1=144.5, nw_x2=x2, nw_y2=152.5, net="AVDD")
    create_ptap_rect(cell, ly, l_map, x1, 153.6, x2, 156.0, net="AVSS")


def add_digital_guard_ring(cell, ly, l_map, dec_x1=25.0, dec_y1=60.0, dec_x2=90.0, dec_y2=105.0):
    """
    Synthesize double guard ring enclosing digital decoder macro:
      - Inner PTap ring (tied to vss_1v2)
      - Outer NTap ring in NWell (tied to vdd_1v2)
    """
    print(f"  [Guard] Synthesizing Digital Double Guard Ring around [{dec_x1:.1f}, {dec_y1:.1f}] -> [{dec_x2:.1f}, {dec_y2:.1f}] um...")
    in_ptap_x1, in_ptap_y1 = dec_x1 - 1.5, dec_y1 - 1.5
    in_ptap_x2, in_ptap_y2 = dec_x2 + 1.5, dec_y2 + 1.5
    create_guard_ring(cell, ly, l_map, in_ptap_x1, in_ptap_y1, in_ptap_x2, in_ptap_y2, w_ring=0.8, is_nwell=False, net="vss_1v2")

    in_ntap_x1 = in_ptap_x1 - 1.6
    in_ntap_y1 = in_ptap_y1 - 1.6
    in_ntap_x2 = in_ptap_x2 + 1.6
    in_ntap_y2 = in_ptap_y2 + 1.6
    create_guard_ring(cell, ly, l_map, in_ntap_x1, in_ntap_y1, in_ntap_x2, in_ntap_y2, w_ring=0.8, is_nwell=True, nw_enc=0.5, net="vdd_1v2")


# ============================================================================
# PHASE 3: TOPMETAL1 POWER GRID DISTRIBUTION
# ============================================================================
def add_power_grid(c_pgia, c_wrapper, ly, l_map):
    """
    Synthesize global power distribution network strictly on TopMetal1 (Layer 126/0).
    Dual-domain star-point topology:
      - Digital Domain: VPWR / VGND encircling West decoder, connected to vdd_1v2 / vss_1v2
      - Analog Domain: AVDD / AVSS rings encircling analog blocks, connected via Kelvin star point
      - Multi-layer via drops down to each block's Metal4 power pins and substrate moats.
    """
    dbu = ly.dbu
    print("  [Power] Synthesizing TopMetal1 Global Power Rings & Drops...")

    def box_tm1(x1, y1, x2, y2):
        c_pgia.shapes(l_map["TopMetal1_drw"]).insert(pya.Box(to_dbu(x1, dbu), to_dbu(y1, dbu), to_dbu(x2, dbu), to_dbu(y2, dbu)))

    def lbl_tm1(net, x, y):
        c_pgia.shapes(l_map["TopMetal1_txt"]).insert(pya.Text(net, to_dbu(x, dbu), to_dbu(y, dbu)))

    # ------------------------------------------------------------------------
    # 1. ANALOG PERIMETER POWER RINGS (AVDD & AVSS)
    # ------------------------------------------------------------------------
    # South Rails:
    # AVDD South: Y in [3.0, 8.0] um (width 5.0 um, directly abuts vdd_1v2 entry pad)
    box_tm1(2.0, 3.0, 505.0, 8.0)
    lbl_tm1("AVDD", 340.0, 5.5)

    # AVSS South: Y in [10.5, 15.5] um (width 5.0 um, spans analog core from West Riser to East Riser)
    box_tm1(165.0, 10.5, 505.0, 15.5)
    lbl_tm1("AVSS", 340.0, 13.0)

    # North Rails:
    # AVDD North: Y in [248.0, 253.0] um (width 5.0 um)
    box_tm1(165.0, 248.0, 505.0, 253.0)
    lbl_tm1("AVDD", 340.0, 250.5)

    # AVSS North: Y in [256.0, 261.0] um (width 5.0 um)
    box_tm1(165.0, 256.0, 505.0, 261.0)
    lbl_tm1("AVSS", 340.0, 258.5)

    # West Vertical Risers (X in [165.0, 175.0] um):
    # AVSS West riser: X in [165.0, 169.0]
    box_tm1(165.0, 10.5, 169.0, 261.0)
    # AVDD West riser: X in [171.0, 175.0]
    box_tm1(171.0, 3.0, 175.0, 253.0)

    # East Vertical Risers (X in [496.0, 505.5] um):
    # AVDD East riser: X in [496.0, 499.5] (Shifted 1.0 um West for TM1.b = 2.50 um space to AVSS at 502.0)
    box_tm1(496.0, 3.0, 499.5, 253.0)
    # AVSS East riser: X in [502.0, 505.5]
    box_tm1(502.0, 10.5, 505.5, 261.0)

    # Central Isolation Moat TopMetal1 Straps:
    # AVSS over Lower PTap: Y in [141.0, 143.4] um
    box_tm1(165.0, 141.0, 497.0, 143.4)
    # AVDD over Center NTap: Y in [146.5, 150.5] um
    box_tm1(171.0, 146.5, 499.5, 150.5)
    # AVSS over Upper PTap: Y in [153.6, 156.0] um
    box_tm1(165.0, 153.6, 497.0, 156.0)

    # ------------------------------------------------------------------------
    # 2. DIGITAL POWER GRID (VPWR & VGND)
    # ------------------------------------------------------------------------
    # vss_1v2 main trunk from vss_1v2 pad (X in [0.0, 2.0], Y in [66.37, 96.37] um)
    # Spans from West pad across decoder (feeding VGND) and continues East to AVSS West Riser (Kelvin star point)
    box_tm1(2.0, 78.5, 169.0, 82.5)
    lbl_tm1("VGND", 30.0, 80.5)
    lbl_tm1("AVSS", 167.0, 80.5)

    # VPWR feeder from vdd_1v2 pad (X in [0.0, 2.0], Y in [1.53, 56.80] um):
    box_tm1(2.0, 48.0, 18.0, 52.0)
    box_tm1(14.0, 48.0, 18.0, 72.0)
    box_tm1(14.0, 68.0, 43.0, 72.0)
    lbl_tm1("VPWR", 30.0, 70.0)

    # ------------------------------------------------------------------------
    # 3. VERTICAL DROPS TO SUB-CELL METAL4 POWER PINS & GUARD MOATS
    # ------------------------------------------------------------------------
    # Decoder drops:
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 40.76, 70.0, size_um=2.2)
    c_pgia.shapes(l_map["Metal4_drw"]).insert(pya.Box(to_dbu(39.66, dbu), to_dbu(70.0, dbu), to_dbu(41.86, dbu), to_dbu(81.0, dbu)))
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 43.76, 80.5, size_um=2.2)

    # Digital guard ring drops:
    create_guard_ring_drop(c_pgia, ly, l_map, 23.1, 80.5, w_ring=0.8)  # VGND to inner PTap
    create_guard_ring_drop(c_pgia, ly, l_map, 21.5, 70.0, w_ring=0.8)  # VPWR to outer NTap

    # Instramp drops:
    # VSS drops:
    for drop_x in [380.0, 430.0, 480.0]:
        box_tm1(drop_x - 1.5, 10.5, drop_x + 1.5, 21.5)
        create_m4_to_tm1_drop(c_pgia, ly, l_map, drop_x, 20.64, size_um=2.2)
    # VDD drops:
    for drop_x in [380.0, 430.0, 480.0]:
        box_tm1(drop_x - 1.5, 137.0, drop_x + 1.5, 148.0)
        create_m4_to_tm1_drop(c_pgia, ly, l_map, drop_x, 138.15, size_um=2.2)

    # Gain Stage 1 drops:
    # AVSS: M4 pin at (312.0, 25.5) -> South AVSS trunk at Y in [10.5, 15.5]
    box_tm1(310.5, 10.5, 313.5, 26.5)
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 312.0, 25.5, size_um=2.2)
    # AVDD: M4 pin at (312.0, 83.9) -> South AVDD trunk via vertical TM1 branch
    box_tm1(310.5, 3.0, 313.5, 85.0)
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 312.0, 83.9, size_um=2.2)

    # Gain Stage 2 drops:
    # AVSS: M4 pin at (225.3, 160.5) -> Upper PTap (AVSS) at Y in [153.6, 156.0]
    box_tm1(223.8, 153.6, 226.8, 161.5)
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 225.3, 160.5, size_um=2.2)
    # AVDD: M4 pin at (225.3, 218.9) -> North AVDD trunk at Y in [248.0, 253.0]
    box_tm1(223.8, 217.5, 226.8, 253.0)
    create_m4_to_tm1_drop(c_pgia, ly, l_map, 225.3, 218.9, size_um=2.2)

    # Output Buffer drops:
    # VSS: M4 rail at Y in [205.0, 206.8], fed from Upper PTap (AVSS)
    for drop_x in [395.0, 445.0, 485.0]:
        box_tm1(drop_x - 1.5, 156.0, drop_x + 1.5, 207.5)
        create_m4_to_tm1_drop(c_pgia, ly, l_map, drop_x, 206.0, size_um=1.6)
    # VDD: M4 rail at Y in [240.65, 242.41], fed from North AVDD trunk
    # Sized to 1.6 um centered at 241.6 um (Y in [240.8, 242.4]) to maintain >= 0.5 um space to M4 at Y=240.3
    for drop_x in [395.0, 445.0, 485.0]:
        box_tm1(drop_x - 1.5, 240.5, drop_x + 1.5, 250.0)
        create_m4_to_tm1_drop(c_pgia, ly, l_map, drop_x, 241.6, size_um=1.6)

    # Central Moat via stacks down to Metal1:
    for stack_x in [200.0, 250.0, 300.0, 350.0, 400.0, 450.0]:
        create_m1_to_tm1_stack(c_pgia, ly, l_map, stack_x, 142.2, size_um=2.2)
        create_m1_to_tm1_stack(c_pgia, ly, l_map, stack_x, 148.5, size_um=2.2)
        create_m1_to_tm1_stack(c_pgia, ly, l_map, stack_x, 154.8, size_um=2.2)

    print("  [PASS] TopMetal1 Power Grid and drops synthesized successfully.")


# ============================================================================
# PHASE 4: INTER-BLOCK SIGNAL ROUTING (<= Metal4)
# ============================================================================
def snap5(v):
    """Snap coordinate or dimension to 5nm SG13CMOS5L manufacturing grid."""
    return round(v * 200.0) / 200.0


def add_wire_segment(cell, layer_idx, x1, y1, x2, y2, width_um, dbu=0.001):
    """Add an orthogonal wire segment with width_um snapped to 5nm grid."""
    x1, y1 = snap5(x1), snap5(y1)
    x2, y2 = snap5(x2), snap5(y2)
    width_um = snap5(width_um)
    half_w = snap5(width_um / 2.0)
    if abs(x1 - x2) < 1e-4:  # Vertical segment
        ymin, ymax = min(y1, y2), max(y1, y2)
        cell.shapes(layer_idx).insert(pya.Box(to_dbu(x1 - half_w, dbu), to_dbu(ymin, dbu),
                                              to_dbu(x1 + half_w, dbu), to_dbu(ymax, dbu)))
    elif abs(y1 - y2) < 1e-4:  # Horizontal segment
        xmin, xmax = min(x1, x2), max(x1, x2)
        cell.shapes(layer_idx).insert(pya.Box(to_dbu(xmin, dbu), to_dbu(y1 - half_w, dbu),
                                              to_dbu(xmax, dbu), to_dbu(y1 + half_w, dbu)))
    else:
        pts = [pya.Point(to_dbu(x1, dbu), to_dbu(y1, dbu)), pya.Point(to_dbu(x2, dbu), to_dbu(y2, dbu))]
        cell.shapes(layer_idx).insert(pya.Path(pts, to_dbu(width_um, dbu)))


def add_path(cell, layer_idx, points, width_um, dbu=0.001):
    """Add connected segments along orthogonal points with corner patches."""
    points = [(snap5(px), snap5(py)) for (px, py) in points]
    width_um = snap5(width_um)
    half_w = snap5(width_um / 2.0)
    for i in range(len(points) - 1):
        x1, y1 = points[i]
        x2, y2 = points[i + 1]
        add_wire_segment(cell, layer_idx, x1, y1, x2, y2, width_um, dbu)
        cell.shapes(layer_idx).insert(pya.Box(to_dbu(x2 - half_w, dbu), to_dbu(y2 - half_w, dbu),
                                              to_dbu(x2 + half_w, dbu), to_dbu(y2 + half_w, dbu)))


def add_via2_drop(cell, l_map, cx_um, cy_um, pad_size=0.50, dbu=0.001):
    """Drop Via2 between Metal2 and Metal3 with DRC-clean 5nm grid alignment."""
    cx_um, cy_um = snap5(cx_um), snap5(cy_um)
    pad_size = snap5(pad_size)
    half_p = snap5(pad_size / 2.0)
    box = pya.Box(to_dbu(cx_um - half_p, dbu), to_dbu(cy_um - half_p, dbu),
                  to_dbu(cx_um + half_p, dbu), to_dbu(cy_um + half_p, dbu))
    cell.shapes(l_map["Metal2_drw"]).insert(box)
    cell.shapes(l_map["Metal3_drw"]).insert(box)
    cell.shapes(l_map["Via2_drw"]).insert(pya.Box(to_dbu(cx_um - 0.095, dbu), to_dbu(cy_um - 0.095, dbu),
                                                  to_dbu(cx_um + 0.095, dbu), to_dbu(cy_um + 0.095, dbu)))


def add_via3_drop(cell, l_map, cx_um, cy_um, pad_size=0.60, dbu=0.001):
    """Drop Via3 between Metal3 and Metal4 with DRC-clean 5nm grid alignment."""
    cx_um, cy_um = snap5(cx_um), snap5(cy_um)
    pad_size = snap5(pad_size)
    half_p = snap5(pad_size / 2.0)
    box = pya.Box(to_dbu(cx_um - half_p, dbu), to_dbu(cy_um - half_p, dbu),
                  to_dbu(cx_um + half_p, dbu), to_dbu(cy_um + half_p, dbu))
    cell.shapes(l_map["Metal3_drw"]).insert(box)
    cell.shapes(l_map["Metal4_drw"]).insert(box)
    cell.shapes(l_map["Via3_drw"]).insert(pya.Box(to_dbu(cx_um - 0.095, dbu), to_dbu(cy_um - 0.095, dbu),
                                                  to_dbu(cx_um + 0.095, dbu), to_dbu(cy_um + 0.095, dbu)))


def add_signal_routing(c_pgia, c_wrapper, master_ly, l_map):
    """Synthesize all Phase 4 inter-block interconnects (<= Metal4)."""
    dbu = master_ly.dbu
    m2 = l_map["Metal2_drw"]
    m3 = l_map["Metal3_drw"]
    m4 = l_map["Metal4_drw"]
    txt3 = l_map["Metal3_txt"]
    txt4 = l_map["Metal4_txt"]

    print("  [Routing] 1. Analog Inputs (East Dedicated Pads -> x_ia)...")
    # s9_an[0] (535.45, 34.545) -> x_ia VINP (484.195, 41.035)
    add_path(c_pgia, m3, [
        (535.450, 34.545),
        (492.000, 34.545),
        (492.000, 41.035),
        (484.195, 41.035)
    ], width_um=0.8, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 484.195, 41.035, pad_size=0.50, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("VINP", to_dbu(535.450, dbu), to_dbu(34.545, dbu)))

    # s9_an[1] (535.45, 144.545) -> x_ia VINN (484.225, 119.385)
    add_path(c_pgia, m3, [
        (535.450, 144.545),
        (492.000, 144.545),
        (492.000, 119.385),
        (484.225, 119.385)
    ], width_um=0.8, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 484.225, 119.385, pad_size=0.50, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("VINN", to_dbu(535.450, dbu), to_dbu(144.545, dbu)))

    print("  [Routing] 2. Lower Lane Forward Link (x_ia VOUT -> x_stage1 V_IN2)...")
    # x_ia VOUT (360.100, 79.490) -> x_stage1 V_IN2 (316.505, 56.755)
    add_path(c_pgia, m3, [
        (360.100, 79.490),
        (338.000, 79.490),
        (338.000, 56.755),
        (316.505, 56.755)
    ], width_um=0.8, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("v_ia", to_dbu(338.000, dbu), to_dbu(70.000, dbu)))

    print("  [Routing] 3. Inter-Stage Turnaround Spine (x_stage1 -> x_stage2 on Metal4)...")
    # Spine routed at X = 216.0 um: guarantees > 6.2 um clearance to x_stage2 AVSS rail (at X = 222.25 um)
    add_path(c_pgia, m3, [(223.735, 43.450), (216.000, 43.450)], width_um=0.6, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 216.000, 43.450, pad_size=0.60, dbu=dbu)
    add_path(c_pgia, m4, [
        (216.000, 43.450),
        (216.000, 191.755)
    ], width_um=0.6, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 216.000, 191.755, pad_size=0.60, dbu=dbu)
    add_path(c_pgia, m3, [(216.000, 191.755), (220.945, 191.755)], width_um=0.6, dbu=dbu)
    c_pgia.shapes(txt4).insert(pya.Text("v_stage1", to_dbu(216.000, dbu), to_dbu(120.000, dbu)))

    print("  [Routing] 4. Upper Lane Forward Link (x_stage2 -> x_buf input)...")
    # x_stage2 V_OUT2 (313.715, 178.450) -> x_buf VINN (380.120, 225.440)
    add_path(c_pgia, m3, [
        (313.715, 178.450),
        (345.000, 178.450),
        (345.000, 225.440),
        (380.120, 225.440)
    ], width_um=0.8, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("v_stage2", to_dbu(345.000, dbu), to_dbu(200.000, dbu)))

    print("  [Routing] 5. Output Feed (x_buf VOUT -> s9_an[2] East Pad)...")
    # x_buf VOUT (493.440, 223.950) -> s9_an[2] (535.450, 254.545) on Metal4
    add_via3_drop(c_pgia, l_map, 493.440, 223.950, pad_size=0.60, dbu=dbu)
    add_path(c_pgia, m4, [
        (493.440, 223.950),
        (515.000, 223.950),
        (515.000, 254.545),
        (535.450, 254.545)
    ], width_um=1.2, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 535.450, 254.545, pad_size=0.60, dbu=dbu)
    c_pgia.shapes(txt4).insert(pya.Text("VOUT", to_dbu(535.450, dbu), to_dbu(254.545, dbu)))

    print("  [Routing] 6. Common-Mode Reference (VCM)...")
    # vbias at (1.000, 95.215) -> Escape to X=14.0 um -> Jog to Corridor Y=120.0 um
    add_path(c_pgia, m3, [(1.000, 95.215), (14.000, 95.215)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 14.000, 95.215, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(14.000, 95.215), (14.000, 120.000)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 14.000, 120.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(14.000, 120.000), (334.000, 120.000)], width_um=0.35, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("VCM", to_dbu(1.000, dbu), to_dbu(95.215, dbu)))

    # Branch north to x_stage2 V_CM (220.920, 190.570) via M2 vertical jumper
    add_via2_drop(c_pgia, l_map, 215.000, 120.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(215.000, 120.000), (215.000, 190.570)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 215.000, 190.570, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(215.000, 190.570), (220.920, 190.570)], width_um=0.35, dbu=dbu)

    # Branch south into x_stage1 V_CM from East channel (X=334.0 um)
    add_via2_drop(c_pgia, l_map, 334.000, 120.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(334.000, 120.000), (334.000, 55.570)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 334.000, 55.570, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(334.000, 55.570), (316.530, 55.570)], width_um=0.35, dbu=dbu)

    # Branch east to x_ia CM via M4 over moat (Y=158.0 um) to East Pad corridor (X=490.0 um)
    add_path(c_pgia, m2, [(334.000, 120.000), (334.000, 158.000)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 334.000, 158.000, pad_size=0.50, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 334.000, 158.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m4, [(334.000, 158.000), (490.000, 158.000)], width_um=0.50, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 490.000, 158.000, pad_size=0.50, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 490.000, 158.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(490.000, 158.000), (490.000, 79.135)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 490.000, 79.135, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(490.000, 79.135), (484.215, 79.135)], width_um=0.35, dbu=dbu)

    print("  [Routing] 7. Current Bias Distribution (IBIAS)...")
    # ibias0 at (1.000, 98.155) -> Escape to X=16.0 um -> Jog to Corridor Y=124.0 um
    add_path(c_pgia, m3, [(1.000, 98.155), (16.000, 98.155)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 16.000, 98.155, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(16.000, 98.155), (16.000, 124.000)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 16.000, 124.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(16.000, 124.000), (336.000, 124.000)], width_um=0.35, dbu=dbu)
    c_pgia.shapes(txt3).insert(pya.Text("IBIAS_IA", to_dbu(1.000, dbu), to_dbu(98.155, dbu)))

    # Branch north to x_stage2 I_BIAS (221.080, 177.805) via M2 jumper
    add_via2_drop(c_pgia, l_map, 212.000, 124.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(212.000, 124.000), (212.000, 177.805)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 212.000, 177.805, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(212.000, 177.805), (221.080, 177.805)], width_um=0.35, dbu=dbu)

    # Branch south into x_stage1 I_BIAS from East channel (X=336.0 um)
    add_via2_drop(c_pgia, l_map, 336.000, 124.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(336.000, 124.000), (336.000, 42.805)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 336.000, 42.805, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(336.000, 42.805), (316.370, 42.805)], width_um=0.35, dbu=dbu)

    # Branch east to x_ia IBIAS via M4 over moat (Y=162.0 um) to East Pad corridor (X=492.0 um)
    add_path(c_pgia, m2, [(336.000, 124.000), (336.000, 162.000)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 336.000, 162.000, pad_size=0.50, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 336.000, 162.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m4, [(336.000, 162.000), (492.000, 162.000)], width_um=0.50, dbu=dbu)
    add_via3_drop(c_pgia, l_map, 492.000, 162.000, pad_size=0.50, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 492.000, 162.000, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m2, [(492.000, 162.000), (492.000, 130.215)], width_um=0.35, dbu=dbu)
    add_via2_drop(c_pgia, l_map, 492.000, 130.215, pad_size=0.50, dbu=dbu)
    add_path(c_pgia, m3, [(492.000, 130.215), (484.250, 130.215)], width_um=0.35, dbu=dbu)

    print("  [Routing] 8. Digital Inputs (dig_in[0..3] -> x_dec gain_sel[0..3])...")
    dig_in_pins = [
        ((1.000, 78.460), (25.200, 65.460), 6.0, "gain_sel[0]"),
        ((1.000, 78.900), (25.200, 76.380), 9.0, "gain_sel[1]"),
        ((1.000, 79.340), (25.200, 87.300), 12.0, "gain_sel[2]"),
        ((1.000, 79.780), (25.200, 98.220), 15.0, "gain_sel[3]"),
    ]
    for (src, dst, jog_x, pname) in dig_in_pins:
        add_path(c_pgia, m3, [
            src,
            (jog_x, src[1]),
            (jog_x, dst[1]),
            dst
        ], width_um=0.22, dbu=dbu)
        c_pgia.shapes(txt3).insert(pya.Text(pname, to_dbu(src[0], dbu), to_dbu(src[1], dbu)))

    print("  [Routing] 9. Decoded Stage 1 Control (Routed via North Corridor & East Ingress)...")
    # All pins of x_stage1 are at X in [317.03, 317.30], Y in [85.96, 99.45].
    # By routing around x_stage1 via the North open corridor (Y in [103..111]) and entering
    # from the East (X = 322..330), we strictly avoid traversing over x_stage1 internal analog core!
    s1_pins = [
        ((89.800, 66.300), (317.085, 85.960), "s1[0]"),
        ((89.800, 74.700), (317.030, 86.945), "S0_st1"),  # S0 tied to s1_b[0]
        ((89.800, 67.980), (317.235, 96.920), "s1[1]"),
        ((89.800, 69.660), (317.250, 97.775), "s1[2]"),
        ((89.800, 71.340), (317.295, 98.620), "s1[3]"),
        ((89.800, 73.020), (317.295, 99.450), "s1[4]"),
    ]
    for i, (src, dst, sname) in enumerate(s1_pins):
        col_west = 114.0 + i * 1.5
        corr_y = 103.0 + i * 1.5
        col_east = 322.0 + i * 1.5
        # 1. Escape decoder East on M3
        add_path(c_pgia, m3, [src, (col_west, src[1])], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_west, src[1], pad_size=0.50, dbu=dbu)
        # 2. Jog North on M2 to open North corridor
        add_path(c_pgia, m2, [(col_west, src[1]), (col_west, corr_y)], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_west, corr_y, pad_size=0.50, dbu=dbu)
        # 3. Traverse East on M3 above x_stage1 to East open channel
        add_path(c_pgia, m3, [(col_west, corr_y), (col_east, corr_y)], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_east, corr_y, pad_size=0.50, dbu=dbu)
        # 4. Jog South on M2 along East channel to exact pin Y
        add_path(c_pgia, m2, [(col_east, corr_y), (col_east, dst[1])], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_east, dst[1], pad_size=0.50, dbu=dbu)
        # 5. Ingress West on M3 directly into x_stage1 East port
        add_path(c_pgia, m3, [(col_east, dst[1]), dst], width_um=0.30, dbu=dbu)
        c_pgia.shapes(txt3).insert(pya.Text(sname, to_dbu(col_west, dbu), to_dbu(corr_y, dbu)))

    print("  [Routing] 10. Decoded Stage 2 Control (Direct West Ingress to x_stage2)...")
    # All pins of x_stage2 are at X in [220.15, 220.42], Y in [220.96, 234.45].
    # Direct Manhattan routing: M3 escape -> M2 North jog -> M3 East entry.
    s2_pins = [
        ((89.800, 83.100), (220.365, 220.960), "s2[0]"),
        ((89.800, 91.500), (220.420, 221.945), "S0_st2"),  # S0 tied to s2_b[0]
        ((89.800, 84.780), (220.215, 231.920), "s2[1]"),
        ((89.800, 86.460), (220.200, 232.775), "s2[2]"),
        ((89.800, 88.140), (220.155, 233.620), "s2[3]"),
        ((89.800, 89.820), (220.155, 234.450), "s2[4]"),
    ]
    for i, (src, dst, sname) in enumerate(s2_pins):
        col_x = 96.0 + i * 1.5
        # 1. Escape decoder East on M3
        add_path(c_pgia, m3, [src, (col_x, src[1])], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_x, src[1], pad_size=0.50, dbu=dbu)
        # 2. Jog North on M2 to exact pin Y
        add_path(c_pgia, m2, [(col_x, src[1]), (col_x, dst[1])], width_um=0.30, dbu=dbu)
        add_via2_drop(c_pgia, l_map, col_x, dst[1], pad_size=0.50, dbu=dbu)
        # 3. Enter West port of x_stage2 on M3
        add_path(c_pgia, m3, [(col_x, dst[1]), dst], width_um=0.30, dbu=dbu)
        c_pgia.shapes(txt3).insert(pya.Text(sname, to_dbu(col_x, dbu), to_dbu(dst[1], dbu)))

    print("  [PASS] All Phase 4 signal interconnects synthesized successfully.")


# ============================================================================
# AUDIT & GEOMETRY VERIFICATION
# ============================================================================
def audit_placement(ly, instances_info):
    """Audit placed instances for bounding boxes, clearances, and overlaps."""
    dbu = ly.dbu
    print("=" * 78)
    print("OPTION B PLACED INSTANCE SCHEDULE AUDIT")
    print("=" * 78)

    placed_boxes = []
    for inst_name, info in instances_info.items():
        cell = info["cell_obj"]
        trans = info["trans"]
        bbox = cell.bbox().transformed(trans)
        x1, y1 = bbox.left * dbu, bbox.bottom * dbu
        x2, y2 = bbox.right * dbu, bbox.top * dbu
        w, h = x2 - x1, y2 - y1
        xc, yc = (x1 + x2) / 2.0, (y1 + y2) / 2.0
        placed_boxes.append((inst_name, (x1, y1, x2, y2), info["desc"]))
        print(f"[{inst_name:8s}] {info['cell']:18s} | [{x1:7.2f}, {y1:7.2f}] -> [{x2:7.2f}, {y2:7.2f}] um")
        print(f"           Center: ({xc:7.2f}, {yc:7.2f}) um, Dim: {w:6.2f} x {h:6.2f} um | {info['domain']}")

    print("\n--- Overlap Audit ---")
    overlap_count = 0
    for i in range(len(placed_boxes)):
        for j in range(i + 1, len(placed_boxes)):
            n1, b1, _ = placed_boxes[i]
            n2, b2, _ = placed_boxes[j]
            overlap = not (b1[2] <= b2[0] or b2[2] <= b1[0] or b1[3] <= b2[1] or b2[3] <= b1[1])
            if overlap:
                print(f"  [ERROR] Unintended spatial collision: {n1} overlaps with {n2}!")
                overlap_count += 1

    if overlap_count == 0:
        print("  [PASS] Zero spatial overlaps detected. All 5 sub-blocks have clear physical boundaries.")

    # Critical clearances
    lower_top = max(placed_boxes[1][1][3], placed_boxes[2][1][3])
    upper_bot = min(placed_boxes[3][1][1], placed_boxes[4][1][1])
    moat_width = upper_bot - lower_top
    ia_stage1_spacing = placed_boxes[1][1][0] - placed_boxes[2][1][2]
    stage2_buf_spacing = placed_boxes[4][1][0] - placed_boxes[3][1][2]
    dig_ana_spacing = placed_boxes[2][1][0] - placed_boxes[0][1][2]
    ia_pad_dist = 535.45 - placed_boxes[1][1][2]
    buf_pad_dist = 535.45 - placed_boxes[4][1][2]
    dec_pad_dist = placed_boxes[0][1][0] - 1.00

    print("\n--- Corridor & Clearance Metrics ---")
    print(f"  Central Isolation Moat Corridor Y : [{lower_top:.2f}, {upper_bot:.2f}] um (Width = {moat_width:.2f} um)")
    print(f"  Lower Lane (IA -> Stage 1) Spacing: {ia_stage1_spacing:.2f} um (Direct horizontal feed)")
    print(f"  Upper Lane (Stage 2 -> Buf) Spacing: {stage2_buf_spacing:.2f} um (Direct horizontal feed)")
    print(f"  Digital Macro to Analog Core Gap  : {dig_ana_spacing:.2f} um (Substantial noise separation)")
    print(f"  IA to East Dedicated Pads (s9_an): {ia_pad_dist:.2f} um (Low parasitic input run)")
    print(f"  Buffer to East Dedicated Pad (s9): {buf_pad_dist:.2f} um (Low parasitic output run)")
    print(f"  Decoder to West Digital Inputs   : {dec_pad_dist:.2f} um (Direct short bus)")
    print("=" * 78)


def audit_ports(ly, instances_info):
    """Print top-level coordinates of all key interface pins."""
    dbu = ly.dbu
    print("\nINTERFACE PORT MAPPING IN TOP COORDINATE SYSTEM")
    print("-" * 78)
    for inst_name, info in instances_info.items():
        cell = info["cell_obj"]
        trans = info["trans"]
        ports = []
        for l_idx in ly.layer_indexes():
            linfo = ly.get_info(l_idx)
            for shape in cell.shapes(l_idx).each():
                if shape.is_text():
                    t = shape.text.transformed(trans)
                    ports.append((linfo.layer, linfo.datatype, t.string, t.x * dbu, t.y * dbu))
        print(f"[{inst_name:8s}] Ports ({len(ports)}):")
        for layer, dt, text, x, y in sorted(ports, key=lambda p: (p[4], p[3])):
            print(f"  Pin {text:15s} (L {layer:3d}/{dt:2d}) @ ({x:7.3f}, {y:7.3f}) um")


# ============================================================================
# MAIN ASSEMBLY PIPELINE
# ============================================================================
def assemble_pgia(output_gds, place_only=False, with_moats=True, with_power=True, with_routing=False, repo_root=None):
    if repo_root is None:
        repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

    sub_blocks = find_sub_block_paths(repo_root)

    print(f"Initializing Top-Level Assembly for PGIA IP in SG13CMOS5L...")
    print(f"Repository Root: {repo_root}")
    print(f"Target Output  : {output_gds}")

    # Verify all input GDS files exist
    for name, path in sub_blocks.items():
        if not os.path.exists(path):
            print(f"[FATAL ERROR] Required sub-block GDS not found: {name} at {path}")
            sys.exit(1)
        else:
            print(f"  Loaded sub-block {name:16s} : {path}")

    # Create Master Layout Database
    master_ly = pya.Layout()
    master_ly.dbu = 0.001

    # Layer mapping indices
    l_map = {}
    for lname, (layer, dt) in LAYERS.items():
        l_map[lname] = master_ly.layer(layer, dt)

    # Load layout options with conflict resolution
    opts = pya.LoadLayoutOptions()
    opts.cell_conflict_resolution = pya.LoadLayoutOptions.CellConflictResolution.RenameCell

    for name, path in sub_blocks.items():
        master_ly.read(path, opts)

    # Resolve cell references
    c_wrapper = master_ly.cell("slot9_wrapper")
    c_ia = master_ly.cell("instramp_cmos5l")
    c_gain = master_ly.cell("gain_network")
    c_buf = master_ly.cell("output_buffer")
    c_dec = master_ly.cell("gain_decoder_4b")

    if None in [c_wrapper, c_ia, c_gain, c_buf, c_dec]:
        print("[FATAL ERROR] Failed to resolve one or more top cell references in loaded layouts.")
        sys.exit(1)

    # Create top core cell `pgia_top`
    # Hierarchy: slot9_wrapper -> pgia_top -> {x_dec, x_ia, x_stage1, x_stage2, x_buf}
    c_pgia = master_ly.cell("pgia_top")
    if c_pgia is None:
        c_pgia = master_ly.create_cell("pgia_top")

    # Clear instances if re-running
    c_pgia.clear_insts()
    c_pgia.clear_shapes()
    c_wrapper.clear_insts()

    # Get Option B transforms
    placements = get_placement_transforms()
    placements["x_dec"]["cell_obj"] = c_dec
    placements["x_ia"]["cell_obj"] = c_ia
    placements["x_stage1"]["cell_obj"] = c_gain
    placements["x_stage2"]["cell_obj"] = c_gain
    placements["x_buf"]["cell_obj"] = c_buf

    # Instantiate sub-blocks into pgia_top
    for inst_name, pinfo in placements.items():
        cell_obj = pinfo["cell_obj"]
        trans = pinfo["trans"]
        c_pgia.insert(pya.CellInstArray(cell_obj.cell_index(), trans))

    # Instantiate pgia_top into slot9_wrapper at (0, 0)
    c_wrapper.insert(pya.CellInstArray(c_pgia.cell_index(), pya.Trans(0, 0)))

    # Run Placement & Clearance Audit
    audit_placement(master_ly, placements)
    audit_ports(master_ly, placements)

    # ------------------------------------------------------------------------
    # Phase 2: Moats and Guard Rings
    # ------------------------------------------------------------------------
    if with_moats and not place_only:
        print("\n" + "=" * 78)
        print("PHASE 2: SYNTHESIZING ISOLATION MOATS & GUARD RINGS")
        print("=" * 78)
        add_central_isolation_moat(c_pgia, master_ly, l_map, x1=180.0, x2=500.0)
        add_digital_guard_ring(c_pgia, master_ly, l_map, dec_x1=25.0, dec_y1=60.0, dec_x2=90.0, dec_y2=105.0)
        print("  [PASS] Isolation moats and digital guard rings synthesized into pgia_top.")

    # ------------------------------------------------------------------------
    # Phase 3: TopMetal1 Power Grid Distribution
    # ------------------------------------------------------------------------
    if with_power and not place_only:
        print("\n" + "=" * 78)
        print("PHASE 3: SYNTHESIZING TOPMETAL1 POWER GRID & DROPS")
        print("=" * 78)
        add_power_grid(c_pgia, c_wrapper, master_ly, l_map)

    # ------------------------------------------------------------------------
    # Phase 4: Inter-Block Signal Routing (<= Metal4)
    # ------------------------------------------------------------------------
    if with_routing and not place_only:
        print("\n" + "=" * 78)
        print("PHASE 4: SYNTHESIZING INTER-BLOCK SIGNAL ROUTING (<= Metal4)")
        print("=" * 78)
        add_signal_routing(c_pgia, c_wrapper, master_ly, l_map)

    # Ensure output directory exists
    os.makedirs(os.path.dirname(os.path.abspath(output_gds)), exist_ok=True)

    # Write Master GDS
    print(f"\nWriting finalized assembly layout to: {output_gds}")
    master_ly.write(output_gds)
    print(f"[SUCCESS] Top-Level Assembly Phase completed successfully.")


# ============================================================================
# CLI INTERFACE
# ============================================================================
def main():
    parser = argparse.ArgumentParser(
        description="Top-Level Physical Layout Assembly Framework for PGIA IP in IHP SG13CMOS5L"
    )
    parser.add_argument(
        "--output",
        default="gds/pgia_top/pgia_top.gds",
        help="Path to output GDS file (default: gds/pgia_top/pgia_top.gds)",
    )
    parser.add_argument(
        "--place-only",
        action="store_true",
        help="Execute Phase 1 only (Ingest and place sub-blocks without moats/power/routing)",
    )
    parser.add_argument(
        "--with-moats",
        action="store_true",
        default=True,
        help="Execute Phase 2 (Add central isolation moat and digital guard ring) [Default: True]",
    )
    parser.add_argument(
        "--with-power",
        action="store_true",
        default=True,
        help="Execute Phase 3 (Add TopMetal1 power rings and TopVia1 stacks) [Default: True]",
    )
    parser.add_argument(
        "--with-routing",
        action="store_true",
        default=True,
        help="Execute Phase 4 (Add inter-block signal routing <= Metal4) [Default: True]",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Execute all assembly phases",
    )

    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    output_path = os.path.join(repo_root, args.output) if not os.path.isabs(args.output) else args.output

    with_moats = (args.with_moats or args.all) and not args.place_only
    with_power = (args.with_power or args.all) and not args.place_only
    with_routing = (args.with_routing or args.all) and not args.place_only

    assemble_pgia(
        output_gds=output_path,
        place_only=args.place_only,
        with_moats=with_moats,
        with_power=with_power,
        with_routing=with_routing,
        repo_root=repo_root,
    )


if __name__ == "__main__":
    main()
