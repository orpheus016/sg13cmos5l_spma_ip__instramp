#!/usr/bin/env bash
# One command from schematic to post-layout comparison for one cell:
#   scripts/flow.sh <cell> [--profile typ|pvt] [--stages cace,drc,lvs,pex,post | --only drc,lvs] [--no-mc] [--netlist c|rc|both] [--force] [--keep-going]
#
# The stages come from cells.yaml (`stages:` of the cell); --stages overrides them, --only intersects with them (CI). Stages, in this order:
#   cace   schematic CACE run = the reference (scripts/run_cace.sh). Reused when newer than the schematic, yaml and templates (--force: rerun)
#   drc    KLayout DRC + antenna (+ density info)               scripts/run_drc.sh
#   lvs    layout versus schematic                              scripts/run_lvs.sh
#   pex    parasitic extraction: kpex C and Magic R+C           scripts/run_pex.sh   (needs lvs MATCH and the cace run)
#   post   CACE on the extracted netlist(s) + comparison        scripts/run_postlayout.sh   (--netlist, default both c and rc)
#   images schematic + layout pictures, README blocks           scripts/update_images.py   (always last; not with --only)
# A stage that cannot run is SKIPPED with the reason (no layout yet, no datasheet...), a stage that depends on a failed one is BLOCKED.
# --no-mc leaves the Monte Carlo parameters out of the schematic run (faster; the reference then has no MC rows).
# Output: runs/flow/<cell>/<stage>.log, docs/<cell>/status.md and docs/<cell>/status.json (read by tools/report.ipynb).
# Exit: 0 everything passed or skipped, 1 a check failed (violation, mismatch, spec), 2 a stage could not run properly.
set -uo pipefail
cell="${1:?usage: flow.sh <cell> [--profile typ|pvt] [--stages a,b] [--no-mc] [--netlist c|rc|both] [--force] [--keep-going]}"; shift
root="$(cd "$(dirname "$0")/.." && pwd)"
info() { python3 -I "$root/scripts/cellinfo.py" "$cell" "$@" 2>/dev/null; }
python3 -I "$root/scripts/cellinfo.py" "$cell" stages >/dev/null 2>&1 || [ -n "$(info note)" ] || { echo "flow.sh: $cell is not in cells.yaml"; exit 2; }

profile="typ"; stages=""; only=""; nomc=""; netlist="both"; force=""
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) profile="$2"; shift 2;; --stages) stages="${2//,/ }"; shift 2;; --only) only="${2//,/ }"; shift 2;; --no-mc) nomc=1; shift;;
    --netlist) netlist="$2"; shift 2;; --force) force=1; shift;; --keep-going) shift;;
    *) echo "flow.sh: unknown option $1"; exit 2;;
  esac
done
[ -z "$stages" ] && stages="$(info stages)"
if [ -n "$only" ]; then   # --only: just these, and only if the cell has them in cells.yaml (used by CI)
  keep=""; for s in $stages; do case " $only " in *" $s "*) keep="$keep $s";; esac; done; stages="${keep# }"
fi
log="$root/runs/flow/$cell"; rm -rf "$log"; mkdir -p "$log"
res="$log/results.tsv"; : >"$res"
has_stage() { case " $stages " in *" $1 "*) return 0;; esac; return 1; }
gds="$(info gds)"; sch="$(info sch)"; yaml="$(info cace)"; top="$(info top)"
drc_args=(); read -ra drc_args <<<"$(info drc_args)"

# record <stage> <status> <seconds> <detail>   status: pass fail error skip blocked
record() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >>"$res"; printf '%-8s %-8s %5ss  %s\n' "$1" "$2" "$3" "$4"; }
status_of() { grep -P "^$1\t" "$res" | tail -1 | cut -f2; }
# run <stage> <ok-codes: space separated "pass-codes|fail-codes"> <cmd...>
run() {
  local st="$1" t0 rc; shift
  t0=$(date +%s); "$@" >"$log/$st.log" 2>&1; rc=$?; RC=$rc; SECS=$(( $(date +%s) - t0 ))
}
now_older() { [ ! -e "$2" ] || [ "$1" -nt "$2" ]; }   # $1 newer than $2 (or $2 missing)

echo "flow: $cell  stages: ${stages:-none}  profile: $profile"
[ -z "$stages" ] && { echo "flow: $cell has no stages yet ($(info note))"; }

