#!/usr/bin/env bash
# Post-layout CACE run and comparison with the schematic:  scripts/run_postlayout.sh <cell> [options] [-- cace args, e.g. -p dc_op ac_response]
#
#   --profile typ|pvt   typ (default): corner tt, typical vdd / temperature only, no Monte Carlo  -> a handful of runs
#                       pvt: the full PVT grid of the datasheet, no Monte Carlo (extraction has no random part)
#   --against <run>     schematic run to compare with (default: newest runs/RUN_* whose summary says "netlist source: schematic")
#   --netlist c|rc      c (default): kpex wire capacitance only;  rc: Magic wire resistance + capacitance (scripts/run_pex.sh)
#   --repex             run scripts/run_pex.sh first even when the post-layout netlist is newer than the GDS
#
# Output: runs/pex_cace/<cell>/RUN_* (rc: runs/pex_cace_rc/), docs/<cell>/cace/postlayout.md (rc: postlayout_rc.md, + .png)
# from scripts/compare_cace.py.
# The datasheet is copied to a temporary yaml (paths.layout added, sweeps reduced, documentation redirected to runs/pex_docs
# so the committed schematic report in docs/<cell>/cace is never overwritten).
# Exit: 0 all parameters pass, 2 a spec failed / error (same convention as run_cace.sh), 1 setup problem.
set -uo pipefail
cell="${1:?usage: run_postlayout.sh <cell> [--profile typ|pvt] [--against run] [--repex] [-- cace args]}"; shift
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
unset DISPLAY   # headless xschem, see run_cace.sh
export PATH="$root/scripts/bin:$PATH"   # xschem wrapper: one HOME per call (see scripts/bin/xschem)
profile="typ"; against=""; repex=""; netlist="c"; cace_args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) profile="$2"; shift 2;; --against) against="$2"; shift 2;; --repex) repex=1; shift;; --netlist) netlist="$2"; shift 2;;
    --) shift; cace_args=("$@"); break;;
    *) echo "run_postlayout.sh: unknown option $1"; exit 1;;
  esac
done
gds="$(python3 -I "$root/scripts/cellinfo.py" "$cell" gds 2>/dev/null || ls "$root"/gds/*/"$cell.gds" 2>/dev/null | head -1)"
[ -f "$gds" ] || { echo "run_postlayout.sh: no gds/*/$cell.gds"; exit 1; }
pexdir="$root/netlist/$cell/pex"
pex="$pexdir/$cell.$netlist.spice"
case "$netlist" in c|rc) ;; *) echo "run_postlayout.sh: --netlist must be c or rc"; exit 1;; esac

# netlist older than the layout -> CACE would start Magic and overwrite it; extract again instead
if [ -n "$repex" ] || [ ! -f "$pex" ] || [ "$gds" -nt "$pex" ]; then
  echo "run_postlayout.sh: (re)running PEX"
  "$root/scripts/run_pex.sh" "$cell" --use "$netlist" || exit 1
fi
# the one CACE reads (it takes netlist/<cell>/pex/<cell>.spice, and layout/<cell>.spice when it believes the layout is newer)
cp "$pex" "$pexdir/$cell.spice"; cp "$pex" "$root/netlist/$cell/layout/$cell.spice"
echo "run_postlayout.sh: netlist $netlist ($pex)"
suffix=""; [ "$netlist" = rc ] && suffix="_rc"

# schematic run to compare with
if [ -z "$against" ]; then
  # newest schematic run of this cell with the most evaluated rows (a full run beats a later partial -p run)
  best=-1
  for d in $(ls -d "$root"/runs/RUN_* 2>/dev/null | sort -r); do
    s="$d/summary.md"
    grep -q "CACE Summary for $cell\$" "$s" 2>/dev/null && grep -q "netlist source\*\*: schematic" "$s" || continue
    n="$(grep -E '\| *(Pass|Fail)' "$s" | wc -l)"
    [ "$n" -gt "$best" ] && { best="$n"; against="$d"; }
  done
fi
[ -n "$against" ] || echo "run_postlayout.sh: WARNING no schematic run found, comparison will be skipped (run scripts/run_cace.sh $cell)"

tmp="$root/cace/${cell}_pex_tmp.yaml"
cace_home="$(mktemp -d)"; trap 'rm -rf "$cace_home" "$tmp"' EXIT
python3 -I - "$root/cace/$cell.yaml" "$tmp" "$profile" "$(dirname "${gds#$root/}")" "$cell" "$suffix" <<'PY'
import sys, yaml
src, dst, profile, gdsdir, cell = sys.argv[1:6]
d = yaml.safe_load(open(src))
d["paths"]["layout"] = gdsdir
d["paths"]["documentation"] = f"runs/pex_docs{sys.argv[6]}/{cell}"
for name in list(d["parameters"]):
    cond = d["parameters"][name].get("conditions", {})
    if "iterations" in cond:            # Monte Carlo: no random part in an extraction
        del d["parameters"][name]
        continue
    if profile == "typ":
        for cn, c in cond.items():
            if "enumerate" in c:
                c["enumerate"] = [c["enumerate"][0]]
            if cn in ("vdd", "temperature"):
                c.pop("minimum", None); c.pop("maximum", None)
yaml.safe_dump(d, open(dst, "w"), sort_keys=False, allow_unicode=True)
PY
out="$root/runs/pex_cace$suffix/$cell"; mkdir -p "$out"
( cd "$root/cace" && HOME="$cace_home" cace -s pex "${cell}_pex_tmp.yaml" --nofail --no-progress-bar --run-path "$out" "${cace_args[@]}" ) >"$out/cace.out" 2>&1
run="$(ls -d "$out"/RUN_* 2>/dev/null | sort | tail -1)"
[ -f "$run/summary.md" ] || { echo "run_postlayout.sh: no summary.md; tail of $out/cace.out:"; tail -15 "$out/cace.out"; exit 1; }
# CACE's own layout-image step fails with 'sg13g2.lyp' (known, see STATUS.md); it runs after the simulations, harmless here
echo "post-layout run: $run"

if [ -n "$against" ]; then
  python3 -I "$root/scripts/compare_cace.py" "$against" "$run" -o "$root/docs/$cell/cace/postlayout$suffix.md" || exit 1
fi
if grep -qE '\| *(Fail|Error)' "$run/summary.md"; then
  echo "run_postlayout.sh: spec failure or error in $run/summary.md"
  grep -E '\| *(Fail|Error)' "$run/summary.md" | sed 's/  */ /g' | cut -c1-150
  exit 2
fi
echo "run_postlayout.sh: all parameters passed"
