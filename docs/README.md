# Documentation index

| Doc | What |
|---|---|
| [gain-stage.md](gain-stage.md) | Gain stage notes |
| [ota_cmos5l/cace/README.md](ota_cmos5l/cace/README.md) | **Generated** CACE report of the OTA (do not edit by hand) |
| [cace_ci/STATUS.md](cace_ci/STATUS.md) | CACE / CI roadmap: what is done, what is not |
| [cace_ci/phase-1-ota-local.md](cace_ci/phase-1-ota-local.md) | Notes and gotchas collected while building the OTA flow |
| [cace_ci/00_overview.md](cace_ci/00_overview.md) | CACE / CI architecture overview |
| [LVS guide](#lvs-guide-klayout) (below) | Layout vs schematic with KLayout: GUI loop, `scripts/run_lvs.sh`, pitfalls |
| [lvs_upstream_issues.md](lvs_upstream_issues.md) | Draft IHP-Open-PDK issues for the MoM-cap LVS limitations (not posted) |
| [Flow guide](#flow-guide-one-command-per-cell) (below) | `scripts/flow.sh <cell>`: schematic CACE -> DRC/antenna -> LVS -> PEX -> post-layout CACE -> comparison for every cell, manual steps, new cells, interactive report |
| [Pictures](#f5-pictures-schematic-and-layout-of-every-cell) (Flow guide F5) | `scripts/update_images.py`: circuit-only schematics and layout renderings, auto-updated in the READMEs and `report.html` |
| [roadmap.md](roadmap.md) | Optimisation (C/ID), ALIGN, ANN and topology-recommendation: feasibility and order of work |
| [Post-layout guide](#post-layout-simulation-guide-pex--cace) (below) | LVS-clean layout -> PEX -> CACE on the extracted netlist -> schematic vs post-layout report |

---

# CACE guide

How to characterise a cell with [CACE](https://cace.readthedocs.io/) in this repo: PVT corners, Monte Carlo, and an auto-generated report with plots.
Worked example for everything below: **`ota_cmos5l`** (copy it, don't start from scratch).

```
xschem/<cell>/<cell>.sch|.sym          the design under test (DUT)
xschem/<cell>/xschemrc                 lets CACE netlist the DUT
xschem/<cell>/tb/...                   your own interactive testbenches (you edit these; the source of the CACE templates)
cace/<cell>.params.yaml                manifest (auto-build, see 3a): which testbench gives which parameter, expressions, units, limits
cace/<cell>.yaml                       the datasheet: pins, conditions (hand-written) + `parameters:` (GENERATED from the manifest)
cace/templates/<cell>/*.sch            CACE testbench templates (one per kind of measurement; GENERATED from the testbenches)
scripts/gen_cace.py <cell>             builds the templates and the `parameters:` of the yaml (run by flow.sh and run_cace.sh)
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

## 3a. Automatic build: testbench -> template + yaml (`instramp_cmos5l`, `ota_cmos5l`)

You edit the interactive testbench (the one with the plots and banners, `xschem/<cell>/tb/tb_<cell>_<x>/tb_<cell>_<x>.sch`); the CACE template and the yaml entry follow by themselves.
A cell opts in by having a manifest `cace/<cell>.params.yaml`. **`scripts/flow.sh <cell>` and `scripts/run_cace.sh <cell>` call `scripts/gen_cace.py <cell>` first**, so a run can no longer use an old template or an old parameter list. It also works by itself:

```bash
python3 scripts/gen_cace.py instramp_cmos5l          # write templates + yaml (only the files whose content changes)
python3 scripts/gen_cace.py instramp_cmos5l --check  # write nothing, exit 1 if something is out of date (CI)
```

What it generates and from what:

| Generated (do not edit) | Source (edit this) |
|---|---|
| `cace/templates/<cell>/<template>.sch` | the testbench named by `tb:` in the manifest |
| `cace/<cell>.yaml` from the line `parameters:` on | `cace/<cell>.params.yaml` (the pins and `default_conditions` above that line stay hand-written) |

A manifest entry (full description in the header of `cace/instramp_cmos5l.params.yaml`):

```yaml
  cmrr:                                   # parameter name in the datasheet
    tb: tb_instramp_cmos5l_cmrr           # testbench folder = file name under xschem/<cell>/tb  (no tb: -> hand-written template, e.g. thd)
    template: cmrr.sch
    display: CMRR
    spec:                                 # one entry per number of the .data file, in this order
      CMRR_DC:  {expr: cmrr_dc,  display: CMRR @10 Hz, unit: dB, min: 40}   # expr = ngspice expression of the testbench, SI base units
      CMRR_1M:  {expr: cmrr_1meg, display: CMRR @1 MHz, unit: dB}           # no min/typ/max = report only
```

Cell status: `instramp_cmos5l` builds everything from its testbenches except `thd` (no testbench yet). `ota_cmos5l` builds `ac` (Tian), `noise`, `cmrr`, `psrr`, `icmr` from `xschem/ota_cmos5l/tb/*`; `dc_op`, `gain_tc`, `tran_small`, `tran_large` stay hand-written templates (entries without `tb:` in `cace/ota_cmos5l.params.yaml`) because they were tuned for the PVT sweep and differ on purpose from the interactive testbench (steps of +-50 mV / +-0.3 V around vcm instead of fixed levels, a 3-point DC sweep for the gain error). The Monte Carlo parameters (`mc_*`) reuse the template of the normal measurement (`collate:`, `variables: [X, null, ...]`, own `conditions:` in the manifest). Moving the OTA to the generator changed no result: all 43 schematic rows are identical to the run before.

The conversion applies the rules of section 3b: DUT symbol -> `<cell>.sym`; `V1 I0 C1 V3 V4 V5` get `{vdd} {ib} {cl} {vcm}` (map `sources:` in the manifest); every `.lib`/`.param` block is replaced by the canonical CACE block (libs, `.include CACE{DUT_path}`, `.temp`, seed); in the control block `plot shell write show echo print run .op` lines are dropped, `set num_threads=CACE{jobs}` is added and, at the end, `let cace_<VAR> = <expr>` plus the `echo ... > .data` line. `.subckt` / `.func` helper blocks (the Tian loop-gain probe) are kept and a symbol that lives in `cace/templates/<cell>/` (`loopgainprobe.sym`) is referenced by its file name. The `.param` block comes from `params:` in the manifest (default `ib vdd vcm cl`; the OTA uses `temp ... vicm ... vid`). Graph boxes and launchers are removed. Your testbench keeps its own plots, banners and raw files for the interactive use. Two things to keep in mind when you write a testbench:
- every number that should become a CACE variable must exist as an ngspice variable/vector at the end of the control block (`meas` result or `let`); put it in the manifest as `expr` (convert to SI base units there, e.g. `irn_100*1e-9` for V/sqrt(Hz)); `CACE{vdd}` etc. may appear in an `expr` or in a `subst:` text replacement (e.g. a hard-coded `0.6` stimulus).
- component names matter: the supplies/loads that CACE sweeps are taken from the map `sources:` of the manifest (instramp: `V1` vdd, `I0` ib, `C1` cl, `V3 V4 V5` vcm; OTA: `V1 I0 C1 V3` with `vicm`); a parameter can add its own `sources:` (OTA ac/noise: `I1 V5 V1/V4 C3`).

Workflow after you changed a testbench: just `scripts/flow.sh <cell>` (the schematic CACE run is repeated only if a generated template, the yaml, the manifest or the schematic really changed; `--force` repeats it anyway; `--stages cace` for only that stage). Adding a parameter = new testbench + one manifest entry.

## 3b. Migrating a testbench to a CACE template by hand (cells without manifest)

The table below is what `gen_cace.py` does for you. Start from your working xschem testbench `xschem/<cell>/tb/tb_<cell>_<x>/tb_<cell>_<x>.sch`, copy it to `cace/templates/<cell>/<x>.sch` and change **only** the following. Keep the circuit topology (follower, Tian loop, …) as it is.

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

Copy `cace/ota_cmos5l.yaml`. For a cell with a manifest (section 3a) you only write the part above `parameters:` here; the `parameters:` part is generated from `cace/<cell>.params.yaml` (same keys as below). Structure:

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
| `Subprocess exited with error code -11`, `Tcl_AppInit() error`, `can't read ::c_toolbar::...`, `tran_large.spice: No such file` | headless xschem crashes when many run in parallel: (1) with `DISPLAY` set each one tries the X server first, (2) all share one `~/.xschem/recent_files`. `scripts/run_cace.sh` / `run_postlayout.sh` unset `DISPLAY` and put `scripts/bin/xschem` (one throw-away HOME per call) first on `PATH`; always use the scripts, never plain `cace` (full OTA run incl. Monte Carlo: 2.2k xschem calls, 43 Pass / 0 errors) |
| `meas ... out of interval` then `no such variable` | the measured point is not reached in that corner; widen/shift the sweep or window, guard the `let` |
| values 1000× off in the report | the template multiplied by a unit prefix; write SI in `.data` |
| `cace -p a b <cell>.yaml` finds nothing | `-p` takes a list and swallows the yaml name — use `scripts/run_cace.sh` |
| report has only a few rows / "Skip" | run was partial (`-p ...`) or docs came from an old run; run the full sweep |
| `Error: Net shorted: vdd - VDD` while netlisting | label spelled with two cases in the schematic; harmless for simulation |
| layout image missing in the report | CACE looks for `ihp-sg13cmos5l.lyp` but the PDK ships `sg13cmos5l.lyp`; `paths.layout` is left out of the yaml until the DRC/LVS step |
| template shows a missing symbol in xschem | open it with `xschem --rcfile ../xschemrc` from `cace/templates/<cell>/` |

## 9. CI

`.github/workflows/cace.yml` runs `scripts/run_cace.sh <cell>` for every entry of its `matrix.cell` on push and pull request inside the iic-osic-tools container, fails the job on a spec violation and uploads `docs/<cell>/cace` and the CACE logs as an artifact. It has **not been run on GitHub yet** (see Phase 2 in [cace_ci/STATUS.md](cace_ci/STATUS.md)); committing the regenerated report from CI is a later item.

---

# LVS guide (KLayout)

How to check that a layout matches its xschem schematic, with the IHP SG13CMOS5L KLayout LVS deck. Everything is done from KLayout; `scripts/run_lvs.sh` does the same from a terminal and is the fastest way to find out *why* a run fails.
Worked example: **`ota_cmos5l`** (`gds/pgia_top/ota_cmos5l.gds` vs `xschem/ota_cmos5l/ota_cmos5l.sch`).

```
xschem/<cell>/<cell>.sch               schematic (pins = iopin/ipin, symbol type subcircuit)
netlist/<cell>/lvs/<cell>.spice        LVS netlist generated from it   (git-ignored)
gds/<dir>/<cell>.gds                   layout, top cell named <cell>
scripts/run_lvs.sh <cell>              netlist -> label check -> LVS -> readable report
scripts/lvs_tools.py                   the helpers it uses (netlist-fix | labels | report)
runs/lvs/<cell>/                       <cell>.lvsdb, <cell>_extracted.cir, logs         (git-ignored)
```

## L1. The three things LVS needs to agree on

1. **Top cell name = schematic `.subckt` name** (case does not matter, KLayout upper-cases the schematic side). Otherwise: `Can't find a schematic counterpart for the top cell`.
2. **A schematic netlist in LVS form** (section L2), not the simulation netlist.
3. **Net names in the layout as text labels on the layer the deck reads** (section L3). Without them the extracted subckt has no ports and every net is called `$12`.

## L2. Schematic side: make an LVS netlist

A simulation netlist (what CACE / the testbenches use) has `**.subckt` commented out and `X...` device lines. KLayout needs the netlist the PDK symbols produce with their `lvs_format` attribute (`M...`, `R... $SUB=`, `C...`) inside a real `.subckt`.

- **Terminal:** `scripts/run_lvs.sh <cell> --netlist-only` (add `--gds <file>` if the GDS is not `gds/*/<cell>.gds`) writes `netlist/<cell>/lvs/<cell>.spice`.
- **xschem GUI:** menu *Simulation → LVS → "LVS netlist + Top level is a .subckt"* (tick it), then *Netlist*. Do this with `PDK=ihp-sg13cmos5l`; the image default is `ihp-sg13g2`, with which every device comes out as `IS MISSING`.
- The script also moves `.param` lines from the user-code block **inside** the `.subckt` (params after the devices make the KLayout reader crash with `TypeError ... NetlistSpiceReaderDelegate::element`) and drops `.save`.

Schematic hygiene that LVS cares about:

- Parts that exist only for simulation and have no layout counterpart (bias/CM resistors such as `10MEG`, probes) get the instance attribute `lvs_ignore=true`; they are dropped from the LVS netlist (the script sets xschem's `lvs_ignore`; in the GUI tick *Simulation → LVS → Set 'lvs_ignore' variable*). Without it LVS reports them as unmatched devices.
- Hierarchy is fine: the schematic subckts are flattened to match the flat layout; `.param` lines are moved per subckt and MoM caps are expanded per subckt using the layout cell of the same name.
- Every external net is an `iopin`/`ipin`/`opin`. Their names become the subckt ports and must be the same as the layout labels (case-sensitive).
- No measurement-only parts in the signal path (ammeters / `vsource 0` probes become extra devices or extra nets). Put them in the testbench.
- Use one spelling per net (`vdd` and `VDD` on one sheet are the same net for xschem but are a warning, and a different net for you later).
- Parameters used in `w=`, `l=`, `m=` must be defined (`.param` in the user-code block is fine). Dummy and bias devices count: LVS sees every transistor.

## L3. Layout side: label the nets on the right layer

The deck reads net names **only** from text on `<layer>/25`:

| Metal | Label layer | | Metal | Label layer |
|---|---|---|---|---|
| Metal1 | `8/25` | | Metal4 | `50/25` |
| Metal2 | `10/25` | | TopMetal1 | `126/25` |
| Metal3 | `30/25` | | nwell | `31/25` |

Text on the pin layer (`30/2`, `50/2`) or on drawing (`8/0`, `30/0`) is **ignored**. Put the label on the `/25` layer, on top of a shape of that same metal that belongs to the net, at the top cell. Keep the pin-purpose shapes if you use them for P&R; they do not hurt.
`scripts/run_lvs.sh` checks this first and tells you which port has no label or a label on the wrong layer; `--fix-labels` runs on a scratch copy with the labels moved so you can see the rest of the result before fixing them in KLayout.

## L4. Running LVS in KLayout (the loop you will use)

One-time: KLayout must use the SG13CMOS5L technology (the PDK menu *SG13CMOS5L PDK* has to exist; start with `klayout -l /foss/pdks/ihp-sg13cmos5l/libs.tech/klayout/tech/sg13cmos5l.lyp <gds>` or pick the tech in the File-open dialog).

1. Open the layout (editable mode `-e` if you want to fix things in the same session).
2. *SG13CMOS5L PDK → SG13CMOS5L LVS Options* (settings are kept in `~/.ihp_pdk/ihp_sg13cmos5l_lvs_options.yml`):
   - **Top Cell:** `<cell>` (empty = the cell active in the view)
   - **Netlist Path:** `.../netlist/<cell>/lvs/<cell>.spice` (from L2). Leave *Layout Netlist Path* empty, the extraction-only checkbox off (with an empty netlist path the macro silently switches to extraction only and nothing is compared).
   - **Output Run Directory** (*Advanced Settings* tab, *Runtime*): `../../runs/lvs/%top_cell%` (relative paths are resolved against the GDS folder, `%top_cell%` is replaced); otherwise every run creates a new `lvs_run_<cell>_<timestamp>` next to the GDS.
   - Leave *Ignore Top-Port Mismatches* **off**; it hides exactly the missing-label problem.
3. **Save the layout (Ctrl+S).** The macro hands the file on disk to `run_lvs.py`, not the unsaved view.
4. *SG13CMOS5L PDK → Run Klayout LVS*. A log window shows progress; at the end the result is loaded and the **Netlist Browser** opens on top of the layout view.
5. Fix, save, run again (2-3 s for the OTA).

Reading the Netlist Browser: the left tree lists circuits, then Pins / Nets / Devices as *layout ⟷ schematic* pairs. The icons tell match / matched-with-warning (parameter differences) / mismatch or no partner. Clicking a net or device highlights its shapes in the layout view, which is how you find a short: select the suspicious net (e.g. `VDD`) and look at which shapes light up. Entries that exist only on the schematic side (empty layout column) are nets the layout merged into another one, or left open.

Terminal equivalent, handy when a run fails before there is anything to browse, and for CI later:

```bash
scripts/run_lvs.sh ota_cmos5l                  # prints per device / per net status with layout coordinates
scripts/run_lvs.sh ota_cmos5l --fix-labels     # same, labels temporarily copied to the /25 layers
scripts/run_lvs.sh ota_cmos5l --view           # afterwards open KLayout with the result loaded
scripts/run_lvs.sh <cell> --gds gds/x/y.gds --top <topcell>   # GDS in another folder / other top name
scripts/run_lvs.sh <cell> -- --combine_devices # everything after -- goes to run_lvs.py
```

Exit code 0 = match, 1 = mismatch, 2 = setup problem.

## L5. Reading a failure

`scripts/run_lvs.sh` output on a mismatch lists every layout device (with its position in µm, so you can find them in the layout view) next to its schematic partner. Typical patterns:

| What you see | Meaning |
|---|---|
| `ports layout: (none ...)` and nets named `$12` | no labels on `/25` layers (L3) |
| `Can't find a schematic counterpart for the top cell` | netlist without `.subckt` (L2), or top cell name differs |
| a net listed as *only in schematic* and 2-3 devices `Mismatch` around it | that net is **shorted** to another (or open) in the layout; the devices on the listed coordinates are the ones touching it |
| almost every net `Mismatch` although the device list looks right | one short/open propagates to all nets that touch the affected devices; find that one first (the net *only in schematic*, or the device whose terminals sit on the wrong net in `<cell>_extracted.cir`) |
| device `MatchWithWarning` | topology fine, parameters differ (`w`, `l`, `m`, cap area) |
| `cap_cmomi` shows as two layout devices (`m=5`, `m=4`) and the nets `VOUT` / the cap node mismatch | known deck limitations, see L5a; handled by `netlist-fix`, regenerate the netlist after moving caps |
| `expected exactly 2 port regions under its recognition marker, found 8` | the `recog_mom` markers of neighbouring caps touch or overlap; keep a gap between caps. The run **aborts**, see the stale-result row |
| LVS "still shows the old layout" after a layout change | the run failed before writing a new `.lvsdb` (check the log window / `*.log` for `ERROR`) and the macro opened the older `.lvsdb` that is still in the run directory. Delete the old `.lvsdb` or use a fresh run directory to be sure |
| `TypeError ... NetlistSpiceReaderDelegate::element` | `.param` lines after the devices or unresolved `{expr}` (L2) |
| devices `IS MISSING` in the netlist | wrong `PDK` in the environment (L2) |

Parallel MOS fingers are merged by KLayout (4 x `W=5u` = one `W=20u`), and the schematic's `m=` is multiplied in, so fingers vs. `m` does not matter. **This does not hold for MoM caps**, see next section.

### L5a. MoM caps (`cap_cmomi`, `cap_cmomf`) with `m > 1`

Two limitations of the IHP deck (present in the 2026.09 image and in IHP-Open-PDK `main` at the time of writing):

1. `custom_reader.lvs` reads `m` (and `A`, `P`) of a capacitor only when the model name contains `mim`. `cap_cmomi` does not, so a schematic `m=9` arrives in KLayout as `m=1` (visible in the `.lvsdb`: schematic device `m = 1.0`).
2. The layout extractor orders the two cap terminals by geometry, and the parallel-cap combiner only merges caps whose terminals sit on the same nets *in the same order*, although the deck declares the terminals interchangeable. A cap array drawn in two orientations (e.g. a row of `r90` caps and a mirrored row around a shared bus) therefore extracts as two devices (`m=5` and `m=4`), electrically identical.

What `scripts/run_lvs.sh` / `lvs_tools.py netlist-fix` does about it, without touching the schematic or the GDS: every `cap_cmomi`/`cap_cmomf` line with `m=N` is written as N single caps (the deck then combines them again), and the terminal order is taken from the layout's orientation groups. Either keep one schematic cap with `m=9` (script splits it 5+4 as drawn) or draw it as two caps `m=5` / `m=4` like the layout (script maps line to group by size). The total must equal the number of caps in the GDS and the group sizes must be consistent, otherwise the script stops with a message. Connectivity is still fully checked by LVS (a cap wired to the wrong net fails).
The GUI run uses whatever file is in *Netlist Path*, so after moving or adding caps rerun `scripts/run_lvs.sh <cell> --netlist-only` before *Run Klayout LVS*.
Keep a gap between neighbouring caps: touching `recog_mom` markers merge and the extraction aborts.

## L6. Checklist for a new cell

- [ ] schematic pins are `iopin`/`ipin`, no probes, params defined; LVS netlist generated (`--netlist-only`)
- [ ] GDS top cell named `<cell>`; every pin has a label on `<metal>/25`
- [ ] `scripts/run_lvs.sh <cell>` ends with `RESULT: MATCH` (or the GUI browser is all green)
- [ ] `runs/lvs/<cell>/<cell>.lvsdb` kept until the layout is signed off; DRC (*SG13CMOS5L PDK → DRC*) is clean as well
- [ ] if the layout was changed to pass LVS, rerun DRC and, if devices changed, the CACE report

---

# Flow guide (one command per cell)

`cells.yaml` lists every cell and what can be done with it today. One command runs everything that applies:

```bash
scripts/flow.sh ota_cmos5l                    # (gen_cace.py ->) cace (reused if fresh) -> drc -> lvs -> pex -> post (C and R+C)   ~1 min with the typ profile
scripts/flow.sh instramp_cmos5l --profile pvt # post-layout over the full PVT grid
scripts/flow.sh output_buffer                 # only the stages its cells.yaml entry lists (drc, lvs)
scripts/flow.sh fine_gain                     # schematic-only cell: prints "no stages yet"
scripts/flow.sh ota_cmos5l --only drc,lvs     # subset (what CI uses)   | --stages post   only that stage   | --force   rerun the schematic CACE
scripts/build_report.sh ota_cmos5l            # docs/<cell>/report.html: interactive Plotly report (all cells: build_report.sh all)
scripts/update_images.py all                  # schematic + layout pictures and the README blocks (see F5)
```

Result: `docs/<cell>/status.md` and `status.json` (stage, result, time, detail; layout/schematic hashes so the report can tell when it is
out of date), logs in `runs/flow/<cell>/<stage>.log`. A stage that cannot run says why: `skip` (no layout / datasheet yet), `blocked`
(an earlier stage failed), `error` (the stage itself broke, e.g. xschem cannot find a symbol). Exit code 0 / 1 (a check failed) / 2 (error).

**"I changed a testbench but the flow shows the old result"**: (1) for a cell without `cace/<cell>.params.yaml` the templates are hand-copies, a change in `xschem/<cell>/tb/` never reaches them (add the manifest, CACE guide 3a); (2) the `cace` stage reuses the newest schematic run
while the schematic, the yaml, the manifest, `gen_cace.py` and the templates are older than it — `--force` repeats it, and the line `cace pass 0s reused RUN_...` tells you it was reused; (3) a testbench that is not named in the manifest is never simulated by CACE;
(4) the `post` stage compares against the last schematic run, so run `cace` before it (a full `flow.sh <cell>` does).

## F1. What a cell needs for each stage

| Stage | Needs | Script |
|---|---|---|
| `cace` | `cace/<cell>.yaml`, `cace/templates/<cell>/*.sch`, `xschem/<cell>/<cell>.sch`; with `cace/<cell>.params.yaml` the templates and the yaml parameters are first rebuilt from `xschem/<cell>/tb/*` (CACE guide 3a) | `scripts/gen_cace.py`, `scripts/run_cace.sh` |
| `drc` | layout (`gds:` in `cells.yaml`) | `scripts/run_drc.sh` |
| `lvs` | layout and `xschem/<cell>/<cell>.sch`, net labels on `<metal>/25` | `scripts/run_lvs.sh` |
| `pex` | LVS MATCH and one schematic CACE run (it writes `netlist/<cell>/schematic/<cell>.spice`, the pin order) | `scripts/run_pex.sh` |
| `post` | extraction, CACE datasheet | `scripts/run_postlayout.sh` (`--netlist c` and `rc`) |

Today: `ota_cmos5l`, `instramp_cmos5l` all five. `output_buffer` has DRC clean, but LVS stops because its schematic uses `cap_mfringe`, a device of the
sg13g2 PDK that does not exist in cmos5l. `decoder_top_10b` has 19 DRC violations, all `CMOS5L.FORB.Metal5/Via4` (the layout uses Metal5, forbidden in
this 4-metal + TopMetal process). `coarse_gain`, `fine_gain`, `fine_driver_6b` have no layout yet. `fine_gain.sch` also references the OTA symbol by an
absolute path of another project (`/foss/designs/chipalooza/.../ota_cmos5l.sym`): CACE reports `Subcircuit ota_cmos5l was not found`. Use `ota_cmos5l.sym` and an xschemrc that lists `xschem/ota_cmos5l`.

## F2. The same thing by hand, stage by stage (every cell)

Replace `<cell>` by the name from `cells.yaml`. All commands run from the repository root; each prints a result line and writes into `runs/`.

1. **Schematic characterisation (reference).** `scripts/run_cace.sh <cell>` (runs `gen_cace.py` first if the cell has a manifest; OTA: ~2 min with Monte Carlo; `-p dc_op ac_response` for only some parameters).
   Result: `runs/RUN_<date>/summary.md`, `docs/<cell>/cace/README.md`, `netlist/<cell>/schematic/<cell>.spice`. Exit 0 = all pass, 2 = a spec fails.
2. **DRC + antenna.** `scripts/run_drc.sh <cell>`: main + maximal rules, **antenna** (Ant.a-i) and, for information, density.
   * *Density* (`M1.j M2.j M3.j TM1.c AFil.g GFil.g`) is a chip-level rule: fill is added at the top level, so a single block always shows 6 items. They are listed as `[info, chip-level]` and do not fail the run. `--density` makes them fail (use on the finished chip, after the PDK filler: KLayout *SG13CMOS5L PDK -> Filler*); `--no-antenna` skips the antenna deck.
   * *Antenna* is a real block-level check and must be clean: a long Metal/Via run connected to a gate and no diffusion charges the gate during processing. Fix: shorten the run at that metal level and jump to a higher metal near the gate, or add a protection diode (`dantenna`) on the net. The script prints the rule family and the fix per violation.
   * Open the markers in KLayout: *Tools -> Marker Browser* -> `runs/drc/<cell>/*.lyrdb`.
3. **LVS.** `scripts/run_lvs.sh <cell>` (details: LVS guide above). Must say `RESULT: MATCH`.
4. **Extraction.** `scripts/run_pex.sh <cell>` (`--skip-lvs` if you just ran LVS). Two netlists in `netlist/<cell>/pex/`: `<cell>.c.spice` (kpex 2.5D, wire capacitance) and `<cell>.rc.spice` (Magic: wire resistance + capacitance, see P2/P3). `--use rc` chooses what CACE reads by default, `--rthresh <mOhm>` drops small resistors, `--no-rc` skips Magic.
5. **Post-layout CACE + comparison.** `scripts/run_postlayout.sh <cell> --netlist c` and `--netlist rc` (`--profile pvt` for the full grid). Result `docs/<cell>/cace/postlayout.md|.json|.png` (C) and `postlayout_rc.*` (R+C): typical/min/max, delta, delta %, new failures flagged.
6. **Compare any two runs.** `python3 scripts/compare_cace.py runs/RUN_a runs/pex_cace_rc/<cell>/RUN_b -o /tmp/cmp.md --threshold 2`.
7. **Report.** `scripts/build_report.sh <cell>` -> `docs/<cell>/report.html` (open it in a browser; works offline).

## F3. Adding a cell

1. Layout in `gds/<dir>/<cell>.gds`, schematic `xschem/<cell>/<cell>.sch` + `.sym`, an entry in `cells.yaml` (`gds`, `sch`, `stages`).
2. Characterisation: `python3 scripts/new_cell.py <cell>` reads the symbol pins and writes `cace/<cell>.yaml` (pins, default conditions, a PVT-swept `dc_op` parameter with report-only limits), the testbench `cace/templates/<cell>/dc_op.sch`, an `xschem/<cell>/xschemrc`, and adds `cace` to the cell's stages. Check the pin roles it prints (power, ground, current input, output, logic; override with `--outputs`, `--current-pins`, `--logic`). Then `scripts/run_cace.sh <cell>`. The real parameters (ac, noise, ...) come from your testbenches: add `cace/<cell>.params.yaml` (copy `cace/instramp_cmos5l.params.yaml`, CACE guide section 3a), or copy a template by hand (section 3b).
3. The CI matrices (`cace.yml`, `verify.yml`, `report.yml`) are generated from `cells.yaml`; nothing to edit there.

## F4. Interactive report and automatic rebuild

`tools/report.ipynb` (Plotly, reads through `scripts/cace_data.py`): status banner (red when the layout or schematic changed after the flow run), stage table,
specification table, PVT explorer (drop-down per variable, corner = colour, supply = marker shape, spec lines), worst cases, Monte Carlo histograms, schematic vs post-layout (C and R+C) bars and table.
`scripts/build_report.sh` runs it with `jupyter nbconvert --execute`. `.github/workflows/report.yml` rebuilds it for every cell when `xschem/**`, `cace/**`, `gds/**`, `cells.yaml`, `scripts/**` or the
notebook change (pull requests: profile `typ`, `main`: `pvt`, published to GitHub Pages from `main`). The netlists themselves are git-ignored, they are derived from the schematic by the flow.
The workflows have never run on GitHub (see STATUS.md).

---

## F5. Pictures: schematic and layout of every cell

```bash
scripts/update_images.py all                  # every cell of cells.yaml: pictures + README blocks (7 s)
scripts/update_images.py ota_cmos5l           # one cell
scripts/update_images.py all --check          # exit 1 if anything is out of date (CI), --dry-run shows what would change
scripts/install_hooks.sh                      # once per clone: pre-commit hook refreshes the pictures of the cells you commit
```

| Picture | Where | Used in |
|---|---|---|
| `docs/<cell>/media/<cell>_schematic.png` / `.svg` | xschem schematic, **circuit only** (the SPICE code blocks - `.param`, simulator commands, every instance of type `netlist_commands` - are removed from the in-memory copy, the `.sch` file is not touched), light colours, cropped; the PNG for READMEs, the SVG (vector) for the report | `xschem/<cell>/README.md`, `docs/<cell>/cace/README.md`, `report.html` |
| `docs/<cell>/media/<cell>_symbol.svg` | the symbol | `docs/<cell>/cace/README.md` |
| `docs/<cell>/media/<cell>_layout.png` | KLayout rendering of the GDS with the PDK layer colours (`--labels` shows texts) | `gds/pgia_top/README.md` (with the measured W/L), `docs/<cell>/cace/README.md`, `report.html` |

| `docs/<cell>/media/<cell>_info.json` | the numbers under the pictures: **`.param` values of the schematic** (and of the registered cells it instantiates, e.g. the OTA under instramp, with the instance names) and the **physical size W, L, area** (bounding box of the top cell, `top:` of `cells.yaml`) | table under the schematic / layout picture in the READMEs, `docs/<cell>/cace/README.md` and `report.html` |

The parameters are read straight from the `.sch` (any instance whose `value`/`code` has `.param` lines), so editing a value updates the table in all places on the next run even though the schematic picture itself no longer shows SPICE code.
README text is never rewritten except between `<!-- AUTO:<kind>:<cell> -->` and `<!-- /AUTO -->`. The first run puts the block where the old hand-pasted
picture was (`gds/pgia_top/README.md`: under the heading named by `title:` in `cells.yaml`, plus the `Dimension:` / `Physical Spec` W/L fence, auto-updated from the GDS; `xschem/<cell>/README.md`: under the
first heading containing topology/schematic/circuit, else below the `# ` title; a README that does not exist is created). After that the block is simply refreshed. To add a cell or an extra schematic (`schematics:` list), edit `cells.yaml`.
Files are rewritten only when their bytes change, so a second run is a no-op and `git diff` shows only real changes (the xschem title block prints the file's modification time, so touching a `.sch` does change its picture).
The flow runs this as its last stage (`images`), `scripts/build_report.sh` runs it before building the report, `scripts/make_readme.py` runs it and links the pictures into `docs/<cell>/cace/README.md`.

Why the schematic in `docs/<cell>/cace/README.md` used to show nothing: CACE exports it with `xschem -x -q --svg --plotfile` and **without `xschem zoom_full`**, so the drawing falls outside the page and the SVG is only a black rectangle
(5 elements). `make_readme.py` overwrites CACE's two SVGs with the real ones (`xschem zoom_full; xschem print svg`) after every CACE run.

A schematic whose symbols cannot be found is drawn with `---MISSING SYMBOL---` boxes and the script prints a WARNING naming them. Currently: `fine_gain.sch`, `decoder_top_10b.sch`, `dec4to16.sch` (absolute paths of another checkout, `/foss/designs/chipalooza/...`),
`output_buffer.sch` (`cap_mfringe`, not in cmos5l) and `ota_5t.sch` (sky130 `nfet_03v3`/`pfet_03v3`). Fix the references (relative `ota_cmos5l.sym`, an xschemrc that lists the sibling directories), then rerun.

---

# Post-layout simulation guide (PEX -> CACE)

From a DRC/LVS-clean layout to the same CACE characterisation run on the extracted netlist, and a table that shows what
the layout cost. One command per cell:

```bash
scripts/run_postlayout.sh ota_cmos5l                  # typ profile: corner tt, typical vdd/T      (~25 s), wire C only
scripts/run_postlayout.sh ota_cmos5l --netlist rc     # same with wire resistance (Magic extresist)
scripts/flow.sh ota_cmos5l                            # everything, both netlists (Flow guide)
scripts/run_postlayout.sh instramp_cmos5l --profile pvt   # full PVT grid, no Monte Carlo
scripts/run_postlayout.sh ota_cmos5l -- -p dc_op ac_response   # only some CACE parameters
```

Result: `runs/pex_cace/<cell>/RUN_*` (raw CACE run, netlist source `pex`) and **`docs/<cell>/cace/postlayout.md` + `.png`**
(schematic vs post-layout, typical/min/max, delta, delta %, flags). The committed schematic report in `docs/<cell>/cace/`
is never overwritten by a post-layout run.

```
layout.gds --run_lvs.sh--> MATCH?
   |  pex_prepare_gds.py   copy: MoM-cap fingers stripped, hierarchy flattened, sub-cell labels dropped
   |  kpex 2.5D (CC)       -> raw netlist with wire capacitances (runs/pex/<cell>/kpex/...)
   |  pex_netlist.py       -> ngspice netlist, pin order of the symbol  -> netlist/<cell>/pex/<cell>.spice
   |  cace -s pex          -> same templates as the schematic run, DUT = pex netlist
   '  compare_cace.py      -> docs/<cell>/cace/postlayout.md
```

| Script | What |
|---|---|
| `scripts/run_pex.sh <cell>` | LVS check + steps above up to `netlist/<cell>/pex/` (`<cell>.c.spice` kpex, `<cell>.rc.spice` Magic with wire R; also usable on its own) |
| `scripts/run_postlayout.sh <cell>` | `run_pex.sh` if needed, CACE `-s pex`, comparison; exit 0 pass, 2 spec fail/error |
| `scripts/compare_cace.py <run_a> <run_b>` | any two CACE runs -> markdown table + bar chart |
| `scripts/pex_prepare_gds.py`, `scripts/pex_netlist.py`, `scripts/pex_magic.tcl` | the helpers (see `--help`); `pex_netlist.py --magic` converts the Magic netlist |

## P1. Prerequisites

1. `scripts/run_drc.sh <cell>` clean and `scripts/run_lvs.sh <cell>` **MATCH** (the PEX script runs LVS itself and stops otherwise).
2. A CACE datasheet `cace/<cell>.yaml` and one schematic run (`scripts/run_cace.sh <cell>`): it writes `netlist/<cell>/schematic/<cell>.spice`
   (pin order for the converter) and is the reference of the comparison. `run_postlayout.sh` picks the most complete
   schematic run of that cell in `runs/`; `--against runs/RUN_x` chooses one.
3. Net labels on `<metal>/25` for every pin (LVS guide L3). Only labels of the **top** cell are used.

## P2. What the scripts do, and why (every item cost an hour)

* **MoM caps are stripped from the extraction copy.** `cap_cmomi` is simulated with its compact model; its drawn fingers
  (578 polygons per metal and ~3300 vias per cap) are plain metal to an extractor. kpex 2.5D on the raw OTA GDS ran >15 min
  and >4 GB without finishing; with the fingers removed (the two wide Metal4 bus bars, the pins and the `recog_mom` marker are kept,
  so LVS still sees the device) it takes **5 s**, and the cap is not counted twice. The original GDS is untouched.
  kpex's `--blackbox` does not help: it only drops layers the tech file marks as capacitor/resistor devices.
* **The extraction copy is flattened.** kpex runs a hierarchical LVS and only extracts parasitics of nets visible at the top
  level: an OTA instance inside `instramp` would keep its devices but lose all internal parasitics. Labels inside sub-cells
  are removed first (each OTA carries its own VINN/VOUT labels, identical names on different nets break the extractor).
* **kpex is run from a patched copy** (`runs/pex/_kpex`, built automatically): the installed 0.4.4 lacks most of the cmos5l
  LVS rule-deck includes and its netlist writer crashes on MoM-cap devices (`Invalid parameter name: 'C'`).
  Nothing in the system packages is modified.
* **kpex gives capacitance only (`--mode CC`).** In kpex 0.4.4 `--mode RC` writes wire resistors whose nodes never connect to the device
  terminals (only the six port nets get one resistor), so that netlist cannot simulate (verified: VOUT = 0 V, IQ = -8 mA).
  Device parasitics (AS/AD/PS/PD of every transistor, poly resistor value, MoM cap) come from the extracted devices -> `<cell>.c.spice`.
* **Wire resistance comes from Magic (`--rc`, on by default): `<cell>.rc.spice`.** Magic `extresist` on the same stripped GDS copy
  (`scripts/pex_magic.tcl`; ~1 s). Checked: the resistors land on the device terminals (`VOUT_t3 ...`, unlike kpex RC), devices carry AS/AD/PS/PD,
  and with every resistor dropped (`--rthresh 100000000`) it reproduces the kpex numbers (OTA A0 57.905 vs 57.904 dB, VOS -0.730 mV both, F3DB within 0.04 %).
  What had to be worked around: (1) `extresist all` only extracts nets that are *ports* (6 of 11 nets on the OTA) -> the script gives every other net a port label `pnN` at the
  location Magic reports for it, and `pex_netlist.py --magic` removes them from the `.subckt` line; (2) Magic has no `cap_cmomi` device (no entry in the cmos5l extract tech) and the
  GDS copy has no fingers -> `pex_prepare_gds.py` writes `<gds>.caps` (a point on each of the two Metal4 terminal bars of every cap marker), Magic's `getnode` names the nets there,
  and the compact-model cap is put back from the schematic line; (3) texts on other layers in sub-cells (`Source`, `Drain Bias` on Metal1) are removed in the flattened copy, Magic would use them as net names.
  Known limitations: the R network differs from run to run (265-287 resistors on the OTA, same electrical result to 5 digits); **Magic gives a contact/via region one cut's resistance** (17 Ω for a drain
  strip that has 14-30 cuts, tech `contact alldiffcont 17000`), so the many small resistors are pessimistic, and the well resistance (3 MΩ/sq) shows up as large resistors on `VSS`/`VDD`.
  `--rthresh 30000` (drop resistors < 30 Ω) shows how much that matters (P3). The sheet resistances are the typical-corner values of the tech file; a corner mapping (hrhc/hrlc) is not wired to the CACE corner.
* **Not used:** `kpex --magic` and CACE's own `-s pex/rcx` run Magic on the raw GDS, where the MoM fingers become a 2280-C / 3900-R network without the compact-model cap (the stripped copy + `pex_magic.tcl` above avoids that); FasterCap (3D) takes ~4 min on the stripped OTA and hits the same writer bug in this version.
* **Conversion (`pex_netlist.py`):** `M`/`R`/`C` device lines -> `X` calls of the PDK subckts, poly resistor geometry
  (µm without unit) -> `w= l=` in metres, `C ... cap_cmomi` -> `X ... cap_cmomi` with `w l mmin mmax feed subblock` taken from the schematic
  (the kpex writer drops them), node names without `\$ . $`, `VSUBS` -> `VSS`, `.subckt` ports in the **symbol pin order** (the templates
  instantiate by position; kpex writes them alphabetically).
* **CACE side:** CACE re-extracts with Magic when `netlist/<cell>/pex/<cell>.spice` is older than the GDS and would overwrite the file.
  The script therefore re-runs PEX whenever the GDS is newer, and also writes the same netlist to `netlist/<cell>/layout/`. A temporary
  datasheet (`cace/<cell>_pex_tmp.yaml`, deleted afterwards) adds `paths.layout`, drops the Monte Carlo parameters and (profile `typ`) reduces
  the sweeps. CACE's own layout-image step prints `sg13g2.lyp` errors at the end of a pex run; the simulations are complete, ignore it.

## P3. Measured, schematic vs post-layout (typical conditions, 2026-10-14 layout)

`ota_cmos5l` (`docs/ota_cmos5l/cace/postlayout.md` = C, `postlayout_rc.md` = R+C):

| | schematic | post-layout C | post-layout R+C |
|---|---:|---:|---:|
| DC gain A0 | 57.87 dB | 57.90 dB | 57.78 dB |
| -3 dB / UGF | 3.70 kHz / 2.70 MHz | 3.74 kHz / 2.73 MHz | 3.79 kHz / 2.73 MHz |
| Phase margin | 60.6° | 59.0° | 58.6° |
| Input noise @1 kHz | 197 nV/√Hz | 195 nV/√Hz | 196 nV/√Hz |
| IQ | 18.30 µA | 18.32 µA | 18.32 µA |
| PSRR @10 Hz | 73.9 dB | 76.3 dB | 77.8 dB |
| **Input offset VOS** | **-0.21 mV** | **-0.73 mV** | **-0.80 mV** (spec ±1 mV) |

`instramp_cmos5l` (`postlayout.md`, `postlayout_rc.md`): closed-loop gain 18.060 dB (C) / **18.008 dB (R+C)**, schematic 18.061, target 18.0618; -3 dB bandwidth 284.8 / 286.0 kHz (+2.0 / +2.4 %);
closed-loop phase at 0 dB -142.7° both; THD -62.6 / -62.7 dB (schematic -63.5 dB). The 0.05 dB gain loss of the R+C netlist is mostly the pessimistic per-contact
resistance of Magic (P2): dropping resistors below 30 Ω gives 18.053 dB. So the cost of wiring resistance on the closed-loop gain is between **-0.008 and -0.053 dB**
(−0.1 … −0.6 %), still inside the PVT spread of the schematic (-0.30/+0.20 dB).

Wire R on the OTA (the large ones): the poly gates of the mirror/input nets (270-780 Ω in the netlist, up to 24 kΩ in the instramp bias/ladder gate nets) and the long supply rails. Effect: A0 -0.13 dB,
VOS -0.07 mV (that stays when the < 30 Ω contact lumps are removed: VOS -0.808 mV), PM -0.4° (-0.7° with the lumps). The wire capacitance is almost free (<3 % on every AC number).
The offset is **not** a wire effect: it is -0.730 mV with and without the extracted wire capacitors, i.e. it comes from the layout-derived device geometry (junction areas/perimeters of the
mirror and input pair differ from the schematic's automatic values, and between the two halves). That is the first thing to look at in the layout.
What is *not* in these numbers: the sim-only `R5`/`R6` (10 MΩ, `lvs_ignore`), substrate coupling to other blocks, fill, resistor/metal corner variation of the wires.

## P4. Doing it by hand (to look at an intermediate result)

```bash
scripts/run_pex.sh ota_cmos5l                    # -> runs/pex/ota_cmos5l/{ota_cmos5l.gds, kpex/..., kpex.out}, netlist/ota_cmos5l/pex/
python3 scripts/pex_prepare_gds.py gds/pgia_top/ota_cmos5l.gds /tmp/ota_pex.gds --top ota_cmos5l   # open it in KLayout to see what is extracted
scripts/run_postlayout.sh ota_cmos5l --against runs/RUN_2026-10-12_09-59-32
python3 scripts/compare_cace.py runs/RUN_a runs/pex_cace/ota_cmos5l/RUN_b -o /tmp/cmp.md --threshold 2
```

In KLayout the stripped extraction copy `runs/pex/<cell>/<cell>.gds` and the LVS database of the same layout
(`runs/lvs/<cell>/<cell>.lvsdb`, *Tools -> Netlist Browser*) show which shapes belong to which net.

## P5. Remaining layout jobs and recommendations

Required for trustworthy post-layout numbers:

1. **DRC + LVS clean for the exact GDS you extract** (re-run after any edit; the scripts refuse a stale netlist).
2. **instramp:** `lvs_ignore=true` on `R5`/`R6` (done) and decide whether the 10 MΩ CM resistors belong to the chip or to the test bench; the layout has none.
3. **Look at the offset** (OTA: -0.73 mV post-layout vs -0.21 mV): compare AS/AD/PS/PD of M1/M2 and M3/M4 in `runs/lvs/ota_cmos5l/ota_cmos5l_extracted.cir`;
   layout the input pair and the mirror with identical diffusion sharing/orientation (common centroid or at least same finger order and dummy ends).
4. **Filler:** extract once without density fill (what the script does), and once more with metal/active fill from the PDK macros
   (*SG13CMOS5L PDK -> Filler*) before sign-off; floating fill adds coupling.
5. **Wire resistance** is covered by the R+C netlist (P2/P3); its cost is small here (<0.2 dB, <0.1 mV). Still keep the high-impedance nodes (OTA `net4` between the poly resistor and the MoM cap,
   VOUT, the instramp resistor ladder) short, and give the poly gates of the bias mirrors a metal strap (the largest resistors in the netlist are poly gates, 0.3-24 kΩ).
6. **Well/substrate ties** around the input pair, the mirrors and the resistor array (noise, latch-up, and the substrate capacitance the extractor attaches to `VSS`).
7. Keep **gaps between MoM caps** (touching `recog_mom` markers abort LVS) and keep the **pin labels** on `/25`.
8. After layout changes that affect devices re-run: DRC, LVS, `run_postlayout.sh`; after changes to the schematic also `scripts/run_cace.sh`.

Open (not done): a post-layout Monte Carlo (the extraction has no random part; mismatch would be the same as in the schematic runs),
wire-resistance corners (hrhc/hrlc) and per-cut contact resistance in the Magic netlist, fill-aware extraction, running the flow in CI (`report.yml` is written, not run).

## P6. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `run_pex.sh: ... netlist/<cell>/schematic/<cell>.spice missing` | no CACE schematic run yet: `scripts/run_cace.sh <cell>` |
| `RESULT: MISMATCH` printed by `run_pex.sh` | fix LVS first (LVS guide); PEX of a non-matching layout is meaningless |
| kpex: `Unable to open file ... rule_decks//...` | the installed kpex copy is incomplete; `rm -rf runs/pex/_kpex` and re-run so the overlay is rebuilt |
| kpex runs for minutes, GBs of RAM | MoM-cap fingers in the extraction GDS: use the script (`pex_prepare_gds.py`), not kpex on the raw GDS |
| post-layout run gives VOUT = 0 V / huge IQ | `--mode RC` netlist (dangling wire resistors); use the default CC |
| `pex_netlist: port mismatch` | the top cell's labels do not equal the symbol pins (LVS guide L3) |
| `unhandled line` in `pex_netlist.py` | the extractor wrote a device the converter does not know yet (inductor, BJT, diode): add a branch |
| `sg13g2.lyp ... errno=2` at the end of a pex run | CACE's layout PNG step, known; simulations and `summary.md` are complete |
| Magic starts during `cace -s pex` | netlist older than the GDS; use `run_postlayout.sh`, which re-extracts first |

## DRC and LVS in CI

`.github/workflows/verify.yml` runs `scripts/flow.sh <cell> --only drc,lvs` (DRC + antenna, density is information only; LVS) for every cell of `cells.yaml` that has those stages on push/PR when `gds/`, `xschem/` or those scripts change,
and uploads `runs/drc|lvs/<cell>` (lyrdb/lvsdb, logs) as artifacts. Not yet run on GitHub. `instramp_cmos5l.sch` references the OTA symbol by an absolute
`/foss/designs/...` path (from another path xschem reports `ota_cmos5l IS MISSING`); the workflow links the checkout to that path. A relative reference
(`C {ota_cmos5l.sym}`) would remove the need.
