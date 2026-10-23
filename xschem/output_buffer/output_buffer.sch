v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -40 -150 -40 -130 {lab=VDD}
N 0 -150 0 -130 {lab=VSS}
N 40 -150 40 -130 {lab=IBIAS}
N -150 40 -120 40 {lab=VINN}
N 120 0 150 0 {lab=VOUT}
N -120 -40 120 -40 {lab=VOUT}
N 120 -40 120 0 {lab=VOUT}
C {ota_cmos5l.sym} 0 0 0 0 {name=x1}
C {iopin.sym} -40 -150 1 0 {name=p1 lab=VDD}
C {iopin.sym} 0 -150 1 0 {name=p4 lab=VSS}
C {iopin.sym} 40 -150 1 0 {name=p11 lab=IBIAS}
C {iopin.sym} -150 40 2 0 {name=p2 lab=VINN}
C {iopin.sym} 150 0 0 0 {name=p10 lab=VOUT}
C {title.sym} -160 200 0 0 {name=l1 author="Mamank Garox"}
