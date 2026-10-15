# 05: The intermediate representation between circuit and layout

**Short answer: yes, an IR is needed.** Without one, every loop iteration means hand-editing three artefacts and re-reading a fourth by eye:
- the `.sch` / `.param` block;
- the GDS generator inputs;
- the CACE yaml;
- the extracted netlist.

That hand step is exactly what the designer does today when trimming R after PEX.

## What the IR must carry
One file per cell, `design_ir/<cell>.yaml` (or JSON). The sizing side and the layout side both read it and both write to it. The proposed shape, using the instramp as the example:

```yaml
cell: instramp_cmos5l
ir_version: 0
provenance: {schematic_sha: a36a205bb1f7, gds_sha: 50fa4fd017b1, pex_netlist: netlist/instramp_cmos5l/pex/instramp_cmos5l.rc.spice}

# 1. what the optimiser changes: physical units, bounds, and the layout grid
params:
  R_in.l:   {value: 2.000e-6,  min: 1.0e-6, max: 4.0e-6,  grid: 5e-9,  devices: [R1, R2]}
  R_fb.l:   {value: 17.84e-6,  min: 10e-6,  max: 30e-6,   grid: 5e-9,  devices: [R3, R4]}
  R.w:      {value: 0.5e-6,    fixed: true}
  R_fb.nseg:{value: 8,         min: 4, max: 16, integer: true}        # layout knob, also changes head/contact R
  trim.nseg:{value: 0,         min: 0, max: 4,  integer: true}        # optional series trim segment

# 2. device → layout mapping (what the generator does with params)
devices:
  R3: {type: rhigh, generator: rhigh_array, unit: {w: R.w, l: R_fb.l / R_fb.nseg}, nseg: R_fb.nseg}
  R4: {type: rhigh, generator: rhigh_array, unit: {w: R.w, l: R_fb.l / R_fb.nseg}, nseg: R_fb.nseg}

# 3. constraints the generator must honour (a superset of ALIGN constraint JSON)
constraints:
  - {type: matched, devices: [R1, R2], style: interdigitated, dummies: 1}
  - {type: matched, devices: [R3, R4], style: common_centroid, dummies: 1}
  - {type: symmetric, pairs: [[x1, x2]], axis: V}

# 4. nets whose parasitics matter, with budgets: the designer's intent, made explicit
net_criticality:
  net5: {why: "x3 inverting node, sets gain", max_series_R: 0.05, max_C: 50e-15}
  net6: {why: "x3 non-inverting node, sets gain/CMRR", max_series_R: 0.05}
  VOUT: {why: "feedback R4 return", max_series_R: 0.5}

# 5. back-annotation, written by the extraction step, keyed by SCHEMATIC names
parasitics:
  nets:   {net5: {C_total: ..., R_series: {R2.2→x3.VINN: ..., R4.1→x3.VINN: ...}}, ...}
  devices: {R4: {R_extracted: ..., R_wire_in_series: ...}}

# 6. results in the same keys as docs/<cell>/postlayout*.json
results:
  schematic: {A_CL: 18.061, A_ERR: -0.000}
  post_rc:   {A_CL: 18.008, A_ERR: -0.054}
  delta:     {A_ERR: -0.054}
```

## Why each section is there
| Section | Without it |
|---|---|
| `params` with `grid` | The optimiser proposes values the layout cannot build, the 01 notebook's unchecked even-nf rounding. Quantisation must be part of the search space, not a post-processing step. |
| `devices → generator` | The sizing vector cannot be turned into GDS without a human. This is the role of the T-coil generator in 03. |
| `constraints` | Matching and symmetry live only in the designer's head. ALIGN's JSON covers part of this, and the IR should be exportable to it so ALIGN stays an option (roadmap M5). |
| `net_criticality` | The surrogate has to learn from scratch which nets matter. Writing the budgets down also gives the layout generator routing targets, which is the analytic route to "layout is the optimal layout for the circuit". |
| `parasitics` keyed by schematic name | The coarse model cannot absorb PEX. **Today the RC netlist calls the gain nodes `pn5`/`pn6`** (`netlist/instramp_cmos5l/pex/instramp_cmos5l.rc.spice`), so a script has to recover the mapping from LVS. |
| `results` | No dataset. Each iteration appends `(params, parasitics, results)`, and the log becomes the training set for the Δ-surrogate. |

## Why per-net parasitics (not raw SPICE) are the right currency
1. **They are what the coarse model consumes.** A C/ID or ratio model takes a node C and a series R per branch. It cannot take 604 R and 389 C elements; that is the instramp RC netlist count in `docs/instramp_cmos5l/status.md`.
2. **They are a small, smooth learning target.** Predicting parasitics from schematic and layout features is the established ML formulation:
   - [ParaGraph, Ren et al., DAC 2020](https://research.nvidia.com/publication/2020-07_paragraph-layout-parasitics-and-device-parameter-prediction-using-graph-neural) uses a GNN on the schematic graph to predict net parasitics and device parameters, and reports simulation error dropping from > 100 % with designer estimates to < 10 %.
   - [Liu et al., DATE 2021](https://research.nvidia.com/publication/2021-02_parasitic-aware-analog-circuit-sizing-graph-neural-networks-and-bayesian) plugs such a predictor into BO sizing.
   - A per-net Δ-model is the small version of that, and it fits the dataset sizes this flow can generate.
3. **They are stable across layout revisions.** Schematic net names do not change when the layout moves. Extracted node names do.

## What has to be built
1. **Net cross-reference from LVS.** Map extracted node to schematic net and extracted device to schematic device. Netgen already computes this when it reports MATCH, and `scripts/lvs_tools.py` / `scripts/pex_netlist.py` are the places to add an export.
2. **Parasitic summariser.** From the RC netlist plus the cross-reference, compute for each critical net the total C and the series R between named device pins: a small graph reduction (effective resistance between two pins with the rest open).
3. **IR read/write in the flow.** `flow.sh` writes the `parasitics` and `results` sections, and the optimiser writes `params`. The rest of the flow keeps working as it does now.
4. **A generator per device class**, starting with `rhigh_array` (KLayout PCell based).
