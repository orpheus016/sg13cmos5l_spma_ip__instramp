# output_buffer: flow status

`scripts/flow.sh output_buffer` at 2026-11-05T21:09:22 (commit a3285dc, profile typ)

layout `gds/pgia_top/output_buffer.gds` sha1 `07214218ff5f`, schematic `xschem/output_buffer/output_buffer.sch` sha1 `0847913f87c3`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| drc | ✅ pass | 22 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| audit | ✅ pass | 1 s |  all device Activ within the tie distance, every NWell tied; 11 p+/n+ abutment site(s), all in the accepted baseline; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| images | ✅ pass | 1 s | 2 updated, 3 unchanged, 0 error(s), 0 warning(s) |
