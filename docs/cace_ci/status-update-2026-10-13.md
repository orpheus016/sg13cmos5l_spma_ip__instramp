# STATUS update 2026-10-13 (merge into STATUS.md)

Not edited in `STATUS.md` itself because that file was open in gvim while this was written. Replace/add the blocks below.

## Corrections to what STATUS.md says today
* Phase 1, "Specs": the OTA **PM minimum is now 50°** in `cace/ota_cmos5l.yaml` (was 60°). The schematic worst case is 55.6° (85 °C), so the
  CACE run passes; the old goal of 60° over all PVT is dropped, **not met** (typ 60.6°). Post-layout typ is 59.0°, min 54.2°.
* Phase 1, "Physical: DRC / LVS against `ota_cmos5l.gds`": **done** (`scripts/run_drc.sh ota_cmos5l`, `scripts/run_lvs.sh ota_cmos5l` -> MATCH, MoM-cap workaround in the LVS guide).
* Phase 3 "Centralize OTA params": **was not done**. The same `.param` block was copied ~20x. Now: the OTA block lives only in
  `xschem/ota_cmos5l/ota_cmos5l.sch` (it lands inside the OTA subckt of every hierarchical netlist, verified on the instramp netlist); copies removed from
  `cace/templates/ota_cmos5l/*.sch` and `xschem/*/tb/*/*.sch` (OTA numbers unchanged: A0 57.873 dB, PM 60.647° typ). Still open: the instramp resistors
  (`rhigh` 6.233k/53.06k, `l=8*2.23e-6`) are drawn values in `instramp_cmos5l.sch`, not parameters; and `.param temp=27` is still in the OTA block.

## Replace "Phase 2 / 3 / 3.5 / 4" items
### Phase 2 – GitHub Actions
- [x] `.github/workflows/verify.yml`: DRC + LVS per cell (`scripts/run_drc.sh`, `scripts/run_lvs.sh`), artifacts + job summary — **not yet run on GitHub**
- [x] `cace.yml` matrix now `[ota_cmos5l, instramp_cmos5l]` (both steps link the checkout to `/foss/designs/sg13cmos5l_spma_ip__instramp`, because `instramp_cmos5l.sch` references the OTA symbol by absolute path)
- [ ] `instramp_cmos5l.sch`: relative OTA symbol reference (`ota_cmos5l.sym`) so that no symlink is needed (needs `xschem/instramp_cmos5l/xschemrc` in the GUI session)

### Phase 3.5 – THD
- [x] THD on **instramp_cmos5l** (`cace/templates/instramp_cmos5l/thd.sch`): coherent FFT, 8 periods x 128 points, harmonics 2..9; fin 1 kHz, vin 25 mV peak (output 0.2 V peak, 8x).
  Schematic typ -63.5 dB (range -72.5 … -46.2 dB over PVT); halving the amplitude improves it by ~10 dB (sanity checked). Limits report-only.
- [ ] THD on the OTA (follower) — not done

### Phase 4 – Other cells
| Cell | yaml | templates | CI |
|---|---|---|---|
| ota_cmos5l | [x] | [x] | [~] in cace.yml + verify.yml, not run on GitHub |
| instramp_cmos5l | [x] `cace/instramp_cmos5l.yaml` | [x] `ac.sch` (closed-loop gain, copied from `tb_instramp_cmos5l_ac`), `thd.sch` | [~] |

instramp AC (schematic): closed-loop gain typ 18.061 dB (target 8 V/V = 18.0618), PVT range 17.765 … 18.262 dB (-0.30/+0.20 dB), -3 dB 279 kHz.
Limits are report-only; proposal after this spread: ±0.35 dB. Not done: dc_op/offset, noise, PSRR, MC for instramp.

### Phase 3.7 – Post-layout (new)
- [x] `scripts/run_pex.sh`, `pex_prepare_gds.py`, `pex_netlist.py`, `run_postlayout.sh`, `compare_cace.py` (guide: "Post-layout simulation guide" in `docs/README.md`)
- [x] ota_cmos5l post-layout (kpex 2.5D, C only): gain/UGF/noise within 3 %, PM -1.6°, **VOS -0.73 mV vs -0.21 mV** (device geometry, not wire C) — min over PVT -1.12 mV exceeds ±1 mV
- [x] instramp_cmos5l post-layout: gain 18.060 dB, -3 dB +2 %, THD +0.9 dB
- [ ] wire resistance (kpex 0.4.4 RC mode unusable), fill-aware extraction, post-layout in CI, investigate the OTA offset in the layout
- Note: the installed kpex 0.4.4 is missing cmos5l rule-deck includes and trips on MoM-cap devices; `run_pex.sh` builds a patched copy (worth reporting to klayout-pex / IHP)

## Fixed: CACE runs crashed randomly (error code -11)
- Cause: parallel headless xschem (a) tried the X server when `DISPLAY` is set, (b) shared one HOME (`recent_files` corruption). The earlier private-HOME fix in `run_cace.sh` was not enough for the Monte Carlo parameters (1113 crashes in one run).
- Fix: `unset DISPLAY` + `scripts/bin/xschem` wrapper (own HOME per call), used by `run_cace.sh` and `run_postlayout.sh`. Result: full OTA run (PVT + MC) 43 Pass / 0 errors / 0 crashes in 2m15s; 3/3 clean non-MC runs.
- Side effect of the parameter centralisation: dc_op/tran numbers move by <=0.1 % in some conditions versus the 2026-10-12 run (AC bit-identical); cause not isolated. The committed OTA report was regenerated (`docs/ota_cmos5l/cace/`).

## Contributor tooling (new)
- [x] `scripts/run_lvs.sh`, `lvs_tools.py` (LVS netlist from xschem, label check, MoM-cap expansion, per-device report), `scripts/run_drc.sh`; LVS guide in `docs/README.md`
- [x] `docs/lvs_upstream_issues.md` (two IHP LVS issues, drafts only)
