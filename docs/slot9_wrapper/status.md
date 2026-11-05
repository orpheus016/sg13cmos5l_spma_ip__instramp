# slot9_wrapper: flow status

`scripts/flow.sh slot9_wrapper` at 2026-11-05T19:04:57 (commit b495d99, profile typ)

layout `gds/slot9_wrapper/slot9_wrapper.gds` sha1 `c08e77fa6619`, schematic `xschem/slot9_wrapper/slot9_wrapper.sch` sha1 `3408a0a99211`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| drc | ✅ pass | 65 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; 44 p+/n+ abutment site(s), all in the accepted baseline; |
| drc_harness | ✅ pass | 13 s | 0 violations |
| lvs | ✅ pass | 9 s | RESULT: MATCH |
| deliver | ✅ pass | 14 s | harness_trial.sh: OK (the harness finds, accepts, places and writes back slot_9.gds); |
| images | ✅ pass | 1 s | 0 updated, 4 unchanged, 0 error(s), 0 warning(s) |
