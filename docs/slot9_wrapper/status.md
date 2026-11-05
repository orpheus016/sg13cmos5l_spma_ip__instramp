# slot9_wrapper: flow status

`scripts/flow.sh slot9_wrapper` at 2026-11-05T12:48:37 (commit b2b1d75, profile typ)

layout `gds/slot9_wrapper/slot9_wrapper.gds` sha1 `7920e75c4181`, schematic `xschem/slot9_wrapper/slot9_wrapper.sch` sha1 `3408a0a99211`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| drc | ✅ pass | 96 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 1 s |  all device Activ within the tie distance, every NWell tied; 44 p+/n+ abutment site(s), all in the accepted baseline; |
| drc_harness | ✅ pass | 17 s | 0 violations |
| lvs | ✅ pass | 15 s | RESULT: MATCH |
| deliver | ✅ pass | 13 s | harness_trial.sh: OK (the harness finds, accepts, places and writes back slot_9.gds); |
