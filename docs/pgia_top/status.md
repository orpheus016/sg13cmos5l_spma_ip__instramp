# pgia_top: flow status

`scripts/flow.sh pgia_top` at 2026-11-04T05:48:20 (commit 8df9d33, profile typ)

layout `gds/pgia_top/pgia_top.gds` sha1 `69e6d0956167`, schematic `xschem/pgia_top/pgia_top.sch` sha1 `e5b4f1fb68ef`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ❌ fail | 415 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-04_05-34-14: 17 rows, 3 failing |
| drc | ✅ pass | 77 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 1 s |  all device Activ within the tie distance, every NWell tied; 44 p+/n+ abutment site(s), all in the accepted baseline; |
| lvs | ✅ pass | 15 s | RESULT: MATCH |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
