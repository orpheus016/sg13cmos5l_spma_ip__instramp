# Changelog & Troubleshooting: PEX Mode RC for `gain_ota`

This document records the root cause diagnostics, script changes, and verification procedures implemented to enable wire resistance + capacitance parasitic extraction (PEX RC via Magic `extresist`) and CACE post-layout characterization for the **`gain_ota`** analog cell (IHP SG13CMOS5L technology).

---

## 1. Initial Failure Summary

While schematic characterization and post-layout C-only characterization (wire capacitance via KPEX 2.5D) passed 100%:
- **Schematic CACE**: 44/44 parameters **Pass ✅** (`runs/RUN_2026-10-21_06-34-59/summary.md`).
- **Post-Layout C**: 40/40 parameters **Pass ✅** (`runs/pex_cace/gain_ota/RUN_2026-10-21_07-35-21/summary.md`).

Post-layout RC simulation (`gain_ota.rc.spice`) failed critically:
- Open-loop DC gain collapsed to $A_0 = -0.865\text{ dB}$ (target $\approx 62\text{ dB}$).
- Phase Margin (PM) corrupted ($10925^\circ$); Gain Margin (GM) and Gain-Bandwidth Product (GBW) were empty (`Error ❗`).
- ngspice reported: `Warning: singular matrix: check node x2.pn19`. Dynamic gmin stepping and source stepping failed to converge.
- DC operating point shifted drastically: $I_Q = 258\,\mu\text{A}$ (schematic $74\,\mu\text{A}$), $V_{OS} = 91\text{ mV}$ (schematic $0.69\text{ mV}$).

---

## 2. Technical Root Cause Diagnostics

### A. Broken MoM Capacitor Terminal Connection (`pn1` vs `V_out`)
- **File**: [scripts/pex_prepare_gds.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_prepare_gds.py)
- **Mechanism**:
  The Miller compensation network in `gain_ota` employs four $8.5\,\mu\text{m} \times 8.5\,\mu\text{m}$ MoM capacitors ($XC4$, $m=4$) in series with a nulling resistor $R_z$ ($R2$).
  In the layout, the top-level wire connecting the output to the compensation capacitors routes on **Metal 3**.
  Previously, `pex_prepare_gds.py` stripped *all* Metal 1–3 and Via 1–3 shapes inside `cap_cmomi` cells, keeping only Metal 4 shapes ($\ge 0.4\,\mu\text{m}$).
  Consequently, the vertical via stack between the Metal 4 terminal bar and the Metal 3 routing wire was severed!
  When Magic queried the coordinates of the capacitor terminals, it detected the isolated Metal 4 bar as a floating node named `pn1` (instead of `V_out`):
  ```text
  # raw.spice.capnodes (before fix):
  pn6 pn1
  pn6 pn1
  pn6 pn1
  pn6 pn1
  pn13 V_out
  ```
  In the RC netlist, $XC4$ was connected to the isolated node `pn1` with no DC path to ground or supply (open loop), causing open-loop gain to collapse.

### B. Floating Node & Singular Matrix on Poly Resistors (`pn18`, `pn19`)
- **File**: [scripts/pex_magic.tcl](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_magic.tcl)
- **Mechanism**:
  Magic extracts the body material of `rhigh` resistors as the non-conductive layer `xres`.
  Step 1 of `pex_magic.tcl` assigned port labels `pn$k` to *all* nodes reported by Magic `.ext`.
  Magic's `extresist all` command then extracted the sheet resistance of the resistor body into standalone resistors:
  `R0 pn19 pn19_t0 5440` and `R1 pn18 pn18_t0 20400`.
  Neither terminal of these extracted resistors had any connection to the electrical circuit, leading ngspice to report a *singular matrix* error on node `x2.pn19`.

### C. MoM Capacitor Dimension Clamping to $25\,\mu\text{m}$
- **File**: [scripts/pex_netlist.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_netlist.py)
- **Mechanism**:
  `schematic_info()` only captured the first MoM capacitor line from the schematic netlist (`and not cap:`), which happened to be $XC3$ ($25\,\mu\text{m} \times 25\,\mu\text{m}$).
  When `convert_magic()` reconstructed the capacitors in `gain_ota.rc.spice`, all 5 instances were instantiated with `w=25e-6 l=25e-6`. This artificially inflated $XC4$ (nominally $4 \times 8.5\,\mu\text{m} \approx 540\text{ fF}$) to $4 \times 25\,\mu\text{m} \approx 4.6\text{ pF}$ ($\sim 8.5\times$ too large).

