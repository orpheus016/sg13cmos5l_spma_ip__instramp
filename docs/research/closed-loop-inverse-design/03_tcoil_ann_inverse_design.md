# 03: ANN-in-the-loop inverse design of a T-coil (Xu, Chu, Wang, ETH Zürich, ISSCC'26 Code-a-Chip)

Source: `notebook_references/TCoil_Dataset_Generator_and_Training (1).ipynb` (84 cells). The process is **IHP SG13G2**, the same open-PDK family as this repo, but BiCMOS with thick TopMetal1/2. The circuit is a CML/EF wireline driver with T-coils at input and output. Their job is to absorb pad (≈ 30 fF) and ESD (≈ 60 fF) capacitance.

## The pipeline
1. **Parametric layout generator** (`tcoil_bias.py`, cell 8, gdspy).
   - It has 9 parameters: `wid, gap, sizX, sizY, firY, tapseg, nseg, tapratio, endratio`, plus a fixed 50 µm pad and feed-line extension.
   - Layers: TopMetal2/1 for the coil, Metal5 for the feed and Metal4 for the shield. Via arrays use PDK sizes.
   - **Fact:** Validity rules (segment and metal parity, no overlap) are built into the sampler and `CheckValidity`. **The parameter space is DRC-feasible by construction.** That is what lets an optimiser search it blindly.
2. **Dataset.**
   - About 5000 random geometries are written as GDS, plus a parameter `.log` and a PNG for possible CNN use.
   - Each geometry goes through openEMS (FDTD, IHP `SG13G2.xml` stackup, 0–100 GHz, 1001 points, three ports), distributed with Ray.
   - **Fact:** *"approx. 3~4 days to finish 5,000 simulation samples on a 1024-core cluster"* (cell 13). The data is ≥ 5 GB.
3. **Surrogate.**
   - An MLP takes 9 inputs, normalised to [−1, 1], and has hidden layers 512, 2048 and 2048 (ReLU, dropout 0.5).
   - It outputs **1818 values** (101 frequencies × 3×3 S-parameters × real/imag).
   - Training: AdamW at lr 1e-3, weight decay 1e-4, 2000 epochs, batch 64 and a 70/20/10 split, on a GPU. Reported MAE ≈ 0.045.
4. **Co-simulation.**
   - The predicted S3P is written as an ngspice subcircuit (`Write_SPfile_Subckt`) and embedded in the active driver netlist (npn13G2, rppd matching, ESD as fixed C).
   - Only S-parameter analysis is run. ngspice cannot run transient analysis with this element, and that is listed as future work.
5. **Inverse design.**
   - Optuna `CmaEsSampler` uses 18 variables (input and output coil), 50 random warm-start trials, then **50 iterations × batch 16** of `ask → write netlists → 8-process ngspice → tell`.
   - Cost, as coded: `−(DC gain, linear)·f3dB/GHz + 30·peaking_dB`. The prose says `−GBW/GHz + 10·peaking`, and the code is the source of truth.
   - **Fact:** About 2 min per run. Example 1 goes from 30 to 63 GHz (2.1×) with < 0.5 dB peaking. Example 2 goes from 17 to 37 GHz (2.2×).
   - The best geometry is regenerated as GDS and re-simulated with real data to check the surrogate.

## Why the ANN pays here, and when it would not
- **The oracle is very expensive:** EM costs CPU-hours per sample. The surrogate costs microseconds.
- **The output is high-dimensional and non-analytic:** 1818 numbers with resonances and coupling. There is no closed form.
- **The input is low-dimensional, bounded and DRC-safe by construction.** That makes dense random sampling possible.
- **The amortisation is real:** one dataset serves several active circuits. The two examples reuse one model.

**Judgement, for this repo:** The instramp gain error after layout has the opposite profile. The fine oracle (`flow.sh`: DRC, LVS, PEX, CACE) costs about 1 min, the output is a scalar, and the physics is nearly analytic (resistor ratio, wire R, loop gain; see [06](06_instramp_rtrim_case_study.md)). An MLP trained on thousands of samples would cost more than the problem it solves.

What transfers is **the pattern**:
- a parametric DRC-safe generator;
- a surrogate of the expensive step;
- a batched ask/tell optimiser;
- re-verification of the winner with the true oracle.

The surrogate should be the smallest model that captures the *residual*:
- an analytic model first;
- then a GP or small MLP on **post-layout minus schematic**;
- an ANN only when many cells or many layout knobs make that residual high-dimensional.

## The notebook's own open items (cell 83)
- transient / eye-diagram simulation with S-parameters;
- **active layout, whole-chip DRC and LVS**;
- **parasitic extraction in the active region**;
- metal-fill parasitics;
- comparison of networks and inverse-design algorithms.

Items 2 and 3 are what this repo already has (`scripts/flow.sh`). The repo can supply the half that the T-coil flow is missing.

## Reusable pieces
- The generator-with-built-in-validity idea, for an rhigh unit-resistor array. The PDK PCell to start from is `$PDK_ROOT/ihp-sg13g2/libs.tech/klayout/python/sg13g2_pycell_lib/ihp/rhigh_code.py`, and KLayout and gdsfactory are installed.
- The batched ask/tell loop. `cma` is installed and offers the same ask/tell API as Optuna's CMA-ES sampler. Optuna and torch are not installed.
- Normalisation and dataset handling, and the "re-verify the winner with the true oracle" step.
- `scikit-rf` is installed, if passives with S-parameters ever enter the PGIA flow.
