#!/usr/bin/env bash
# KLayout DRC for one cell:  scripts/run_drc.sh <cell> [--gds f] [--top c] [--density] [-- extra run_drc.py args]
#
# Wraps the PDK's run_drc.py (same deck as KLayout menu "SG13CMOS5L PDK -> DRC"), so CI and the GUI agree.
# Density rules (M1.j M2.j M3.j TM1.c AFil.g GFil.g ...) are chip-level and cannot be met by a single block, so like the
# GUI default (no_density: true in ~/.ihp_pdk/ihp_sg13cmos5l_drc_options.yml) they are skipped unless --density is given.
# Results: runs/drc/<cell>/ (git-ignored): <top>_<top>_full.lyrdb (open it in KLayout: Tools -> Marker Browser),
# logs. Exit: 0 clean, 1 violations (per-rule counts printed), 2 setup error.
set -uo pipefail
cell="${1:?usage: run_drc.sh <cell> [--gds f] [--top c] [-- run_drc.py args]}"; shift
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
drc_py="$PDK_ROOT/$PDK/libs.tech/klayout/tech/drc/run_drc.py"

gds=""; top="$cell"; density=""; extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --gds) gds="$2"; shift 2;;
    --top) top="$2"; shift 2;;
    --density) density=1; shift;;
    --) shift; extra=("$@"); break;;
    *) echo "run_drc.sh: unknown option $1"; exit 2;;
  esac
done
if [ -z "$gds" ]; then
  mapfile -t found < <(ls "$root"/gds/*/"$cell.gds" 2>/dev/null)
  [ "${#found[@]}" -eq 1 ] || { echo "run_drc.sh: pass --gds (found ${#found[@]} candidates: ${found[*]:-none})"; exit 2; }
  gds="${found[0]}"
fi
[ -f "$gds" ] || { echo "run_drc.sh: $gds not found"; exit 2; }

run="$root/runs/drc/$cell"; rm -rf "$run"; mkdir -p "$run"
nod="--no_density"; [ -n "$density" ] && nod=""
python3 "$drc_py" --path="$gds" --topcell="$top" --run_dir="$run" $nod "${extra[@]}" >"$run/run_drc.out" 2>&1
grep -E "ERROR|Passed|Failed|violations" "$run/run_drc.out" | sed 's/^.*| //' | head -10

db="$(ls "$run"/*_full.lyrdb 2>/dev/null | head -1)"
[ -n "$db" ] || { echo "run_drc.sh: no lyrdb produced, see $run/run_drc.out"; exit 2; }
# per-rule violation counts from the report database
python3 -I - "$db" <<'PY'
import sys, collections, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
cnt = collections.Counter(i.findtext("category", "").strip("'") for i in root.iter("item"))
for k, v in sorted(cnt.items()):
    print(f"  {k:16s} {v}")
print("DRC items:", sum(cnt.values()))
sys.exit(1 if cnt else 0)
PY
res=$?
echo "files: $db  (layout: $gds)"
exit $res
