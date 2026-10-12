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
- [x] Monte Carlo (local mismatch) on VOS, CMRR, PSRR: 5 corners × **3 temperatures (−40/27/85 °C)** × 50 seeds, vdd 1.2 V (same 50 seeds at every corner/T → paired; ≈ 50 independent draws)
- [x] Gain error (`dc_op`, follower) and gain tempco in ppm/°C (`gain_tc`, box method, T swept in ngspice)
- [x] Generated docs: `scripts/make_readme.py` → `docs/ota_cmos5l/cace/README.md` (CACE design md/svg + results table + CACE xy plots, plus script-only PVT worst-case conditions and MC table + spread images). `docs/cace_ci/results_ota_cmos5l.md` now just points there
- [~] Specs: only A0 ≥ 50 dB, UGF ≥ 1 MHz, PM ≥ 60°, |VOS| ≤ 1 mV, P ≤ 50 µW enforced; all new metrics are `any` (report-only). **PM fails** (15/45 PVT runs, min 55.6° at 85 °C); **MC σ(VOS) ≈ 0.8 mV** (72 % of samples within ±1 mV) → decide limits
- [x] tt / 1.2 V / 27 °C: A0 57.7 dB, PM 60.8°, UGF 2.52 MHz, IQ 17.2 µA, P 20.6 µW, VOS −0.29 mV (README: 57.2 dB / 64.9° / 2.78 MHz / 29.6 µW — README power is at 1.5 V ≈ 19.5 µA·1.5 V; PM is ~4° lower than README)
- [x] PSRR at vdd ≥ 1.35 V (up to ~105 dB at sf/1.5 V, 74 dB typ over PVT): reviewed by user — accepted, no action (user sees ≈ 73 dB at tt/1.35 V)
- [ ] Physical: DRC / LVS against `ota_cmos5l.gds`
- [x] CACE's doc step skips on spec failure unless `--nofail` → `run_cace.sh` always passes `--nofail` and derives the exit code (0 pass / 2 spec fail or error) from `summary.md`
- [x] Fixed: parallel headless xschem corrupted `~/.xschem/recent_files` (segfaults, thousands of failed sims) → `run_cace.sh` runs CACE with a private `HOME`. **Side effect on the user's real `~/.xschem/recent_files`: earlier runs had flooded and then corrupted it; it was cleaned (backup in the session scratchpad) and the list of your own recent files was already lost**
- [ ] CACE layout PNG skipped (`paths.layout` removed from yaml): CACE looks for `ihp-sg13cmos5l.lyp` but the PDK ships `sg13cmos5l.lyp` → re-add `layout` with the DRC/LVS step (needs workaround or upstream fix)
- Not done on purpose / not optimal now: global-process MC (`*_stat` libs; caps have no spread anyway), MC across vdd, THD (phase 3.5), Plotly report (phase 5), tran_large original ±0.4 V step (exceeds ICMR at vdd 1.2 V → ±0.3 V used)

## Phase 2 – GitHub Actions
- [x] `scripts/run_cace.sh`
- [x] `.github/workflows/cace.yml` written (push + PR + manual, matrix over cells, uploads `docs/<cell>/cace` + logs, step summary) — **not yet run on GitHub**: image tag / PATH / `--user 0` are assumptions
- [x] Contributor manual: `docs/README.md` → "CACE guide" (file structure, tb → template migration, yaml, running, reports)
- [ ] CI commit-back of the regenerated README (artifact only for now; needs `contents: write`, `[skip ci]`)
- [ ] Verified green on GitHub; verified red on a broken spec
- [ ] Auto build documentation for each cell without ai only script based like a datasheet from ADI or TI  → first version = `scripts/make_readme.py` (CACE-native parts + MC/PVT additions); open: GitHub Pages / PDF export

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
