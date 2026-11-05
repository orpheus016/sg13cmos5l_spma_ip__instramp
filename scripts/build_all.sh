#!/usr/bin/env bash
# Build and verify everything from one command:  scripts/build_all.sh [options]
#
#   --fast               only the checks of every layout cell: DRC, tap audit, LVS (+ harness DRC and deliverable check of slot9_wrapper),
#                        registry, slot_9.gds, LVS canary. No CACE / extraction / post-layout, no pictures, no reports. Minutes.
#   --cells a,b          only these cells (default: every cell of cells.yaml that has stages)
#   --profile typ|pvt    CACE profile (default typ)          --no-mc   leave the Monte Carlo parameters out of the schematic CACE runs
#   --skip a,b           leave steps out: registry export canary bias images reports (and any flow stage name, e.g. cace, pex, post, audit)
#   --open               open docs/index.html when done
#
# Order (leaves first, the chip last; a failing step never stops the following ones):
#   registry    scripts/cellinfo.py --check          cells.yaml matches the files (gds/sch exist, top cell = schematic name)
#   export      scripts/export_slot_gds.py           gds/slot9_wrapper/slot9_wrapper.gds -> gds/slot_9.gds, the file the Chipalooza harness takes
#   flow:<cell> scripts/flow.sh <cell>               the stages of the cell in cells.yaml: cace drc audit drc_harness lvs deliver pex post, then
#                                                    schematic + layout pictures and README blocks (images). Results docs/<cell>/status.{md,json}
#   canary      scripts/lvs_canary.py pgia_top       proves that LVS still catches a wrong W/L, a missing well tap and a short
#   bias        scripts/verify_central_bias.py       the chip works from the single harness bias pin (central_bias): currents, VOUT, power, 11 gain codes
#   images      scripts/update_images.py all         pictures and README blocks of the cells that have no flow
#   reports     scripts/build_report.sh all          interactive HTML of the CACE cells (docs/<cell>/report.html), then
#               scripts/build_chip_report.py         static HTML of all other cells + docs/index.html
# Output: runs/build_all/<timestamp>/ (one log per step), docs/build_summary.{md,json}, docs/index.html, docs/<cell>/ (status, audit, report).
# Exit: 0 everything passed or was skipped, 1 a check failed, 2 a step could not run.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"

fast=""; cells_arg=""; profile="typ"; nomc=""; skip=","; open=""
while [ $# -gt 0 ]; do
  case "$1" in
    --fast) fast=1; shift;;
    --cells) cells_arg="${2//,/ }"; shift 2;;
    --profile) profile="$2"; shift 2;;
    --no-mc) nomc=1; shift;;
    --skip) skip=",$2,"; shift 2;;
    --open) open=1; shift;;
    -h|--help) sed -n 2,24p "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "build_all.sh: unknown option $1"; exit 2;;
  esac
done
skipped() { case "$skip" in *",$1,"*) return 0;; esac; return 1; }

ts="$(date +%Y-%m-%d_%H%M%S)"; log="$root/runs/build_all/$ts"; mkdir -p "$log"
steps="$log/steps.tsv"; : >"$steps"
t_all=$(date +%s)
echo "build_all: $ts  mode: $([ -n "$fast" ] && echo fast || echo full)  profile: $profile  logs: runs/build_all/$ts"

# step <name> <command...>: run, log, record (status ok | FAIL | ERROR)
step() {
  local name="$1"; shift; local t0 rc secs st d
  t0=$(date +%s); "$@" >"$log/${name//:/_}.log" 2>&1; rc=$?; secs=$(( $(date +%s) - t0 ))
  case $rc in 0) st=ok;; 1) st=FAIL;; *) st=ERROR;; esac
  d="$(grep -v '^\s*$' "$log/${name//:/_}.log" | tail -n 1 | cut -c1-160)"
  printf '%s\t%s\t%s\t%s\n' "$name" "$st" "$secs" "$d" >>"$steps"
  printf '  %-26s %-5s %5ss  %s\n' "$name" "$st" "$secs" "$d"
}
skip_step() { printf '%s\t%s\t0\t%s\n' "$1" "skip" "$2" >>"$steps"; printf '  %-26s %-5s %5s   %s\n' "$1" "skip" "" "$2"; }

# the cells to handle, leaves first
all_cells="$(python3 -I scripts/cellinfo.py --order)"
sel=""
for c in $all_cells; do
  [ -n "$cells_arg" ] && ! [[ " $cells_arg " == *" $c "* ]] && continue
  [ -n "$(python3 -I scripts/cellinfo.py "$c" stages 2>/dev/null)" ] && sel="$sel $c"
done
has_cell() { [[ " $sel " == *" $1 "* ]]; }

# 1. registry
if skipped registry; then skip_step registry "skipped"; else step registry python3 -I scripts/cellinfo.py --check; fi

# 2. harness deliverable
if skipped export; then skip_step export "skipped"
elif [ -z "$cells_arg" ] || has_cell slot9_wrapper; then step export python3 -I scripts/export_slot_gds.py
else skip_step export "slot9_wrapper not selected"; fi

