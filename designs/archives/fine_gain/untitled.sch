v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -0 -190 -0 -150 {lab=Vcon}
N 0 140 0 190 {lab=Vcon_inv}
N -130 -0 -90 -0 {lab=IN}
N -90 -110 -90 -0 {lab=IN}
N -40 -110 -30 -110 {lab=IN}
N 0 -110 0 -100 {lab=IN}
N -40 -100 -0 -100 {lab=IN}
N -40 -110 -40 -100 {lab=IN}
N -90 -110 -40 -110 {lab=IN}
N -90 -0 -90 100 {lab=IN}
N -90 100 -30 100 {lab=IN}
N -0 90 -0 100 {lab=OUT}
N -0 90 40 90 {lab=OUT}
N 40 90 40 100 {lab=OUT}
N 30 100 40 100 {lab=OUT}
N 30 -110 80 -110 {lab=OUT}
N 80 -0 80 100 {lab=OUT}
N 40 100 80 100 {lab=OUT}
N 80 -0 150 -0 {lab=OUT}
N 80 -110 80 -0 {lab=OUT}
C {ipin.sym} -130 0 0 0 {name=p8 lab=IN}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 -130 1 0 {name=M1
l=\{L_INV_N\}
w=\{W_INV_N\}
ng=\{NG_INV_N\}
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 0 120 3 0 {name=M2
l=\{L_INV_P\}
w=\{W_INV_P\}
ng=\{NG_INV_P\}
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {opin.sym} 150 0 0 0 {name=p1 lab=OUT}
C {ipin.sym} 0 -190 0 0 {name=p2 lab=Vcon}
C {ipin.sym} 0 190 0 0 {name=p3 lab=Vcon_inv}
