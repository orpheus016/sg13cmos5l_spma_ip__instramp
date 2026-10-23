#!/usr/bin/env bash
# KLayout LVS for one cell:  scripts/run_lvs.sh <cell> [options] [-- extra run_lvs.py args]
#
#   --gds <file>      layout (default: the only gds/*/<cell>.gds)
#   --top <cell>      top cell in the GDS (default: <cell>)
#   --netlist-only    only write netlist/<cell>/lvs/<cell>.spice (for the KLayout GUI "Netlist Path"), then stop.
#                     Rerun it (with --gds if the GDS is not gds/*/<cell>.gds) after moving MoM caps.
#   --fix-labels      run on a scratch copy of the GDS where missing /25 net labels are copied from the pin/drawing
#                     layer. The real GDS is never touched; fix the labels in KLayout afterwards.
#   --no-taps         disable ntap1 and ptap1 device extraction (--disable_tap_extraction)
#   --view            open KLayout with the GDS and the result database afterwards
#
# Steps: xschem LVS netlist -> make it readable for KLayout -> check labels -> run_lvs.py -> readable report.
# Results: runs/lvs/<cell>/ (git-ignored): <cell>.lvsdb, <cell>_extracted.cir, logs.  Exit: 0 match, 1 mismatch, 2 setup error.
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
    exec docker exec -i -w "$container_cwd" iic-osic-tools_x11 bash "$container_root/scripts/run_lvs.sh" "${args[@]}"
  elif ! command -v klayout >/dev/null 2>&1; then
    echo "run_lvs.sh: ERROR: klayout is not found in PATH and iic-osic-tools_x11 container is not running." >&2
    exit 2
  fi
fi

cell="${1:?usage: run_lvs.sh <cell> [--gds f] [--top c] [--netlist-only] [--fix-labels] [--view] [-- run_lvs.py args]}"; shift
lvs_py="$PDK_ROOT/$PDK/libs.tech/klayout/tech/lvs/run_lvs.py"
tools="$root/scripts/lvs_tools.py"

gds=""; top="";  netlist_only=""; fix_labels=""; view=""; extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --gds) gds="$2"; shift 2;;
    --top) top="$2"; shift 2;;
    --netlist-only) netlist_only=1; shift;;
    --fix-labels) fix_labels=1; shift;;
    --no-taps|--disable-tap-extraction) extra+=(--disable_tap_extraction); shift;;
    --view) view=1; shift;;
    --) shift; extra+=("$@"); break;;
    *) echo "run_lvs.sh: unknown option $1"; exit 2;;
  esac
done
if [ ${#extra[@]} -eq 0 ]; then
  read -ra lvs_extra <<<"$(python3 -I "$root/scripts/cellinfo.py" "$cell" lvs_args 2>/dev/null || true)"
  [ ${#lvs_extra[@]} -gt 0 ] && extra=("${lvs_extra[@]}")
fi
[ -n "$top" ] || top="$(python3 -I "$root/scripts/cellinfo.py" "$cell" top 2>/dev/null || echo "$cell")"   # default: top of cells.yaml (e.g. slot9_wrapper for pgia_top), else the cell name

sch="$root/xschem/$cell/$cell.sch"
[ -f "$sch" ] || { echo "run_lvs.sh: $sch not found"; exit 2; }
if [ -z "$gds" ]; then
  mapfile -t found < <(python3 -I "$root/scripts/cellinfo.py" "$cell" gds 2>/dev/null || ls "$root"/gds/*/"$cell.gds" 2>/dev/null)
  if [ "${#found[@]}" -eq 1 ]; then gds="${found[0]}"
  elif [ -z "$netlist_only" ]; then echo "run_lvs.sh: pass --gds (found ${#found[@]} candidates: ${found[*]:-none})"; exit 2; fi
fi

# 1. LVS netlist from the schematic. Private HOME: xschem rewrites ~/.xschem/recent_files.
nl_dir="$root/netlist/$cell/lvs"; mkdir -p "$nl_dir"
raw="$(mktemp -d)"; xhome="$(mktemp -d)"; trap 'rm -rf "$raw" "$xhome"' EXIT
rc="xschemrc"; [ -f "$root/xschem/$cell/xschemrc" ] || rc="$PDK_ROOT/$PDK/libs.tech/xschem/xschemrc"   # cells without their own rc
# lvs_ignore: parts with the instance attribute lvs_ignore=true (simulation-only resistors, probes) are left out
( cd "$root/xschem/$cell" && HOME="$xhome" xschem -q -n -s -x --rcfile "$rc" --tcl "set lvs_netlist 1; set lvs_ignore 1" -o "$raw" "$cell.sch" ) >"$raw/xschem.log" 2>&1
[ -f "$raw/$cell.spice" ] || { echo "run_lvs.sh: xschem produced no netlist"; cat "$raw/xschem.log"; exit 2; }
if grep -q "IS MISSING" "$raw/$cell.spice"; then
  echo "run_lvs.sh: xschem could not find PDK symbols (IS MISSING). PDK=$PDK PDK_ROOT=$PDK_ROOT"; grep "IS MISSING" "$raw/$cell.spice"; exit 2
fi
gds_args=(); [ -n "$gds" ] && gds_args=(--gds "$gds" --top "$top")   # MoM cap orientation is taken from the layout
python3 -I "$tools" netlist-fix "$raw/$cell.spice" "$nl_dir/$cell.spice" "${gds_args[@]}" || exit 2
[ -n "$netlist_only" ] && { echo "run_lvs.sh: use this as 'Netlist Path' in the KLayout LVS options: $nl_dir/$cell.spice"; exit 0; }

# 2. labels
run="$root/runs/lvs/$cell"; rm -rf "$run"; mkdir -p "$run"
layout="$gds"
if [ -n "$fix_labels" ]; then
  python3 -I "$tools" labels "$gds" "$top" "$nl_dir/$cell.spice" --write "$run/$top.gds"; rc=$?
  [ -f "$run/$top.gds" ] && layout="$run/$top.gds"
else
  python3 -I "$tools" labels "$gds" "$top" "$nl_dir/$cell.spice"; rc=$?
  [ "$rc" -eq 3 ] && echo "run_lvs.sh: continuing; the layout side will have no ports. (--fix-labels to see the rest of the result.)"
fi

# 3. LVS
python3 "$lvs_py" --layout="$layout" --netlist="$nl_dir/$cell.spice" --topcell="$top" --run_dir="$run" "${extra[@]}" >"$run/run_lvs.out" 2>&1
grep -E "ERROR|Outcome" "$run/run_lvs.out" | sed 's/^.*| //' | head -8
db="$run/$top.lvsdb"
[ -f "$db" ] || { echo "run_lvs.sh: no lvsdb produced, see $run/run_lvs.out"; exit 2; }

# 4. report
python3 -I "$tools" report "$db"; res=$?
echo "files: $db  $run/${top}_extracted.cir  (layout used: $layout)"
if [ -n "$view" ]; then
  printf 'lv = RBA::LayoutView.current\nl = RBA::LayoutVsSchematic.new; l.read("%s")\nlv.show_lvsdb(lv.add_lvsdb(l), 0)\n' "$db" >"$run/view.rb"
  klayout -l "$PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13cmos5l.lyp" "$layout" -rr "$run/view.rb" &
fi
exit $res
