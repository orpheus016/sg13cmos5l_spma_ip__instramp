# Research statement (draft)

## Working title
**Layout-in-the-loop inverse design for analog ICs on an open PDK: closing the C/ID-sizing ↔ layout ↔ extraction loop with physics-first surrogates**

Alternatives:
- *"From specification to post-layout-correct GDS: space-mapped C/ID design with learned layout residuals"*;
- *"Designing the layout that the circuit needs: an open closed-loop flow on IHP SG13CMOS5L"*.

## One-paragraph pitch
Analytic sizing methods such as gm/ID and C/ID now take an analog block from specification to device sizes in seconds, and open layout generators can produce GDS from those sizes. The chain is still **open-loop**. The sizes are computed before the layout exists, and the parasitics the layout adds are corrected afterwards by a designer who reads post-layout simulations and nudges values by hand. The ISSCC'25/'26 Code-a-Chip flows show the parts: analytic C/ID optimisation (Adair; Elhelly) and ANN-surrogate inverse design of a layout-defined passive (Xu, Chu, Wang). Each of them names the missing feedback as future work. This research closes that loop. Extracted layout is turned into **schematic-level corrections** (per-net parasitics in an intermediate representation) and fed back into the analytic model, which is treated as the coarse model of a **space-mapping** iteration. A learned model is used only for the residual the physics does not capture. The first demonstrator is the post-layout gain trim of an 8× instrumentation amplifier in IHP SG13CMOS5L. The goal is to replace a manual PEX-and-adjust loop with an automated one that converges in a handful of extractions, and to state what a 10 ppm gain target means against matching and loop-gain limits.

