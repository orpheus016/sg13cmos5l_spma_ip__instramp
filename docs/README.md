# Documentation index

| Doc | What |
|---|---|
| [gain-stage.md](gain-stage.md) | Gain stage notes |
| [ota_cmos5l/cace/README.md](ota_cmos5l/cace/README.md) | **Generated** CACE report of the OTA (do not edit by hand) |
| [cace_ci/STATUS.md](cace_ci/STATUS.md) | CACE / CI roadmap: what is done, what is not |
| [cace_ci/phase-1-ota-local.md](cace_ci/phase-1-ota-local.md) | Notes and gotchas collected while building the OTA flow |
| [cace_ci/00_overview.md](cace_ci/00_overview.md) | CACE / CI architecture overview |

---

# CACE guide

How to characterise a cell with [CACE](https://cace.readthedocs.io/) in this repo: PVT corners, Monte Carlo, and an auto-generated report with plots.
Worked example for everything below: **`ota_cmos5l`** (copy it, don't start from scratch).

```
xschem/<cell>/<cell>.sch|.sym          the design under test (DUT)
xschem/<cell>/xschemrc                 lets CACE netlist the DUT
xschem/<cell>/tb/...                   your own interactive testbenches (stay untouched, used as a source)
cace/<cell>.yaml                       the datasheet: pins, conditions, specs, which template measures what
cace/templates/<cell>/*.sch            CACE testbench templates (one per kind of measurement)
scripts/run_cace.sh <cell>             run everything, build the report, exit code for CI
scripts/make_readme.py <cell>          (called by run_cace.sh) writes docs/<cell>/cace/README.md
docs/<cell>/cace/                      generated report: README.md, PNGs, CACE md/svg   <- commit this
runs/RUN_<date>/                       raw results of every run (git-ignored)
```

## 1. Prerequisites

```bash
source .designinit_osic      # PDK=ihp-sg13cmos5l, PDK_ROOT=/foss/pdks  (the default shell has ihp-sg13g2!)
cace --version               # 2.11.0 in the iic-osic-tools 2026.09 container
```

## 2. File structure for a new cell `<cell>`

1. **DUT**: `xschem/<cell>/<cell>.sch` and `<cell>.sym` — the file names must equal the CACE `name:` (and the subcircuit name). The symbol must be `type=subcircuit` and its pin names are the ones used in the yaml.
2. **Project xschemrc**: copy `xschem/ota_cmos5l/xschemrc` to `xschem/<cell>/xschemrc`. CACE looks for it in `paths.schematic`, without it the PDK default is used with a warning.
3. **Templates folder**: `cace/templates/<cell>/`. If a template needs a custom symbol (e.g. `loopgainprobe.sym`), copy that symbol **into this folder** — CACE only adds the templates folder to xschem's search path, absolute paths into other testbenches break the portability.
4. **Datasheet**: `cace/<cell>.yaml` (section 4). The file name must be `<cell>.yaml`, because `scripts/run_cace.sh <cell>` derives it from the cell name.

Do not create `netlist/`, `runs/` or `docs/<cell>/cace/` by hand, they are generated (`netlist/` and `runs/` are git-ignored).

Sizing parameters: the OTA schematic uses free parameters (`{wbias}`, `{linpair}`, …) that every template currently declares in an `OTA_Params` block. Copy that block 1:1 into new templates for now (centralising it is Phase 3 in [cace_ci/STATUS.md](cace_ci/STATUS.md)).

## 3. Migrating a testbench to a CACE template

Start from your working xschem testbench `xschem/<cell>/tb/tb_<cell>_<x>/tb_<cell>_<x>.sch`, copy it to `cace/templates/<cell>/<x>.sch` and change **only** the following. Keep the circuit topology (follower, Tian loop, …) as it is.

| In the xschem testbench | In the CACE template |
|---|---|
| DUT placed by absolute path `/foss/.../<cell>.sym` | `<cell>.sym` (relative name). CACE copies the symbol into every run, marks it `primitive` and `.include`s the netlist made from the schematic. |
| fixed `vdd`, `Ib`, `Vcm`, load | `.param temp=CACE{temperature} cl=CACE{cl} ib=CACE{ib} vdd=CACE{vdd} vicm=CACE{vcm}` and sources use `{vdd} {ib} {vicm} {cl}` |
| `.lib cornerMOSlv.lib mos_tt` (bare names) | full paths and conditions, see snippet below |
| — | `.include CACE{DUT_path}`, `.temp CACE{temperature}`, `.option SEED=CACE[CACE{seed=12345} + CACE{iterations=0}]` |
| `.control` first line | `set num_threads=CACE{jobs}` (**mandatory**, see gotchas) |
| `plot`, `shell mkdir`, `write *.raw`, banner `echo`s, `launcher.sym`, graph boxes | delete |
| hard-coded numbers (`vdd*0.5`, `1.2`, thresholds `0.28/0.92 V`) | derive from `CACE{vdd}` / `CACE{vcm}` |
| results only printed | last line: `echo $&A $&B ... > CACE{simpath}/CACE{filename}_CACE{N}.data` |

In the xschem schematic text, braces must be escaped: write `CACE\{vdd\}` in `value=` fields of the `.sch` (use the xschem GUI property editor or edit the file as the existing templates do).

Libraries block (copy from `cace/templates/ota_cmos5l/dc_op.sch`):

```spice
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE{corner}
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE{corner}
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerRES.lib res_CACE{rcorner}
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE{PDK_ROOT}/CACE{PDK}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt
.include CACE{DUT_path}
.temp CACE{temperature}
.option SEED=CACE[CACE{seed=12345} + CACE{iterations=0}]
```
(`rcorner` is its own condition so that Monte Carlo can switch resistors to `typ_mismatch` independently of the MOS corner.)

Control block pattern (example from `dc_op.sch`):

```spice
.control
set num_threads=CACE{jobs}
save all
let vlo = CACE{vcm} - 0.05
let vhi = CACE{vcm} + 0.05
dc v3 $&vlo $&vhi 0.05
let v_in = v(vinp3)
let v_out = v(out3)
let VOS = v_in[1] - v_out[1]
echo $&VOS > CACE{simpath}/CACE{filename}_CACE{N}.data
.endc
```

Rules for the measurement code:
- **The `.data` file holds SI base units** (V, A, W, s, Hz, dB, °, dimensionless). Never multiply by 1e3/1e6 — CACE converts to the `unit:` you write in the yaml. `%` and `ppm` are valid prefixes (data `0.01` = `1 %`).
- **The order of numbers in the `echo` line = the order of `variables:` in the yaml.**
- ngspice vector names are case-insensitive: `let VOUT = vout[1]` overwrites the `vout` vector. Use different names for intermediate vectors (`v_out`, `i_q`, …).
- `meas` does not work on noise plots; index the spectrum instead (`dec 20 10 100MEG`: point 20 = 100 Hz, 40 = 1 kHz …).
- A failing `meas` leaves the variable undefined and the whole run errors (`Error: ... no such variable`). Restrict windows with `from=`/`to=` and check the corner extremes (hot/slow, vdd max) — most failures show up there.
- Do not use interactive commands (`plot`, `shell`, `write`); runs are batch.

Before running the whole sweep, test one template in the GUI with the symbol visible:
`cd cace/templates/<cell> && xschem --rcfile ../xschemrc <x>.sch` (CACE does not simulate from the GUI; look at a finished run's `runs/RUN_*/parameters/<param>/run_00/<x>.sch|.spice` instead and run `ngspice -b <x>.spice` by hand).

## 4. Writing `cace/<cell>.yaml`

Copy `cace/ota_cmos5l.yaml`. Structure:

```yaml
name:           <cell>                # == file names of .sch/.sym
description:    ...
PDK:            ihp-sg13cmos5l
cace_format:    5.2
paths:
  root:           ..                  # relative to the yaml (repo root)
  schematic:      xschem/<cell>       # folder with <cell>.sch, .sym and xschemrc
  netlist:        netlist/<cell>
  documentation:  docs/<cell>/cace    # report goes here
  templates:      cace/templates/<cell>
pins:                                 # names exactly as on the symbol
  VDD: {description: ..., type: power, direction: inout, Vmin: 1.2, Vmax: 1.5}
default_conditions:                   # defaults used by every parameter; names are the CACE{...} used in templates
  vdd: {display: Vdd, unit: V, typical: 1.2}
  vcm: ...   ib: ...   cl: ...   corner: {typical: tt}   rcorner: {typical: typ}   temperature: {unit: °C, typical: 27}
parameters:
  dc_op:                              # one block per measurement
    display: DC operating point
    spec:
      VOS:                            # one entry per number in the .data line
        display: Input offset voltage
        unit: "mV"                    # quote units like "%" and "°"
        minimum: {value: -1}          # or `any`
        typical: {value: any}
        maximum: {value: 1}
    tool:
      ngspice:
        template: dc_op.sch
        format: ascii
        suffix: .data
        variables: [VOS]              # SAME ORDER as the echo line; use `null` to skip a position
    conditions:                       # PVT sweep: min/typ/max = 3 points, enumerate = list
      corner: {enumerate: [tt, ss, ff, sf, fs]}
      vdd:    {minimum: 1.2, typical: 1.35, maximum: 1.5}
      temperature: {minimum: -40, typical: 27, maximum: 85}
    plot:                             # optional CACE-native xy plot (see "plots" below)
      dc_op_VOS_vs_temperature: {type: xyplot, xaxis: temperature, yaxis: VOS, limits: auto}
```

Facts to know:
- **Limits** `minimum/maximum value:` are in the display unit. `any` = report only (no pass/fail). A parameter fails if any simulation violates a limit; `run_cace.sh` then exits with code 2.
- **Number of simulations** of a parameter = product of the points of its conditions (45 for corner × vdd × temperature). Do not give `minimum == typical` (duplicate runs).
- **Monte Carlo parameter**: reuse the template of a normal measurement with other conditions and `collate: iterations`:

  ```yaml
  mc_vos:
    spec: {VOS: {unit: "mV", ...}}
    tool: {ngspice: {template: dc_op.sch, collate: iterations, format: ascii, suffix: .data, variables: [VOS, null, null, null, null]}}
    conditions:
      corner: {enumerate: [tt_mismatch, ss_mismatch, ff_mismatch, sf_mismatch, fs_mismatch]}   # lib sections mos_<c>_mismatch
      rcorner: {typical: typ_mismatch}                                                         # res_typ_mismatch
      vdd: {typical: 1.2}
      temperature: {minimum: -40, typical: 27, maximum: 85}
      iterations: {display: Iterations, minimum: 1, maximum: 50, step: linear, stepsize: 1}    # N seeds
  ```
  The netlist of the DUT already has `mm_ok=1` on every device, so mismatch is activated just by choosing the `_mismatch` lib sections. Each iteration gets `.option SEED = 12345 + iteration`; the seed is the same for all corners/temperatures (paired comparison, N independent draws in total). `cap_cmomi` has no characterised mismatch in the PDK.
- **Plots**: CACE's own plots take raw SI values but label the axis with the display unit, so only plot variables whose unit has no prefix (dB, °, Hz, V). Do **not** add `plot:` for `mV`, `uA`, `ns`, … nor histograms — the Monte Carlo spread images come from `make_readme.py`.
- Keep variable names unique inside one parameter; the same name may be reused in different parameters.
- Throughput is about 7 simulations per second on 16 cores (OTA: ~2700 simulations in ~6 min).

## 5. Running

```bash
source .designinit_osic
scripts/run_cace.sh <cell>                     # everything: sweep + report; exit code 0 = pass, 2 = spec failure/error
scripts/run_cace.sh <cell> -p dc_op cmrr       # only these parameters (wildcards: -p 'mc_*'); datasheet name is placed first by the script
scripts/run_cace.sh <cell> --no-progress-bar   # for logs / CI
NO_README=1 scripts/run_cace.sh <cell> -p x    # skip the report step
python3 scripts/make_readme.py <cell>          # rebuild only the report from the newest run (5 s)
```

Develop a new cell in this order (each step takes seconds): one template with `-p <param>` and a reduced condition set (single corner/temperature) → check `ngspice_stderr.out` and the numbers → widen the sweep → add the Monte Carlo parameter → full run.
Always check the first run of a template by hand: compare one `.data` result with the value you read in your interactive xschem testbench at the same condition.

Things the script does for you (do not undo them): `--nofail` so CACE always writes its docs, the exit code derived from `summary.md`, and a **private `HOME`** for CACE (parallel headless xschem processes corrupt `~/.xschem/recent_files` and segfault otherwise).

## 6. Finding the results

| Where | What |
|---|---|
| terminal / `runs/RUN_*/summary.md` | CACE table: min / typ / max per spec over all conditions, Pass/Fail |
| **`docs/<cell>/cace/README.md`** | the report: design info, symbol + schematic, results table, CACE xy plots, **PVT worst-case conditions**, **Monte Carlo tables and spread images** |
| `docs/<cell>/cace/mc_<param>_spread.png` | **visual Monte Carlo histograms**: left box+dots per corner × temperature (number on top = σ, dotted lines = spec), right pooled histogram per temperature with mean/σ |
| `docs/<cell>/cace/<cell>/schematic/*.png` | CACE-native PVT xy plots (from the `plot:` entries of the yaml) |
| `runs/RUN_*/parameters/<param>/simulation_summary.{md,csv}` | one row per condition set |
| `runs/RUN_*/parameters/<param>/run_NN/` | single simulation: `<template>.spice` (netlist you can re-run with `ngspice -b`), `conditions.yaml`, `*.data`, `ngspice_stderr.out`, `.sch` |
| `runs/RUN_*/{flow,error,warning}.log` | CACE logs |

Commit `docs/<cell>/cace/` after a full run so the report is visible on GitHub (CI also uploads it as an artifact). `runs/` is never committed. Do not edit `README.md` there by hand, it is overwritten.

How the Monte Carlo numbers are made: `make_readme.py` reads every `*.data` of an `mc_*` (collate) parameter, groups by corner × temperature, converts to the display unit with CACE's own `spice_unit_unconvert` and prints mean, σ, min, max and mean ± 3σ plus the share of samples inside the spec if the same variable has limits in a PVT parameter (e.g. ±1 mV for `VOS`).
Assumptions in the script: corner names `tt/ss/ff/sf/fs` (+ `_mismatch` in MC), colours for −40/27/85 °C (other temperatures are drawn grey), report path from `paths.documentation`.

## 7. Checklist for a new cell

- [ ] `xschem/<cell>/{<cell>.sch,<cell>.sym,xschemrc}`; symbol is `type=subcircuit`
- [ ] one template per measurement in `cace/templates/<cell>/`, no absolute paths, `set num_threads=CACE{jobs}`, `.include CACE{DUT_path}`, SI `echo` line
- [ ] `cace/<cell>.yaml`: pins = symbol pins, variables order = echo order, units quoted, limits only where agreed (`any` otherwise)
- [ ] first runs with `-p`, results compared with the interactive testbench
- [ ] full `scripts/run_cace.sh <cell>`; no `error code -11`, no `Error` in `runs/*/parameters/*/run_*/ngspice_stderr.out`
- [ ] `docs/<cell>/cace/` committed; add `<cell>` to the matrix in `.github/workflows/cace.yml`; tick the cell in [cace_ci/STATUS.md](cace_ci/STATUS.md)

## 8. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `Error: unknown subckt: ... cap_cmomi` (or another PDK device) | the library for that device is missing in the template's lib block (e.g. `cornerCAP.lib cap_typ`) |
| `Too many parameters for subcircuit` | simulated against the layout netlist; the script passes `-s schematic`, do not remove it |
| sweep hangs for tens of minutes, load average huge | `set num_threads=CACE{jobs}` missing in a `.control` block (OpenMP threads of 16 parallel ngspice thrash each other) |
| `Subprocess exited with error code -11`, `Tcl_AppInit() error`, `can't read ::c_toolbar::...` | corrupted `~/.xschem/recent_files` (running CACE without `scripts/run_cace.sh`); delete or repair the file, always use the script |
| `meas ... out of interval` then `no such variable` | the measured point is not reached in that corner; widen/shift the sweep or window, guard the `let` |
| values 1000× off in the report | the template multiplied by a unit prefix; write SI in `.data` |
| `cace -p a b <cell>.yaml` finds nothing | `-p` takes a list and swallows the yaml name — use `scripts/run_cace.sh` |
| report has only a few rows / "Skip" | run was partial (`-p ...`) or docs came from an old run; run the full sweep |
| `Error: Net shorted: vdd - VDD` while netlisting | label spelled with two cases in the schematic; harmless for simulation |
| layout image missing in the report | CACE looks for `ihp-sg13cmos5l.lyp` but the PDK ships `sg13cmos5l.lyp`; `paths.layout` is left out of the yaml until the DRC/LVS step |
| template shows a missing symbol in xschem | open it with `xschem --rcfile ../xschemrc` from `cace/templates/<cell>/` |

## 9. CI

`.github/workflows/cace.yml` runs `scripts/run_cace.sh <cell>` for every entry of its `matrix.cell` on push and pull request inside the iic-osic-tools container, fails the job on a spec violation and uploads `docs/<cell>/cace` and the CACE logs as an artifact. It has **not been run on GitHub yet** (see Phase 2 in [cace_ci/STATUS.md](cace_ci/STATUS.md)); committing the regenerated report from CI is a later item.
