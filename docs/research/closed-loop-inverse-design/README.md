# Closed-loop inverse design: research notes

These are notes on the three ISSCC Code-a-Chip notebooks in [`notebook_references/`](../../../notebook_references). They were read to answer one question: *can C/ID sizing, layout generation and an ANN surrogate be closed into one loop that iterates the way a designer does: size, lay out, extract, re-size?*

Written 2026-10-15. **Fact** marks something read in the notebook or measured in this repository. **Judgement** marks an engineering opinion.
Long-term research direction of this repository (the short-term, shippable tool is in [`../deterministic-analog-optimizer/`](../deterministic-analog-optimizer/README.md)). The reference papers are kept here: [AnalogGym, arXiv 2409.08534](2409.08534v1.pdf) and [FALCON, arXiv 2505.21923, NeurIPS 2025](2505.21923v2.pdf); see also [07_layout_tool_decision.md](07_layout_tool_decision.md) (ALIGN-on-IHP vs SKY130).

| # | Doc | Notebook | One line |
|---|---|---|---|
| 1 | [01_cid_cm_ota_align.md](01_cid_cm_ota_align.md) | `current_mirror_ota_optimization (1).ipynb` (Adair, Utah, ISSCC'25) | C/ID LUT → analytic min-current objective → W → ALIGN fingers → ALIGN GDS → Magic PEX → ngspice. Spec to GDS, **open loop**. |
| 2 | [02_cid_cml_dividers.md](02_cid_cml_dividers.md) | `current_mode_logic_optimization.ipynb` (Elhelly, ISSCC'26) | C/ID for high-speed CML. The LUT is re-parametrised by (Av, Vswing), then NSGA-II on analytic tail current. Layout enters as a **guessed `cwire = 20 fF`**. |
| 3 | [03_tcoil_ann_inverse_design.md](03_tcoil_ann_inverse_design.md) | `TCoil_Dataset_Generator_and_Training (1).ipynb` (Xu, Chu, Wang, ETH, ISSCC'26, IHP SG13G2) | Parametric GDS generator → 5000 openEMS runs → MLP surrogate (9 → 1818 S-params) → CMA-ES inverse design with ngspice co-simulation. **The layout is the design variable.** |
| 4 | [04_gap_analysis.md](04_gap_analysis.md) | all three | What each notebook closes and what none of them close. Each notebook's own "future work" is quoted as evidence. |
| 5 | [05_intermediate_representation.md](05_intermediate_representation.md) | proposal | The IR needed between circuit and layout (`design_ir`). |
| 6 | [06_instramp_rtrim_case_study.md](06_instramp_rtrim_case_study.md) | this repo | First use case: post-layout resistor trim of the 8× instrumentation amplifier. Feasibility numbers measured with the PDK models. |
| — | [research_statement.md](research_statement.md) | — | The research direction, written up: problem, hypothesis, research questions, contributions, evaluation. |

The milestone plan is in [`docs/roadmap.md` §5](../../roadmap.md#5-closed-loop-cid--layout-inverse-design-research-direction).

## How the three compose

```
             spec
              │
   ┌──────────▼───────────┐   C/ID LUTs (ngspice sweeps per L, corner, T)        ← notebook 1, 2
   │  analytic sizing      │   objective = current / power, constraints = gain, GBW, PM, swing
   │  (C/ID, gm/ID)        │   optimiser: grid / NSGA-II / CMA-ES
   └──────────┬───────────┘
              │ sizing vector  (W, L, nf, R, C)
   ┌──────────▼───────────┐   quantise to the layout grid (fingers, segments, unit cells)  ← notebook 1 (ALIGN nf rule)
   │  layout generator     │   parametric, DRC-clean by construction                      ← notebook 3 (gdspy T-coil)
   └──────────┬───────────┘
              │ GDS
   ┌──────────▼───────────┐   DRC / LVS / PEX (this repo: scripts/flow.sh, ~1 min)
   │  extraction           │   EM for passives (notebook 3: openEMS, hours per sample)
   └──────────┬───────────┘
              │ parasitics, keyed by schematic net          ← missing in all three (see 04, 05)
   ┌──────────▼───────────┐
   │  surrogate of the     │   notebook 3: MLP replaces EM.
   │  expensive step       │   Here: a model of Δ(post − schematic) replaces PEX in the inner loop
   └──────────┬───────────┘
              └──────────► back into the analytic sizing (the arrow none of the notebooks draws)
```

The short version (judgement):
- Notebook 1 gives the **coarse model**: analytic, cheap, PVT-aware.
- Notebook 3 gives the **recipe for replacing an expensive oracle with a learned one**, plus a layout-native parameter space.
- Notebook 2 shows that **loading can be iterated to a fixed point inside the analytic model**. Its `cwire` constant is precisely where extracted layout should be fed back.
- The repository already has the fine model: CACE plus DRC, LVS and PEX in about a minute.
- The research contribution is the feedback edge and the representation it needs.
