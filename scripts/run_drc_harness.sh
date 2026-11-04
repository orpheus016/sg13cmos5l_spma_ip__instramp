#!/usr/bin/env bash
# DRC with the deck and flags the Chipalooza harness uses for its final check (validate/run_klayout_drc_final.sh):
#   scripts/run_drc_harness.sh [<cell>] [--gds <file>] [--top <cell>] [--thr <n>]
#
#   <cell>          registry cell (cells.yaml) to take gds and top from; default: the harness deliverable gds/slot_9.gds, top slot_9
#   --gds / --top   explicit layout and top cell
#
# klayout -b -zz -r $PDK_ROOT/ihp-sg13cmos5l/libs.tech/klayout/tech/drc/ihp-sg13cmos5l.drc
#         -rd feol=True -rd beol=True -rd conn_drc=True -rd wedge=True -rd run_mode=deep -rd thr=<n> -rd topcell=<top>
# This is the old monolithic deck, not scripts/run_drc.sh's run_drc.py (main + antenna + density info): same rules, different driver and the
# `wedge` / `conn_drc` options. The harness runs it on the filled chip; here it runs on the pre-fill slot, so density/fill rules are not part of it.
# Results: runs/drc_harness/<name>/<top>.lyrdb + log. Exit: 0 no violations, 1 violations, 2 setup/tool problem.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
gds=""; top=""; cell=""; thr="$(nproc 2>/dev/null || echo 4)"; [ "$thr" -gt 8 ] && thr=8
while [ $# -gt 0 ]; do
  case "$1" in
    --gds) gds="$2"; shift 2;; --top) top="$2"; shift 2;; --thr) thr="$2"; shift 2;;
    -*) echo "run_drc_harness.sh: unknown option $1"; exit 2;;
    *) cell="$1"; shift;;
  esac
done
deck="$PDK_ROOT/$PDK/libs.tech/klayout/tech/drc/ihp-sg13cmos5l.drc"
[ -f "$deck" ] || { echo "run_drc_harness.sh: deck $deck not found"; exit 2; }
command -v klayout >/dev/null || { echo "run_drc_harness.sh: klayout not found"; exit 2; }
if [ -n "$cell" ]; then
  [ -n "$gds" ] || gds="$(python3 -I "$root/scripts/cellinfo.py" "$cell" gds 2>/dev/null)" || { echo "run_drc_harness.sh: no gds for $cell in cells.yaml"; exit 2; }
  [ -n "$top" ] || top="$(python3 -I "$root/scripts/cellinfo.py" "$cell" top 2>/dev/null || echo "$cell")"
else
  [ -n "$gds" ] || gds="$root/gds/slot_9.gds"
  [ -n "$top" ] || top="slot_9"; cell="$top"
fi
[ -f "$gds" ] || { echo "run_drc_harness.sh: $gds not found"; exit 2; }

run="$root/runs/drc_harness/$cell"; rm -rf "$run"; mkdir -p "$run"
klayout -b -zz -r "$deck" -rd input="$gds" -rd report="$run/$top.lyrdb" -rd feol=True -rd beol=True -rd conn_drc=True -rd wedge=True \
  -rd run_mode=deep -rd thr="$thr" -rd topcell="$top" >"$run/klayout.log" 2>&1
rc=$?
if [ ! -f "$run/$top.lyrdb" ]; then
  echo "run_drc_harness.sh: the deck produced no report (exit $rc), see $run/klayout.log"; tail -3 "$run/klayout.log"; exit 2
fi
python3 -I - "$run/$top.lyrdb" "$gds" "$top" <<'PY'
import collections, os, sys, xml.etree.ElementTree as ET
db, gds, top = sys.argv[1:4]
c = collections.Counter(i.findtext("category", "").strip("'") for i in ET.parse(db).getroot().iter("item"))
print(f"harness-style DRC (ihp-sg13cmos5l.drc, feol beol conn_drc wedge, deep) on {os.path.basename(gds)} top {top}")
if not c:
    print("  0 violations"); sys.exit(0)
for k, n in sorted(c.items()):
    print(f"  {k:28s} {n}")
print(f"  {sum(c.values())} violations in {len(c)} rules")
sys.exit(1)
PY
exit $?
