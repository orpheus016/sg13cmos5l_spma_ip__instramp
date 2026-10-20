v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -190 60 -170 60 {lab=A1}
N -70 60 -10 60 {lab=#net1}
N -30 20 -10 20 {lab=#net2}
N -270 20 -250 20 {lab=A0}
N -270 100 -10 100 {lab=A0}
N -270 20 -270 100 {lab=A0}
N -290 20 -270 20 {lab=A0}
N -70 60 -70 140 {lab=#net1}
N -90 60 -70 60 {lab=#net1}
N -70 140 -10 140 {lab=#net1}
N -190 180 -10 180 {lab=A1}
N -190 60 -190 180 {lab=A1}
N -290 60 -190 60 {lab=A1}
N -30 220 -10 220 {lab=#net2}
N -30 20 -30 220 {lab=#net2}
N -170 20 -30 20 {lab=#net2}
N -190 180 -190 260 {lab=A1}
N -190 260 -10 260 {lab=A1}
N -270 100 -270 300 {lab=A0}
N -270 300 -10 300 {lab=A0}
N 110 40 150 40 {lab=Y0}
N 110 120 150 120 {lab=Y1}
N 110 200 150 200 {lab=Y2}
N 110 280 150 280 {lab=Y3}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -210 20 0 0 {name=xinv1 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -130 60 0 0 {name=xinv2 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {ipin.sym} -290 20 0 0 {name=p1 lab=A0}
C {ipin.sym} -290 60 0 0 {name=p2 lab=A1}
C {opin.sym} 150 40 0 0 {name=p3 lab=Y0}
C {opin.sym} 150 120 0 0 {name=p4 lab=Y1}
C {opin.sym} 150 200 0 0 {name=p5 lab=Y2}
C {opin.sym} 150 280 0 0 {name=p6 lab=Y3}
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 50 40 0 0 {name=xand1 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 50 120 0 0 {name=xand2 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 50 200 0 0 {name=xand3 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 50 280 0 0 {name=xand4 VDD=VDD VSS=VSS prefix=sg13cmos5l_ }
C {iopin.sym} 260 20 0 0 {name=p7 lab=VDD}
C {iopin.sym} 260 50 0 0 {name=p8 lab=VSS}
C {title.sym} -420 350 0 0 {name=l1 author="Rafi Ananta Alden"}
C {lab_pin.sym} 260 20 0 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 260 50 0 0 {name=p10 sig_type=std_logic lab=VSS}
