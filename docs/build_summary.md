# Build summary

`scripts/build_all.sh` (fast, CACE profile typ) at 2026-11-04T05:51:14, branch `phase2` commit 8df9d33, 479 s. Logs: `runs/build_all/2026-11-04_054315/`.

## Steps

| Step | Result | Time | Last line |
|---|---|---:|---|
| registry | ✅ ok | 0 s | cellinfo: note: dec2to4: gds xschem/dec2to4/dec2to4.gds does not exist yet |
| export | ✅ ok | 2 s | export_slot_gds: OK |
| flow:ota_cmos5l | ✅ ok | 34 s | flow: docs/ota_cmos5l/status.md |
| flow:instramp_cmos5l | ✅ ok | 38 s | flow: docs/instramp_cmos5l/status.md |
| flow:output_buffer | ✅ ok | 30 s | flow: docs/output_buffer/status.md |
| flow:dec2to4 | ✅ ok | 1 s | flow: docs/dec2to4/status.md |
| flow:gain_ota | ✅ ok | 31 s | flow: docs/gain_ota/status.md |
| flow:gain_network | ✅ ok | 36 s | flow: docs/gain_network/status.md |
| flow:gain_stage | ✅ ok | 38 s | flow: docs/gain_stage/status.md |
| flow:pgia_top | ✅ ok | 93 s | flow: docs/pgia_top/status.md |
| flow:slot9_wrapper | ✅ ok | 123 s | flow: docs/slot9_wrapper/status.md |
| canary | ✅ ok | 51 s | lvs_canary: OK, 4/4 mutations detected |
| images | ⏭ skip | 0 s | --fast |
| reports | ⏭ skip | 0 s | --fast |

## Cells x flow stages (from docs/<cell>/status.json)

| Cell | cace | drc | audit | drc_harness | lvs | deliver | pex | post_c | post_rc | images |
|---|---|---|---|---|---|---|---|---|---|---|
| ota_cmos5l | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| instramp_cmos5l | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| output_buffer | · | ✅ | ✅ | · | ✅ | · | · | · | · | · |
| dec2to4 | · | ⏭ | · | · | · | · | · | · | · | · |
| gain_ota | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| gain_network | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| gain_stage | · | ✅ | ✅ | · | ✅ | · | · | · | · | · |
| pgia_top | ❌ | ✅ | ✅ | · | ✅ | · | · | · | · | ✅ |
| slot9_wrapper | · | ✅ | ✅ | ✅ | ✅ | ✅ | · | · | · | · |
