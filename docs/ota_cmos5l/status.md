# ota_cmos5l: flow status

`scripts/flow.sh ota_cmos5l` at 2026-10-15T18:52:17 (commit 7cec125, profile typ)

layout `gds/pgia_top/ota_cmos5l.gds` sha1 `d27c68f60025`, schematic `xschem/ota_cmos5l/ota_cmos5l.sch` sha1 `98f97e2e52a6`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 0 s | reused RUN_2026-10-15_18-48-38: 43 rows, 0 failing |
| drc | ✅ pass | 23 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| lvs | ✅ pass | 4 s | RESULT: MATCH |
| pex | ✅ pass | 5 s | ota_cmos5l.c.spice: ports VSS IBIAS VDD VINN VINP VOUT; M=29, Rpoly=1, Rext=0, Cdev=9, Cext=48;ota_cmos5l.rc.spice: ports VSS IBIAS VDD VINN VINP VOUT; X=30, R=279, C=117, Cdev=9; |
| post_c | ✅ pass | 17 s | 40 parameters with a % delta, 5 flagged |
| post_rc | ✅ pass | 15 s | 40 parameters with a % delta, 7 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
