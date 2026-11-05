# central_bias: flow status

`scripts/flow.sh central_bias` at 2026-11-05T18:55:12 (commit b495d99, profile typ)

layout `gds/central_bias/central_bias.gds` sha1 `88df2e3b647e`, schematic `xschem/central_bias/central_bias.sch` sha1 `3440a6dc3269`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 67 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_18-53-48: 17 rows |
| drc | ✅ pass | 13 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; no p+/n+ abutment outside standard cells; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| pex | ✅ pass | 13 s | central_bias.c.spice: ports IB_IN IB_IA IB_BUF IB_G1 IB_G2 AVDD AVSS; M=90, Rpoly=0, Rext=0, Cdev=0, Cext=27, D=0;central_bias.rc.spice: ports IB_IN IB_IA IB_BUF IB_G1 IB_G2 AVDD AVSS; X=90, R=488, C= |
| post_c | ✅ pass | 8 s | 8 parameters with a % delta, 0 flagged |
| post_rc | ✅ pass | 5 s | 8 parameters with a % delta, 0 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⛔ blocked | 0 s | pex stage: error |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
