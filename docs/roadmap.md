# Roadmap: optimisation, auto-layout, topology selection

What is realistic on top of the CACE flow (`docs/README.md` "Flow guide"), in the order I would do it. Written 2026-10-14; verdicts are
engineering judgement, the facts they rest on are marked.

## 0. What the repository already has (the enabling part)

| Piece | Where | Why it matters |
|---|---|---|
| Verified PVT characterisation as a function call | `scripts/run_cace.sh <cell> [-p ...]`, ~25 s for a typical-profile OTA, ~2 min full | the objective function of any optimiser |
| Post-layout loop | `scripts/flow.sh`, `run_postlayout.sh --netlist c|rc` (~1 min) | the "layout in the loop" check, wire C and R |
| One param block per cell | OTA: `.param` block in `ota_cmos5l.sch` (done); instramp resistors: **not yet parameters** | what the optimiser changes. Needs finishing before anything below (STATUS phase 3) |
| gm/ID LUT notebook | `tools/gm-id-sizing_with-lut.ipynb` | starting point for a C/ID table |
| Machine-readable results | `docs/<cell>/status.json`, `postlayout.json`, `scripts/cace_data.py` | dataset generation |

Tools (checked 2026-10-15). **Present:** scipy (`differential_evolution`), scikit-learn, `cma`, gdsfactory, klayout (python), scikit-rf, magic, ngspice. **Not installed:** torch, optuna, pymoo, ALIGN.
None of the missing ones is needed before §5 M2. `cma` gives the CMA-ES ask/tell loop that the T-coil notebook gets from optuna.

## 1. C/ID (Adair) sizing + optimisation loop: feasible, worth doing, first

*Facts:* C/ID(S) is a sizing method from the Utah group (Tajalli); Alec Adair's ISSCC 2025 paper is "Automated Current-Mirror based OTA Design and Optimization -
from Specifications to Layout" and uses C/ID algorithms for a low-complexity OTA design algorithm (sources below). I could not
find the paper's equations on the web and did not implement from memory: **get the paper (or the definition you use) before writing the notebook**. *(Update 2026-10-15: the CM-OTA notebook in `notebook_references/` has the objective as code, `total_current_ota`, and points to the PDF in github.com/alecadair/CM-OTA-Synthesis; see [01](research/closed-loop-inverse-design/01_cid_cm_ota_align.md).)*
What can be said without it: like gm/ID it needs a handful of technology tables extracted by simulation, here from ngspice sweeps of `sg13_lv_nmos/pmos` per L,
and the design flow is analytical, which is why it automates well.

Plan:
1. Finish parametrisation: instramp resistors (`rhigh` 6.233k/53.06k, `l=8*2.23e-6`) and `.param temp=27` out of the OTA block.
2. `tools/cid-sizing.ipynb`: table extraction (ngspice, W-normalised, per L and corner) -> analytic OTA sizing from specs (gain, GBW, PM, noise, power) -> candidate parameters.
3. Verify with CACE: write the candidate into the `.param` block (or a `.param` override file), run `scripts/run_cace.sh ota_cmos5l -p ac_response dc_op noise` (typ profile first, PVT for the final candidate).
4. Refine with a derivative-free optimiser (scipy `differential_evolution` or CMA-ES, `pip install cma`), objective = weighted spec violations from `cace_data.load_run`; every evaluation is ~25 s,
   16 in parallel, so a 500-evaluation search is ~15 min.
Done when the optimiser reproduces the hand design (A0 57.9 dB, PM 60.6°, 18 µA) from the spec, and finds a better one on at least one axis (power, area of the MoM cap).

## 2. Dataset + ANN surrogate: only after step 1, and only if it pays

A surrogate `specs = f(sizing, corner, vdd, T)` replaces the ~25 s simulation by microseconds. It pays when you run **many** optimisations or want gradients (inverse design). For one or two OTAs,
the search of step 1 is cheaper than building and validating a network. Needed: a few thousand labelled points (CACE typ run each: ~1000-2000/hour in parallel), `scripts/cace_data.py` as the
reader, a sampling script (Sobol over the parameter ranges), a model (sklearn `MLPRegressor`/GP now; torch is not installed). **Verdict: build the dataset generator as a by-product of step 1 (it is almost free), decide on the ANN when you have seen how many CACE calls the optimiser really uses.**
Always verify the final candidate with CACE; the network is a proposal generator, never the sign-off.

