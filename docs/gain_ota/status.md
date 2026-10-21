# gain_ota: flow status

`scripts/flow.sh gain_ota` at 2026-10-21T20:35:41 (commit be66ad2, profile typ)

layout `gds/gain_ota/gain_ota.gds` sha1 `e2632fd500b4`, schematic `xschem/gain_ota/gain_ota.sch` sha1 `d747b5e7626f`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 0 s | reused RUN_2026-10-21_07-18-34: 44 rows, 0 failing |
| drc | ✅ pass | 20 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| pex | ✅ pass | 14 s | gain_ota.c.spice: ports VDD V_inp V_inn V_out I_bias VSS; M=57, Rpoly=2, Rext=0, Cdev=5, Cext=182;gain_ota.rc.spice: ports VDD V_inp V_inn V_out I_bias VSS; X=59, R=2414, C=582, Cdev=5; |
| post_c | ✅ pass | 15 s | 41 parameters with a % delta, 27 flagged |
| post_rc | ✅ pass | 39 s | 41 parameters with a % delta, 22 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⏭ skip | 0 s | no layout |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
