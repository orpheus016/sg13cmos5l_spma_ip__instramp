# Build summary

`scripts/build_all.sh` (full, CACE profile typ) at 2026-11-05T19:06:03, branch `phase2` commit b495d99, 1070 s. Logs: `runs/build_all/2026-11-05_184813/`.

## Steps

| Step | Result | Time | Last line |
|---|---|---:|---|
| registry | ✅ ok | 1 s | cellinfo: note: dec2to4: gds xschem/dec2to4/dec2to4.gds does not exist yet |
| export | ✅ ok | 2 s | export_slot_gds: OK |
| flow:ota_cmos5l | ✅ ok | 23 s | flow: docs/ota_cmos5l/status.md |
| flow:instramp_cmos5l | ✅ ok | 39 s | flow: docs/instramp_cmos5l/status.md |
| flow:output_buffer | ✅ ok | 24 s | flow: docs/output_buffer/status.md |
| flow:dec2to4 | ✅ ok | 0 s | flow: docs/dec2to4/status.md |
| flow:gain_ota | ✅ ok | 28 s | flow: docs/gain_ota/status.md |
| flow:gain_network | ❌ FAIL | 116 s | flow: docs/gain_network/status.md |
| flow:gain_stage | ❌ FAIL | 100 s | flow: docs/gain_stage/status.md |
| flow:central_bias | ✅ ok | 85 s | flow: docs/central_bias/status.md |
| flow:pgia_top | ✅ ok | 482 s | flow: docs/pgia_top/status.md |
| flow:slot9_wrapper | ✅ ok | 103 s | flow: docs/slot9_wrapper/status.md |
| canary | ⏭ skip | 0 s | skipped |
| bias | ⏭ skip | 0 s | skipped |
| images | ✅ ok | 7 s | images: 0 updated, 49 unchanged, 0 error(s), 0 warning(s) |
| reports:cace | ✅ ok | 59 s | report: docs/index.html |
| reports:chip | ✅ ok | 0 s | chip report: docs/index.html |

## Cells x flow stages (from docs/<cell>/status.json)

| Cell | cace | drc | audit | drc_harness | lvs | deliver | pex | post_c | post_rc | images |
|---|---|---|---|---|---|---|---|---|---|---|
| ota_cmos5l | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| instramp_cmos5l | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| output_buffer | · | ✅ | ✅ | · | ✅ | · | · | · | · | ✅ |
| dec2to4 | · | ⏭ | · | · | · | · | · | · | · | · |
| gain_ota | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| gain_network | ❌ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| gain_stage | ❌ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| central_bias | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ✅ | ✅ | ✅ |
| pgia_top | ✅ | ✅ | ✅ | · | ✅ | · | ✅ | ❌ | ❌ | ✅ |
| slot9_wrapper | · | ✅ | ✅ | ✅ | ✅ | ✅ | · | · | · | ✅ |
