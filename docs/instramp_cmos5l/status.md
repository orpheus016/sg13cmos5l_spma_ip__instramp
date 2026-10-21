# instramp_cmos5l: flow status

`scripts/flow.sh instramp_cmos5l` at 2026-10-21T10:06:21 (commit 2bf6127, profile typ)

layout `gds/pgia_top/instramp_cmos5l.gds` sha1 `50fa4fd017b1`, schematic `xschem/instramp_cmos5l/instramp_cmos5l.sch` sha1 `a36a205bb1f7`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 48 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-10-21_10-03-50: 31 rows |
| drc | ✅ pass | 45 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| lvs | ✅ pass | 11 s | RESULT: MATCH |
| pex | ✅ pass | 13 s | instramp_cmos5l.c.spice: ports VSS VDD IBIAS VINN VOUT VINP CM; M=87, Rpoly=9, Rext=0, Cdev=27, Cext=154;instramp_cmos5l.rc.spice: ports VSS VDD IBIAS VINN VOUT VINP CM; X=96, R=602, C=382, Cdev=27; |
| post_c | ✅ pass | 16 s | 30 parameters with a % delta, 3 flagged |
| post_rc | ✅ pass | 18 s | 30 parameters with a % delta, 7 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