# 3. per cell flow
fast_stages=" drc audit drc_harness lvs deliver "
for c in $sel; do
  stages=""
  for s in $(python3 -I scripts/cellinfo.py "$c" stages); do
    skipped "$s" && continue
    [ -n "$fast" ] && [[ "$fast_stages" != *" $s "* ]] && continue
    stages="$stages,$s"
  done
  stages="${stages#,}"
  if [ -z "$stages" ]; then skip_step "flow:$c" "no stage left"; continue; fi
  args=("$c" --profile "$profile")
  if [ -n "$fast" ]; then args+=(--only "$stages"); else args+=(--stages "$stages"); fi
  [ -n "$nomc" ] && args+=(--no-mc)
  step "flow:$c" scripts/flow.sh "${args[@]}"
done

# 4. LVS canary (needs the LVS netlist the flow wrote)
if skipped canary; then skip_step canary "skipped"
elif [ -z "$cells_arg" ] || has_cell pgia_top; then step canary python3 -I scripts/lvs_canary.py pgia_top
else skip_step canary "pgia_top not selected"; fi

# 4b. bias: the chip works with only the harness bias pin (central_bias)
if skipped bias; then skip_step bias "skipped"
elif [ -z "$cells_arg" ] || has_cell pgia_top; then step bias python3 -I scripts/verify_central_bias.py
else skip_step bias "pgia_top not selected"; fi

# 5. pictures + READMEs of everything (the flow only does its own cell), 6. reports
if [ -n "$fast" ]; then skip_step images "--fast"; skip_step reports "--fast"
else
  if skipped images; then skip_step images "skipped"; else step images python3 -I scripts/update_images.py all; fi
  if skipped reports; then skip_step reports "skipped"
  else
    step reports:cace scripts/build_report.sh all
    step reports:chip python3 -I scripts/build_chip_report.py
  fi
fi

# 7. summary
secs_all=$(( $(date +%s) - t_all ))
python3 -I - "$root" "$ts" "$steps" "$secs_all" "$([ -n "$fast" ] && echo fast || echo full)" "$profile" <<'PY'
import datetime, json, os, subprocess, sys
root, ts, steps_f, secs_all, mode, profile = sys.argv[1:7]
steps = [dict(zip(("name", "status", "seconds", "detail"), l.rstrip("\n").split("\t", 3))) for l in open(steps_f)]
icon = {"ok": "✅", "FAIL": "❌", "ERROR": "❗", "skip": "⏭"}
sicon = {"pass": "✅", "fail": "❌", "error": "❗", "skip": "⏭", "blocked": "⛔"}
cells = [s["name"][5:] for s in steps if s["name"].startswith("flow:")]
matrix = {}
for c in cells:
    f = os.path.join(root, "docs", c, "status.json")
    if os.path.isfile(f):
        matrix[c] = {s["name"]: s["status"] for s in json.load(open(f)).get("stages", [])}
cols = [n for n in ("cace", "drc", "audit", "drc_harness", "lvs", "deliver", "pex", "post_c", "post_rc", "images") if any(n in m for m in matrix.values())]
try:
    commit = subprocess.check_output(["git", "-C", root, "rev-parse", "--short", "HEAD"], text=True).strip()
    branch = subprocess.check_output(["git", "-C", root, "branch", "--show-current"], text=True).strip()
except Exception:
    commit = branch = "?"
md = [f"# Build summary", "", f"`scripts/build_all.sh` ({mode}, CACE profile {profile}) at {datetime.datetime.now().isoformat(timespec='seconds')}, "
      f"branch `{branch}` commit {commit}, {secs_all} s. Logs: `runs/build_all/{ts}/`.", "", "## Steps", "", "| Step | Result | Time | Last line |", "|---|---|---:|---|"]
for s in steps:
    md.append(f"| {s['name']} | {icon.get(s['status'], '')} {s['status']} | {s['seconds']} s | {s['detail'].replace('|', '/')} |")
if matrix:
    md += ["", "## Cells x flow stages (from docs/<cell>/status.json)", "", "| Cell | " + " | ".join(cols) + " |", "|---|" + "---|" * len(cols)]
    for c, m in matrix.items():
        md.append(f"| {c} | " + " | ".join(sicon.get(m.get(k, ''), '·') if k in m else '·' for k in cols) + " |")
open(os.path.join(root, "docs", "build_summary.md"), "w").write("\n".join(md) + "\n")
json.dump(dict(generated=datetime.datetime.now().isoformat(timespec="seconds"), mode=mode, profile=profile, branch=branch, commit=commit,
               seconds=int(secs_all), steps=steps, matrix=matrix), open(os.path.join(root, "docs", "build_summary.json"), "w"), indent=1)
PY
echo
echo "== build summary ($secs_all s) -> docs/build_summary.md"
awk -F'\t' '{printf "  %-26s %s\n", $1, $2}' "$steps"
[ -n "$open" ] && [ -f docs/index.html ] && xdg-open docs/index.html >/dev/null 2>&1
if awk -F'\t' '$2=="ERROR"{f=1} END{exit !f}' "$steps"; then exit 2; fi
if awk -F'\t' '$2=="FAIL"{f=1} END{exit !f}' "$steps"; then exit 1; fi
exit 0
