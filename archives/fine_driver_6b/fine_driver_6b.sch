v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 150 -50 170 -50 {lab=S4}
N 360 -50 380 -50 {lab=S4B}
N 50 -50 70 -50 {lab=D4}
N 260 -50 280 -50 {lab=D4}
N 150 10 170 10 {lab=S5}
N 360 10 380 10 {lab=S5B}
N 50 10 70 10 {lab=D5}
N 260 10 280 10 {lab=D5}
N 150 70 170 70 {lab=S6}
N 360 70 380 70 {lab=S6B}
N 50 70 70 70 {lab=D6}
N 260 70 280 70 {lab=D6}
N 150 130 170 130 {lab=S7}
N 360 130 380 130 {lab=S7B}
N 50 130 70 130 {lab=D7}
N 260 130 280 130 {lab=D7}
N 150 190 170 190 {lab=S8}
N 360 190 380 190 {lab=S8B}
N 50 190 70 190 {lab=D8}
N 260 190 280 190 {lab=D8}
N 150 250 170 250 {lab=S9}
N 360 250 380 250 {lab=S9B}
N 50 250 70 250 {lab=D9}
N 260 250 280 250 {lab=D9}
N -40 -50 -20 -50 {lab=D4}
N -40 10 -20 10 {lab=D5}
N -40 70 -20 70 {lab=D6}
N -40 130 -20 130 {lab=D7}
N -40 190 -20 190 {lab=D8}
N -40 250 -20 250 {lab=D9}
C {ipin.sym} -40 -50 0 0 {name=p1 lab=D4}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 -50 0 0 {name=x1 VDD=VDD VSS=VSS}
C {opin.sym} 170 -50 0 0 {name=p7 lab=S4}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 -50 0 0 {name=x2 VDD=VDD VSS=VSS}
C {opin.sym} 380 -50 0 0 {name=p8 lab=S4B}
C {iopin.sym} 100 -160 0 0 {name=p9 lab=VDD}
C {iopin.sym} 100 -140 0 0 {name=p10 lab=VSS}
C {ipin.sym} -40 10 0 0 {name=p2 lab=D5}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 10 0 0 {name=x3 VDD=VDD VSS=VSS}
C {opin.sym} 170 10 0 0 {name=p3 lab=S5}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 10 0 0 {name=x4 VDD=VDD VSS=VSS}
C {opin.sym} 380 10 0 0 {name=p4 lab=S5B}
C {ipin.sym} -40 70 0 0 {name=p5 lab=D6}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 70 0 0 {name=x5 VDD=VDD VSS=VSS}
C {opin.sym} 170 70 0 0 {name=p6 lab=S6}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 70 0 0 {name=x6 VDD=VDD VSS=VSS}
C {opin.sym} 380 70 0 0 {name=p11 lab=S6B}
C {ipin.sym} -40 130 0 0 {name=p12 lab=D7}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 130 0 0 {name=x7 VDD=VDD VSS=VSS}
C {opin.sym} 170 130 0 0 {name=p13 lab=S7}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 130 0 0 {name=x8 VDD=VDD VSS=VSS}
C {opin.sym} 380 130 0 0 {name=p14 lab=S7B}
C {ipin.sym} -40 190 0 0 {name=p15 lab=D8}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 190 0 0 {name=x9 VDD=VDD VSS=VSS}
C {opin.sym} 170 190 0 0 {name=p16 lab=S8}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 190 0 0 {name=x10 VDD=VDD VSS=VSS}
C {opin.sym} 380 190 0 0 {name=p17 lab=S8B}
C {ipin.sym} -40 250 0 0 {name=p18 lab=D9}
C {sg13cmos5l_stdcells/sg13cmos5l_buf_1.sym} 110 250 0 0 {name=x11 VDD=VDD VSS=VSS}
C {opin.sym} 170 250 0 0 {name=p19 lab=S9}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 320 250 0 0 {name=x12 VDD=VDD VSS=VSS}
C {opin.sym} 380 250 0 0 {name=p20 lab=S9B}
C {lab_wire.sym} -20 -50 0 1 {name=p21 sig_type=std_logic lab=D4}
C {lab_wire.sym} -20 10 0 1 {name=p22 sig_type=std_logic lab=D5}
C {lab_wire.sym} -20 70 0 1 {name=p23 sig_type=std_logic lab=D6}
C {lab_wire.sym} -20 130 0 1 {name=p24 sig_type=std_logic lab=D7}
C {lab_wire.sym} -20 190 0 1 {name=p25 sig_type=std_logic lab=D8}
C {lab_wire.sym} -20 250 0 1 {name=p26 sig_type=std_logic lab=D9}
C {lab_wire.sym} 50 -50 0 0 {name=p27 sig_type=std_logic lab=D4}
C {lab_wire.sym} 50 10 0 0 {name=p28 sig_type=std_logic lab=D5}
C {lab_wire.sym} 50 70 0 0 {name=p29 sig_type=std_logic lab=D6}
C {lab_wire.sym} 50 130 0 0 {name=p30 sig_type=std_logic lab=D7}
C {lab_wire.sym} 50 190 0 0 {name=p31 sig_type=std_logic lab=D8}
C {lab_wire.sym} 50 250 0 0 {name=p32 sig_type=std_logic lab=D9}
C {lab_wire.sym} 260 -50 0 0 {name=p33 sig_type=std_logic lab=D4}
C {lab_wire.sym} 260 10 0 0 {name=p34 sig_type=std_logic lab=D5}
C {lab_wire.sym} 260 70 0 0 {name=p35 sig_type=std_logic lab=D6}
C {lab_wire.sym} 260 130 0 0 {name=p36 sig_type=std_logic lab=D7}
C {lab_wire.sym} 260 190 0 0 {name=p37 sig_type=std_logic lab=D8}
C {lab_wire.sym} 260 250 0 0 {name=p38 sig_type=std_logic lab=D9}
C {title.sym} -240 320 0 0 {name=l1 author="Rafi Ananta Alden"}
