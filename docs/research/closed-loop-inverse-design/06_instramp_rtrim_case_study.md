# 06: Case study. Closing the post-layout R trim of the 8× instrumentation amplifier

**Goal (from the designer):**
- Today: run PEX, read the gain error, adjust the rhigh lengths, redo the layout, repeat.
- Wanted: a loop that returns **the R values for this layout configuration** that give **8.000× with |gain error| < 0.001 % (10 ppm)**.

All numbers below were measured on 2026-10-15 with the PDK models in `$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models`, unless they are marked as taken from repository reports. The scratch decks used are reproduced at the end.

## 1. The circuit, as netlisted
From `netlist/instramp_cmos5l/schematic/instramp_cmos5l.spice`:
- **The structure is the classic three-op-amp form.** The top-level README describes it as two followers plus a subtractor but calls it a "two-op-amp IA".
  - `x1` and `x2` are unity followers: R8 and R7 sit in their feedback, with no DC current.
  - `x3` is a difference amplifier. R2 (`net2→net5`) and R4 (`net5→VOUT`) are on the inverting side. R1 (`net4→net6`) and R3 (`net6→CM`) are on the non-inverting side.
- **Ideal gain** is `G = R4/R2` when `R3/R1 = R4/R2`.
- R1, R2, R7 and R8 are rhigh, w = 0.5 µm, l = 2 µm. R3 and R4 are rhigh, w = 0.5 µm, l = 8 × 2.23 µm = 17.84 µm. All values are literals in the `.sch`, not parameters.

## 2. Measured facts
| Quantity | Value | Source |
|---|---|---|
| R(l = 2 µm) | **6233.06 Ω** | ngspice op, `res_typ` |
| R(l = 17.84 µm) | **53064.4 Ω** | ngspice op, `res_typ` |
| Ideal ratio R4/R2 | **8.5134** | computed from the two rows above |
| Schematic gain, typical | 18.061 dB ≈ 8.000× (A_ERR ≈ 0) | `docs/instramp_cmos5l/cace/postlayout_rc.md` |
| Schematic gain over PVT (min/max) | 17.765 / 18.262 dB, i.e. −3.4 % / +2.3 % | same |
| **Post-layout RC gain, typical** | **18.008 dB, A_ERR = −0.054 dB ≈ −0.62 %** | same |
| One 5 nm grid step on l, long R | **279 ppm** of R (14.8 Ω) | ngspice, Δl = 5 nm |
| One 5 nm grid step on l, short R | **2372 ppm** of R (14.8 Ω) | ngspice, Δl = 5 nm |
| rhigh local mismatch (PDK) | `rsh_rhigh_mm = 5.0 %·µm`, `dl/dw_rhigh_mm = 0.009 µm` | `cornerRES.lib`, `res_typ_mismatch` |
| **σ(R4/R2), current geometry** | **4.97 %** | ngspice MC, 300 runs |
| σ(R4/R2), 10× w and 10× l (100× area) | 0.59 % | ngspice MC, 200 runs |

## 3. What the numbers say
### 3.1 The trim is already compensating loop gain, not a resistor error
The ideal ratio is 8.513, yet the circuit gives 8.000. With `G = G_ideal / (1 + 1/T)`, that implies a loop gain **T ≈ 15.6**. With β = 1/(1 + 8.51), the loaded open-loop gain of `x3` is A ≈ 148 (≈ 43 dB).
- This is *inferred*: all the error is attributed to `x3`. The OTA's unloaded A0 is about 58 dB, and the roughly 59 kΩ feedback load (R2 + R4) plausibly accounts for the drop. Verify this with an `.op`/`.tf` on `x3`.
- **Consequence:** `dG/G ≈ (1/(1+T))·dA/A ≈ 0.060·dA/A`. A 10 % change in A across PVT moves the gain by about 0.6 %. That matches the −3.4 % / +2.3 % PVT spread far better than resistor tolerance does, because global rhigh variation cancels in a ratio.
- **10 ppm robust to ±10 % change in A needs T ≳ 10⁴ (≈ 80 dB of loop gain).** The present design is about 56 dB short. Ratio trimming cannot fix this, because the trim is only correct at the corner where it was computed.

### 3.2 Layout quantisation
- One-knob moves are 279 ppm (feedback R) or 2372 ppm (input R) per 5 nm. Neither reaches 10 ppm.
- A search over both lengths together (|k| ≤ 400 and |m| ≤ 40 grid steps) gives ratios spaced 2.8 ppm apart at the median, but the **worst-case gap is 127 ppm**. Hitting an arbitrary target within 10 ppm is therefore not guaranteed by length alone.
- **A fine-trim element is needed.** For example, a short **rsil** series segment (7 Ω/sq vs 1360 Ω/sq for rhigh) in the R4 branch gives sub-ppm steps per grid point. Its different TC is diluted by the ratio of about 1 Ω to 53 kΩ. A wider-w rhigh trim segment is an alternative.

