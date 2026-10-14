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
- [~] Specs: only A0 ≥ 50 dB, UGF ≥ 1 MHz, PM ≥ **50°** (was 60°, dropped 2026-10-13: schematic worst case 55.6° at 85 °C, typ 60.6°), |VOS| ≤ 1 mV, P ≤ 50 µW enforced; all new metrics are `any` (report-only). **PM fails** (15/45 PVT runs, min 55.6° at 85 °C); **MC σ(VOS) ≈ 0.8 mV** (72 % of samples within ±1 mV) → decide limits
- [x] tt / 1.2 V / 27 °C: A0 57.7 dB, PM 60.8°, UGF 2.52 MHz, IQ 17.2 µA, P 20.6 µW, VOS −0.29 mV (README: 57.2 dB / 64.9° / 2.78 MHz / 29.6 µW — README power is at 1.5 V ≈ 19.5 µA·1.5 V; PM is ~4° lower than README)
- [x] PSRR at vdd ≥ 1.35 V (up to ~105 dB at sf/1.5 V, 74 dB typ over PVT): reviewed by user — accepted, no action (user sees ≈ 73 dB at tt/1.35 V)
- [x] Physical: DRC (+antenna) / LVS against `ota_cmos5l.gds` and `instramp_cmos5l.gds`: clean / MATCH (`scripts/run_drc.sh`, `scripts/run_lvs.sh`, `scripts/flow.sh`)
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
- [x] OTA: the one `.param` block lives in `xschem/ota_cmos5l/ota_cmos5l.sch` (it lands inside the OTA subckt of every hierarchical netlist); copies removed from `cace/templates/ota_cmos5l/*.sch` and `xschem/*/tb/*/*.sch` (OTA numbers unchanged: A0 57.873 dB, PM 60.647° typ)
- [ ] instramp resistors (`rhigh` 6.233k/53.06k, `l=8*2.23e-6`) are still drawn values, not parameters; `.param temp=27` is still in the OTA block
- [ ] Make this scalable for dataset generation and optimization by changing params

## Phase 3.5 - THD
- [x] THD on **instramp_cmos5l** (`cace/templates/instramp_cmos5l/thd.sch`): coherent FFT 8 periods x 128 points, harmonics 2..9, 1 kHz, 25 mV peak (0.2 V peak out); schematic typ -63.5 dB (-72.5 … -46.2 over PVT), post-layout -62.6 dB. Report-only limits
- [ ] THD on the OTA (follower)

## Phase 4 – Other cells
auto build scaffolding but later move to phase 5 first
| Cell | yaml | templates | CI |
|---|---|---|---|
| ota_cmos5l | [x] | [x] | [~] cace.yml + verify.yml + report.yml, **not run on GitHub** |
| instramp_cmos5l | [x] `cace/instramp_cmos5l.yaml` | [x] `ac.sch` (closed-loop gain, typ 18.061 dB, PVT 17.765 … 18.262 dB, -3 dB 279 kHz), `thd.sch` | [~] |
| coarse_gain | [ ] | [ ] | [ ] |
| fine_gain | [ ] | [ ] | [ ] |
| output_buffer | [ ] | [ ] | [ ] |
| fine_driver_6b | [ ] | [ ] | [ ] |
| digital cells | [ ] | n/a | [ ] |

## Phase 5 – Jupyter + Plotly report
- [x] `tools/report.ipynb` (generated source: nbformat) + `scripts/cace_data.py` + `scripts/build_report.sh` -> `docs/<cell>/report.html` (status banner, PVT explorer, worst cases, Monte Carlo, schematic vs post-layout C and R+C). Checked by rendering the HTML headless
- [x] `plotly`, `pandas`, `nbformat`, `pyyaml` in `tools/requirements.txt`
- [x] `.github/workflows/report.yml` rebuilds on changes of xschem/cace/gds/cells.yaml/scripts and publishes to GitHub Pages from main - **not run on GitHub**, Pages must be enabled in the repo settings
- [ ] Bode / transient waveforms in the report (CACE keeps only the scalar results; would need the ngspice raw data kept per run)

## Phase 6 - Future Usge for Optimization (feasibility and order of work: [../roadmap.md](../roadmap.md))
- [ ] CACE loop with optimizers or even ANN check feasibility
- [ ] Notebook for inverse design with ALIGN and C/ID Optimization, using ANN in the loop for sync and optimize layout (bridging design framework with auto layout generation, scaling to system level)

