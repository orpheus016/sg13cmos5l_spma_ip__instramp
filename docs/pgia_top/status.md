# pgia_top: flow status

`scripts/flow.sh pgia_top` at 2026-11-05T19:03:14 (commit b495d99, profile typ)

layout `gds/pgia_top/pgia_top.gds` sha1 `9f7959ad6ff0`, schematic `xschem/pgia_top/pgia_top.sch` sha1 `15d9c1d818e3`

| Stage | Result | Time | Detail |
|---|---|---:|---|
| cace | ✅ pass | 401 s | /foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_18-55-13: 17 rows |
| drc | ✅ pass | 67 s | main : 0 items [ok];antenna : 0 items [ok];density : 7 items [info, chip-level]; |
| audit | ✅ pass | 0 s |  all device Activ within the tie distance, every NWell tied; 44 p+/n+ abutment site(s), all in the accepted baseline; |
| lvs | ✅ pass | 13 s | RESULT: MATCH |
| pex | ✅ pass | 216 s | pgia_top.c.spice: ports VINP VINN VCM gain_sel[0] gain_sel[1] gain_sel[2] gain_sel[3] VOUT AVDD VPWR IBIAS_IA AVSS VGND; M=686, Rpoly=30, Rext=0, Cdev=46, Cext=2445, D=2, floating=10;pgia_top.rc.spice |
| post_c | ❌ fail | 76 s | 8 parameters with a % delta, 8 flagged; spec failed or errors |
| post_rc | ❌ fail | 436 s | 8 parameters with a % delta, 8 flagged; spec failed or errors |
| images | ✅ pass | 1 s | 0 updated, 5 unchanged, 0 error(s), 0 warning(s) |
| post | ⛔ blocked | 0 s | pex stage: error |

Schematic vs post-layout (wire C only): [postlayout.md](cace/postlayout.md)

Schematic vs post-layout (wire R + C): [postlayout_rc.md](cace/postlayout_rc.md)
