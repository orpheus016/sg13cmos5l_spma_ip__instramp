# 02: C/ID for high-speed current-mode logic (Elhelly, ISSCC'26 Code-a-Chip)

Source: `notebook_references/current_mode_logic_optimization.ipynb` (69 cells, SKY130A, 1.8 V LVT, L = 150 nm). Repository: <https://github.com/adhammo/CML-DIV-Synthesis>. The notebook names notebook 01 as its inspiration.

## What is new compared with 01
1. **LUT "swap" (cells 17–24).**
   - The raw device LUT is indexed by (Vsw, ID/W). It is re-indexed by **design-meaningful degrees of freedom**: (Av, Vswing) for a CML pair, and (gm/ID, Vsw) for a source follower.
   - For the CML pair this is done by solving `gm/ID − Av·gds/ID = 2·Av/Vsw` for ID/W, then interpolating every other column at that ID/W.
   - **Judgement:** This is a general trick. Change variables until the optimiser's variables are the ones a designer reasons in. For the instramp, that means optimising *gain ratio and absolute R* rather than four resistor lengths.
2. **Scipy `RegularGridInterpolator` surrogates (cell 26).** There is one interpolator per quantity (`idw, gm_full, cgs, cgd, cdb, csb, vsr`, plus SF variants). The analytic model is a composition of cheap, smooth lookups. It is a physics-shaped surrogate that needs no training.
3. **Composable sub-circuit evaluators (cell 28).** `eval_latch_idw → eval_latch_vsr → eval_latch_caps → calc_latch_iss` each return the input dict extended with new keys. The divider and the 2/3 divider reuse the latch, SF and gate evaluators.
4. **Self-loading fixed-point iteration (cell 44).**
   - In the divider, latch 1 loads latch 2 and vice versa, and the SF loads latch 2.
   - The code iterates five times: compute every block's Iss from its load, then recompute the loads (`(cgd_in + cgs_in)·iss` of the next stage), then repeat.
   - The swing degradation `vsr` is iterated the same way, five times.
5. **pymoo NSGA-II with explicit constraints (cells 34–36, 48, 62).**
   - The objective is total Iss.
   - The `G ≤ 0` constraints are minimum swing ratio, minimum SF gain and Iss > 0.
   - Population 100, 50 offspring, SBX crossover and PM mutation.
   - The analytic optimum is **verified with one transient ngspice simulation** (`run_latch_tb`, `run_divider_tb`), and the error vs the target `tcq` is printed.
6. **Design-space tables (cells 39–42, 53–56).** These sweep spec × load and pickle the optima (`latch.pkl`, `divider.pkl`) as sensitivity curves. That is a cheap dataset built from the analytic model.

## The layout hole
- **Fact:** `divider_total_current(…, cwire, cload)` is called with `cwire = 20e-15` (cell 52). It is one guessed interconnect C applied to every internal node.
- **Fact:** The divide-by-2/3 optimisation is marked *"Not yet working (refer to the next cell for hand design)"* (cell 65). The analytic approach stops converging as the topology grows.
- **Judgement:** The fixed-point loop in item 4 is *the* mechanism a layout loop needs. Replace the scalar `cwire` with **extracted C (and R) per net from PEX, keyed by schematic net name**. The same five-pass loop then becomes "size → lay out → extract → re-size". The analytic structure stays as it is: only the data source changes, and a stable net-name mapping is needed (see [05](05_intermediate_representation.md)).

## Transfer to precision analog (this repo)
| CML notebook | Instramp / OTA analogue |
|---|---|
| (Av, Vsw) re-parametrisation | (gain ratio, absolute R, unit-element count) instead of four lengths |
| `cwire` constant | extracted wire **R** and C on the gain-setting nets (`net5`, `net6`, `VOUT`, `CM` in `netlist/instramp_cmos5l/schematic/instramp_cmos5l.spice`) |
| self-loading fixed point | loading fixed point: R4+R2 (≈ 59 kΩ) load the output OTA, so its A drops and the ratio that gives 8× changes (see [06](06_instramp_rtrim_case_study.md)) |
| NSGA-II, then one SPICE check | analytic or GP optimum, then one `flow.sh` post-layout run, then correct and repeat (space mapping) |
| `latch.pkl` sensitivity tables | the dataset for the Δ-layout surrogate |

Tools: pymoo is **not installed** here. `scipy.optimize` and `cma` are. pymoo only earns its place for genuinely multi-objective work (roadmap M3+).
