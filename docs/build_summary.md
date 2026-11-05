# Build summary

`scripts/build_all.sh` (fast, CACE profile typ) at 2026-11-05T15:50:31, branch `phase2` commit 73a60b6, 296 s. Logs: `runs/build_all/2026-11-05_154535/`.

## Steps

| Step | Result | Time | Last line |
|---|---|---:|---|
| registry | ✅ ok | 0 s | cellinfo: note: dec2to4: gds xschem/dec2to4/dec2to4.gds does not exist yet |
| export | ✅ ok | 2 s | export_slot_gds: OK |
| flow:pgia_top | ✅ ok | 83 s | flow: docs/pgia_top/status.md |
| flow:slot9_wrapper | ✅ ok | 115 s | flow: docs/slot9_wrapper/status.md |
| flow:central_bias | ✅ ok | 18 s | flow: docs/central_bias/status.md |
| canary | ✅ ok | 51 s | lvs_canary: OK, 4/4 mutations detected |
| bias | ✅ ok | 27 s | verify_central_bias: OK |
| images | ⏭ skip | 0 s | --fast |
| reports | ⏭ skip | 0 s | --fast |

## Cells x flow stages (from docs/<cell>/status.json)

| Cell | cace | drc | audit | drc_harness | lvs | deliver | images |
|---|---|---|---|---|---|---|---|
| pgia_top | ❌ | ✅ | ✅ | · | ✅ | · | ✅ |
| slot9_wrapper | · | ✅ | ✅ | ✅ | ✅ | ✅ | · |
| central_bias | · | ✅ | ✅ | · | ✅ | · | ✅ |
