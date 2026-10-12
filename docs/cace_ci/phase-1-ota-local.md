# Phase 1 – CACE on `ota_cmos5l` (local)

## How to run it yourself
```bash
cd /foss/designs/sg13cmos5l_spma_ip__instramp
source .designinit_osic                # PDK=ihp-sg13cmos5l, PDK_ROOT=/foss/pdks (default shell has sg13g2!)
scripts/run_cace.sh ota_cmos5l         # full sweep: 5 corners x 3 temps x 3 vdd per parameter (~90 s, ~1100 simulations incl. Monte Carlo)
scripts/run_cace.sh ota_cmos5l -p dc_op cmrr           # only these parameters (names from the yaml; wildcards ok: -p 'mc_*')
scripts/run_cace.sh ota_cmos5l --nofail                # do not exit non-zero on failing specs
scripts/summarize_cace.py ota_cmos5l > /tmp/summary.md # PVT min/max + MC mean/sigma from the latest run (SI -> display units)
scripts/run_cace.sh ota_cmos5l --no-progress-bar       # for logs / CI
```
(`scripts/run_cace.sh` = `cd cace && cace -s schematic <cell>.yaml`.
`-s schematic` is required: otherwise CACE tries the (non-existent) extracted layout netlist, which has different pins.)

Where things land:
| What | Path |
|---|---|
| Run results (one dir per run, `runs/RUN_<date>/parameters/<param>/run_NN/`) | `runs/` (git-ignored) |
| Per-run files: generated `*.spice`, `conditions.yaml`, `*.data`, `ngspice_stderr.out` | inside each `run_NN/` |
| DUT netlist generated from schematic | `netlist/ota_cmos5l/schematic/ota_cmos5l.spice` (git-ignored) |
| CACE datasheet | `cace/ota_cmos5l.yaml` |
| Templates | `cace/templates/ota_cmos5l/*.sch` (+ `loopgainprobe.sym`) |
| MC histograms (CACE) | `runs/RUN_*/parameters/mc_*/mc_*_hist.png`, per-corner tables `simulation_summary.csv` |

Debugging a failing parameter: open `runs/RUN_*/parameters/<param>/run_00/ngspice_stderr.out` and the generated `<name>.spice`; run it by hand with `ngspice -b <name>.spice`.

## What was built
- `xschem/ota_cmos5l/xschemrc` – needed by CACE to netlist the DUT (schematic lives in `xschem/ota_cmos5l/`, so the yaml sets `paths.schematic: xschem/ota_cmos5l`).
- `cace/ota_cmos5l.yaml` – pins match the symbol (`VDD VSS IBIAS VINP VINN VOUT`); conditions from the OTA README (Ib 1.4 µA, CL 3 pF, Vcm 0.6 V).
  **PVT sweep:** corner tt/ss/ff/sf/fs × vdd 1.2/1.35/1.5 V × temperature **−40/27/85 °C** (capped at 85 °C).
  **Monte Carlo:** 5 mismatch corners × 50 seeds, vdd 1.2 V, 27 °C, `collate: iterations`.