## Phase 3.7 – Post-layout (2026-10-13/14)
- [x] `scripts/run_pex.sh`, `pex_prepare_gds.py`, `pex_netlist.py`, `run_postlayout.sh`, `compare_cace.py` (guide: docs/README.md "Post-layout simulation guide")
- [x] **kpex C** netlist (`netlist/<cell>/pex/<cell>.c.spice`) and **Magic R+C** netlist (`.rc.spice`, `scripts/pex_magic.tcl`, `pex_netlist.py --magic`): the wire resistance is now included. Checked against the C-only result with all R dropped (identical to 4 digits). Limitation: Magic gives a contact region one cut's resistance (pessimistic); R network varies in size between runs, same electrical result
- [x] ota_cmos5l typ: A0 57.87 -> 57.90 (C) / 57.78 (R+C) dB, PM 60.6 -> 59.0 / 58.6°, **VOS -0.21 -> -0.73 / -0.80 mV** (device geometry, not wire); instramp: gain 18.061 -> 18.060 (C) / 18.008 (R+C, 18.053 without the sub-30 Ω contact lumps) dB
- [ ] wire-resistance corners (hrhc/hrlc), per-cut contact resistance, fill-aware extraction, post-layout Monte Carlo, investigate the OTA offset in the layout (common centroid input pair)
- Note: the installed kpex 0.4.4 is missing cmos5l rule-deck includes and trips on MoM-cap devices; `run_pex.sh` builds a patched copy (worth reporting to klayout-pex / IHP)

## Phase 3.8 – Flow for every cell, antenna/density, registry (2026-10-14)
- [x] `scripts/run_drc.sh`: main + maximal + **antenna** (default on) + density as information (`--density` makes it fail, `--all`); per-rule hints. Verified with a synthetic Metal1 antenna (Ant.b triggers, exit 1). OTA and instramp: antenna clean; density: the 6 chip-level rules (M1.j M2.j M3.j TM1.c AFil.g GFil.g)
- [x] `cells.yaml` registry + `scripts/cellinfo.py`; `scripts/flow.sh <cell>` (cace -> drc -> lvs -> pex -> post c/rc) writes `docs/<cell>/status.md|json`; CI matrices (`cace.yml`, `verify.yml`, `report.yml`) generated from it
- [x] `scripts/new_cell.py`: scaffolds `cace/<cell>.yaml` + `dc_op.sch` testbench + `xschemrc` from the symbol pins (tested on `inv`: runs in 6 s, then removed again)
- [x] `compare_cace.py` also writes `postlayout.json`
- Findings on the other cells: `output_buffer`: DRC clean, **LVS cannot run** (schematic uses `cap_mfringe`, not in the cmos5l PDK); `decoder_top_10b`: **19 DRC violations** `CMOS5L.FORB.Metal5` (14) / `FORB.Via4` (5); `fine_gain.sch` references the OTA symbol by an absolute path of another project (`/foss/designs/chipalooza/...`), CACE reports "Subcircuit ota_cmos5l was not found"
- [ ] relative OTA symbol reference in `instramp_cmos5l.sch` (still absolute `/foss/designs/sg13cmos5l_spma_ip__instramp/...`; CI symlinks the checkout to that path)
- [ ] CI verified green on GitHub for cace / verify / report (none has run yet); CI commit-back of regenerated README
- [ ] coarse_gain, fine_gain, output_buffer, fine_driver_6b: CACE datasheets (use `scripts/new_cell.py`), layouts

## Fixed 2026-10-13: CACE runs crashed randomly (error code -11)
Cause: parallel headless xschem tried the X server (`DISPLAY` set) and shared one HOME (`recent_files` corruption). Fix: `unset DISPLAY` + `scripts/bin/xschem` wrapper (own HOME per call) in `run_cace.sh` and `run_postlayout.sh`. Full OTA run (PVT + MC): 43 Pass / 0 errors in 2m15s (before: up to 1113 crashes). dc_op/tran numbers moved by <=0.1 % in some conditions versus 2026-10-12 after the parameter centralisation (cause not isolated); the OTA report was regenerated.

## Phase 3.9 – Pictures of every cell (2026-10-14)
- [x] `scripts/update_images.py`: circuit-only light schematics (SPICE `netlist_commands` blocks removed), symbols and KLayout layout renderings -> `docs/<cell>/media/`; README blocks (markers) in `gds/pgia_top/README.md` (with measured W/L), `xschem/<cell>/README.md`; W/L matched the hand-entered values of OTA, instramp, buffer
- [x] `docs/<cell>/cace/README.md`: CACE's own schematic/symbol SVG was a black rectangle (CACE calls `xschem -x --svg` without `zoom_full`); `make_readme.py` now overwrites them and adds a Layout section. Worth an upstream issue to CACE (missing `zoom_full`) and for the layout PNG (it looks for `ihp-sg13cmos5l.lyp`, the PDK ships `sg13cmos5l.lyp`)
- [x] `report.html` has a "Schematic and layout" section (inline SVG + PNG); `flow.sh` stage `images`; `scripts/install_hooks.sh` pre-commit hook (tested in a scratch clone); `verify.yml` has a non-blocking `--check`
- [ ] Schematics with missing symbols (drawn as `---MISSING SYMBOL---`): `fine_gain`, `decoder_top_10b`, `dec4to16` (absolute `/foss/designs/chipalooza/...` paths), `output_buffer` (`cap_mfringe`), `ota_5t` (sky130 symbols) - fix the references, rerun `scripts/update_images.py`