# ---- cace (schematic reference)
if has_stage cace; then
  if [ -z "$yaml" ] || [ ! -f "$yaml" ]; then record cace skip 0 "no CACE datasheet (scripts/new_cell.sh $cell)"
  else
    ref=""
    for d in $(ls -d "$root"/runs/RUN_* 2>/dev/null | sort -r); do
      grep -q "CACE Summary for $cell\$" "$d/summary.md" 2>/dev/null && grep -q "netlist source\*\*: schematic" "$d/summary.md" || continue
      ref="$d"; break
    done
    fresh=""
    if [ -n "$ref" ] && [ -z "$force" ]; then
      fresh=1
      for f in "$sch" "$yaml" $(ls "$root"/cace/templates/"$cell"/*.sch 2>/dev/null) "$root"/xschem/ota_cmos5l/ota_cmos5l.sch; do
        [ -f "$f" ] && [ "$f" -nt "$ref/summary.md" ] && fresh=""
      done
    fi
    if [ -n "$fresh" ]; then
      n=$(grep -cE '\| *(Pass|Fail)' "$ref/summary.md"); f=$(grep -cE '\| *Fail' "$ref/summary.md")
      record cace "$([ "$f" -eq 0 ] && echo pass || echo fail)" 0 "reused $(basename "$ref"): $n rows, $f failing"
    else
      skip_mc=(); [ -n "$nomc" ] && skip_mc=(-sp $(info mc-params))
      run cace "$root/scripts/run_cace.sh" "$cell" --no-progress-bar "${skip_mc[@]}"
      ref="$(ls -d "$root"/runs/RUN_* 2>/dev/null | sort | tail -1)"
      n=$(grep -cE '\| *(Pass|Fail)' "$ref/summary.md" 2>/dev/null); f=$(grep -cE '\| *Fail' "$ref/summary.md" 2>/dev/null)
      case $RC in 0) record cace pass "$SECS" "$ref: $n rows";; 2) record cace fail "$SECS" "$ref: $n rows, $f failing";; *) record cace error "$SECS" "rc=$RC, see $log/cace.log";; esac
    fi
  fi
fi

# ---- drc
if has_stage drc; then
  if [ -z "$gds" ] || [ ! -f "$gds" ]; then record drc skip 0 "no layout"
  else
    run drc "$root/scripts/run_drc.sh" "$cell" "${drc_args[@]}"
    d=$(grep -E '^(main|antenna|density) ' "$log/drc.log" | sed 's/  */ /g' | tr '\n' ';')
    case $RC in 0) record drc pass "$SECS" "$d";; 1) record drc fail "$SECS" "$d";; *) record drc error "$SECS" "rc=$RC, see $log/drc.log";; esac
  fi
fi

# ---- lvs
if has_stage lvs; then
  if [ -z "$gds" ] || [ ! -f "$gds" ]; then record lvs skip 0 "no layout"
  elif [ -z "$sch" ] || [ ! -f "$sch" ]; then record lvs skip 0 "no schematic"
  else
    run lvs "$root/scripts/run_lvs.sh" "$cell"
    d=$(grep -E 'RESULT|MATCH|MISMATCH' "$log/lvs.log" | head -1 | sed 's/  */ /g')
    case $RC in 0) record lvs pass "$SECS" "${d:-MATCH}";; 1) record lvs fail "$SECS" "${d:-mismatch}";; *) record lvs error "$SECS" "rc=$RC, see $log/lvs.log";; esac
  fi
fi

# ---- pex
if has_stage pex; then
  if [ -z "$gds" ] || [ ! -f "$gds" ]; then record pex skip 0 "no layout"
  elif [ "$(status_of lvs)" = fail ] || [ "$(status_of lvs)" = error ]; then record pex blocked 0 "LVS not clean"
  elif [ ! -f "$root/netlist/$cell/schematic/$cell.spice" ]; then record pex blocked 0 "no schematic CACE run (netlist/$cell/schematic missing)"
  else
    skip_lvs=(); [ "$(status_of lvs)" = pass ] && skip_lvs=(--skip-lvs)
    run pex "$root/scripts/run_pex.sh" "$cell" "${skip_lvs[@]}"
    d=$(grep -E 'pex_netlist: .*(rc|c)\.spice' "$log/pex.log" | sed 's/^.*netlist\/[^/]*\/pex\///' | tr '\n' ';' | cut -c1-200)
    case $RC in 0) record pex pass "$SECS" "$d";; *) record pex error "$SECS" "rc=$RC, see $log/pex.log";; esac
  fi
fi

