# 01: C/ID current-mirror OTA, spec to GDS (Adair, ISSCC'25 Code-a-Chip)

Source: `notebook_references/current_mirror_ota_optimization (1).ipynb` (76 cells, SKY130A).
Companion material named in the notebook:
- A. Adair, A. Tajalli, *"Analytical Optimization for Robust and Efficient Analog IC Design Automation"*, under review at DAC 2025 when the notebook was written.
- Repositories: <https://github.com/alecadair/CM-OTA-Synthesis> (scripts, templates, LUTs, `src/cid.py`, plus the PDF `AnalyticalOptimization-OTA.pdf`) and <https://github.com/alecadair/DAC2025_ROAR>.
- Travel-grant listing: [LCAS Utah](https://lcas.ece.utah.edu/2025/01/04/isscc-travel-grant).

I did not find the published DAC'25 paper with a web search, so use the PDF in the CM-OTA-Synthesis repo for the full derivation. The notebook embeds the derivation only as images (`analysis_page1-4.png`).

## What C/ID is (as the notebook uses it)
- **Fact:** It extends gm/ID. Every small-signal quantity is normalised by drain current and tabulated against gm/ID. In code, the prefix `k` means "divided by ID": `kgm = gm/ID`, `kcgs = Cgs/ID`, `kcgd`, `kcds`, `kgds`, and `iden = ID/W`.
- Capacitances per unit current are what make it "C/ID". Self-loading becomes analytic in current, so an objective such as total current is a closed-form function of the gm/ID choices.
- The notebook calls the family "inverse-ID based design".
- **Fact:** The claimed property is *"systematic convergence for process and temperature variation without simulation or computational iteration"*. PVT robustness comes from evaluating the same analytic objective on several LUT corners and keeping the region where they agree.

## LUT generation (cell 16)
- ngspice sweeps a characterisation template with the placeholders `_LENGTH`, `_CORNER` and `_TEMPERATURE`.
- The hierarchy is `LUTs_<TECH>/<n|p>_<model>/LUT_<N|P>_<L>/<fet><corner><T>.csv`.
- Defaults are L ∈ {0.15, 0.2, 0.25, 0.3, 0.5, 1.0} µm, corners {ss, tt, ff} and T ∈ {−25, 25, 75} °C, with W fixed at 0.84 µm (two 0.42 µm fingers).
- **Fact:** `CIDCorner` wraps one CSV in a pandas frame and does interpolated lookups `lookup(param1="kgm", param2="kcgs", param1_val=…)`. `CIDCornerCollection` returns a vector with one entry per corner.

## The objective (cells 19–21, "Eq. 25")
`total_current_ota(ncorner, pcorner, kgm_n, kgm_p, alpha, gbw, cload, gain_spec, …)`:
- `alpha = 1/tan(90° − PM)`. This is how far the non-dominant pole must sit beyond GBW.
- `gain = kgm1/(kgds6 + kgds8)`. This is the DC gain in C/ID form, independent of current.
- `kcout = kcgd8 + kcds8 + kcgd6 + kcds6`. This is the self-loading of the output node per unit current.
- Mirror ratio: `beta = (kgm4 − 2π·α·GBW·kcgs4)/(2π·α·GBW·(kcgs8 + kcgd8))`. The mirror pole limits it, and feasibility requires beta ≥ 1.
- `I_total = [α·CL·ω1²·(kcs8 − kcgs4) + ω1·CL·kgm4] / [(kgm4 − α·ω1·kcgs4)·(kgm1 − ω1·kcout)]`, multiplied by 2 for the full circuit.
- The validity masks are beta ≥ 1, gain ≥ spec and noise.

**Judgement:** This is the idea to carry over. Self-loading appears in the denominator as `kgm1 − ω1·kcout`. The analytic model already accounts for its own capacitance per unit current. **A layout parasitic has the same form, an extra C on a known node.** So the slot for back-annotation exists in the equation, and the notebook never fills it from extraction.

## Optimisation and PVT choice (cells 22–27)
- The spec is GBW 100 MHz, CL 4 pF, PM > 60° and gain > 50 V/V.
- The method is a 50×50 grid over (gm/ID_n, gm/ID_p) per temperature. A contour marks where the current spread across −25/25/75 °C is < 10 %, and hatching marks spec-infeasible regions.
- **Fact:** The final pick is gm/ID_n = 16 and gm/ID_p = 5.25, **chosen by the designer**. The n-side value is the maximum inside the < 10 % region, and the p-side value trades power against headroom and mismatch. The "optimisation" is a visualised exhaustive search.
- **Fact:** There is a SKY130 pFET current-density artefact at high gm/ID ([skywater-pdk#381](https://github.com/google/skywater-pdk/issues/381)). The notebook advises pFET gm/ID < 15.

## Sizing → layout quantisation (cells 31–33)
- `W = I_branch / iden(kgm)`.
- **Fact:** ALIGN wants one finger width for all devices and an **even finger count**, with a 0.42 µm minimum finger, so `nf = round(W/0.42 µm)` is rounded up to even.
- **Judgement:** This is the first place where layout pushes back on the circuit. Rounding changes W and therefore gm/ID, and the notebook does not re-evaluate the objective after quantising. A closed loop must re-evaluate after every quantisation step.

## Netlists, ALIGN, verification (cells 34–74)
- SPICE and ALIGN netlists come from `$W1-2…` and `$NF1-2…` template substitution.
- ALIGN constraint JSON:
  ```json
  [{"constraint":"PowerPorts","ports":["vdd"]},{"constraint":"GroundPorts","ports":["vss"]},
   {"constraint":"SymmetricBlocks","pairs":[["M1","M2"],["M3","M4"],["M5","M6"],["M7","M8"],["M9","M10"]],"direction":"V"},
   {"constraint":"CompactPlacement","style":"center"},{"constraint":"ConfigureCompiler","is_digital":false}]
  ```
- The run is `schematic2layout.py … -p <pdk>`. Magic extracts, and `make_subckt_from_extraction` adds the missing `.subckt` wrapper. Ideal vs post-layout Bode plots follow.
- **Fact (cell 32):** One layout is generated **per temperature corner**, because a fixed W cannot hold gm/ID over T. The notebook says: *"Further work aims to address analytical and procedural layout and design convergence."* That open item is the research gap this repository picks up.

## Porting to SG13CMOS5L (this repo)
| Item | Notebook | Here |
|---|---|---|
| LUT source | ngspice + SKY130 `nfet_01v8` | ngspice + `sg13_lv_nmos/pmos`. `tools/gm-id-sizing_with-lut.ipynb` is the starting point and needs the `kcgs, kcgd, kcds, kgds, iden` columns per L, corner and T |
| Topology | 8T current-mirror OTA | two-stage Miller OTA (`xschem/ota_cmos5l`). The equations must be **re-derived** (CC, RZ, second-stage pole); they do not carry over |
| Layout | ALIGN (no IHP support, see [roadmap §3](../../roadmap.md)) | hand layout plus KLayout/PDK PCells. Generators are proposed instead of ALIGN for M1–M3 |
| PVT | three temperature LUTs | the analytic corners are the coarse check, and the CACE PVT profile is the fine check |
| Verification | Magic extraction + ngspice Bode | `scripts/flow.sh` (DRC, LVS, PEX C and RC, CACE comparison) |

## What to reuse
1. The `CIDCorner` lookup pattern and the k-prefix convention.
2. The **PVT agreement region** as a robustness constraint. It is cheaper than worst-case optimisation and easy to explain in a report.
3. The closed-form objective as the **coarse model** of the loop, with a slot for extracted node C and R.
