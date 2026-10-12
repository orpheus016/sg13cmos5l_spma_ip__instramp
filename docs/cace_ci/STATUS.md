# CACE CI – Status

Legend: [x] done · [ ] not yet · [~] in progress. Update at the end of every chat.

## Starting state (found 2026-10-09)
- `cace/` is untracked and is an unadapted sky130 example (wrong pins, 1.8 V/10 uA conditions, sky130 `.lib`, sky130 DUT symbol).
- `xschem/ota_cmos5l/tb/*` are standalone xschem tbs, NOT CACE templates (no `CACE{}`, hard-coded values, absolute DUT path, interactive `plot`).
- No `xschem/xschemrc`, no `netlist/`, no `.github/`.

## Phase 0 – Docs scaffold + cleanup
- [x] `docs/cace_ci/` created (overview + this file)
- [x] `.gitignore` ignores CACE run outputs
- [ ] `cace/` committed (waiting for user OK)

## Phase 1 – CACE runs locally on `ota_cmos5l`
- [x] `xschem/ota_cmos5l/xschemrc`
- [x] `cace/ota_cmos5l.yaml` (pins `VDD VSS IBIAS VINP VINN VOUT`, PDK `ihp-sg13cmos5l`)
- [x] Templates converted to CACE: ac (Tian), noise, dc_op (dc+op merged), cmrr, psrr, icmr, tran_small, tran_large (see phase-1-ota-local.md)
- [x] PVT: corners tt/ss/ff/sf/fs × vdd 1.2/1.35/1.5 × T −40/27/**85 °C** (capped at 85)
- [x] Monte Carlo (local mismatch) on VOS, CMRR, PSRR: 5 corners × 50 seeds, vdd 1.2 V, 27 °C
- [x] Gain error (`dc_op`, follower) and gain tempco in ppm/°C (`gain_tc`, box method, T swept in ngspice)
- [x] `scripts/summarize_cace.py` + `results_ota_cmos5l.md` (PVT min/max, MC mean/σ)
- [~] Specs: only A0 ≥ 50 dB, UGF ≥ 1 MHz, PM ≥ 60°, |VOS| ≤ 1 mV, P ≤ 50 µW enforced; all new metrics are `any` (report-only). **PM fails** (15/45 PVT runs, min 55.6° at 85 °C); **MC σ(VOS) ≈ 0.8 mV** (71 % of samples within ±1 mV) → decide limits
- [x] tt / 1.2 V / 27 °C: A0 57.7 dB, PM 60.8°, UGF 2.52 MHz, IQ 17.2 µA, P 20.6 µW, VOS −0.29 mV (README: 57.2 dB / 64.9° / 2.78 MHz / 29.6 µW — README power is at 1.5 V ≈ 19.5 µA·1.5 V; PM is ~4° lower than README)
- [ ] Look at PSRR vs vdd: ~55 dB at 1.2 V but ~80–105 dB at ≥ 1.35 V (real, flat; not an artifact)
- [ ] Physical: DRC / LVS against `ota_cmos5l.gds`
- Not done on purpose / not optimal now: global-process MC (`*_stat` libs; caps have no spread anyway), MC across temperature or vdd, THD (phase 3.5), Plotly report (phase 5), tran_large original ±0.4 V step (exceeds ICMR at vdd 1.2 V → ±0.3 V used)

## Phase 2 – GitHub Actions
- [x] `scripts/run_cace.sh`
- [ ] `.github/workflows/cace.yml` (push + PR, matrix over `cace/*.yaml`, artifacts)
- [ ] Verified green on GitHub; verified red on a broken spec
- [ ] Auto build documentation for each cell without ai only script based like a datasheet from ADI or TI  (note: CACE's own doc step writes a partial `docs/cace_ci/generated/*.md/svg` without results and fails on `sg13g2.lyp`; `scripts/summarize_cace.py` is a first building block)

## Phase 3 – Centralize OTA params
- [ ] `xschem/ota_cmos5l/ota_params.spice` (or symbol defaults)
- [ ] Duplicated `.param` blocks removed; R1/C2 parameterised

## Phase 3.5 - THD
- [ ] Add THD testbench on OTA

## Phase 4 – Other cells
| Cell | yaml | templates | CI |
|---|---|---|---|
| ota_cmos5l | [x] | [x] | [ ] |
| instramp_cmos5l | [ ] | [ ] | [ ] |
| coarse_gain | [ ] | [ ] | [ ] |
| fine_gain | [ ] | [ ] | [ ] |
| output_buffer | [ ] | [ ] | [ ] |
| fine_driver_6b | [ ] | [ ] | [ ] |
| digital cells | [ ] | n/a | [ ] |

## Phase 5 – Jupyter + Plotly report
- [ ] `tools/cace_report.ipynb`
- [ ] `plotly`, `pandas` in `tools/requirements.txt`

## Phase 6 - Future Usge for Optimization
- [ ] CACE loop with optimizers or even ANN
