#!/usr/bin/env bash
# KLayout DRC for one cell:  scripts/run_drc.sh <cell> [--gds f] [--top c] [--no-antenna] [--density] [-- extra run_drc.py args]
#
# Wraps the PDK's run_drc.py (same deck as KLayout menu "SG13CMOS5L PDK -> DRC"), so CI and the GUI agree. Three decks run:
#   main (+ maximal)  DRC rules                                           -> failing
#   antenna           Ant.a-i (gate antenna ratios, protection diodes)    -> failing; block-level, a block can and must meet it
#   density           M1.j M2.j M3.j TM1.c AFil.g GFil.g DEN.*            -> only INFORMATION, unless --density is given:
#                     these are chip-level rules (fill is added at the top level) and a single block cannot meet them,
#                     like the GUI default (no_density: true in ~/.ihp_pdk/ihp_sg13cmos5l_drc_options.yml).
# --no-antenna skips the antenna deck. --density makes density violations fail the run (use it on the finished chip).
# Results: runs/drc/<cell>/ (git-ignored): <top>_<top>_{full,antenna,density}.lyrdb (open in KLayout: Tools -> Marker Browser), logs.
# Exit: 0 clean, 1 violations (per-deck / per-rule counts printed), 2 setup error.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"

# Container Auto-Detection & Forwarding:
# If klayout is not in PATH or PDK_ROOT is missing on host, forward to docker container if available
if ! command -v klayout >/dev/null 2>&1 || [ ! -d "$PDK_ROOT/$PDK" ]; then
  if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^iic-osic-tools_x11$'; then
    container_root="/foss/designs$(echo "$root" | sed 's|^/home/ranantalden/Projects/Designs||')"
    container_cwd="/foss/designs$(pwd | sed 's|^/home/ranantalden/Projects/Designs||')"
    args=()
    for arg in "$@"; do
      args+=("${arg//\/home\/ranantalden\/Projects\/Designs/\/foss\/designs}")
    done
    exec docker exec -i -w "$container_cwd" iic-osic-tools_x11 bash "$container_root/scripts/run_drc.sh" "${args[@]}"
  elif ! command -v klayout >/dev/null 2>&1; then
    echo "run_drc.sh: ERROR: klayout is not found in PATH and iic-osic-tools_x11 container is not running." >&2
    exit 2
  fi
fi

cell="${1:?usage: run_drc.sh <cell> [--gds f] [--top c] [--no-antenna] [--density] [-- run_drc.py args]}"; shift
drc_py="$PDK_ROOT/$PDK/libs.tech/klayout/tech/drc/run_drc.py"

if [ ! -f "$drc_py" ]; then
  echo "run_drc.sh: ERROR: DRC runner script not found at $drc_py" >&2
  exit 2
fi

gds=""; top="";  density=""; antenna=1; extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --gds) gds="$2"; shift 2;;
    --top) top="$2"; shift 2;;
    --density) density=1; shift;;
    --no-antenna) antenna=""; shift;;
    --antenna) antenna=1; shift;;
    --all) antenna=1; density=1; shift;;
    --) shift; extra=("$@"); break;;
    *) echo "run_drc.sh: unknown option $1"; exit 2;;
  esac