- Templates in `cace/templates/ota_cmos5l/` (derived from the user's xschem tbs, which stay untouched; converted by a script that lives outside the repo – see "Template conversion rules" below):
  | CACE parameter | Template | Circuit | Variables (SI in `.data`) |
  |---|---|---|---|
  | ac_response | ac | Tian loop-gain probe, unity feedback | A0, F3DB, UGF, PM, GM, GBW |
  | noise | noise | Tian circuit, noise referred to input source `v4` | IRN_100/1K/10K/1M, ORN_1K, INOISE_TOT, ONOISE_TOT |
  | dc_op | dc_op | unity-gain follower, 3-point DC sweep around Vcm | VOS, IQ, PWR, VOUT, GAIN_ERR |
  | gain_tc | gain_tc | follower, `dc ... temp tmin tmax tstep` swept inside ngspice | GAIN_TC (box method), G_MEAN |
  | cmrr / psrr | cmrr / psrr | follower, ac on Vcm / on VDD | CMRR_DC/100K/1M, PSRR_DC/100K/1M |
  | icmr | icmr | follower, DC sweep 0..Vdd, gain > 0.98 | ICMR_MIN/MAX/SPAN |
  | tran_small / tran_large | same | follower, ±50 mV / ±0.3 V step | delay, rise, overshoot, settling / SR±, tr, tf, tpLH, tpHL |
  | mc_vos / mc_cmrr / mc_psrr | dc_op / cmrr / psrr | same templates, mismatch libs + seed per iteration | VOS / CMRR_DC / PSRR_DC |
- `scripts/run_cace.sh`, `scripts/summarize_cace.py`.

### Template conversion rules (what was changed vs the xschem tbs)
- DUT `ota_cmos5l.sym` and `loopgainprobe.sym` by relative name (the latter copied next to the templates).
- Operating point from CACE conditions: `.param temp/cl/ib/vdd/vicm = CACE{...}`; sources use `{vdd} {ib} {vicm} {cl}`.
- Libs by full PDK path: `mos_CACE{corner}` (LV+HV), `res_CACE{rcorner}`, `cap_typ`, `dio_tt`, `moscap_tt`; `.include CACE{DUT_path}`, `.temp CACE{temperature}`, `.option SEED=CACE[CACE{seed=12345}+CACE{iterations=0}]`.
- `.control`: starts with `set num_threads=CACE{jobs}`; no `plot`, `shell mkdir`, `write *.raw`, banners; ends with `echo $&A $&B ... > CACE{simpath}/CACE{filename}_CACE{N}.data` (SI units).
- Deliberate differences vs the original tbs: noise referred to `v4` instead of `v6` (VSS source); power = IQ·vdd (not ·1.2); icmr sweeps to vdd; tran_large step is vcm ± 0.3 V (the original 0.2→1.0 V exceeds the upper ICMR at vdd 1.2 V); settling-time `meas` restricted to `from=20n to=500n` (otherwise `cross=last` catches the falling edge); stale `alter @v5[...]` resets dropped.

### Monte Carlo recipe (IHP sg13cmos5l)
- MOS: lib section `mos_<corner>_mismatch`; resistors: `res_typ_mismatch`; capacitors: `cap_typ` (the `cap_*_mismatch` sections have no spread). The netlist already carries `mm_ok=1` on every device, so switching the lib section activates `agauss()` per instance.
- Each iteration gets `.option SEED = 12345 + iteration` (verified: different seeds → different VOS).
- yaml: MC parameters use the *same template* as the PVT parameter and override conditions: `corner: enumerate [tt_mismatch,...]`, `rcorner: typical: typ_mismatch`, `iterations 1..50`, `collate: iterations`. That is why the resistor corner is its own condition (`rcorner`).
- Global process spread (`*_stat` libs) is not used: only mismatch.

## Gotchas found (so you don't re-discover them)
1. **Data files must be in SI base units.** CACE scales by the `unit:` prefix itself (`unit: uA` shows 1.8e-5 A as 18 uA). Do not multiply by 1e6 in the template.
2. `netlist_source` is a CLI flag (`-s schematic`), not a yaml key.
3. The OTA now uses `cap_cmomi` -> templates need `.lib cornerCAP.lib cap_typ` (the old standalone tbs lacked it).
4. ngspice `meas` doesn't work on noise plots -> use index into the spectrum (`dec 100` from 1 Hz: 1 kHz = [300], 1 MHz = [600]); change both if you change the sweep.
5. Library files use full path `CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/...`.
6. `--run-path ../runs` resolves relative to the yaml `root` -> lands in `/foss/designs/runs`. Don't pass it.
7. Doc generation at the end ("Generating documentation") errors: `sg13g2.lyp` doesn't exist in the cmos5l PDK. Harmless for simulation; fix later (low priority).
8. Don't `pkill -f cace` from a shell command that contains "cace" – it kills itself.
9. The sizing `.param` block is still copied into each template (centralised in phase 3).
10. Only conditions with identical min/typ values create duplicate simulations (vdd min=typ was wasteful -> typical set to 1.35).
11. **OpenMP thread thrashing:** ngspice spawns one thread per core, and CACE runs many sims in parallel -> sweeps hung for 30+ min (45 sims × 16 threads). Fix: every template's `.control` starts with `set num_threads=CACE{jobs}` (`OMP_NUM_THREADS` and `.option num_threads` do NOT work). Sweep went from >30 min to 30 s.

12. **ngspice vectors are case-insensitive**: `let VOUT = vout[1]` silently overwrote the `vout` vector (and `IQ` vs `iq`). Intermediate vectors are named `v_in`, `v_out`, `i_q`, ...
13. **`-p` swallows the yaml name**: `cace -p a b file.yaml` treats `file.yaml` as a parameter name. `run_cace.sh` now puts the yaml first.
14. CACE units: `%` and `ppm` are SI-like prefixes (data 0.01 = 1 %, data 1e-6 = 1 ppm); GAIN_TC is stored in 1/°C and shown as ppm (= ppm/°C). `V/s`, `V/V` have no prefix handling and are shown raw. YAML needs `unit: "%"` quoted.
15. `docs/cace_ci/generated/` is written by CACE's documentation step (partial datasheet md/svg; fails at the klayout step) – git-ignored.

## Corner results
See [results_ota_cmos5l.md](results_ota_cmos5l.md) (PVT min/max with worst-case conditions, Monte Carlo mean/σ per corner).

## Not done yet in phase 1
- Physical checks (DRC/LVS vs `ota_cmos5l.gds`).
- Look at PSRR vs vdd (step from ~55 dB at 1.2 V to ~100 dB at ≥ 1.35 V) before quoting a PSRR spec.
- Limits for the new metrics are `any` (report-only); PM ≥ 60° currently fails at hot corners; MC σ(VOS) 0.8 mV vs ±1 mV target.
- Global-process Monte Carlo, MC over temperature/vdd, THD (phase 3.5), large-signal slew still limited by the class-A output tail (1.5 µs rise at ss/−40 °C).
## FAQ
**"Note: No compatibility mode selected!" – is that an error?** No. ngspice prints this note for *every* netlist that doesn't `set ngbehavior=...` (even a 1-resistor circuit). The real error next to it in the standalone tbs is
`unknown subckt: x1.xc2 ... cap_cmomi`: `ota_cmos5l.sch` now uses the PDK `cap_cmomi` (uncommitted change replacing the old `capa`), but the standalone `tb/*_{ac,dc,op,noise,psrr,tran}` have no `.lib cornerCAP.lib cap_typ`. `tb_ota_cmos5l_integrated` already has it (+ `cornerMOSCAP`). Fix in each standalone tb's Libs block: add `.lib cornerCAP.lib cap_typ`.

**How does CACE simulate with only `ota_cmos5l.sym`?** Templates just place `ota_cmos5l.sym` (name `x1`). Per run CACE (1) netlists `xschem/ota_cmos5l/ota_cmos5l.sch` into `netlist/ota_cmos5l/schematic/ota_cmos5l.spice` (the `.subckt`), (2) copies the `.sym` into the run dir with `type=subcircuit` -> `primitive`, so xschem only emits the instance line `x1 ... ota_cmos5l` and does not descend, (3) the template's `.include CACE{DUT_path}` pulls the `.subckt` in. So a template is never simulated from the GUI; to see/debug a finished run open `runs/RUN_*/parameters/<param>/run_NN/<name>.sch` (+ `.spice`). To *edit* a template in the GUI with the symbol visible: `cd cace/templates/ota_cmos5l && xschem --rcfile ../xschemrc ac.sch`.
