# 01: LLMForge and CircuitsDNA, and what transfers to analog sizing

Both are ISSCC'26 Code-a-Chip notebooks from Brown (ReaLLMASIC lab), in `notebook_references/`. Both are digital. They were read for ideas, not code.

## LLMForge (`main_notebook.ipynb`): joint HW/SW optimisation of edge transformers on sky130
- **Search space:** a declarative spec `{"type": "int"|"cat", "low", "high", "step"}` for global and per-layer parameters, edited with ipywidgets.
- **Feasibility before evaluation:** `is_feasible(...)` checks divisibility rules between model and accelerator dimensions. Infeasible points are never evaluated.
- **Evaluation:**
  - per-PE PPA comes from a Yosys/OpenROAD sweep run once (> 12 h) and stored as a CSV database;
  - full-accelerator PPA is aggregated analytically from it;
  - software accuracy comes from a training sweep.
- **Search:** NSGA-II over a heterogeneous space too large to enumerate; about 1.5 days on 8 H100. Results are shown as Pareto scatter plots.
- **For analog:**
  - the declarative space becomes `dao.spec.Variable` (real/int, bounds, log, layout grid);
  - feasibility filters become cheap pre-checks (headroom, grid);
  - the sweep database plus analytic aggregation becomes the LUT/C/ID coarse model of the closed loop;
  - the Pareto view becomes `dao pareto` (ε-constraint).
  - The compute cost does *not* transfer: an analog evaluation here takes about 0.15 s.

## CircuitsDNA (`CircuitsDNA.ipynb`): evolutionary synthesis of approximate multipliers on GF180
- **It starts from a seed:** the synthesised netlist of an exact 8-bit multiplier (`mult_8bits.syn.v`).
- **A C++ genetic algorithm:**
  - population 100, top-k elitism 2 %, **fixed seed 2025**, up to 100 000 generations;
  - mutations add/delete gates, change gate type, rewire, and merge equivalent nodes, so **the topology changes**.
- **Fitness:** area (equivalent transistor count) under a worst-case-error bound ε. The bound is relaxed by a schedule (`eps_start` → `eps_end`, time constant `eps_tau`). Error is computed **exactly over all 2¹⁶ input vectors**.
- **The winner is re-verified** with independent tools: gate-level simulation and OpenSTA.
- **Result:** at 0.5 % relative worst-case error, 76.5 % of the original transistor count.
- **For analog:**
  - seeding from the existing circuit (your "half-optimised in, optimised out") → `variables[].seed`, evaluated first;
  - elitism and a fixed seed → seeded algorithms that start from the best-so-far;
  - the ε-schedule → the ε-constraint Pareto;
  - independent re-verification → CACE sign-off.
  - **Not transferable:** topology mutation (DAO keeps the topology fixed by design), and exact exhaustive fitness. Analog metrics are continuous, PVT-dependent and need simulation.

## Corrections to the original idea
1. **"Deterministic, not probabilistic like an LLM."**
   - GA, NSGA-II and CMA-ES are stochastic algorithms, but **seeded runs are reproducible bit for bit**, given the same simulator version, single-threaded simulation and the same inputs.
   - DAO enforces this and checks it: a manifest plus a SHA-256 of the evaluation history.
   - *Deterministic does not mean globally optimal.* For nonconvex sizing, no method guarantees a global optimum. DAO adds a **mesh-local optimality certificate** from its final pattern search instead.
2. **"Any topology."**
   - True within a circuit class, through **port-based testbenches**. The amplifier kit only touches vdd, vss, inp, inn, out and ibias, so any amplifier topology works.
   - It needs your input: sizing exposed as parameters, and bounds declared ([05](05_serving_a_circuit.md)).
3. **"Any PDK."**
   - True through a **PDK profile** (device classes → models, units, corners, op-variable names).
   - An optimised sizing does **not** transfer between PDKs. A new PDK means re-optimising, possibly seeded by gm/ID scaling (future work, shared with the retargeting thread in [07](../closed-loop-inverse-design/07_layout_tool_decision.md)).
4. **"Half-optimised in, fully optimised out."**
   - Yes, as local optimisation from the seed, with the certificate and a seed-vs-best report.
   - "Fully optimised" means *locally optimal for the stated FoM, constraints, bounds and grid*. The answer is only as good as the constraint set. The case study shows the saturation-margin constraint deciding the result ([06](06_case_ota_noise.md)).