## Problem
1. **Fidelity gap.** Schematic-level optimisation optimises the wrong function. In this repo the instramp moves from 0 to −0.62 % gain error after RC extraction (`docs/instramp_cmos5l/cace/postlayout_rc.md`). The optimum of the schematic model is not the optimum of the layout.
2. **Iteration gap.** The correction is manual and serial: look at PEX, change R, re-layout, re-extract. A 2025 Fraunhofer presentation abstract reports ten or more schematic/post-layout cycles ([publica.fraunhofer.de/handle/publica/489197](https://publica.fraunhofer.de/handle/publica/489197); seen only as a search snippet, the page was not readable, so treat this as unverified).
3. **Representation gap.** Extracted netlists use layout node names (`pn5`, `pn6`). Analytic models use schematic nets and per-unit-current quantities. Nothing translates between them.

## Hypothesis
- **H1:** A physics-based coarse model (C/ID or a closed-form ratio model) corrected by **per-net extracted parasitics** reaches post-layout specifications in **O(1–5) fine evaluations** (DRC, LVS, PEX, simulation). That is fewer than pre-layout optimisation followed by manual correction, and fewer than black-box BO on the post-layout simulation.
- **H2:** The residual between coarse and fine is **low-dimensional and smooth** in layout features. A small model (affine, then GP, then MLP) learns it with tens to hundreds of samples, unlike the thousands needed when the full response is learned (the T-coil case: 5000 EM samples).
- **H3:** Making the layout knobs (segments, unit counts, routing widths and lengths) **first-class, quantised optimisation variables** with DRC-safe generators removes the post-hoc rounding error seen in open-loop flows, for example ALIGN's even-finger rule applied after sizing.

## Research questions
- **RQ1, representation.** What is the minimal intermediate representation that lets a sizing model consume layout? How much accuracy is lost by reducing an RC netlist to per-net C and per-branch series R?
- **RQ2, convergence.** How many fine evaluations does space-mapped C/ID need, compared with (a) manual iteration, (b) pre-layout optimisation then a single trim, and (c) BO directly on post-layout? This should be measured on the instramp trim and on the OTA.
- **RQ3, surrogate scale.** When does a learned residual (GP or MLP) beat an affine space-mapping update? How does the answer change with the number of cells and layout knobs? Where is the break-even point at which the T-coil-style ANN pays?
- **RQ4, robustness.** Can the loop optimise PVT and mismatch statistics, not only the nominal value? For example: post-layout 10 ppm at typical subject to σ_gain from MC, or the C/ID PVT agreement region extended to post-layout.

## Expected contributions
1. An **open, reproducible closed-loop flow** on IHP SG13CMOS5L, built on xschem, ngspice, CACE, KLayout, Magic and kpex: spec → C/ID sizing → generated layout → DRC/LVS/PEX → back-annotated re-sizing, as notebooks.
2. A **design IR** (`design_ir`) with schematic-keyed parasitics and layout-grid-aware parameters, plus the LVS-based extractor that fills it.
3. **Layout-aware C/ID**: the C/ID objective with explicit extracted node C and branch R terms. This extends Adair's formulation and fills the hole that Elhelly's `cwire` constant leaves open.
4. A **quantitative feasibility study** for precision gain on an open PDK: grid quantisation, wire-R budget, mismatch floor and loop-gain floor, with the instramp as the worked example (see [06](06_instramp_rtrim_case_study.md)).
5. A **dataset** of (sizing, layout knobs, per-net parasitics, pre and post metrics), released with the flow.

## Evaluation
| Metric | Baseline | Target |
|---|---|---|
| Fine evaluations (PEX runs) to reach spec | manual loop (count from history) | ≤ 5 |
| Post-layout typical gain error | −0.62 % today | ≤ 10 ppm nominal |
| Wall-clock spec → verified GDS | hours to days by hand | < 30 min |
| PVT/MC gain spread | −3.4 % / +2.3 % schematic | report, then reduce (needs loop gain and area, §3 of 06) |
| Generality | 1 cell | instramp, OTA, coarse and fine gain stages |

## Threats to validity, stated up front
- **The nominal and silicon targets differ.** rhigh local mismatch in this PDK gives σ(R4/R2) ≈ 5 % at the current size, and loop gain T ≈ 16 makes gain sensitive to OTA PVT. A 10 ppm *nominal* result must not be presented as a 10 ppm *silicon* result. The loop's real value is systematic-error removal plus fast exploration.
- **Extraction fidelity.** Magic RC and kpex C are the reference. Their own error against a sign-off extractor is unknown for SG13CMOS5L.
- **Generator bias.** "Optimal layout" means optimal within the generator's family, and the study must state that family.
- **Small benchmark set.** Mitigate with the PGIA's own blocks (OTA, coarse, fine, buffer) as a family of related cells.

## Related work (verified links)
- **C/ID / inverse-ID design:** Adair & Tajalli (DAC'25 submission; [CM-OTA-Synthesis](https://github.com/alecadair/CM-OTA-Synthesis), [LCAS Utah](https://lcas.ece.utah.edu/2025/01/04/isscc-travel-grant)); Elhelly, CML dividers ([CML-DIV-Synthesis](https://github.com/adhammo/CML-DIV-Synthesis)).
- **ANN inverse design of passives:** Xu, Chu, Wang (ETH), ISSCC'26 Code-a-Chip T-coil notebook (in `notebook_references/`).
- **Open analog layout generators:**
  - [ALIGN](https://arxiv.org/pdf/2008.10682);
  - [MAGICAL (UT Austin)](https://ieee-ceda.org/presentation/lecture/magical-machine-generated-analog-ic-layout), with code at [github.com/magical-eda/MAGICAL](https://github.com/magical-eda/MAGICAL);
  - [BAG2, process-portable generators](https://www.researchgate.net/profile/Woorham-Bae/publication/325107048_BAG2_A_Process-Portable_Framework_for_Generator-Based_AMS_Circuit_Design/links/6269e2fe6a39cb1180e09a4a/BAG2-A-Process-Portable-Framework-for-Generator-Based-AMS-Circuit-Design.pdf);
  - BAG3++ ([Berkeley EECS-2023-213](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2023/EECS-2023-213.pdf)), which encodes "closed loop design methodologies".
- **Parasitic prediction and layout-aware sizing:**
  - [ParaGraph, DAC 2020](https://research.nvidia.com/publication/2020-07_paragraph-layout-parasitics-and-device-parameter-prediction-using-graph-neural);
  - [Liu et al., parasitic-aware sizing with GNN + BO, DATE 2021](https://research.nvidia.com/publication/2021-02_parasitic-aware-analog-circuit-sizing-graph-neural-networks-and-bayesian);
  - [Gao et al., post-layout simulation driven sizing, arXiv 2310.14049](https://arxiv.org/abs/2310.14049);
  - [Budak, Zhu, Pan, layout-aware AMS automation with BNNs, ICCAD 2023](https://arxiv.org/abs/2311.17073).
- **Closest related work: FALCON** ([Mehradfar et al., NeurIPS 2025](2505.21923v2.pdf); [repo](https://github.com/AsalMehradfar/FALCON), MIT). It does three things:
  - selects a topology with an MLP;
  - predicts performance with an edge-centric GNN;
  - infers parameters by gradient descent through the frozen GNN, with a layout-area penalty that activates only once performance is close.

  Data and results: 1 M Cadence Spectre simulations on a closed 45 nm PDK, at 30 GHz, in 5 RF families with no op-amps; 78.5 % end-to-end success and 17.7 % mean error against Spectre. Its own limitations are what this research starts from:
  - the layout model is analytic passive area only;
  - it *"does not replace EM simulation or post-layout verification"*;
  - routing was done manually.

  This work closes that gap with real DRC, LVS and PEX on an open PDK, with a certified simulator-in-the-loop optimiser as the backbone. Assessment: [`../deterministic-analog-optimizer/02b_falcon_assessment.md`](../deterministic-analog-optimizer/02b_falcon_assessment.md).
- **Benchmark suite: AnalogGym** ([CODA-Team, arXiv 2409.08534](2409.08534v1.pdf); [repo](https://github.com/CODA-Team/AnalogGym), BSD-3). It has 17 ngspice amplifier netlists on SKY130, and published GCNRL, WEIBO and cVTS results at about 1000 simulations each. DAO is benchmarked on the same circuits ([`02_analoggym_assessment.md`](../deterministic-analog-optimizer/02_analoggym_assessment.md)).
- **Space mapping:** [Bandler et al., "Space Mapping: The State of the Art"](https://pure.kfupm.edu.sa/en/publications/space-mapping-the-state-of-the-art/); [aggressive space mapping](https://macsphere.mcmaster.ca/html/11375/28919/SOS_Publications/SOS-00-16-V.pdf).

**Positioning, in one line:** the cited ML works, FALCON included, use proprietary PDKs and learn either parasitics or post-layout performance end to end. This work uses an **open PDK and flow**, keeps the **analytic C/ID model as the backbone** of the optimisation, and learns **only the layout residual**. Its claim is fewer fine evaluations, interpretability, and reproducibility by anyone.
