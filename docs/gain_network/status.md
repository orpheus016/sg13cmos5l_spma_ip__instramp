# gain_network: flow status

`scripts/flow.sh gain_network` at 2026-11-05T21:11:53 (commit a3285dc, profile typ)

layout `gds/gain_network/gain_network.gds` sha1 `d67f3975e103`, schematic `xschem/gain_network/gain_network.sch` sha1 `8376509a9bdc`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ❌ fail | 90 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_21-09-53: 35 rows, 1 failing |
| drc | ✅ pass | 25 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 1 s |  all device Activ within the tie distance, every NWell tied; no p+/n+ abutment outside standard cells; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| pex | ✅ pass | 22 s | gain_network.c.spice: ports S4 S5 S0 S2 S1 S3 AVDD V_CM V_IN2 V_OUT2 I_BIAS AVSS; M=81, Rpoly=10, Rext=0, Cdev=5, Cext=350, D=1;gain_network.rc.spice: ports S4 S5 S0 S2 S1 S3 AVDD V_CM V_IN2 V_OUT2 I_ |
| post_c | ✅ pass | 12 s | 34 parameters with a % delta, 29 flagged |
| post_rc | ✅ pass | 22 s | 34 parameters with a % delta, 32 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⛔ blocked | 0 s | pex stage: error |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
