#!/usr/bin/env bash
# DRC + LVS of every cell with a layout, leaves first and the chip last (order from `children:` in cells.yaml):
#   scripts/verify_all.sh [--only cell1,cell2] [-- extra flow.sh args]
# Runs scripts/flow.sh <cell> --only drc,lvs for each cell; a stage that cannot run is SKIP (see flow.sh), a failing cell does not stop
# the others. Summary table at the end, exit 1 if any cell failed, 2 if the registry does not match the files.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
only=""; extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --only) only=" ${2//,/ } "; shift 2;;
    --) shift; extra=("$@"); break;;
    *) echo "verify_all.sh: unknown option $1"; exit 2;;
  esac
done
python3 -I "$root/scripts/cellinfo.py" --check || exit 2
rc=0; rows=()
for cell in $(python3 -I "$root/scripts/cellinfo.py" --order); do
  [ -n "$only" ] && [[ "$only" != *" $cell "* ]] && continue
  case " $(python3 -I "$root/scripts/cellinfo.py" "$cell" stages 2>/dev/null) " in *" drc "*|*" lvs "*) ;; *) continue;; esac
  echo "=== $cell"
  "$root/scripts/flow.sh" "$cell" --only drc,lvs "${extra[@]}"; r=$?
  rows+=("$(printf '%-20s %s' "$cell" "$([ $r -eq 0 ] && echo ok || { [ $r -eq 1 ] && echo FAIL || echo ERROR; })")")
  [ $r -ne 0 ] && rc=1
done
echo; echo "=== summary (leaves -> chip)"; printf '%s\n' "${rows[@]}"
exit $rc