# ---- post-layout CACE + comparison
if has_stage post; then
  variants=""; case "$netlist" in both) variants="c rc";; c|rc) variants="$netlist";; esac
  if [ -z "$gds" ] || [ ! -f "$gds" ]; then record post skip 0 "no layout"
  elif [ -z "$yaml" ] || [ ! -f "$yaml" ]; then record post skip 0 "no CACE datasheet"
  elif [ -n "$(status_of pex)" ] && [ "$(status_of pex)" != pass ]; then record post blocked 0 "pex stage: $(status_of pex)"
  elif [ -z "$(status_of pex)" ] && [ ! -f "$root/netlist/$cell/pex/$cell.c.spice" ]; then record post blocked 0 "no extraction yet (run the pex stage)"
  else
    for v in $variants; do
      run "post_$v" "$root/scripts/run_postlayout.sh" "$cell" --profile "$profile" --netlist "$v"
      d=$(grep -E '^compare_cace' "$log/post_$v.log" | sed 's/compare_cace: //; s/ ->.*//')
      case $RC in 0) record "post_$v" pass "$SECS" "$d";; 2) record "post_$v" fail "$SECS" "$d; spec failed or errors";; *) record "post_$v" error "$SECS" "rc=$RC, see $log/post_$v.log";; esac
    done
  fi
fi

# ---- images: schematic + layout pictures and their README blocks (always, unless --only restricts the stages, e.g. in CI)
if [ -z "$only" ] && { [ -f "$gds" ] || [ -f "$sch" ]; }; then
  run images python3 -I "$root/scripts/update_images.py" "$cell"
  d=$(grep -E '^images:' "$log/images.log" | tail -1 | sed 's/^images: //')
  case $RC in 0) record images pass "$SECS" "$d";; *) record images error "$SECS" "rc=$RC, see $log/images.log";; esac
fi

# ---- status page
python3 -I - "$root" "$cell" "$profile" "$res" "$gds" "$sch" <<'PY'
import datetime, hashlib, json, os, subprocess, sys
root, cell, profile, res, gds, sch = sys.argv[1:7]
def sha(p):
    return hashlib.sha1(open(p, "rb").read()).hexdigest()[:12] if p and os.path.isfile(p) else None
stages = []
for line in open(res):
    n, s, t, d = line.rstrip("\n").split("\t")
    stages.append(dict(name=n, status=s, seconds=int(t), detail=d))
# a partial run (--stages / --only) updates only the stages it ran; the others keep their last result
now = datetime.datetime.now().isoformat(timespec="seconds")
for s in stages:
    s["at"] = now
old_f = os.path.join(root, "docs", cell, "status.json")
if os.path.isfile(old_f):
    try:
        prev = {s["name"]: s for s in json.load(open(old_f)).get("stages", [])}
        ran = {s["name"] for s in stages}
        stages = [prev[n] for n in prev if n not in ran] + stages
        order = ["cace", "drc", "lvs", "pex", "post_c", "post_rc", "images"]
        stages.sort(key=lambda s: order.index(s["name"]) if s["name"] in order else 99)
    except Exception:
        pass
try:
    commit = subprocess.check_output(["git", "-C", root, "rev-parse", "--short", "HEAD"], text=True).strip()
except Exception:
    commit = None
rel = lambda p: os.path.relpath(p, root) if p else None
info = dict(cell=cell, generated=datetime.datetime.now().isoformat(timespec="seconds"), commit=commit, profile=profile,
            gds=dict(path=rel(gds), sha1=sha(gds)), schematic=dict(path=rel(sch), sha1=sha(sch)), stages=stages,
            postlayout={v: f"docs/{cell}/cace/postlayout{'_rc' if v == 'rc' else ''}.json" for v in ("c", "rc")
                        if os.path.isfile(os.path.join(root, f"docs/{cell}/cace/postlayout{'_rc' if v == 'rc' else ''}.json"))})
os.makedirs(os.path.join(root, "docs", cell), exist_ok=True)
json.dump(info, open(os.path.join(root, "docs", cell, "status.json"), "w"), indent=1)
icon = dict(pass_="✅", fail="❌", error="❗", skip="⏭", blocked="⛔")
md = [f"# {cell}: flow status", "", f"`scripts/flow.sh {cell}` at {info['generated']} (commit {commit}, profile {profile})", "",
      f"layout `{info['gds']['path']}` sha1 `{info['gds']['sha1']}`, schematic `{info['schematic']['path']}` sha1 `{info['schematic']['sha1']}`", "",
      "| Stage | Result | Time | Detail |", "|---|---|---:|---|"]
for s in stages:
    md.append(f"| {s['name']} | {icon.get(s['status'] + ('_' if s['status'] == 'pass' else ''), '')} {s['status']} | {s['seconds']} s | {s['detail']} |")
for v, f in info["postlayout"].items():
    md.append(f"\nSchematic vs post-layout ({'wire C only' if v == 'c' else 'wire R + C'}): [{os.path.basename(f[:-5])}.md](cace/{os.path.basename(f[:-5])}.md)")
open(os.path.join(root, "docs", cell, "status.md"), "w").write("\n".join(md) + "\n")
PY
echo "flow: docs/$cell/status.md"
if grep -qP '\t(error)\t' "$res"; then exit 2; fi
if grep -qP '\t(fail)\t' "$res"; then exit 1; fi
exit 0