## 3. ALIGN (or any auto-layout) with the network in the loop: possible, expensive, not needed yet

*Facts:* ALIGN turns a SPICE netlist into GDSII using a per-technology JSON design-rule abstraction plus primitive-cell generators (NMOS, PMOS, resistor, capacitor, guard ring); the public repository ships a mock
FinFET 14 nm PDK (sources: ALIGN paper and docs). I found **no IHP SG13G2/SG13CMOS5L support** anywhere; a new PDK means writing the abstraction and primitives yourself.
Your layouts need things a generic placer does not know: IHP MoM caps with the `recog_mom` marker and no touching markers, the `/25` label convention for LVS, the stripped extraction copy (`pex_prepare_gds.py`), and the
antenna/forbidden-layer rules (the decoder already violates `FORB.Metal5`).

Verdict: *feasible* as a research project, *not needed* for this IP: two analog cells are laid out by hand and pass DRC/LVS/antenna. It starts to pay with many varied blocks (coarse/fine gain, buffer) or when
layout parasitics must be in the sizing loop. Cheaper steps first, each usable on its own:
1. parametrised layout generators for the few primitives you repeat (KLayout Python PCell / gdsfactory-style scripts: input pair, mirror, MoM cap array, resistor array) - gets 80 % of the "layout follows the optimiser" benefit;
2. close the loop with what exists: optimiser -> sizing -> generator -> `flow.sh` (DRC, LVS, PEX R+C, CACE) -> objective. One iteration ~2 min;
3. only then evaluate ALIGN against the generators on one block (the OTA: you have the reference layout and its post-layout numbers) before committing to a PDK port.
The ANN in that loop would predict the *layout-induced delta* (post-layout minus schematic, you already produce this table per cell) from sizing + floorplan features - a much smaller learning problem than predicting the specs themselves.

## 4. Topology recommendation from the PDK and the use case: yes, as a deterministic selector; no, as free-form LLM advice

"What people say the most" is a popularity prior; what you want is evidence from this PDK. That can be made deterministic:
1. a **topology library** of parametrised netlists (5T OTA, Miller two-stage - the current design, folded cascode, telescopic, current-mirror OTA, inverter-based, chopper/auto-zero front-ends, ...), each a sizing function of the same spec vector;
2. for each topology and a grid of specs, a **feasibility envelope in this PDK**, computed by the C/ID tables and then CACE runs: reachable gain at 1.2 V (headroom of stacked devices), GBW per µA, noise per µA, area, PM, mismatch-limited offset;
3. a **ranking** by simulated figures of merit for the use case (e.g. biosignal front end: noise and offset first, power second, 1.2 V supply);
4. the LLM's role: propose candidate topologies and write the justification, then call the selector; the choice is made by the numbers and the report shows them (same Plotly report).
Honest limits: the answer is only as good as the library and the envelope; unusual circuits outside the library are not found; process corners and mismatch must be in the envelope or the recommendation is optimistic.
Needs: step 1 first (the sizing machinery), then ~5 topologies as parametrised xschem subcircuits with CACE datasheets (`scripts/new_cell.py` scaffolds the datasheet part).

## 5. Closed-loop C/ID ↔ layout inverse design (research direction)

*Added 2026-10-15 after reading the three notebooks in `notebook_references/`. The notes are in [`docs/research/closed-loop-inverse-design/`](research/closed-loop-inverse-design/README.md) and the research write-up is in [research_statement.md](research/closed-loop-inverse-design/research_statement.md).*

**The idea.** One notebook loop that does what a designer does by hand: size (C/ID), lay out (generator), extract (`flow.sh`), read the post-layout delta, re-size. The pieces come from:
- the CM-OTA notebook: the analytic coarse model;
- the CML notebook: the self-loading fixed-point iteration, and the `cwire` hole where extracted data belongs;
- the T-coil notebook: a DRC-safe generator, a surrogate of the expensive step, and the batched CMA-ES ask/tell loop.