### 3.3 Routing resistance is the same size as the target
- 10 ppm of R4 is **0.53 Ω**, and 10 ppm of R2 is **0.062 Ω**.
- Metal1 is about **110 mΩ/sq** (typical, `ihp-sg13cmos5l-extract.tech`). So **less than one square of Metal1 in series with R2 already uses the 10 ppm budget**, and contact and via R add to it.
- This is why the trim must be computed *on the extracted layout*, and why the wire in series with R2/R1 has to be inside the objective. It is the strongest argument for layout-in-the-loop in this repo.

### 3.4 Matching sets the silicon floor
- σ(R4/R2) ≈ **5 %** with today's geometry. That is 5000× the 10 ppm target.
- Area helps as 1/√area: 100× area gives 0.59 %, as expected. Reaching 10 ppm by area alone would need about (5 % / 10 ppm)² ≈ 2.5·10⁷ × today's area, which is impossible.
- **Conclusion:** 10 ppm is meaningful as a **nominal, typical-corner, post-layout systematic error**, and the loop below can hit that. It is **not** a silicon or PVT spec. On silicon you would need:
  - post-fabrication trim/calibration (the fine/coarse PGA stages are a natural place for a digital gain-correction code);
  - or a matching-insensitive architecture: chopping or dynamic element matching of the resistors, a current-feedback IA, or a capacitive-feedback IA with chopping.
- A realistic hardware target with sensible area is **≲ 0.1 % σ**. That means about 2500× the current resistor area: matched unit arrays, common centroid, dummies.

## 4. The loop
```
   x = (R_in.l, R_fb.l, nseg, trim)  ∈ layout grid            ← design_ir params (05)
        │
   coarse model:  G(x) = r(x)/(1 + (1+r(x))/A(x)) · (1 + ε_wire(x))
        │          r(x)  = R4/R2 from the rhigh formula (exact, 2.1)
        │          A(x)  = loaded OTA gain (C/ID or one .tf per candidate)
        │          ε_wire= series wire R from the IR parasitics section
        ▼
   solve |G(x)/8 − 1| < 10 ppm on the coarse model (integer search over grid steps, trivial)
        │
   generator → GDS → scripts/flow.sh instramp_cmos5l (DRC, LVS, PEX rc, CACE typ)   ~1 min
        │
   residual e = G_post − G_coarse  → update the coarse model (space mapping: shift / Jacobian update)
        └──── repeat until |G_post/8 − 1| < 10 ppm (expected 2–4 fine evaluations)
```
- This is **space mapping**: optimise a fast physics-based coarse model and align it to the fine model with as few fine evaluations as possible ([Bandler et al., "Space Mapping: The State of the Art"](https://pure.kfupm.edu.sa/en/publications/space-mapping-the-state-of-the-art/); [Bakr, Bandler et al., aggressive SM](https://macsphere.mcmaster.ca/html/11375/28919/SOS_Publications/SOS-00-16-V.pdf)).
- The "ANN in the loop" from the T-coil notebook is the **residual model**. Start with an affine shift and a GP over (x, layout features). Train an MLP only once many layouts or cells share one model (roadmap M2/M4).
- Each fine evaluation reuses the existing flow unchanged. The new pieces are the generator, the IR, the parasitic summariser and the optimiser driver.

## 5. Pre-requisites found while measuring
1. **Measurement resolution.** CACE prints A_ERR in dB to three decimals, which is 0.001 dB ≈ 115 ppm, coarser than the target. Add `A_ERR_PPM = (10^(A_CL/20)/8 − 1)·1e6` to `cace/templates/instramp_cmos5l/ac.sch`. Check that the 1 Hz AC point is far enough below the closed-loop pole: at f3dB ≈ 286 kHz the gain droop at 1 Hz is far below 1 ppm, so it is fine. A DC `.tf` is the cleaner number.
2. **Parametrise the resistors.** Replace the literals in `instramp_cmos5l.sch` with `.param` entries. This is roadmap step 1, still open.
3. **Net-name-stable extraction.** Map `pnNN` back to `net5`/`net6` via LVS (see [05](05_intermediate_representation.md)).
4. **Generator.** An rhigh unit-segment array with a dummy and common-centroid option, plus an rsil trim stub, from the PDK PCell reference `sg13g2_pycell_lib/ihp/rhigh_code.py`.
5. **Decide what "8×" means.** Is it the typical post-layout systematic error (achievable) or the PVT/MC envelope (needs loop gain and trim, §3.1 and §3.4)? This decision changes the objective function.

## Appendix: scratch decks (reproducible)
```spice
* resistance and grid sensitivity
.lib $PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerRES.lib res_typ
V1 a 0 0.1
XRs a 0 0 rhigh w=0.5e-6 l=2e-6 m=1 b=0
* ... repeated for l=17.84u, 2.005u, 17.845u;  R = -0.1/i(V)
```
```spice
* ratio mismatch MC: res_typ_mismatch, mm_ok=1 on both devices, loop {reset; op}, 300 runs
```
```python
# ratio granularity: (Rl + k*d)/(Rs + m*d), d = 14.785 ohm per 5 nm, |k|<=400, |m|<=40 -> max gap 127 ppm, median 2.8 ppm
```
