# Build summary

`scripts/build_all.sh` (fast, CACE profile typ) at 2026-11-05T12:49:30, branch `phase2` commit b2b1d75, 315 s. Logs: `runs/build_all/2026-11-05_124415/`.

## Steps

| Step | Result | Time | Last line |
|---|---|---:|---|
| registry | ✅ ok | 0 s | cellinfo: note: dec2to4: gds xschem/dec2to4/dec2to4.gds does not exist yet |
| export | ✅ ok | 2 s | export_slot_gds: OK |
| flow:output_buffer | ✅ ok | 32 s | flow: docs/output_buffer/status.md |
| flow:pgia_top | ✅ ok | 85 s | flow: docs/pgia_top/status.md |
| flow:slot9_wrapper | ✅ ok | 142 s | flow: docs/slot9_wrapper/status.md |
| canary | ✅ ok | 53 s | lvs_canary: OK, 4/4 mutations detected |
| images | ⏭ skip | 0 s | --fast |
| reports | ⏭ skip | 0 s | --fast |

## Cells x flow stages (from docs/<cell>/status.json)

| Cell | cace | drc | audit | drc_harness | lvs | deliver | images |
|---|---|---|---|---|---|---|---|
| output_buffer | · | ✅ | ✅ | · | ✅ | · | · |
| pgia_top | ❌ | ✅ | ✅ | · | ✅ | · | ✅ |
| slot9_wrapper | · | ✅ | ✅ | ✅ | ✅ | ✅ | · |