*Fact:* none of the three feeds extracted layout back into sizing, and each lists that as future work ([gap analysis](research/closed-loop-inverse-design/04_gap_analysis.md)). *Judgement:* that feedback edge, together with the representation it needs, is the research contribution. The formal frame is **space mapping**: optimise the cheap physics model and align it to the expensive one with as few expensive runs as possible. The "ANN in the loop" is the residual model inside that frame, not a replacement for the physics.

**Facts that shape the plan.** They were measured with the PDK models and are in [06](research/closed-loop-inverse-design/06_instramp_rtrim_case_study.md).
- The instramp ideal R ratio is 8.513. It gives 8.000× only because the loop gain is T ≈ 16 (inferred), so the trim is compensating the OTA's finite gain. dG/G ≈ 0.06·dA/A.
- One 5 nm length step is 279 ppm (R3/R4) or 2372 ppm (R1/R2). Combining both gives a 2.8 ppm median spacing but a 127 ppm worst case. **A fine-trim element (an rsil stub) is needed for a guaranteed 10 ppm.**
- 10 ppm of R2 is 0.06 Ω, less than one square of Metal1 (≈ 110 mΩ/sq). **Wire R must be in the objective.**
- rhigh mismatch gives σ(R4/R2) ≈ 5.0 % at the present size (ngspice MC, 300 runs) and 0.59 % at 100× area. **10 ppm is a nominal post-layout target, not a silicon one.** Silicon needs trim or calibration, or a matching-insensitive architecture.
- The CACE A_ERR output (0.001 dB ≈ 115 ppm) is coarser than the target, so a ppm-resolution output is needed.

### Milestones
| | What | Done when | Verdict |
|---|---|---|---|
| **M0** | Parametrise the instramp R (`.param`). Add `A_ERR_PPM` (or a DC `.tf`) to `cace/templates/instramp_cmos5l/ac.sch`. Write the first `design_ir/instramp_cmos5l.yaml` by hand ([05](research/closed-loop-inverse-design/05_intermediate_representation.md)) | the schematic and the IR agree, and CACE reports ppm | days, prerequisite (also §1 step 1) |
| **M1** | **R-trim loop.** An rhigh unit-segment array generator (KLayout, based on the PDK `rhigh_code.py` PCell; dummies, common centroid, optional rsil trim stub). LVS-based net cross-reference and a per-net R/C summariser. Coarse model `G = r/(1+(1+r)/A)·(1+ε_wire)`. Space-mapping driver around `flow.sh` | post-layout typical |G/8 − 1| < 10 ppm in ≤ 5 `flow.sh` runs, with no hand edits | **feasible, first research result.** About 2–3 weeks |
| **M2** | Δ-layout surrogate: log `(params, layout knobs, per-net parasitics, pre/post metrics)` every iteration. Fit affine → GP (sklearn) → MLP (torch only if needed) to predict the post-minus-schematic residual. Compare with M1's affine update | the surrogate cuts fine evaluations further, or the comparison shows that affine is enough (both are publishable answers to RQ3) | feasible. The dataset comes almost free with M1 (§2) |
| **M3** | **Layout-aware C/ID OTA.** Re-derive the C/ID objective for the Miller OTA with explicit extracted node C and branch R terms (01's `kgm1 − ω1·kcout` slot, 02's `cwire` hole). Add a generator for the input pair, mirror and MoM array. Run the same loop | the optimiser reproduces the hand OTA from the spec and the post-layout numbers converge in ≤ 5 iterations (§1 "done when", now post-layout) | feasible, harder: the generator is the effort. Use the CM-OTA-Synthesis repo PDF for the equations |
| **M4** | Multi-cell: coarse/fine gain stages and the buffer share the IR and the residual model. PVT/MC objectives (agreement region from 01, MC σ as a constraint) | one residual model serves ≥ 3 cells, and the PVT objective is in the loop | research-grade. This is where an ANN may start to pay |
| **M5** | Export the IR constraints to ALIGN JSON and compare with the generators on the OTA (§3) | a quantitative comparison table | only if M3 generators are limiting |

