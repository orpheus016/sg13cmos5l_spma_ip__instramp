#!/usr/bin/env bash
# Run CACE for one cell:  scripts/run_cace.sh ota_cmos5l [extra cace args, e.g. -p ac_response]
# Used both locally and by CI.
set -euo pipefail
cell="${1:?usage: run_cace.sh <cell> [cace args]}"; shift || true
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
cd "$root/cace"
exec cace -s schematic "$cell.yaml" "$@"   # datasheet first: -p/-sp take lists and would swallow it
