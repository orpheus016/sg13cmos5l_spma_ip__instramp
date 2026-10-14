#!/usr/bin/env bash
# Interactive HTML report of one cell (or all):  scripts/build_report.sh [cell|all] [--open]
#
# Executes tools/report.ipynb with CELL=<cell> (nbconvert, code hidden) -> docs/<cell>/report.html, a self-contained page (plotly.js
# embedded, works offline). The notebook reads what scripts/flow.sh left behind (docs/<cell>/status.json, runs/RUN_*, runs/pex_cace*,
# docs/<cell>/cace/postlayout*.json) and shows a red banner when the layout or schematic changed after that run.
# `all` builds every cell of cells.yaml that has a CACE datasheet and writes docs/index.html. Needs: jupyter nbconvert, plotly, pandas.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:-all}"; open=""; [ "${2:-}" = "--open" ] && open=1
if [ "$target" = all ]; then
  cells=$(python3 -I "$root/scripts/cellinfo.py" --matrix cace | python3 -I -c 'import json,sys;print(" ".join(json.load(sys.stdin)))')
else cells="$target"; fi
rc=0; built=""
for cell in $cells; do
  out="$root/docs/$cell/report.html"
  # schematic + layout pictures of the cell (the report embeds them); READMEs are not touched here
  python3 -I "$root/scripts/update_images.py" "$cell" --no-readme >"$root/runs/images_$cell.log" 2>&1 || echo "report: update_images.py failed for $cell, see runs/images_$cell.log"
  # nbconvert runs in tools/ (the notebook finds ../scripts); a private HOME/runtime dir keeps jupyter from touching ~/.local
  ( cd "$root/tools" && CELL="$cell" jupyter nbconvert --to html --execute --no-input --ExecutePreprocessor.timeout=300 \
      --output-dir "$root/docs/$cell" --output report report.ipynb ) >"$root/runs/report_$cell.log" 2>&1
  if [ -f "$out" ]; then echo "report: $out ($(du -h "$out" | cut -f1))"; built="$built $cell"
  else echo "report: $cell FAILED, see runs/report_$cell.log"; tail -5 "$root/runs/report_$cell.log"; rc=1; fi
done
if [ "$target" = all ] && [ -n "$built" ]; then
  python3 -I - "$root" $built <<'PY'
import json, os, sys
root, cells = sys.argv[1], sys.argv[2:]
rows = []
for c in cells:
    f = os.path.join(root, "docs", c, "status.json")
    st = json.load(open(f)) if os.path.isfile(f) else None
    stages = " ".join(f"{s['name']}:{s['status']}" for s in st["stages"]) if st else "no flow run"
    rows.append(f"<tr><td><a href='{c}/report.html'>{c}</a></td><td>{st['generated'] if st else ''}</td><td>{stages}</td></tr>")
open(os.path.join(root, "docs", "index.html"), "w").write(
    "<!doctype html><meta charset=utf-8><title>Cell reports</title><style>body{font:15px system-ui;margin:2rem auto;max-width:60rem;padding:0 1rem}"
    "td,th{padding:.3rem .8rem;text-align:left}</style><h1>Cell reports</h1><table><tr><th>Cell</th><th>Flow run</th><th>Stages</th></tr>"
    + "".join(rows) + "</table>")
print("report: docs/index.html")
PY
fi
[ -n "$open" ] && [ -f "$root/docs/${cells%% *}/report.html" ] && xdg-open "$root/docs/${cells%% *}/report.html" >/dev/null 2>&1
exit $rc