### Needs (what does not exist yet)
1. **An intermediate representation** (`design_ir/<cell>.yaml`): params with layout grid, device→generator map, matching constraints, net criticality budgets, parasitics **keyed by schematic net**, and results ([05](research/closed-loop-inverse-design/05_intermediate_representation.md)).
2. **Net-name-stable back-annotation.** The RC netlist names the gain nodes `pnNN`, and the mapping comes only from LVS. Extend `scripts/lvs_tools.py` / `pex_netlist.py`.
3. **Deterministic, DRC-clean layout generators**: rhigh arrays first, then MOS pairs and mirrors, then MoM arrays.
4. **Gain measurement at ppm resolution** (A_ERR_PPM, or `.tf`).
5. **A per-iteration dataset log** in the `postlayout.json` key space.
6. **A spec decision:** is "8×, < 0.001 %" the typical post-layout systematic error (achievable, M1) or the PVT/MC envelope? The envelope needs about 80 dB of loop gain plus trim, which means OTA redesign (M3) and a calibration path.

## 6. Deterministic Analog Optimizer (short term, started 2026-10-15)

*Decision 2026-10-15:* ALIGN has no IHP port (1–2 months to add one), and SKY130 would leave the Chipalooza IHP target ([07](research/closed-loop-inverse-design/07_layout_tool_decision.md)). So the layout loop (§5) is **deferred**, and the shippable piece is a deterministic, PDK-agnostic sizing optimiser.
- **Code:** separate repository `/foss/designs/dao`. AnalogGym's circuit library is used through an adapter, not forked; ideas are taken from FALCON (NeurIPS'25).
- **Docs:** [`research/deterministic-analog-optimizer/`](research/deterministic-analog-optimizer/README.md).

*Facts (measured):*
- the port-based kit reproduces OTA CACE within a few %;
- 0.14 s per IHP evaluation;
- a 4817-evaluation run repeats byte-identically without cache;
- the same converted AnalogGym NMCF netlist evaluates on SKY130 and IHP;
- demos A (noise) and B (FoM_S) end with a mesh-local optimality certificate.

*Next:*
1. Sign off the OTA result with CACE (typ, then pvt).
2. A closed-loop kit for the instramp (gain ppm, noise, f3dB).
3. A trimmed SKY130 include, then the AnalogGym NMCF benchmark against GCNRL/WEIBO/cVTS.
4. `surrogate_gradient` (FALCON-style, verified by simulation).

The optimiser is also §5's "coarse optimiser". The loop then adds layout generators and PEX back-annotation on top of it.

## Suggested order

0. **Until 2026-10-31:** §6 (dao on the OTA and then the instramp), plus the relayout of the resized cells. §5 waits.
1. Parametrise instramp, decide the spec limits (STATUS phase 1 questions), add ppm gain output (§5 M0) - days.
2. **R-trim closed loop on the instramp (§5 M1)** - 2-3 weeks. This is the first demonstrator of the research direction and needs no ML.
3. C/ID notebook + optimiser against CACE (§1). The equations are in the CM-OTA notebook (`total_current_ota`) and the CM-OTA-Synthesis repo PDF; they must be re-derived for the Miller OTA - 1-2 weeks.
4. Dataset logging and the residual surrogate (§2, §5 M2) - days, as a by-product of 2.
5. Layout generators for the OTA primitives, then layout-aware C/ID in the loop (§5 M3) - weeks.
6. Multi-cell and PVT/MC in the loop (§5 M4); topology library and selector (§4) - weeks, reuses 3-5.
7. ALIGN evaluation through the IR export (§3, §5 M5) - only if 5 is not enough.

Sources: [IEEE Toronto 2022 seminar abstract describing C/IDS](https://www.ieeetoronto.ca/events/2022-06-03/), [LCAS Utah: Adair's ISSCC 2025 OTA work](https://lcas.ece.utah.edu/2025/01/04/isscc-travel-grant), [ALIGN: A System for Automating Analog Layout](https://arxiv.org/pdf/2008.10682), [ParaGraph (DAC 2020)](https://research.nvidia.com/publication/2020-07_paragraph-layout-parasitics-and-device-parameter-prediction-using-graph-neural), [Post-layout simulation driven sizing (arXiv 2310.14049)](https://arxiv.org/abs/2310.14049), [Layout-aware AMS automation with BNNs (ICCAD 2023)](https://arxiv.org/abs/2311.17073), [Space Mapping: The State of the Art](https://pure.kfupm.edu.sa/en/publications/space-mapping-the-state-of-the-art/). The notebook sources are listed in [`docs/research/closed-loop-inverse-design/README.md`](research/closed-loop-inverse-design/README.md).
