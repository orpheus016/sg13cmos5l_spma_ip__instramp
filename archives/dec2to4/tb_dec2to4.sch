v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -90 -20 -70 -20 {lab=A0}
N -90 40 -70 40 {lab=A1}
N 0 80 0 100 {lab=0}
N 70 -20 270 -20 {lab=Y0}
N 70 -0 210 -0 {lab=Y1}
N 70 20 150 20 {lab=Y2}
N 70 40 90 40 {lab=Y3}
N 90 40 90 60 {lab=Y3}
N 90 40 110 40 {lab=Y3}
N 90 120 90 140 {lab=0}
N 150 20 150 60 {lab=Y2}
N 150 120 150 140 {lab=0}
N 150 20 170 20 {lab=Y2}
N 210 -0 210 60 {lab=Y1}
N 210 120 210 140 {lab=0}
N 210 -0 230 -0 {lab=Y1}
N 270 -20 270 60 {lab=Y0}
N 270 120 270 140 {lab=0}
N 270 -20 290 -20 {lab=Y0}
N 0 -160 0 -140 {lab=0}
N -0 -80 -0 -60 {lab=#net1}
N -90 40 -90 60 {lab=A1}
N -90 120 -90 140 {lab=0}
N -90 -120 -90 -100 {lab=0}
N -90 -40 -90 -20 {lab=A0}
N -110 -20 -90 -20 {lab=A0}
N -110 40 -90 40 {lab=A1}
C {gnd.sym} 0 100 0 0 {name=l1 lab=0}
C {capa.sym} 90 90 0 0 {name=CL3
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 90 140 0 0 {name=l2 lab=0}
C {capa.sym} 150 90 0 0 {name=CL2
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 150 140 0 0 {name=l3 lab=0}
C {capa.sym} 210 90 0 0 {name=CL1
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 210 140 0 0 {name=l4 lab=0}
C {capa.sym} 270 90 0 0 {name=CL0
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 270 140 0 0 {name=l5 lab=0}
C {vsource.sym} 0 -110 2 0 {name=VDD value=1.2 savecurrent=false}
C {gnd.sym} 0 -160 2 0 {name=l6 lab=0}
C {vsource.sym} -90 90 0 1 {name=VA1 value="PULSE(0 1.2 20n 100p 100p 20n 40n)" savecurrent=false}
C {gnd.sym} -90 140 0 0 {name=l7 lab=0}
C {vsource.sym} -90 -70 2 0 {name=VA0 value="PULSE(0 1.2 10n 100p 100p 10n 20n)" savecurrent=false}
C {gnd.sym} -90 -120 2 0 {name=l8 lab=0}
C {code_shown.sym} 330 -140 0 0 {name=MODELS only_toplevel=false value=".lib cornerMOSlv.lib mos_tt
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice"}
C {code_shown.sym} 330 -70 0 0 {name=NGSPICE only_toplevel=false value=".control
  tran 10p 50n
  write tb_dec2to4.raw

  * Multi-trace offset plots for clean verification
  plot v(A0) v(A1)+1.5 title 'Decoder Inputs (A0, A1)' xlabel 'Time (s)' ylabel 'Voltage (V)'
  plot v(Y0) v(Y1)+1.5 v(Y2)+3.0 v(Y3)+4.5 title 'Decoded Outputs (Y0..Y3)' xlabel 'Time (s)' ylabel 'Voltage (V)'
.endc"
}
C {lab_wire.sym} -110 -20 0 0 {name=p1 sig_type=std_logic lab=A0}
C {lab_wire.sym} -110 40 0 0 {name=p2 sig_type=std_logic lab=A1}
C {lab_wire.sym} 290 -20 0 1 {name=p3 sig_type=std_logic lab=Y0}
C {lab_wire.sym} 230 0 0 1 {name=p4 sig_type=std_logic lab=Y1}
C {lab_wire.sym} 170 20 0 1 {name=p5 sig_type=std_logic lab=Y2}
C {lab_wire.sym} 110 40 0 1 {name=p6 sig_type=std_logic lab=Y3}
C {dec2to4.sym} 0 -150 0 0 {name=x1}
C {title.sym} -30 240 0 0 {name=l9 author="Rafi Ananta Alden"}
