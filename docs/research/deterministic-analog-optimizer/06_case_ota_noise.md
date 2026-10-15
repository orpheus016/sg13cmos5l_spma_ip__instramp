# 06: Case study. `ota_cmos5l` noise, by hand and with DAO

All simulations: ngspice 47, IHP SG13CMOS5L tt, VDD 1.2 V, VCM 0.6 V, Ib 1.4 µA, CL 3 pF, 27 °C, OTA in the CACE unity-follower noise configuration.

## 1. Hand investigation: testing the "the input pair needs more gm" hypothesis
**Baseline** (the current hand design, the same as CACE):
- 195 / 74 / 50 nV/√Hz at 1 k / 10 k / 100 kHz;
- input pair at gm/ID 16.8 (37 µS at 2.2 µA);
- **the diode-connected NMOS load has a higher gm than the pair** (gm_load/gm_pair = 1.07), so it contributes as much noise.

| Change | I_pair | gm/ID | gm_L/gm | 1 kHz | 10 kHz | 100 kHz |
|---|---|---|---|---|---|---|
| baseline | 2.2 µA | 16.8 | 1.07 | 195 | 74 | 50 |
| Ib ×16 only | 8.9 µA (not 35) | 9.9 | 1.12 | **243** | 82 | 39 |
| pair m=16 only | 2.4 µA | 29.6 | 0.59 | 84 | 37 | 30 |
| load W2.5/L10 only | 2.25 µA | 16.6 | 0.49 | 183 | 69 | 46 |
| Ib ×4 + pair m16 + load W2.5/L10 m4 + bias W2/L1 | 10.4 µA | 23.6 | 0.33 | 44 | 19.4 | 14.9 |

**Tail headroom** (Vsd7 must exceed Vdsat7):

| Case | Vsd7 | Vdsat7 | I_tail got / wanted |
|---|---|---|---|
| baseline, bias 0.15/0.15 µm | 0.153 | 0.171 | 4.4 / 5.6 µA, **already in triode** |
| Ib ×8, bias 0.15/0.15 | 0.073 | 0.331 | 15 / 45 µA |
| Ib ×8, bias 20/1 | 0.039 | 0.148 | 23 / 45 µA |
| Ib ×8, bias 20/1, pair m16 | 0.177 | 0.148 | 42 / 45 µA (saturated) |

**Conclusions, after testing the designer's hypothesis:**
- **Bias current alone does not help.** Pair current saturates because the tail runs out of headroom: VDD − VCM − Vsg leaves too little Vsd. Noise at 1 kHz gets worse, because 1/f dominates there.
- **W alone stalls in weak inversion**, where gm ≤ ID/(n·U_T). This is why resizing W "did not work well".
- **Current helps the thermal floor**, but only once headroom is fixed. That needs larger bias devices *and* a lower pair Vsg (a bigger pair).
- **rhigh → rsil cannot help.** Resistor thermal noise depends on the R value, and the OTA noise dominates anyway.

## 2. DAO, demo A: minimise `IRN_1k + IRN_10k` (nV/√Hz)
**Problem:** 11 variables (`wbias, lbias, m7, m8, winpair, linpair, wload, lload, wcs, lcs, cc_units`), seeded with the hand design. Constraints:
- PM ≥ 60°, GM ≥ 10 dB, A0 ≥ 60 dB;
- UGF ≥ 2 MHz;
- P ≤ 150 µW;
- **every MOS saturated with ≥ 50 mV margin**;
- area ≤ 20 000 µm².

**Chain:** Sobol 512, then CMA-ES 3000 (4 starts), then CMA-ES 1000, then pattern 3000. That is 4817 evaluations in 2 min 33 s.

| | hand design (seed) | DAO best |
|---|---:|---:|
| feasible | **no** (A0 57.7 < 60, M7 margin −18 mV) | yes |
| IRN 1 kHz / 10 kHz | 195 / 74 nV/√Hz | **124 / 67 nV/√Hz** |
| A0 | 57.7 dB | **68.6 dB** |
| UGF / PM / GM | 2.54 MHz / 62.0° / 17.6 dB | 2.03 MHz / 60.0° / 21.0 dB |
| P | 20.6 µW | 138 µW |
| worst saturation margin | −18 mV (M7) | +50 mV (M7) |
| area | 2306 µm² | 1288 µm² |
| certificate | | **mesh-local optimum** (no improving poll at Δ = 0.002) |

Determinism: a rerun **without cache** reproduced the history byte for byte (SHA-256 `9863b74c…`).

