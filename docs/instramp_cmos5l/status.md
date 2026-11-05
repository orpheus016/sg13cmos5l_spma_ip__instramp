# instramp_cmos5l: flow status

`scripts/flow.sh instramp_cmos5l` at 2026-11-05T21:08:53 (commit a3285dc, profile typ)

layout `gds/pgia_top/instramp_cmos5l.gds` sha1 `50fa4fd017b1`, schematic `xschem/instramp_cmos5l/instramp_cmos5l.sch` sha1 `ce9e7cf4d16b`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 40 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_21-07-40: 38 rows |
| drc | ✅ pass | 27 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; 33 p+/n+ abutment site(s), all in the accepted baseline; |
| lvs | ✅ pass | 6 s | RESULT: MATCH |
| pex | ✅ pass | 9 s | instramp_cmos5l.c.spice: ports VSS VDD IBIAS VINN VOUT VINP CM; M=87, Rpoly=9, Rext=0, Cdev=27, Cext=154, D=0;instramp_cmos5l.rc.spice: ports VSS VDD IBIAS VINN VOUT VINP CM; X=96, R=608, C=382, Cdev= |
| post_c | ✅ pass | 13 s | 37 parameters with a % delta, 4 flagged |
| post_rc | ✅ pass | 11 s | 37 parameters with a % delta, 9 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
