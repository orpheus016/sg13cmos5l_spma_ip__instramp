# gain_stage: flow status

`scripts/flow.sh gain_stage` at 2026-11-04T05:46:47 (commit 8df9d33, profile typ)

layout `gds/gain_stage/gain_stage.gds` sha1 `123812104b49`, schematic `xschem/gain_stage/gain_stage.sch` sha1 `b53a5c981835`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| drc | ✅ pass | 33 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; no p+/n+ abutment outside standard cells; |
| lvs | ✅ pass | 5 s | RESULT: MATCH |
