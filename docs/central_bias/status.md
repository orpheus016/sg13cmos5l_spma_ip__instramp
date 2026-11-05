# central_bias: flow status

`scripts/flow.sh central_bias` at 2026-11-05T15:49:13 (commit 73a60b6, profile typ)

layout `gds/central_bias/central_bias.gds` sha1 `383b9226c237`, schematic `xschem/central_bias/central_bias.sch` sha1 `3440a6dc3269`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| drc | ✅ pass | 13 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; no p+/n+ abutment outside standard cells; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| images | ✅ pass | 1 s | 6 updated, 0 unchanged, 0 error(s), 0 warning(s) |
