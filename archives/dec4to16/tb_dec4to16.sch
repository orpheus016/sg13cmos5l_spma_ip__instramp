v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -390 -160 -370 -160 {lab=VA0}
N -390 -140 -370 -140 {lab=VA1}
N -390 -120 -370 -120 {lab=VA2}
N -390 -100 -370 -100 {lab=VA3}
N -640 -190 -640 -170 {lab=VA0}
N -640 -110 -640 -90 {lab=0}
N -640 -50 -640 -30 {lab=VA1}
N -640 30 -640 50 {lab=0}
N -640 90 -640 110 {lab=VA2}
N -640 170 -640 190 {lab=0}
N -640 240 -640 260 {lab=VA3}
N -640 320 -640 340 {lab=0}
N -230 -160 690 -160 {lab=VY0}
N -230 -140 630 -140 {lab=VY1}
N -230 -120 570 -120 {lab=VY2}
N -230 -100 510 -100 {lab=VY3}
N -230 -80 450 -80 {lab=VY4}
N -230 -60 390 -60 {lab=VY5}
N -230 -40 330 -40 {lab=VY6}
N -230 -20 270 -20 {lab=VY7}
N -230 0 210 0 {lab=VY8}
N -230 20 150 20 {lab=VY9}
N -230 40 90 40 {lab=VY10}
N -230 60 30 60 {lab=VY11}
N -230 80 -30 80 {lab=VY12}
N -230 100 -90 100 {lab=VY13}
N -230 120 -150 120 {lab=VY14}
N -230 140 -210 140 {lab=VY15}
N -210 140 -210 160 {lab=VY15}
N -150 120 -150 160 {lab=VY14}
N -90 100 -90 160 {lab=VY13}
N -30 80 -30 160 {lab=VY12}
N 30 60 30 160 {lab=VY11}
N 90 40 90 160 {lab=VY10}
N 150 20 150 160 {lab=VY9}
N 210 0 210 160 {lab=VY8}
N 270 -20 270 160 {lab=VY7}
N 330 -40 330 160 {lab=VY6}
N 390 -60 390 160 {lab=VY5}
N 450 -80 450 160 {lab=VY4}
N 510 -100 510 160 {lab=VY3}
N 570 -120 570 160 {lab=VY2}
N 630 -140 630 160 {lab=VY1}
N 690 -160 690 160 {lab=VY0}
N -300 -220 -300 -200 {lab=#net1}
N -300 -300 -300 -280 {lab=0}
N -300 170 -300 190 {lab=0}
N -210 220 -210 240 {lab=0}
N -150 220 -150 240 {lab=0}
N -90 220 -90 240 {lab=0}
N -30 220 -30 240 {lab=0}
N 30 220 30 240 {lab=0}
N 90 220 90 240 {lab=0}
N 150 220 150 240 {lab=0}
N 210 220 210 240 {lab=0}
N 270 220 270 240 {lab=0}
N 330 220 330 240 {lab=0}
N 390 220 390 240 {lab=0}
N 450 220 450 240 {lab=0}
N 510 220 510 240 {lab=0}
N 570 220 570 240 {lab=0}
N 630 220 630 240 {lab=0}
N 690 220 690 240 {lab=0}
C {dec4to16.sym} -10 10 0 0 {name=x1}
C {lab_wire.sym} -390 -160 0 0 {name=p1 sig_type=std_logic lab=VA0}
C {lab_wire.sym} -390 -140 0 0 {name=p2 sig_type=std_logic lab=VA1}
C {lab_wire.sym} -390 -120 0 0 {name=p3 sig_type=std_logic lab=VA2}
C {lab_wire.sym} -390 -100 0 0 {name=p4 sig_type=std_logic lab=VA3}
C {vsource.sym} -640 -140 0 0 {name=V1 value="PULSE(0 1.2 10n 100p 100p 10n 20n)" savecurrent=false}
C {lab_wire.sym} -640 -190 0 1 {name=p5 sig_type=std_logic lab=VA0}
C {gnd.sym} -640 -90 0 0 {name=l1 lab=0}
C {vsource.sym} -640 0 0 0 {name=V2 value="PULSE(0 1.2 20n 100p 100p 20n 40n)" savecurrent=false}
C {lab_wire.sym} -640 -50 0 1 {name=p6 sig_type=std_logic lab=VA1}
C {gnd.sym} -640 50 0 0 {name=l2 lab=0}
C {vsource.sym} -640 140 0 0 {name=V3 value="PULSE(0 1.2 40n 100p 100p 40n 80n)" savecurrent=false}
C {lab_wire.sym} -640 90 0 1 {name=p7 sig_type=std_logic lab=VA2}
C {gnd.sym} -640 190 0 0 {name=l3 lab=0}
C {vsource.sym} -640 290 0 0 {name=V4 value="PULSE(0 1.2 80n 100p 100p 80n 160n)" savecurrent=false}
C {lab_wire.sym} -640 240 0 1 {name=p8 sig_type=std_logic lab=VA3}
C {gnd.sym} -640 340 0 0 {name=l4 lab=0}
C {gnd.sym} -300 190 0 0 {name=l5 lab=0}
C {vsource.sym} -300 -250 2 0 {name=VDD value=1.2 savecurrent=false}
C {gnd.sym} -300 -300 2 0 {name=l6 lab=0}
C {capa.sym} -210 190 0 0 {name=C15
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -210 240 0 0 {name=l8 lab=0}
C {lab_wire.sym} -210 140 0 1 {name=p9 sig_type=std_logic lab=VY15}
C {capa.sym} -150 190 0 0 {name=C14
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -150 240 0 0 {name=l9 lab=0}
C {capa.sym} -90 190 0 0 {name=C13
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -90 240 0 0 {name=CL1 lab=0}
C {capa.sym} -30 190 0 0 {name=C12
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -30 240 0 0 {name=CL3 lab=0}
C {capa.sym} 30 190 0 0 {name=C11
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 30 240 0 0 {name=CL2 lab=0}
C {capa.sym} 90 190 0 0 {name=C10
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 90 240 0 0 {name=CL4 lab=0}
C {capa.sym} 150 190 0 0 {name=C9
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 150 240 0 0 {name=CL5 lab=0}
C {capa.sym} 210 190 0 0 {name=C8
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 210 240 0 0 {name=CL6 lab=0}
C {capa.sym} 270 190 0 0 {name=C7
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 270 240 0 0 {name=CL16 lab=0}
C {gnd.sym} 330 240 0 0 {name=CL18 lab=0}
C {gnd.sym} 390 240 0 0 {name=CL20 lab=0}
C {gnd.sym} 450 240 0 0 {name=CL22 lab=0}
C {gnd.sym} 510 240 0 0 {name=CL24 lab=0}
C {gnd.sym} 570 240 0 0 {name=CL26 lab=0}
C {gnd.sym} 630 240 0 0 {name=CL28 lab=0}
C {capa.sym} 690 190 0 0 {name=C0
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 690 240 0 0 {name=CL30 lab=0}
C {capa.sym} 630 190 0 0 {name=C1
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {capa.sym} 570 190 0 0 {name=C2
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {capa.sym} 510 190 0 0 {name=C3
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {capa.sym} 450 190 0 0 {name=C4
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {capa.sym} 390 190 0 0 {name=C5
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {capa.sym} 330 190 0 0 {name=C6
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} -150 120 0 1 {name=p10 sig_type=std_logic lab=VY14}
C {lab_wire.sym} -90 100 0 1 {name=p11 sig_type=std_logic lab=VY13}
C {lab_wire.sym} -30 80 0 1 {name=p12 sig_type=std_logic lab=VY12}
C {lab_wire.sym} 30 60 0 1 {name=p13 sig_type=std_logic lab=VY11}
C {lab_wire.sym} 90 40 0 1 {name=p14 sig_type=std_logic lab=VY10}
C {lab_wire.sym} 150 20 0 1 {name=p15 sig_type=std_logic lab=VY9}
C {lab_wire.sym} 210 0 0 1 {name=p16 sig_type=std_logic lab=VY8}
C {lab_wire.sym} 270 -20 0 1 {name=p17 sig_type=std_logic lab=VY7}
C {lab_wire.sym} 330 -40 0 1 {name=p18 sig_type=std_logic lab=VY6}
C {lab_wire.sym} 390 -60 0 1 {name=p19 sig_type=std_logic lab=VY5}
C {lab_wire.sym} 450 -80 0 1 {name=p20 sig_type=std_logic lab=VY4}
C {lab_wire.sym} 510 -100 0 1 {name=p21 sig_type=std_logic lab=VY3}
C {lab_wire.sym} 570 -120 0 1 {name=p22 sig_type=std_logic lab=VY2}
C {lab_wire.sym} 630 -140 0 1 {name=p23 sig_type=std_logic lab=VY1}
C {lab_wire.sym} 690 -160 0 1 {name=p24 sig_type=std_logic lab=VY0}
C {code_shown.sym} 800 -200 0 0 {name=MODELS only_toplevel=false value=".lib cornerMOSlv.lib mos_tt
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice"}
C {code_shown.sym} 800 -130 0 0 {name=NGSPICE only_toplevel=false value=".control
  tran 100p 160n
  write tb_dec4to16.raw

  * ==========================================
  * AUTOMATED TRUTH TABLE VOLTAGE MEASUREMENTS
  * (Each state is sampled at its mid-window)
  * ==========================================
  meas tran v_y0_0000  find v(VY0)  at=5n
  meas tran v_y1_0001  find v(VY1)  at=15n
  meas tran v_y2_0010  find v(VY2)  at=25n
  meas tran v_y3_0011  find v(VY3)  at=35n
  meas tran v_y4_0100  find v(VY4)  at=45n
  meas tran v_y5_0101  find v(VY5)  at=55n
  meas tran v_y6_0110  find v(VY6)  at=65n
  meas tran v_y7_0111  find v(VY7)  at=75n
  meas tran v_y8_1000  find v(VY8)  at=85n
  meas tran v_y9_1001  find v(VY9)  at=95n
  meas tran v_y10_1010 find v(VY10) at=105n
  meas tran v_y11_1011 find v(VY11) at=115n
  meas tran v_y12_1100 find v(VY12) at=125n
  meas tran v_y13_1101 find v(VY13) at=135n
  meas tran v_y14_1110 find v(VY14) at=145n
  meas tran v_y15_1111 find v(VY15) at=155n

  * ==========================================
  * MULTI-TRACE OFFSET PLOTS
  * ==========================================
  * 1. 4-bit Binary Input Code (A0..A3)
  plot v(VA0) v(VA1)+1.5 v(VA2)+3.0 v(VA3)+4.5 title 'Decoder Inputs (A0, A1, A2, A3)' xlabel 'Time (s)' ylabel 'Voltage (V)'

  * 2. Lower 8 Decoded Channels (Y0..Y7)
  plot v(VY0) v(VY1)+1.5 v(VY2)+3.0 v(VY3)+4.5 v(VY4)+6.0 v(VY5)+7.5 v(VY6)+9.0 v(VY7)+10.5 title 'Decoded Outputs (Y0..Y7)' xlabel 'Time (s)' ylabel 'Voltage (V)'

  * 3. Upper 8 Decoded Channels (Y8..Y15)
  plot v(VY8) v(VY9)+1.5 v(VY10)+3.0 v(VY11)+4.5 v(VY12)+6.0 v(VY13)+7.5 v(VY14)+9.0 v(VY15)+10.5 title 'Decoded Outputs (Y8..Y15)' xlabel 'Time (s)' ylabel 'Voltage (V)'
.endc
"
}
C {title.sym} -490 430 0 0 {name=l7 author="Rafi Ananta Alden"}
