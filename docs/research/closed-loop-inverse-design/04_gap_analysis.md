# 04: Gap analysis. What is closed, what is not

## Coverage matrix
✅ done in the notebook · ◐ partial or hand-made · ✗ absent

| Stage | 01 C/ID CM-OTA | 02 C/ID CML | 03 T-coil ANN | this repo today |
|---|---|---|---|---|
| Device LUTs from simulation | ✅ ngspice, per L, corner, T | ✅ ngspice, swapped to (Av, Vsw) | n/a (passive) | ◐ `tools/gm-id-sizing_with-lut.ipynb` (gm/ID only, no C/ID columns) |
| Analytic sizing objective | ✅ closed form, Eq. 25 | ✅ composable evaluators | n/a | ✗ hand design (OTA `.param` block) |
| Optimiser | ◐ grid + designer's pick | ✅ NSGA-II | ✅ CMA-ES, batched ask/tell | ✗ |
| PVT in the objective | ✅ agreement region over 3 T | ✗ tt, 25 °C only | ✗ nominal | ✅ CACE PVT profile (verification only) |
| Sizing → layout quantisation | ◐ even nf, not re-evaluated | ◐ `nf = W/2` in the testbench | ✅ validity built into the generator | ✗ |
| Layout generation | ✅ ALIGN (SKY130) | ✗ | ✅ gdspy parametric coil | ◐ hand GDS, passes DRC/LVS/antenna |
| DRC / LVS | ◐ Magic extraction with manual fixes | ✗ | ✗ (listed as to-do) | ✅ `scripts/run_drc.sh`, `run_lvs.sh` |
| Extraction | ✅ Magic | ✗ (`cwire = 20 fF` guess) | ✅ EM (openEMS), passive only; active-region PEX is a to-do | ✅ kpex C + Magic RC (`run_pex.sh`) |
| Post-layout simulation | ✅ Bode, ideal vs PEX | ✗ | ✅ S-param co-sim | ✅ CACE on PEX + delta tables (`run_postlayout.sh`) |
| **Extracted data fed back into sizing** | ✗ | ✗ | ◐ only for its own passive variables | ✗ |
| Surrogate of the expensive step | ✗ (analytic only) | ◐ LUT interpolators | ✅ MLP on EM | ✗ |
| Dataset / logging | ✗ | ◐ pickled tables | ✅ 5000 GDS + S3P | ◐ `docs/<cell>/postlayout*.json`, one point per run |

## Evidence in their own words
- 01, cell 32: *"Further work aims to address analytical and procedural layout and design convergence."* The notebook also needs **one layout per temperature**, so the sizing it produces is not layout-stable.
- 02, cell 52: `cwire = 20e-15`, one guessed number for all interconnect. Cell 65: the 2/3 divider optimisation is *"Not yet working"*.
- 03, cell 83: *"Active layout, plus whole-chip DRC & LVS check"* and *"Parasitic extraction in active region"* are listed as future work.
- Outside the notebooks:
  - [Gao et al., *Post-Layout Simulation Driven Analog Circuit Sizing*, arXiv 2310.14049](https://arxiv.org/abs/2310.14049) puts automatic layout generation inside a BO sizing loop and reports > 20 % better post-layout results than pre-layout-only sizing.
  - [Budak, Zhu, Pan, ICCAD 2023, arXiv 2311.17073](https://arxiv.org/abs/2311.17073) notes that *"a scalable solution to optimize AMS design parameters under layout parasitics is yet to be studied"*, and uses multi-fidelity BNNs.
  - The closed loop is recognised as open in academia too. None of these works runs on an open IHP PDK with a sign-off-grade open flow.

## The gap, stated precisely
Each notebook's optimiser sees only one fidelity.
- **01 and 02:** the analytic coarse model, plus a final SPICE check.
- **03:** an EM-trained surrogate for the passive, with a fixed active circuit.

**Nobody updates the coarse model with what the layout actually did.** Three things are missing:
1. **The edge:** post-layout results → corrected coarse model → new sizing. This is the "designer looks at PEX and nudges R" step.
2. **The currency:** parasitics expressed in **schematic terms**, per schematic net and per device, so the coarse model can absorb them. The notebooks work with raw extracted netlists.
   - In this repo, the RC netlist `netlist/instramp_cmos5l/pex/instramp_cmos5l.rc.spice` names the gain-path nodes `pn5`, `pn6`, …, not `net5`/`net6`. Only ports keep their names.
   - The mapping exists only implicitly, through LVS.
3. **The knob set:** layout variables (segments, unit count, routing width and length) must be *optimisation variables*, quantised, and generated DRC-clean. 01 has quantisation without re-evaluation, and 03 has generator variables but no active circuit.

## What the repo uniquely brings
- **A fast fine model.** `flow.sh` runs DRC, LVS, PEX and post-layout CACE in about 1 min for the instramp (`docs/instramp_cmos5l/status.md`: DRC 25 s, LVS 7 s, PEX 8 s, post 6–9 s).
- **Delta tables already in a machine-readable form** (`postlayout.json`, `postlayout_rc.json`). These are the training targets for a Δ-surrogate.
- **An open PDK with mismatch and corner models**, enough to state what a 10 ppm target means on silicon (see [06](06_instramp_rtrim_case_study.md)).
- A real, small, well-posed first target: an R ratio. It can be closed end to end before scaling to OTA sizing.
