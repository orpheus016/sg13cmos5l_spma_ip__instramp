# 02b: FALCON (NeurIPS 2025). What it answers and what it does not

Sources:
- paper [arXiv 2505.21923](../closed-loop-inverse-design/2505.21923v2.pdf) (Mehradfar et al., NeurIPS 2025), read through the arXiv HTML;
- repository [AsalMehradfar/FALCON](https://github.com/AsalMehradfar/FALCON) at `845145c` (2025-11-19), MIT, 124 MB, inspected from a shallow clone.

## What it is
A three-stage ML pipeline:
1. **Topology selection.** An MLP (5 layers, hidden width 256) maps a 16-metric target to one of 20 topologies: 99.57 % accuracy.
2. **Forward model.** An edge-centric GNN (nets are nodes, devices are edges, 4 message-passing layers) predicts the 16 metrics from topology plus parameters: R² 0.972, 9.09 % mean relative error.
3. **Inverse design.** Gradient descent through the frozen GNN on `L_perf + λ_area·L_layout·g(L_perf)`, with `g = 1 − σ(γ(L_perf − τ))` (τ = 0.05, γ = 50, λ = 0.02). The layout term switches on only once performance is close. Adam, parameters clipped to bounds, restart if not converged. Milliseconds to under 1 s per instance on a laptop CPU.

**Data:**
- About 1 M **Cadence Spectre** simulations on an unnamed **45 nm PDK**;
- **fixed 30 GHz**, five RF/mm-wave families (LNA, mixer, PA, voltage amplifier, VCO), four topologies each;
- **no op-amps**;
- the netlists are Spectre syntax (`dataset/*/*/netlist`), with per-topology CSVs.

**Layout:**
- an analytical, non-learned **passive-area** model: R and C as W·L, and an octagonal inductor fit `A = 4R² + 108R + 440 µm²`;
- active devices are excluded;
- DRC-style spacing guidelines are applied in a hand layout;
- **routing was done manually**.

**End-to-end results:**
- 78.5 % success and **17.7 % mean error against Spectre** on 9500 instances. The abstract's "< 10 %" figure is the forward-model error.
- On an unseen topology (RVCO): 30.4 % zero-shot, and 0.9 % after fine-tuning the output head on about 30k samples.

## Verdict: state of the art for learned inverse design, but it does not replace DAO
| You want | FALCON |
|---|---|
| Open PDK, reproducible by anyone | Closed 45 nm PDK plus Cadence. The dataset cannot be regenerated with open tools; IHP would need new data |
| Deterministic, certified answer | Gradient descent from a perturbed initialisation with restarts. The repo seeds 42, so it is reproducible, but there is no optimality evidence and the answer carries the surrogate's error |
| Op-amps / precision analog | Not in the dataset |
| Simulator in the loop | Only for final verification; the design itself comes from the surrogate |
| Real layout awareness | Passive area only; no PEX; manual routing |

**FALCON's own limitations are the deferred research goal.** The paper states that the layout model *"does not replace EM simulation or post-layout verification"*, and that routing was manual. Closing the loop with real DRC/LVS/PEX on an open PDK ([closed-loop-inverse-design](../closed-loop-inverse-design/README.md)) is the step after FALCON. That makes it the anchor of the related-work section.

## What DAO takes from FALCON (MIT)
1. **The edge-centric netlist graph** (`data_modules/netlist2graph.py`), to be ported from Spectre to SPICE syntax as `dao/graph/`. It is the graph form of the IR, and the input of a future learned surrogate.
2. **The gated loss** `g(L_perf)`: "performance first, then area/layout". It goes into `opt/surrogate_gradient.py` and is reusable as a constraint-handling option.
3. **`surrogate_gradient`** (stub in DAO):
   - train on DAO's *own* ngspice history;
   - do gradient inference;
   - **simulate** the proposals;
   - polish with the certified pattern search.

   That way FALCON's 17.7 % surrogate error costs extra simulations, but never decides the answer.
4. **Topology selection (stage 1).** This maps to roadmap §4 (topology selector). It is deferred because DAO keeps the topology fixed.
