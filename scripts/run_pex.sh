#!/usr/bin/env bash
# Parasitic extraction of one cell for post-layout simulation:  scripts/run_pex.sh <cell> [options]
#
#   --gds <file>   layout (default: the only gds/*/<cell>.gds)      --top <cell>  top cell (default <cell>)
#   --skip-lvs     do not run scripts/run_lvs.sh first (it must be MATCH, PEX is meaningless otherwise)
#   --mode CC|RC   kpex 2.5D mode (default CC = coupling/ground capacitance; see the note below)
#
# Steps: LVS must match -> strip MoM-cap internals from a GDS copy (scripts/pex_prepare_gds.py) -> kpex 2.5D ->
# ngspice-ready netlist (scripts/pex_netlist.py) -> netlist/<cell>/pex/<cell>.spice (+ layout/ copy so CACE never starts Magic).
# Needs netlist/<cell>/schematic/<cell>.spice (written by any CACE run: scripts/run_cace.sh <cell>) for the pin order.
#
# Why CC: with kpex 0.4.4 `--mode RC` writes wire resistors that are NOT connected to the device terminals (only the
# port nets get one resistor), so the netlist does not simulate. Device parasitics (AS/AD/PS/PD), poly resistor and
# MoM cap come from the LVS devices, wire capacitance from the extractor; wire resistance is not included.
set -uo pipefail
cell="${1:?usage: run_pex.sh <cell> [--gds f] [--top c] [--skip-lvs] [--mode CC|RC]}"; shift
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
gds=""; top="$cell"; skip_lvs=""; mode="CC"
while [ $# -gt 0 ]; do
  case "$1" in
    --gds) gds="$2"; shift 2;; --top) top="$2"; shift 2;; --skip-lvs) skip_lvs=1; shift;; --mode) mode="$2"; shift 2;;
    *) echo "run_pex.sh: unknown option $1"; exit 2;;
  esac
done
if [ -z "$gds" ]; then
  mapfile -t found < <(ls "$root"/gds/*/"$cell.gds" 2>/dev/null)
  [ "${#found[@]}" -eq 1 ] || { echo "run_pex.sh: pass --gds (found ${#found[@]} candidates)"; exit 2; }
  gds="${found[0]}"
fi
sch="$root/netlist/$cell/schematic/$cell.spice"
[ -f "$sch" ] || { echo "run_pex.sh: $sch missing - run scripts/run_cace.sh $cell once (CACE writes it)"; exit 2; }
command -v kpex >/dev/null || { echo "run_pex.sh: kpex not found"; exit 2; }

if [ -z "$skip_lvs" ]; then
  "$root/scripts/run_lvs.sh" "$cell" --gds "$gds" --top "$top" | tail -3
  [ "${PIPESTATUS[0]}" -eq 0 ] || { echo "run_pex.sh: LVS is not clean, fix it first (or --skip-lvs)"; exit 1; }
fi

work="$root/runs/pex/$cell"; rm -rf "$work"; mkdir -p "$work"

# 1. kpex 0.4.4 as installed lacks most cmos5l LVS rule-deck includes and trips over MoM caps in its writer:
#    build a patched copy once (rule decks from the PDK, one-line writer fix). Package paths are not modified.
ov="$root/runs/pex/_kpex"
if [ ! -f "$ov/.ok" ]; then
  rm -rf "$ov"; mkdir -p "$ov"
  src="$(python3 -c 'import klayout_pex,os;print(os.path.dirname(klayout_pex.__file__))')"
  cp -r "$src" "$ov/klayout_pex"; cp -r "$(dirname "$src")/klayout_pex_protobuf" "$ov/"
  dec="$ov/klayout_pex/pdk/ihp-sg13cmos5l/libs.tech/kpex/rule_decks"
  for f in "$PDK_ROOT/$PDK/libs.tech/klayout/tech/lvs/rule_decks/"*; do [ -e "$dec/$(basename "$f")" ] || cp -L "$f" "$dec/"; done
  cp "$src/pdk/ihp-sg13g2/libs.tech/kpex/rule_decks/auto_name_layers.rb" "$dec/"
  python3 -I - "$ov/klayout_pex/klayout/netlist_printer.py" <<'PY'
import sys
p = sys.argv[1]; t = open(p).read()
old = "            case kdb.DeviceClassCapacitor():\n                c_farad = device.parameter('C')"
new = "            case kdb.DeviceClassCapacitor() if dc.has_parameter('C'):\n                c_farad = device.parameter('C')"
assert old in t, "kpex changed: netlist_printer patch no longer applies"
open(p, "w").write(t.replace(old, new))
PY
  touch "$ov/.ok"
fi

# 2. GDS copy without MoM-cap fingers
python3 -I "$root/scripts/pex_prepare_gds.py" "$gds" "$work/$top.gds" --top "$top" || exit 2

# 3. kpex (2.5D)
( cd "$work" && PYTHONPATH="$ov" python3 -m klayout_pex extract --pdk ihp-sg13cmos5l --gds "$work/$top.gds" --cell "$top" \
    --schematic "$root/netlist/$cell/lvs/$cell.spice" --2.5D --mode "$mode" --blackbox true --out_dir "$work/kpex" ) >"$work/kpex.out" 2>&1
raw="$(ls "$work"/kpex/*/*_k25d_pex_netlist.spice 2>/dev/null | head -1)"
[ -n "$raw" ] || { echo "run_pex.sh: kpex produced no netlist, see $work/kpex.out"; tail -5 "$work/kpex.out"; exit 2; }

# 4. convert + install where CACE looks for it
mkdir -p "$root/netlist/$cell/pex" "$root/netlist/$cell/layout"
python3 -I "$root/scripts/pex_netlist.py" "$raw" "$sch" "$root/netlist/$cell/pex/$cell.spice" --cell "$top" || exit 2
cp "$root/netlist/$cell/pex/$cell.spice" "$root/netlist/$cell/layout/$cell.spice"
echo "run_pex.sh: done. raw kpex netlist: $raw"
