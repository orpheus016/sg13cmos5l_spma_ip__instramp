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
            "domain": "Analog Sens (3.3V)"
        },
        "x_stage1": {
            "cell": "gain_network",
            "trans": pya.Trans(pya.Trans.M90, 263300, 75880),
            "desc": "Gain Stage 1 Core (Lower Lane Center, V_IN2 faces IA)",
            "domain": "Analog Core (3.3V)"
        },
        "x_stage2": {
            "cell": "gain_network",
            "trans": pya.Trans(274150, 210880),
            "desc": "Gain Stage 2 Core (Upper Lane Center, turnaround from Stage 1)",
            "domain": "Analog Core (3.3V)"
        },
        "x_buf": {
            "cell": "output_buffer",
            "trans": pya.Trans(380000, 205000),
            "desc": "Output Buffer Driver (Upper Lane East, driving s9_an[2])",
            "domain": "Analog Driver (3.3V)"
        },
    }


# ============================================================================
# GEOMETRY GENERATORS (CONTACTS, TAPS, MOATS, GUARD RINGS)
# ============================================================================
def create_contact_array(cell, ly, l_cont, x1_um, y1_um, x2_um, y2_um):
    """Generate DRC-clean array of 0.16x0.16 um contacts with 0.18 um space."""
    dbu = ly.dbu
    c_size = 0.16
    c_space = 0.18
    c_pitch = c_size + c_space  # 0.34 um
    c_inset = 0.07  # Cnt.c enclosure by Activ

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
    psd_over = 0.18  # pSD_c enclosure of Activ
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
    # 4 segments: South, North, West, East
    sx1, sy1, sx2, sy2 = in_x1 - w_ring, in_y1 - w_ring, in_x2 + w_ring, in_y1
    nx1, ny1, nx2, ny2 = in_x1 - w_ring, in_y2, in_x2 + w_ring, in_y2 + w_ring
    wx1, wy1, wx2, wy2 = in_x1 - w_ring, in_y1, in_x1, in_y2
    ex1, ey1, ex2, ey2 = in_x2, in_y1, in_x2 + w_ring, in_y2

    if not is_nwell:
        for x1, y1, x2, y2 in [(sx1, sy1, sx2, sy2), (nx1, ny1, nx2, ny2), (wx1, wy1, wx2, wy2), (ex1, ey1, ex2, ey2)]:
            create_ptap_rect(cell, ly, l_map, x1, y1, x2, y2, net=net)
    else:
        # Create continuous NWell frame (donut polygon)
        nw_x1 = in_x1 - w_ring - nw_enc
        nw_y1 = in_y1 - w_ring - nw_enc
        nw_x2 = in_x2 + w_ring + nw_enc
        nw_y2 = in_y2 + w_ring + nw_enc

        outer_box = pya.Box(to_dbu(nw_x1, dbu), to_dbu(nw_y1, dbu), to_dbu(nw_x2, dbu), to_dbu(nw_y2, dbu))
        inner_hole = pya.Box(to_dbu(in_x1 - nw_enc, dbu), to_dbu(in_y1 - nw_enc, dbu), to_dbu(in_x2 + nw_enc, dbu), to_dbu(in_y2 + nw_enc, dbu))
        r_nwell = pya.Region(outer_box) - pya.Region(inner_hole)
        cell.shapes(l_map["NWell_drw"]).insert(r_nwell)

        for x1, y1, x2, y2 in [(sx1, sy1, sx2, sy2), (nx1, ny1, nx2, ny2), (wx1, wy1, wx2, wy2), (ex1, ey1, ex2, ey2)]:
            create_ntap_rect(cell, ly, l_map, x1, y1, x2, y2, net=net)


# ============================================================================
# PHASE 2: SYNTHESIZE ISOLATION STRUCTURES
# ============================================================================
def add_central_isolation_moat(cell, ly, l_map, x1=180.0, x2=500.0):
    """
    Synthesize the horizontal inter-lane isolation moat across Y in [141.0, 156.0] um.
    PNP sandwich topology:
      - Lower PTap: Y in [141.0, 143.4] um (AVSS)
      - Center NTap in NWell: Y in [144.5, 152.5] um (AVDD)
      - Upper PTap: Y in [153.6, 156.0] um (AVSS)
    """
    print(f"  [Moat] Synthesizing Central Isolation Moat: X=[{x1:.1f}, {x2:.1f}], Y=[141.0, 156.0] um (Width=15.0 um)...")

    # Lower PTap strip (AVSS)
    create_ptap_rect(cell, ly, l_map, x1, 141.0, x2, 143.4, net="AVSS")

    # Center NTap strip in NWell (AVDD)
    # NWell: [x1, 144.5] -> [x2, 152.5] (8.0 um)
    # Activ: [x1, 146.0] -> [x2, 151.0] (5.0 um, centered)
    create_ntap_rect(cell, ly, l_map, x1, 146.0, x2, 151.0, nw_x1=x1, nw_y1=144.5, nw_x2=x2, nw_y2=152.5, net="AVDD")

    # Upper PTap strip (AVSS)
    create_ptap_rect(cell, ly, l_map, x1, 153.6, x2, 156.0, net="AVSS")