**What the optimum says** (from probing around it):
- The binding constraints are **PM = 60.0°, UGF = 2.03 MHz and M7 saturation = 50 mV**.
- A larger pair lowers noise (W = 80–320 µm gives 74–93 nV at 1 kHz), but it **costs phase margin and pushes M7 into triode**.
- Raising Cc restores PM, but then UGF falls below 2 MHz.

So with VDD 1.2 V, VCM 0.6 V and a PMOS input pair, **tail headroom plus the GBW/PM pair limit noise, not effort**. The hand candidate from §1 (51/26 nV) sits at a −119 mV tail margin, deep triode. It only looks better because it breaks a constraint the optimiser enforces.

**Levers the formulation leaves out** (the designer's decision):
- relax UGF ≥ 2 MHz: the instramp's closed-loop bandwidth needs far less than 2 MHz of OTA UGF for a 20 kHz signal band;
- lower VCM for this OTA;
- an NMOS-input or folded topology (that changes the topology, so it falls outside DAO's scope by design);
- chopping, for the 1 kHz flicker region.

## 3. DAO, demo B: maximise FoM_S = UGF·CL/I [MHz·pF/mA] with IRN_10k ≤ 60 nV/√Hz
5050 evaluations; **certified** mesh-local optimum.
- **FoM_S 352** (the seed's 443 is infeasible).
- IRN 142 / 60 nV/√Hz at 1 k / 10 kHz.
- A0 68 dB, UGF 3.29 MHz, PM 61.4°, P 34 µW, saturation margin 50 mV.

This is the same circuit with the same variables and a different objective: nothing in DAO is noise-specific.

## 4. Noise–power Pareto (ε-constraint `P <= ε` added to demo A; about 5200 evaluations each)
| ε (P max) | IRN 1 kHz | IRN 10 kHz | P | A0 | UGF | PM | m7 / m8 | pair W/L | Cc units |
|---|---:|---:|---:|---:|---:|---:|---|---|---:|
| 30 µW | 136.0 | 68.5 | 22 µW | 66.8 | 2.00 M | 63.7 | 1 / 11 | 32.5/2.82 µm | 5 |
| 60 µW | 128.7 | 69.3 | 59 µW | 67.3 | 2.00 M | 60.4 | 1 / 33 | 29.3/3.47 µm | 4 |
| 100 µW | **118.6** | 66.0 | 83 µW | 69.3 | 2.13 M | 60.0 | 1 / 47 | 31.9/4.53 µm | 4 |
| 150 µW | 128.9 | 60.0 | 62 µW | 66.5 | 2.00 M | 62.8 | 2 / 34 | 26.3/3.31 µm | 7 |

**Reading:**
- **The front is flat.** Going from 22 µW to 83 µW buys only about 13 % at 1 kHz. Every point has the tail at minimum (m7 = 1–2), and in every point the binding constraints are UGF ≈ 2 MHz, PM ≈ 60° and saturation = 50 mV. **Power is not what limits noise in this formulation.** That is consistent with §1–2.
- **The front is not monotone:** ε = 100 µW (184.6) beats ε = 150 µW (189.0) and demo A (191.5). This is the honest face of the certificate. Each result is a *mesh-local* optimum, and a different constraint set steers the multi-start search into a different basin.
- **Practical rule:** run more seeds, or more CMA-ES starts, and keep the best certified result. DAO makes that cheap (minutes) and reproducible (each seed's run is hash-identical on rerun).

## 5. Status of the sign-off
**Nothing has been written into `xschem/ota_cmos5l/ota_cmos5l.sch` yet.** The best certified design is the ε = 100 µW point (118.6 / 66.0 nV/√Hz, 83 µW, A0 69 dB, all MOS saturated). Two warnings before adopting it:
- it uses a 1.4 µA tail with a large second stage;
- slew rate, CMRR/PSRR and PVT are **not in the formulation yet**.

**Recommended before adopting it:**
1. Decide whether UGF ≥ 2 MHz is really needed. **Measured:** the same problem with UGF ≥ 500 kHz gives a certified **108 / 66 nV/√Hz at 24 µW** (A0 69.7 dB, PM 61°, UGF 1.13 MHz). That is better, but not a step change.
   - In *every* run the M7 saturation margin sits exactly at its 50 mV limit, with the tail at minimum. **The real limit is tail headroom** with VCM = 0.6 V on a PMOS pair at 1.2 V.
   - Remaining levers are outside the current formulation: input common mode, supply (1.5 V is allowed by the spec), the topology (NMOS input / folded cascode), or chopping for the 1/f region.
2. Add CMRR, PSRR and SR to the kit or the constraints.
3. Rerun with `corners: [tt, ss, ff]`.
4. `dao signoff`, then full CACE PVT.
