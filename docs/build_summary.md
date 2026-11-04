# Build summary

`scripts/build_all.sh` (fast, CACE profile typ) at 2026-11-04T05:28:08, branch `phase2` commit 0f10340, 214 s. Logs: `runs/build_all/2026-11-04_052434/`.

## Steps

| Step | Result | Time | Last line |
|---|---|---:|---|
| registry | ✅ ok | 0 s | cellinfo: note: dec2to4: gds xschem/dec2to4/dec2to4.gds does not exist yet |
| export | ⏭ skip | 0 s | skipped |
| flow:pgia_top | ✅ ok | 89 s | flow: docs/pgia_top/status.md |
| flow:slot9_wrapper | ✅ ok | 125 s | flow: docs/slot9_wrapper/status.md |
| canary | ⏭ skip | 0 s | skipped |
| images | ⏭ skip | 0 s | --fast |
| reports | ⏭ skip | 0 s | --fast |

## Cells x flow stages (from docs/<cell>/status.json)

| Cell | drc | audit | drc_harness | lvs | deliver |
|---|---|---|---|---|---|
| pgia_top | ✅ | ✅ | · | ✅ | · |
| slot9_wrapper | ✅ | ✅ | ✅ | ✅ | ✅ |
