#!/usr/bin/env bash
# Dry run of what the Chipalooza harness does with our slot_9.gds:  scripts/harness_trial.sh [--harness <dir>] [--keep]
#
#   --harness <dir>  the harness repository (default: ../sg13cmos5l_ocd_chipalooza, or $HARNESS_DIR)
#   --keep           keep the sandbox (runs/harness_trial/) for inspection; it is always rebuilt on the next run
#
# Steps, in a throw-away copy of the harness (its own checkout is never touched):
#   1. scripts/export_slot_gds.py --check          gds/slot_9.gds exists, has the top cell slot_9, is current
#   2. harness scripts/get_project_gds.sh 9        finds slot_9.gds the way `make projects-gds` does (final/gds, gds, anywhere), checks the
#                                                  cell name, asks Magic where slot 9 sits in the chip and writes scripts/user_projects.tcl
#   3. Magic with the commands of that Tcl         `gds readonly true; gds noduplicates true; gds read ...slot_9.gds; getcell slot_9 ...;
#                                                  gds write` : the file is accepted by Magic (cell names with $ included)
#   4. KLayout                                     the geometry Magic writes back, moved to the slot origin, equals gds/slot_9.gds on every layer
# What it does not do: the full chip build (`make gds-prefill`, fill, final DRC) and the harness top-level LVS (upstream: still failing).
# Exit: 0 ok, 1 a step failed, 2 cannot run (harness repo, magic, klayout or the output of the export missing).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PDK=ihp-sg13cmos5l PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
harness="${HARNESS_DIR:-$root/../sg13cmos5l_ocd_chipalooza}"; keep=""
while [ $# -gt 0 ]; do
  case "$1" in --harness) harness="$2"; shift 2;; --keep) keep=1; shift;; *) echo "harness_trial.sh: unknown option $1"; exit 2;; esac
done
[ -f "$harness/scripts/get_project_gds.sh" ] || { echo "harness_trial.sh: harness repository not found at $harness (--harness <dir>)"; exit 2; }
command -v magic >/dev/null || { echo "harness_trial.sh: magic not found"; exit 2; }
fail() { echo "harness_trial.sh: FAILED - $*"; exit 1; }

# 1. our side
python3 -I "$root/scripts/export_slot_gds.py" --check || fail "slot_9.gds is missing or stale (scripts/export_slot_gds.py)"

# 2. sandbox = copy of the harness without .git, as a fresh git repo (the harness scripts insist on one), our gds/ as dependencies/slot_9
sb="$root/runs/harness_trial"; rm -rf "$sb"; mkdir -p "$sb"
( cd "$harness" && tar --exclude=.git -cf - . ) | tar -xf - -C "$sb"
mkdir -p "$sb/dependencies/slot_9"
( cd "$root" && tar --exclude=backups --exclude='*run*' --exclude='*.lyrdb' -cf - gds ) | tar -xf - -C "$sb/dependencies/slot_9"
( cd "$sb" && git init -q . )
trap '[ -n "$keep" ] || rm -rf "$sb"' EXIT
out="$( cd "$sb" && scripts/get_project_gds.sh 9 2>&1 )"; rc=$?
echo "$out" | sed 's/^/  harness: /'
[ $rc -eq 0 ] || fail "get_project_gds.sh exited with $rc"
echo "$out" | grep -q "ERROR" && fail "get_project_gds.sh reported an ERROR"
echo "$out" | grep -q "^slot_9: .*slot_9.gds" || fail "the harness did not find slot_9.gds"
read -r px py < <(echo "$out" | sed -n 's/.*place at \([0-9.]*\) \([0-9.]*\).*/\1 \2/p' | head -1)
[ -n "${px:-}" ] || fail "no placement coordinates in the harness output"

# 3. Magic, the way scripts/user_projects.tcl does it
( cd "$sb/magic" && magic -dnull -noconsole -rcfile "$PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc" >"$sb/magic.log" 2>&1 <<EOF
drc off
crashbackups stop
locking disable
units microns
gds readonly true
gds noduplicates true
gds read ../dependencies/slot_9/gds/slot_9.gds
if {[lsearch [cellname list allcells] slot_9] < 0} { puts "TRIAL_ERROR no cell slot_9"; quit -noprompt }
load slot_9
property GDS_END ""
property GDS_START 0
load trial_top
getcell slot_9 child 0 0 parent $px $py
gds write trial_top
puts "TRIAL_WRITTEN"
quit -noprompt
EOF
)
grep -q "TRIAL_WRITTEN" "$sb/magic.log" && [ -f "$sb/magic/trial_top.gds" ] || { tail -5 "$sb/magic.log"; fail "Magic could not read/place/write slot_9.gds"; }
echo "  magic: read slot_9.gds read-only, placed at $px $py, wrote trial_top.gds ($(grep -c '^Reading' "$sb/magic.log") cells read)"

# 4. geometry after the round trip
python3 -I - "$sb/magic/trial_top.gds" "$root/gds/slot_9.gds" <<'PY' || fail "geometry changed in the Magic round trip"
import sys
import klayout.db as db
t = db.Layout(); t.read(sys.argv[1]); s = db.Layout(); s.read(sys.argv[2])
tt = t.cell("trial_top"); st = s.top_cells()[0]
inst = list(tt.each_inst())
if len(inst) != 1 or t.cell(inst[0].cell_index).name != "slot_9":
    sys.exit("trial_top does not contain exactly one instance of slot_9")
off = inst[0].trans.disp
bad = {}
for li in s.layer_indices():
    i = s.get_info(li)
    rs = db.Region(st.begin_shapes_rec(li)); rs.merge()
    lt = t.find_layer(i.layer, i.datatype)
    rt = db.Region(tt.begin_shapes_rec(lt)) if lt is not None else db.Region()
    rt.merge(); rt = rt.moved(-off.x, -off.y)
    x = rs ^ rt
    if not x.is_empty():
        bad[f"{i.layer}/{i.datatype}"] = round(x.area() / 1e6, 3)
if bad:
    sys.exit("layers that differ after Magic (um2): " + str(bad))
print(f"  klayout: geometry identical to gds/slot_9.gds on all {s.layers()} layers")
PY
echo "harness_trial.sh: OK (the harness finds, accepts, places and writes back slot_9.gds)"
exit 0