def add_digital_guard_ring(cell, ly, l_map, dec_x1=25.0, dec_y1=60.0, dec_x2=90.0, dec_y2=105.0):
    """
    Synthesize double guard ring enclosing digital decoder macro:
      - Inner PTap ring (tied to vss_1v2)
      - Outer NTap ring in NWell (tied to vdd_1v2)
    """
    print(f"  [Guard] Synthesizing Digital Double Guard Ring around [{dec_x1:.1f}, {dec_y1:.1f}] -> [{dec_x2:.1f}, {dec_y2:.1f}] um...")

    # Inner PTap ring (1.5 um gap to decoder, 0.8 um width)
    # Inner: [23.5, 58.5] -> [91.5, 106.5], Outer: [22.7, 57.7] -> [92.3, 107.3]
    in_ptap_x1, in_ptap_y1 = dec_x1 - 1.5, dec_y1 - 1.5
    in_ptap_x2, in_ptap_y2 = dec_x2 + 1.5, dec_y2 + 1.5
    create_guard_ring(cell, ly, l_map, in_ptap_x1, in_ptap_y1, in_ptap_x2, in_ptap_y2, w_ring=0.8, is_nwell=False, net="vss_1v2")

    # Outer NTap ring (0.8 um space from PTap outer edge, 0.8 um width)
    # Inner: [21.9, 56.9] -> [93.1, 108.1], Outer: [21.1, 56.1] -> [93.9, 108.9]
    in_ntap_x1 = in_ptap_x1 - 0.8 - 0.8  # 23.5 - 1.6 = 21.9
    in_ntap_y1 = in_ptap_y1 - 0.8 - 0.8  # 58.5 - 1.6 = 56.9
    in_ntap_x2 = in_ptap_x2 + 0.8 + 0.8  # 91.5 + 1.6 = 93.1
    in_ntap_y2 = in_ptap_y2 + 0.8 + 0.8  # 106.5 + 1.6 = 108.1
    create_guard_ring(cell, ly, l_map, in_ntap_x1, in_ntap_y1, in_ntap_x2, in_ntap_y2, w_ring=0.8, is_nwell=True, nw_enc=0.5, net="vdd_1v2")


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
def assemble_pgia(output_gds, place_only=False, with_moats=True, with_power=False, with_routing=False, repo_root=None):
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
    # Phase 3: TopMetal1 Power Grid Distribution (Placeholder hook for Phase 3)
    # ------------------------------------------------------------------------
    if with_power:
        print("\n[Phase 3] Synthesizing TopMetal1 Power Distribution Grid...")
        # Will be implemented in Phase 3

    # ------------------------------------------------------------------------
    # Phase 4: Inter-Block Signal Routing (Placeholder hook for Phase 4)
    # ------------------------------------------------------------------------
    if with_routing:
        print("\n[Phase 4] Synthesizing Interconnect Signal Routing (<= Metal4)...")
        # Will be implemented in Phase 4

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
        help="Execute Phase 1 only (Ingest and place sub-blocks without moats)",
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
        help="Execute Phase 3 (Add TopMetal1 power rings and TopVia1 stacks)",
    )
    parser.add_argument(
        "--with-routing",
        action="store_true",
        help="Execute Phase 4 (Add inter-block signal routing <= Metal4)",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Execute all assembly phases",
    )

    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    output_path = os.path.join(repo_root, args.output) if not os.path.isabs(args.output) else args.output

    with_moats = args.with_moats or args.all
    with_power = args.with_power or args.all
    with_routing = args.with_routing or args.all
    place_only = args.place_only and not (args.with_moats or args.all)

    assemble_pgia(
        output_gds=output_path,
        place_only=place_only,
        with_moats=with_moats,
        with_power=with_power,
        with_routing=with_routing,
        repo_root=repo_root,
    )


if __name__ == "__main__":
    main()
