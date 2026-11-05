v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {central_bias: one input current (ibias0, SOURCED into IB_IN by the harness) -> the four bias currents of pgia_top by ratio (calibrated: the mirrors deliver ~1.26x their drawn ratio).
NMOS reference MN_R (m=10). Sinks (pins of PMOS-diode references): IB_IA m=33, IB_BUF m=11. MN_P (m=8) pulls the PMOS reference MP_R (m=10) whose m=9 mirrors SOURCE IB_G1 / IB_G2 (pins of NMOS-diode references).
With ibias0 = 1.0 uA: IA 4.4 uA, buffer 1.47 uA, stages 1.08 uA each (targets 4.2 / 1.4 / 1.0 / 1.0). scripts/verify_central_bias.py proves the whole chip with it.} 0 -250 0 0 0.3 0.3 {}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 0 0 0 {name=MN_R
l=2u
w=1u
ng=1
m=10
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 20 -30 1 0 {name=l_MN_R_t lab=IB_IN}
C {lab_wire.sym} 20 30 3 0 {name=l_MN_R_b lab=AVSS}
C {lab_wire.sym} -20 0 2 0 {name=l_MN_R_g lab=IB_IN}
C {lab_wire.sym} 20 0 0 0 {name=l_MN_R_bulk lab=AVSS}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 120 0 0 0 {name=MN_IA
l=2u
w=1u
ng=1
m=33
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 140 -30 1 0 {name=l_MN_IA_t lab=IB_IA}
C {lab_wire.sym} 140 30 3 0 {name=l_MN_IA_b lab=AVSS}
C {lab_wire.sym} 100 0 2 0 {name=l_MN_IA_g lab=IB_IN}
C {lab_wire.sym} 140 0 0 0 {name=l_MN_IA_bulk lab=AVSS}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 240 0 0 0 {name=MN_BUF
l=2u
w=1u
ng=1
m=11
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 260 -30 1 0 {name=l_MN_BUF_t lab=IB_BUF}
C {lab_wire.sym} 260 30 3 0 {name=l_MN_BUF_b lab=AVSS}
C {lab_wire.sym} 220 0 2 0 {name=l_MN_BUF_g lab=IB_IN}
C {lab_wire.sym} 260 0 0 0 {name=l_MN_BUF_bulk lab=AVSS}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 360 0 0 0 {name=MN_P
l=2u
w=1u
ng=1
m=8
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 380 -30 1 0 {name=l_MN_P_t lab=n_pref}
C {lab_wire.sym} 380 30 3 0 {name=l_MN_P_b lab=AVSS}
C {lab_wire.sym} 340 0 2 0 {name=l_MN_P_g lab=IB_IN}
C {lab_wire.sym} 380 0 0 0 {name=l_MN_P_bulk lab=AVSS}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 360 -300 0 0 {name=MP_R
l=2u
w=2u
ng=1
m=10
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 380 -330 1 0 {name=l_MP_R_t lab=AVDD}
C {lab_wire.sym} 380 -270 3 0 {name=l_MP_R_b lab=n_pref}
C {lab_wire.sym} 340 -300 2 0 {name=l_MP_R_g lab=n_pref}
C {lab_wire.sym} 380 -300 0 0 {name=l_MP_R_bulk lab=AVDD}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 480 -300 0 0 {name=MP_G1
l=2u
w=2u
ng=1
m=9
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 500 -330 1 0 {name=l_MP_G1_t lab=AVDD}
C {lab_wire.sym} 500 -270 3 0 {name=l_MP_G1_b lab=IB_G1}
C {lab_wire.sym} 460 -300 2 0 {name=l_MP_G1_g lab=n_pref}
C {lab_wire.sym} 500 -300 0 0 {name=l_MP_G1_bulk lab=AVDD}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 600 -300 0 0 {name=MP_G2
l=2u
w=2u
ng=1
m=9
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 620 -330 1 0 {name=l_MP_G2_t lab=AVDD}
C {lab_wire.sym} 620 -270 3 0 {name=l_MP_G2_b lab=IB_G2}
C {lab_wire.sym} 580 -300 2 0 {name=l_MP_G2_g lab=n_pref}
C {lab_wire.sym} 620 -300 0 0 {name=l_MP_G2_bulk lab=AVDD}
C {iopin.sym} -120 0 2 0 {name=p_in lab=IB_IN}
C {iopin.sym} 760 -120 0 0 {name=p_ia lab=IB_IA}
C {iopin.sym} 760 -80 0 0 {name=p_buf lab=IB_BUF}
C {iopin.sym} 760 -40 0 0 {name=p_g1 lab=IB_G1}
C {iopin.sym} 760 0 0 0 {name=p_g2 lab=IB_G2}
C {iopin.sym} 300 -380 1 0 {name=p_vdd lab=AVDD}
C {iopin.sym} 300 120 3 0 {name=p_vss lab=AVSS}
