# ota_cmos5l: flow status

`scripts/flow.sh ota_cmos5l` at 2026-10-21T10:02:43 (commit 2bf6127, profile typ)

layout `gds/pgia_top/ota_cmos5l.gds` sha1 `d27c68f60025`, schematic `xschem/ota_cmos5l/ota_cmos5l.sch` sha1 `98f97e2e52a6`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 146 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-10-21_09-59-13: 43 rows |
| drc | ✅ pass | 24 s | main : 0 items [ok];antenna : 0 items [ok];density : 6 items [info, chip-level]; |
| lvs | ✅ pass | 5 s | RESULT: MATCH |
| pex | ✅ pass | 4 s | ota_cmos5l.c.spice: ports VSS IBIAS VDD VINN VINP VOUT; M=29, Rpoly=1, Rext=0, Cdev=9, Cext=48;ota_cmos5l.rc.spice: ports VSS IBIAS VDD VINN VINP VOUT; X=30, R=275, C=116, Cdev=9; |
| post_c | ✅ pass | 15 s | 40 parameters with a % delta, 6 flagged |
| post_rc | ✅ pass | 17 s | 40 parameters with a % delta, 21 flagged |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
