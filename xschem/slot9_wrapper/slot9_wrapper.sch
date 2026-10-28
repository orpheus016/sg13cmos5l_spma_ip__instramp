v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 -10 -360 {}
N 400 -310 500 -310 {lab=s9_an[2]}
N 0 -310 100 -310 {lab=s9_an_1_esd}
N 0 -350 100 -350 {lab=s9_an_0_esd}
N 170 -440 210 -440 {lab=vdd_1v2}
N 210 -500 210 -440 {lab=vdd_1v2}
N 0 -210 100 -210 {lab=dig_in[0]}
N 0 -270 100 -270 {lab=vbias}
N 0 -180 100 -180 {lab=dig_in[1]}
N 0 -150 100 -150 {lab=dig_in[2]}
N 0 -120 100 -120 {lab=dig_in[3]}
N 250 -440 290 -440 {lab=ibias0}
N 290 -500 290 -440 {lab=ibias0}
N 190 -60 230 -60 {lab=vss_1v2}
N 190 -60 190 0 {lab=vss_1v2}
N -270 -310 -170 -310 {lab=s9_an_1_esd}
N -270 -350 -170 -350 {lab=s9_an_0_esd}
N -270 -210 -170 -210 {lab=dig_in[0]}
N -270 -270 -170 -270 {lab=vbias}
N -270 -180 -170 -180 {lab=dig_in[1]}
N -270 -150 -170 -150 {lab=dig_in[2]}
N -270 -120 -170 -120 {lab=dig_in[3]}
N -270 -460 -170 -460 {lab=vss_1v2}
N -270 -500 -170 -500 {lab=vdd_1v2}
N -270 -420 -170 -420 {lab=ibias0}
N -270 -540 -170 -540 {lab=s9_an[2]}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/pgia_top/pgia_top.sym} 250 -250 0 0 {name=x1}
C {lab_wire.sym} 500 -310 0 0 {name=l_ia_vdd1 lab=s9_an[2]}
C {lab_wire.sym} 0 -310 2 0 {name=l_ia_vdd2 lab=s9_an_1_esd}
C {lab_wire.sym} 0 -350 2 0 {name=l_ia_vdd3 lab=s9_an_0_esd}
C {lab_wire.sym} 210 -500 0 0 {name=l_ia_vdd4 lab=vdd_1v2}
C {lab_wire.sym} 0 -210 2 0 {name=l_ia_vdd5 lab=dig_in[0]}
C {lab_wire.sym} 0 -270 2 0 {name=l_ia_vdd6 lab=vbias}
C {lab_wire.sym} 0 -180 2 0 {name=l_ia_vdd7 lab=dig_in[1]}
C {lab_wire.sym} 0 -150 2 0 {name=l_ia_vdd8 lab=dig_in[2]}
C {lab_wire.sym} 0 -120 2 0 {name=l_ia_vdd9 lab=dig_in[3]}
C {lab_wire.sym} 290 -500 0 0 {name=l_ia_vdd10 lab=ibias0}
C {lab_wire.sym} 190 0 2 0 {name=l_ia_vdd11 lab=vss_1v2}
C {lab_wire.sym} -170 -310 2 1 {name=l_ia_vdd12 lab=s9_an_1_esd}
C {lab_wire.sym} -170 -350 2 1 {name=l_ia_vdd13 lab=s9_an_0_esd}
C {lab_wire.sym} -170 -210 2 1 {name=l_ia_vdd14 lab=dig_in[0]}
C {lab_wire.sym} -170 -270 2 1 {name=l_ia_vdd15 lab=vbias}
C {lab_wire.sym} -170 -180 2 1 {name=l_ia_vdd16 lab=dig_in[1]}
C {lab_wire.sym} -170 -150 2 1 {name=l_ia_vdd17 lab=dig_in[2]}
C {lab_wire.sym} -170 -120 2 1 {name=l_ia_vdd18 lab=dig_in[3]}
C {iopin.sym} -270 -350 2 0 {name=p_avdd lab=s9_an_0_esd}
C {iopin.sym} -270 -310 2 0 {name=p_avdd1 lab=s9_an_1_esd}
C {iopin.sym} -270 -270 2 0 {name=p_avdd2 lab=vbias}
C {iopin.sym} -270 -210 2 0 {name=p_avdd3 lab=dig_in[0]}
C {iopin.sym} -270 -180 2 0 {name=p_avdd4 lab=dig_in[1]}
C {iopin.sym} -270 -150 2 0 {name=p_avdd5 lab=dig_in[2]}
C {iopin.sym} -270 -120 2 0 {name=p_avdd6 lab=dig_in[3]}
C {iopin.sym} -270 -500 2 0 {name=p_avdd7 lab=vdd_1v2}
C {iopin.sym} -270 -460 2 0 {name=p_avdd8 lab=vss_1v2}
C {iopin.sym} -270 -420 2 0 {name=p_avdd9 lab=ibias0}
C {lab_wire.sym} -170 -500 0 0 {name=l_ia_vdd22 lab=vdd_1v2}
C {lab_wire.sym} -170 -460 0 0 {name=l_ia_vdd19 lab=vss_1v2}
C {lab_wire.sym} -170 -420 0 0 {name=l_ia_vdd20 lab=ibias0}
C {iopin.sym} -270 -540 2 0 {name=p_avdd10 lab=s9_an[2]}
C {lab_wire.sym} -170 -540 0 0 {name=l_ia_vdd23 lab=s9_an[2]}