### D. Incomplete Hierarchy Flattening (`top.flatten(True)`) & Unexpanded Cell Selection
- **Files**: [scripts/pex_prepare_gds.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_prepare_gds.py) & [scripts/pex_magic.tcl](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_magic.tcl)
- **Mechanism**:
  In KLayout's Python API, `Cell.flatten(levels)` takes an integer representing the hierarchy depth. Passing `True` evaluated to integer `1` (flattening only one hierarchy level).
  Consequently, subcells remained underneath the terminal coordinates of the $25\,\mu\text{m}$ capacitor. Magic's `select area` command selected the subcell bounding box rather than paint tiles, prompting Magic's `getnode` command to error with:
  `You must select paint (not a cell) to use getnode.` and producing `{}` or tile alias lists `{c_n5135_1663# pn12}`.

---

## 3. Detailed Script Modifications

### 1. `scripts/pex_prepare_gds.py`
- **Preserve Terminal Bus Bars Across All Metal Layers**:
  Wide metal shapes ($\ge \text{min\_width}$, default $0.4\,\mu\text{m}$) are preserved across Metal 1, Metal 2, Metal 3, and Metal 4, maintaining terminal bars on whichever metal the top-level wires connect to.
- **Preserve Bus-Bar Vias**:
  Implemented `boxes_overlap` arithmetic checking to keep Via 1, Via 2, and Via 3 arrays that intersect terminal bus bars. Only vias embedded in the fine capacitor finger core are deleted.
- **Export $W$ and $L$ Dimensions**:
  In `write_caps()`, marker bounding box dimensions ($W$ and $L$) are appended to `.caps` lines.
- **Full Recursive Hierarchy Flattening**:
  Replaced `top.flatten(True)` with `top.flatten(-1)` so KLayout flattens all hierarchy levels into raw polygons.

### 2. `scripts/pex_magic.tcl`
- **Skip Non-Conductive `xres` Layers**:
  Added check `if {$type eq "xres" || [string match "*res*" $type]} { continue }` to prevent labeling resistor bodies as ports.
- **Recursive Hierarchy Expansion**:
  Updated `select top cell; expand` to `select top cell; expand *` to expand all subcells down to paint.
- **Pass Dimensions to `.capnodes`**:
  Updated `.caps` parsing to pass $W$ and $L$ dimension tokens to `.capnodes`.
- **Tile Alias Resolution**:
  Added filter to handle multi-token return lists from `getnode` (e.g., `{c_n5135_1663# pn12}`), stripping internal `#` coordinate tiles and selecting the circuit port name (`pn12`).

### 3. `scripts/pex_netlist.py`
- **Dynamic MoM Capacitor Parameterization**:
  Reads $W$ and $L$ per line from `.capnodes`, ensuring $8.5\,\mu\text{m}$ and $25\,\mu\text{m}$ capacitors retain their respective drawn values.
- **Robust Regex Token Parsing**:
  Tolerates potential curly braces `{...}` in node names from Magic Tcl.
- **Dangling Resistor Stub Pruning**:
  Automatically prunes parasitic resistors having an internal terminal node that appears nowhere else in the circuit, preventing singular matrix issues.

### 4. `scripts/run_pex.sh`
- Fixed `klayout_pex` execution command by removing unsupported `extract` argument.
- Preserved default `rthresh=0` to avoid affecting other cells, while supporting explicit `--rthresh 30000` via CLI for analog blocks.

---

## 4. Final Verification

With all fixes applied, `runs/pex/gain_ota/magic/raw.spice.capnodes` resolves cleanly:

```text
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn12 V_out 26.160u 25.560u
```

- Lines 1–4 ($XC4$): Connected between $R_z$ node (`pn5`) and output (`V_out`) with drawn dimensions $W \approx 10.2\,\mu\text{m}, L \approx 8.65\,\mu\text{m}$.
- Line 5 ($XC3$): Connected between differential node $F2$ (`pn12`) and output (`V_out`) with drawn dimensions $W \approx 26.16\,\mu\text{m}, L \approx 25.56\,\mu\text{m}$.

---

## 5. Execution Commands

```bash
# 1. Run PEX RC extraction (30 Ohm threshold to filter tiny contact cuts)
./scripts/run_pex.sh gain_ota --use rc --rthresh 30000 --skip-lvs

# 2. Verify extracted cap nodes
cat runs/pex/gain_ota/magic/raw.spice.capnodes

# 3. Run post-layout RC characterization via CACE
./scripts/run_postlayout.sh gain_ota --netlist rc
```
