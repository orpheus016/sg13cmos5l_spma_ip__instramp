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

Tools **not** installed: torch, optuna, scipy is present (`differential_evolution`), scikit-learn is present, ALIGN is not.

## 1. C/ID (Adair) sizing + optimisation loop: feasible, worth doing, first

*Facts:* C/ID(S) is a sizing method from the Utah group (Tajalli); Alec Adair's ISSCC 2025 paper is "Automated Current-Mirror based OTA Design and Optimization -
from Specifications to Layout" and uses C/ID algorithms for a low-complexity OTA design algorithm (sources below). I could not
find the paper's equations on the web and did not implement from memory: **get the paper (or the definition you use) before writing the notebook**.
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

## Suggested order

1. Parametrise instramp, decide the spec limits (STATUS phase 1 questions) - days.
2. C/ID notebook + optimiser against CACE - 1-2 weeks, after you have the paper.
3. Dataset generator; decide on the surrogate - days.
4. Layout generators for the repeated primitives; loop with `flow.sh` - weeks.
5. Topology library and selector - weeks; reuses 2-3.
6. ALIGN evaluation - only if 4 is not enough.

Sources: [IEEE Toronto 2022 seminar abstract describing C/IDS](https://www.ieeetoronto.ca/events/2022-06-03/), [LCAS Utah: Adair's ISSCC 2025 OTA work](https://lcas.ece.utah.edu/2025/01/04/isscc-travel-grant), [ALIGN: A System for Automating Analog Layout](https://arxiv.org/pdf/2008.10682).
