v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {CMOS Inverter} 240 -540 0 0 0.4 0.4 {}
N 320 -340 320 -320 {lab=VO}
N 320 -440 320 -420 {lab=VDD}
N 320 -260 320 -240 {lab=VSS}
N 320 -340 340 -340 {lab=VO}
N 320 -360 320 -340 {lab=VO}
N 260 -390 280 -390 {lab=VI}
N 260 -340 260 -290 {lab=VI}
N 260 -290 280 -290 {lab=VI}
N 240 -340 260 -340 {lab=VI}
N 260 -390 260 -340 {lab=VI}
N 320 -390 400 -390 {lab=VDD}
N 400 -420 400 -390 {lab=VDD}
N 320 -420 400 -420 {lab=VDD}
N 320 -290 400 -290 {lab=VSS}
N 400 -290 400 -260 {lab=VSS}
N 320 -260 400 -260 {lab=VSS}
C {title.sym} 170 -50 0 0 {name=l1 author="Rafi Ananta Alden"}
C {iopin.sym} 320 -440 3 0 {name=p1 lab=VDD}
C {iopin.sym} 320 -240 1 0 {name=p2 lab=VSS}
C {ipin.sym} 240 -340 0 0 {name=p3 lab=VI}
C {opin.sym} 340 -340 0 0 {name=p4 lab=VO
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 -290 0 0 {name=M1
l=0.13u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 300 -390 0 0 {name=M2
l=0.13u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
