v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {iopin.sym} -300 -150 0 0 {name=p_avdd lab=AVDD}
C {iopin.sym} -300 -120 0 0 {name=p_avss lab=AVSS}
C {ipin.sym} -300 -90 0 0 {name=p_ibias lab=IBIAS}
C {ipin.sym} -300 -50 0 0 {name=p_vin lab=VIN}
C {ipin.sym} -300 -20 0 0 {name=p_vcm lab=VCM}
C {opin.sym} 450 -140 0 0 {name=p_vout lab=VOUT}
C {ipin.sym} -300 30 0 0 {name=p_s0 lab=s[0]}
C {ipin.sym} -300 60 0 0 {name=p_s1 lab=s[1]}
C {ipin.sym} -300 90 0 0 {name=p_s2 lab=s[2]}
C {ipin.sym} -300 120 0 0 {name=p_s3 lab=s[3]}
C {ipin.sym} -300 150 0 0 {name=p_s4 lab=s[4]}
C {sg13cmos5l_stdcells/sg13cmos5l_nor3_1.sym} -100 50 0 0 {name=x_nor3 VDD=AVDD VSS=AVSS prefix=sg13cmos5l_}
N -160 10 -140 10 {lab=s[0]}
C {lab_wire.sym} -160 10 0 0 {name=l_s0 lab=s[0]}
N -160 50 -140 50 {lab=s[1]}
C {lab_wire.sym} -160 50 0 0 {name=l_s1 lab=s[1]}
N -160 90 -140 90 {lab=s[2]}
C {lab_wire.sym} -160 90 0 0 {name=l_s2 lab=s[2]}
N -40 50 -20 50 {lab=nor3_out}
C {lab_wire.sym} -20 50 2 0 {name=l_n3 lab=nor3_out}
C {sg13cmos5l_stdcells/sg13cmos5l_nor2_1.sym} -100 170 0 0 {name=x_nor2 VDD=AVDD VSS=AVSS prefix=sg13cmos5l_}
N -160 150 -140 150 {lab=s[3]}
C {lab_wire.sym} -160 150 0 0 {name=l_s3 lab=s[3]}
N -160 190 -140 190 {lab=s[4]}
C {lab_wire.sym} -160 190 0 0 {name=l_s4 lab=s[4]}
N -40 170 -20 170 {lab=nor2_out}
C {lab_wire.sym} -20 170 2 0 {name=l_n2 lab=nor2_out}
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 50 110 0 0 {name=x_and2 VDD=AVDD VSS=AVSS prefix=sg13cmos5l_}
N -10 90 10 90 {lab=nor3_out}
C {lab_wire.sym} -10 90 0 0 {name=l_a1 lab=nor3_out}
N -10 130 10 130 {lab=nor2_out}
C {lab_wire.sym} -10 130 0 0 {name=l_a2 lab=nor2_out}
N 110 110 130 110 {lab=S0}
C {lab_wire.sym} 130 110 2 0 {name=l_s0_out lab=S0}
C {gain_network.sym} 250 0 0 0 {name=x_core}
N 260 -80 260 -60 {lab=S0}
C {lab_wire.sym} 260 -80 1 0 {name=l_g_s0 lab=S0}
N 240 -80 240 -60 {lab=s[0]}
C {lab_wire.sym} 240 -80 1 0 {name=l_g_s1 lab=s[0]}
N 220 -80 220 -60 {lab=s[1]}
C {lab_wire.sym} 220 -80 1 0 {name=l_g_s2 lab=s[1]}
N 200 -80 200 -60 {lab=s[2]}
C {lab_wire.sym} 200 -80 1 0 {name=l_g_s3 lab=s[2]}
N 180 -80 180 -60 {lab=s[3]}
C {lab_wire.sym} 180 -80 1 0 {name=l_g_s4 lab=s[3]}
N 160 -80 160 -60 {lab=s[4]}
C {lab_wire.sym} 160 -80 1 0 {name=l_g_s5 lab=s[4]}
N 280 -80 280 -60 {lab=AVSS}
C {lab_wire.sym} 280 -80 1 0 {name=l_g_avss lab=AVSS}
N 230 -210 230 -190 {lab=AVDD}
C {lab_wire.sym} 230 -210 1 0 {name=l_g_avdd lab=AVDD}
N 210 -210 210 -190 {lab=IBIAS}
C {lab_wire.sym} 210 -210 1 0 {name=l_g_ibias lab=IBIAS}
N 80 -150 100 -150 {lab=VIN}
C {lab_wire.sym} 80 -150 0 0 {name=l_g_vin lab=VIN}
N 80 -130 100 -130 {lab=VCM}
C {lab_wire.sym} 80 -130 0 0 {name=l_g_vcm lab=VCM}
N 340 -140 360 -140 {lab=VOUT}
C {lab_wire.sym} 360 -140 2 0 {name=l_g_vout lab=VOUT}
C {title.sym} -100 300 0 0 {name=l_title author="SPMA Team"}
