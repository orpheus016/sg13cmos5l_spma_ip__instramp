# gain_network: flow status

`scripts/flow.sh gain_network` at 2026-10-22T12:24:59 (commit ab932a5, profile typ)

layout `gds/gain_network/gain_network.gds` sha1 `b8e8aff4495b`, schematic `xschem/gain_network/gain_network.sch` sha1 `3b8e23f86a3c`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 142 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-10-22_12-19-21: 35 rows |
| drc | ✅ pass | 69 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| lvs | ✅ pass | 9 s | RESULT: MATCH |
| pex | ✅ pass | 35 s | gain_network.c.spice: ports S4 S5 S0 S2 S1 S3 AVDD V_CM V_IN2 V_OUT2 I_BIAS AVSS; M=81, Rpoly=9, Rext=0, Cdev=5, Cext=343;gain_network.rc.spice: ports S4 S5 S0 S2 S1 S3 AVDD V_CM V_IN2 V_OUT2 I_BIAS A |
| post_c | ✅ pass | 23 s | 34 parameters with a % delta, 28 flagged |
| post_rc | ✅ pass | 60 s | 34 parameters with a % delta, 31 flagged |
| images | ✅ pass | 2 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⛔ blocked | 0 s | pex stage: blocked |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
