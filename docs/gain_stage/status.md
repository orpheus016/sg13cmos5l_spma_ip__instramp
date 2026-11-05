# gain_stage: flow status

`scripts/flow.sh gain_stage` at 2026-11-05T18:53:47 (commit b495d99, profile typ)

layout `gds/gain_stage/gain_stage.gds` sha1 `123812104b49`, schematic `xschem/gain_stage/gain_stage.sch` sha1 `b53a5c981835`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ❌ fail | 69 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_18-52-08: 34 rows, 1 failing |
| drc | ✅ pass | 22 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; no p+/n+ abutment outside standard cells; |
| lvs | ✅ pass | 8 s | RESULT: MATCH |
| pex | ✅ pass | 24 s | gain_stage.c.spice: ports AVDD AVSS IBIAS VIN VCM VOUT s[0] s[1] s[2] s[3] s[4]; M=97, Rpoly=10, Rext=0, Cdev=5, Cext=378, D=1;gain_stage.rc.spice: ports AVDD AVSS IBIAS VIN VCM VOUT s[0] s[1] s[2] s[ |
| post_c | ✅ pass | 11 s | 33 parameters with a % delta, 29 flagged |
| post_rc | ✅ pass | 24 s | 33 parameters with a % delta, 30 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⛔ blocked | 0 s | pex stage: error |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
