#!/usr/bin/env bash
# Run CACE for one cell and build its README:  scripts/run_cace.sh ota_cmos5l [extra cace args, e.g. -p dc_op cmrr]
# Used both locally and by CI.
#
# CACE only writes its documentation (design md, svg, results table, plots) when every parameter passes or
# --nofail is given, so we always pass --nofail and derive the exit code from the summary table ourselves:
#   0 = all parameters pass, 2 = a spec failed or a parameter errored.
set -uo pipefail
cell="${1:?usage: run_cace.sh <cell> [cace args]}"; shift || true
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"

# Headless: with DISPLAY set every parallel xschem first tries the X server ("Authorization required ...") and some of them
# segfault (error code -11, "tran_large.spice: No such file"). Verified: 3/3 full OTA runs clean without DISPLAY, flaky with it.
unset DISPLAY
export PATH="$root/scripts/bin:$PATH"   # xschem wrapper: one HOME per call (see scripts/bin/xschem)

# CACE starts one headless xschem per simulation, and every xschem rewrites ~/.xschem/recent_files.
# With 16 in parallel the file gets corrupted (interleaved writes) and the next xschem segfaults, and it also
# floods the user's real recent-file list. So run CACE with a private HOME (the project/PDK xschemrc are passed
# explicitly and CACE writes its own .spiceinit into every run dir, so nothing is lost).
cace_home="$(mktemp -d)"
trap 'rm -rf "$cace_home"' EXIT

cd "$root/cace" || exit 1
# datasheet first: -p/-sp take lists and would swallow it
HOME="$cace_home" cace -s schematic "$cell.yaml" --nofail "$@"
cace_rc=$?
cd "$root" || exit 1
[ "$cace_rc" -ne 0 ] && { echo "run_cace.sh: cace itself failed (rc=$cace_rc)"; exit "$cace_rc"; }

run="$(ls -d runs/RUN_* 2>/dev/null | sort | tail -1)"
[ -f "$run/summary.md" ] || { echo "run_cace.sh: no summary.md in $run"; exit 1; }

# README (skip with NO_README=1)
if [ -z "${NO_README:-}" ]; then
  python3 -I "$root/scripts/make_readme.py" "$cell" "$run" || echo "run_cace.sh: make_readme.py failed"
fi

# Status rows look like '... | Pass ✅ |', '... | Fail ❌ |', '... | Error ❗ |'
if grep -qE '\| *(Fail|Error)' "$run/summary.md"; then
  echo "run_cace.sh: spec failure or error in $run/summary.md"
  grep -E '\| *(Fail|Error)' "$run/summary.md" | sed 's/  */ /g' | cut -c1-150
  exit 2
fi
echo "run_cace.sh: all parameters passed ($run)"