done
[ -n "$top" ] || top="$(python3 -I "$root/scripts/cellinfo.py" "$cell" top 2>/dev/null || echo "$cell")"   # default: top of cells.yaml (e.g. slot9_wrapper for pgia_top), else the cell name
if [ -z "$gds" ]; then
  mapfile -t found < <(python3 -I "$root/scripts/cellinfo.py" "$cell" gds 2>/dev/null || ls "$root"/gds/*/"$cell.gds" 2>/dev/null)
  [ "${#found[@]}" -eq 1 ] || { echo "run_drc.sh: pass --gds (found ${#found[@]} candidates: ${found[*]:-none})"; exit 2; }
  gds="${found[0]}"
fi
[ -f "$gds" ] || { echo "run_drc.sh: $gds not found"; exit 2; }

run="$root/runs/drc/$cell"; rm -rf "$run"; mkdir -p "$run"
common=(--path="$gds" --topcell="$top" --run_dir="$run")

# 1. main (+ maximal) and, in the same call, antenna (its items end up in *_full.lyrdb, told apart below by the Ant.* names)
args=("${common[@]}" --no_density)
[ -n "$antenna" ] && args+=(--antenna)
python3 "$drc_py" "${args[@]}" "${extra[@]}" >"$run/run_drc.out" 2>&1
grep -E "ERROR|Passed|Failed|violations" "$run/run_drc.out" | sed 's/^.*| //' | head -10

# Validate that the main deck actually executed and completed
if grep -q "KLayout is not found" "$run/run_drc.out"; then
  echo "run_drc.sh: ERROR: KLayout was not found during DRC run. See $run/run_drc.out" >&2
  exit 2
fi

if ! grep -q -E "Completed running|completed in|Violations were detected|No DRC violations detected" "$run/run_drc.out"; then
  echo "run_drc.sh: ERROR: Main DRC run did not complete successfully. See $run/run_drc.out" >&2
  exit 2
fi

# 2. density on its own (the PDK runner fails the whole call on a density item); information unless --density
python3 "$drc_py" "${common[@]}" --density_only >"$run/run_drc_density.out" 2>&1

# a clean deck writes no lyrdb, so make sure the antenna deck really ran
if [ -n "$antenna" ] && ! grep -q "Completed running Antenna" "$run/run_drc.out"; then
  echo "run_drc.sh: antenna deck did not run, see $run/run_drc.out"; exit 2
fi

# per-deck, per-rule violation counts from the report databases
python3 -I - "$run" "${density:+1}" <<'PY'
import collections, glob, os, sys, xml.etree.ElementTree as ET
run, density_fails = sys.argv[1], bool(sys.argv[2])
decks = {"main": [], "antenna": [], "density": []}
for db in sorted(glob.glob(os.path.join(run, "*.lyrdb"))):
    root = ET.parse(db).getroot()
    for i in root.iter("item"):
        k = i.findtext("category", "").strip("'")
        deck = "density" if "_density" in os.path.basename(db) else "antenna" if k.startswith("Ant.") else "main"
        decks[deck].append(k)

# Safety check: if no items were found, verify run_drc.out explicitly reported pass/completion
out_file = os.path.join(run, "run_drc.out")
if os.path.exists(out_file):
    with open(out_file) as f:
        out_txt = f.read()
    if not any(msg in out_txt for msg in ["No DRC violations detected", "KLayout DRC Check Passed", "completed in", "Violations were detected"]):
        print("run_drc.sh: ERROR: DRC run output did not confirm valid execution.")
        sys.exit(2)

hint = {
    "Ant.a": "GatPoly over field oxide / gate area too large: shorten the poly run or connect the gate to a diode",
    "Ant.c": "Cont area / gate area too large: same fix as Ant.a",
    "Ant.b": "cumulative metal / gate area (no diode): add a dantenna on the gate net or jump to a higher metal",
    "Ant.e": "same as Ant.b with a protection diode present",
    "Ant.d": "cumulative via / gate area (no diode): add a dantenna or reduce via count before the gate is tied to a diffusion",
    "Ant.f": "same as Ant.d with a protection diode present",
    "Ant.g": "protection diode too small",
    "Ant.h": "dantenna must not be in NWell",
    "Ant.i": "dpantenna must not be in PWell",
}
fail = False
for deck, items in decks.items():
    cnt = collections.Counter(items)
    informational = deck == "density" and not density_fails
    tag = "info, chip-level" if informational else "fail" if cnt else "ok"
    print(f"{deck:8s}: {sum(cnt.values()):4d} items  [{tag}]")
    for k, v in sorted(cnt.items()):
        h = hint.get(k.split("_")[0], "")
        print(f"    {k:16s} {v:4d}  {h}")
    if cnt and not informational:
        fail = True
sys.exit(1 if fail else 0)
PY
res=$?
echo "files: $run/*.lyrdb  (layout: $gds)"
exit $res
