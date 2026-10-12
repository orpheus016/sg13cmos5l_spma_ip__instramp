# CACE CI – Overview

**Goal:** every push to GitHub runs CACE on the cells we care about, starting with `ota_cmos5l`.
Later: centralized OTA parameters and a Jupyter + Plotly results report.

## Architecture (target)
```
cace/
  <cell>.yaml                 one CACE datasheet per cell (CI matrix = these files)
  templates/<cell>/*.sch      xschem CACE templates (CACE{...} placeholders)
  templates/xschemrc          xschem setup used by CACE
  scripts/                    LVS/DRC helper scripts
xschem/<cell>/tb/...          original standalone testbenches (kept read-only as reference)
.github/workflows/cace.yml    CI (container hpretl/iic-osic-tools)
scripts/run_cace.sh           same entry point locally and in CI (runs cace, builds the README, exit code 2 on spec failure)
scripts/make_readme.py        docs/<cell>/cace/README.md: CACE docs + PVT worst case + Monte Carlo tables/images
docs/<cell>/cace/             generated docs (README.md, *.png, CACE md/svg) - meant to be committed
docs/cace_ci/                 these notes (STATUS.md = what is done / not done)
```

## Environment
- Tools: iic-osic-tools 2026.09 (cace 2.11.0, ngspice 47, xschem, magic, netgen, klayout)
- `source .designinit_osic` -> `PDK=ihp-sg13cmos5l`, `PDK_ROOT=/foss/pdks`
  (the default shell has `PDK=ihp-sg13g2`, so always set it explicitly)

## Run locally
```
source .designinit_osic
scripts/run_cace.sh ota_cmos5l        # ~6 min, writes docs/ota_cmos5l/cace/README.md
```

## Phases
See [STATUS.md](STATUS.md). Plan source: `/headless/.claude/plans/hi-i-would-like-splendid-dahl.md`.
